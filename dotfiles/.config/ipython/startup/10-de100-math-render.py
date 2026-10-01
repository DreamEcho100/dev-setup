"""Auto-render IPython.display.Math/Latex as an actual image in Molten.

Molten (this Neovim setup's Jupyter runner) only shows real image mimetypes
(image/png, image/svg+xml) via image.nvim; Math()/Latex() only provide
text/latex plus a plain repr, so without this a cell showing
`display(Math("..."))` prints "<IPython.core.display.Math object>" instead
of rendered math. This registers a formatter for both classes that renders
them with real LaTeX (pdflatex + pdftocairo, so amsmath matrices,
\\operatorname, aligned, ... all work),
falling back to matplotlib's mathtext if LaTeX is unavailable or an item
fails to compile, and finally to the plain text form. Any
Math(...)/Latex(...) — via display() or as a cell's last expression —
renders as an image automatically, with no change needed to the calling
code. The rendered colors and size track the active Neovim colorscheme and
the terminal's real font size (see _render_context()) rather than being
hardcoded, falling back to a fixed DPI/transparent-black when no render
context has been exported yet. Deployed via neovim.yml / dev-env/runs/neovim
into ~/.ipython/profile_default/startup/, which IPython auto-runs at kernel
startup for every profile.

Molten renders every image chunk within one cell's output at the same
screen position (a molten-nvim bug, not fixable from here), so more than
one Math()/Latex() call in a single cell would overlap if each produced its
own separate image immediately. Instead: each call is buffered (not
displayed) as it happens — via the _ipython_display_ formatter protocol,
which fully bypasses IPython's normal per-mimetype publishing so nothing is
shown for it at all — and combined into a single vertically-stacked,
bordered image shown once the cell finishes running (via IPython's
post_run_cell event) — trading exact inline interleaving with other output
for a guaranteed non-overlapping result while staying fully inline (no
floating window).
"""
from IPython import get_ipython
from IPython.display import Math, Latex

# Rendering *natively* at a tiny DPI to hit a ~1-row pixel target looks
# blurry/small next to the terminal's own hinted font rendering — a raster
# renderer with no font hinting has too few pixels to work with at that
# size. So instead: always rasterize at a fixed, good-quality DPI, then
# downscale to the real target size with a proper resampling filter
# (Lanczos, via Pillow — already installed as a matplotlib dependency).
# This is the supersampling image.nvim/Kitty's protocol won't do for us,
# since Molten never gives image.nvim an explicit size hint to work from.
_SUPERSAMPLE_DPI = 300

# Session-lifetime cache (this module reloads per kernel, so "session" here
# is "this kernel process"), expiring after _CONTEXT_TTL_SECONDS so a theme
# switch or terminal resize is still picked up within a few renders rather
# than requiring a kernel restart.
_CONTEXT_TTL_SECONDS = 5.0
_context_cache = {"data": (None, None, None), "checked_at": 0.0}


def _render_context():
    """Reads {bg, fg, cell_width, cell_height} written by
    dotfiles/.config/nvim/lua/de100/utils/render-context.lua on every
    ColorScheme/VimResized autocmd. Note the extra "nvim" segment:
    Neovim's own stdpath("state") is $XDG_STATE_HOME/nvim, not
    $XDG_STATE_HOME itself. Cached for _CONTEXT_TTL_SECONDS since this can
    run once per Math()/Latex() display in a cell.
    """
    import time

    now = time.monotonic()
    if now - _context_cache["checked_at"] < _CONTEXT_TTL_SECONDS:
        return _context_cache["data"]

    import json
    import os

    state_home = os.environ.get(
        "XDG_STATE_HOME", os.path.expanduser("~/.local/state")
    )
    path = os.path.join(
        state_home, "nvim", "de100", "theme", "render-context.json"
    )
    try:
        with open(path) as f:
            data = json.load(f)
        result = (data.get("bg"), data.get("fg"), data.get("cell_height"))
    except Exception:
        result = (None, None, None)

    _context_cache["data"] = result
    _context_cache["checked_at"] = now
    return result


def _math_to_png(obj):
    """Renders a single Math/Latex object to PNG bytes, or None on failure
    (e.g. real LaTeX syntax outside mathtext's supported subset).
    """
    import io

    # Build the Figure directly on the Agg canvas, bypassing pyplot/
    # matplotlib.use() entirely — those mutate the kernel's global backend
    # state, which would silently clobber a user's own %matplotlib
    # widget/inline setup for unrelated plots elsewhere in the session.
    from matplotlib.backends.backend_agg import FigureCanvasAgg
    from matplotlib.figure import Figure

    text = obj.data.strip()
    if not (text.startswith("$") and text.endswith("$")):
        text = "$" + text + "$"

    bg, fg, cell_height = _render_context()

    fig = Figure(figsize=(0.01, 0.01))
    FigureCanvasAgg(fig)
    try:
        fig.text(0, 0, text, fontsize=20, color=fg or "black")
        buf = io.BytesIO()
        fig.savefig(
            buf,
            format="png",
            dpi=_SUPERSAMPLE_DPI,
            bbox_inches="tight",
            pad_inches=0.15,
            facecolor=bg or "none",
            transparent=bg is None,
        )
        if not cell_height:
            return buf.getvalue()

        from PIL import Image

        buf.seek(0)
        img = Image.open(buf)
        # 1.1x (barely more than one code line) still looked visibly small
        # and blurry after supersampling — there's a hard floor here: a
        # plain raster image has no font-hinting engine the way a
        # terminal's own text renderer does, so small anti-aliased text
        # reads as "soft" no matter the source quality. More target pixels
        # is the only real lever; 1.8x trades a bit of extra height for
        # meaningfully crisper text.
        target_height = max(1, round(cell_height * 1.8))
        scale = target_height / img.height
        target_width = max(1, round(img.width * scale))
        img = img.resize((target_width, target_height), Image.LANCZOS)
        out = io.BytesIO()
        img.save(out, format="PNG")
        return out.getvalue()
    except Exception:
        return None


# --- Real LaTeX rendering -------------------------------------------------
# One pdflatex run per cell: a `standalone` document with `multi=mathitem`
# makes every item its own tightly-cropped PDF page, and pdftocairo turns
# the pages into transparent PNGs (no dvipng needed). Results are cached on
# disk by content so re-running a cell costs nothing.
_LATEX_TIMEOUT_SECONDS = 15
_LATEX_DPI = 300
# One 12pt em at _LATEX_DPI, in pixels; used to scale every item by the same
# factor so a fraction or matrix stays proportionally bigger than a one-line
# formula instead of being squashed to the same height.
_LATEX_EM_PX = 12 * _LATEX_DPI / 72
_LATEX_PREAMBLE = (
    "\\documentclass[multi=mathitem,border=2pt,12pt]{standalone}\n"
    "\\usepackage{amsmath,amssymb,amsfonts,xcolor}\n"
)


def _latex_available():
    import shutil

    return bool(shutil.which("pdflatex") and shutil.which("pdftocairo"))


def _latex_body(obj):
    text = obj.data.strip()
    if isinstance(obj, Latex):
        return text  # may mix prose and $...$, so leave it in text mode
    if text.startswith("$$") and text.endswith("$$") and len(text) > 4:
        text = text[2:-2]
    elif text.startswith("$") and text.endswith("$") and len(text) > 2:
        text = text[1:-1]
    return "$\\displaystyle " + text + "$"


def _latex_cache_dir():
    import os

    base = os.environ.get("XDG_CACHE_HOME") or os.path.expanduser("~/.cache")
    path = os.path.join(base, "de100", "math")
    os.makedirs(path, exist_ok=True)
    return path


def _latex_first_error(log_text):
    lines = log_text.splitlines()
    for i, line in enumerate(lines):
        if line.startswith("!"):
            detail = next((l for l in lines[i + 1:i + 6] if l.startswith("l.")), "")
            return (line + " " + detail).strip()
    return "LaTeX failed (see the .log)"


def _latex_compile(bodies, color):
    """Compiles the bodies into one document. Returns (list of PNG paths, None)
    or (None, first LaTeX error message)."""
    import glob
    import os
    import re
    import subprocess
    import tempfile

    doc = (
        _LATEX_PREAMBLE + "\\color[HTML]{" + color + "}\n\\begin{document}\n" +
        "\n".join("\\begin{mathitem}" + b + "\\end{mathitem}" for b in bodies) +
        "\n\\end{document}\n")
    with tempfile.TemporaryDirectory(prefix="de100-math-") as tmp:
        with open(os.path.join(tmp, "d.tex"), "w") as f:
            f.write(doc)
        try:
            subprocess.run(
                ["pdflatex", "-no-shell-escape", "-interaction=nonstopmode",
                 "-halt-on-error", "d.tex"],
                cwd=tmp, capture_output=True, timeout=_LATEX_TIMEOUT_SECONDS,
                stdin=subprocess.DEVNULL)
        except subprocess.TimeoutExpired:
            return None, "LaTeX timed out"
        if not os.path.exists(os.path.join(tmp, "d.pdf")):
            try:
                with open(os.path.join(tmp, "d.log"), errors="replace") as f:
                    return None, _latex_first_error(f.read())
            except OSError:
                return None, "pdflatex failed"
        subprocess.run(
            ["pdftocairo", "-png", "-transp", "-r", str(_LATEX_DPI), "d.pdf", "p"],
            cwd=tmp, capture_output=True, timeout=_LATEX_TIMEOUT_SECONDS,
            stdin=subprocess.DEVNULL)
        pages = sorted(
            glob.glob(os.path.join(tmp, "p-*.png")),
            key=lambda path: int(re.search(r"p-(\d+)\.png$", path).group(1)))
        if len(pages) != len(bodies):
            return None, "LaTeX produced %d pages for %d items" % (len(pages), len(bodies))
        return [open(path, "rb").read() for path in pages], None


def _latex_images(objs, fg):
    """Renders each object with real LaTeX. Returns (images, errors): parallel
    lists, image None (and an error message) for items that couldn't be
    rendered. A bad item never takes the others down with it."""
    import hashlib
    import io
    import os

    from PIL import Image

    count = len(objs)
    images = [None] * count
    errors = [None] * count
    if not _latex_available():
        return images, ["LaTeX (pdflatex/pdftocairo) not installed"] * count

    color = (fg or "#000000").lstrip("#").upper()
    cache_dir = _latex_cache_dir()
    todo = []
    for i, obj in enumerate(objs):
        body = _latex_body(obj)
        key = hashlib.sha1(
            (_LATEX_PREAMBLE + color + str(_LATEX_DPI) + body).encode()).hexdigest()
        path = os.path.join(cache_dir, key + ".png")
        if os.path.exists(path):
            images[i] = Image.open(path)
            images[i].load()
        else:
            todo.append((i, body, path))

    def store(i, path, data):
        with open(path, "wb") as f:
            f.write(data)
        images[i] = Image.open(io.BytesIO(data))
        images[i].load()

    if todo:
        pngs, error = _latex_compile([b for _, b, _ in todo], color)
        if pngs is not None:
            for (i, _, path), data in zip(todo, pngs):
                store(i, path, data)
        elif len(todo) == 1:
            errors[todo[0][0]] = error
        else:
            for i, body, path in todo:
                pngs, error = _latex_compile([body], color)
                if pngs is not None:
                    store(i, path, pngs[0])
                else:
                    errors[i] = error
    return images, errors


# How much heavier to make the glyphs: 0 = LaTeX's own weight, 1 = a full
# 1px (at _LATEX_DPI) dilation of every stroke. Real LaTeX at this size looks
# thin next to the terminal font after downscaling, so a half step reads as
# "a little bolder" without blobbing small details (0.35 adds roughly a third
# more ink; raise toward 1 for bolder, set 0 to turn it off).
_WEIGHT_BOOST = 0.35


def _embolden(img, fg):
    """Thicken strokes slightly by growing the alpha channel, keeping the
    colour solid (transparent pixels carry no usable colour of their own)."""
    from PIL import Image, ImageChops, ImageFilter

    rgba = img.convert("RGBA")
    alpha = rgba.getchannel("A")
    grown = alpha.filter(ImageFilter.MaxFilter(3))
    alpha = ImageChops.blend(alpha, grown, _WEIGHT_BOOST)
    hex_color = (fg or "#000000").lstrip("#")
    rgb = tuple(int(hex_color[i:i + 2], 16) for i in (0, 2, 4))
    solid = Image.new("RGBA", rgba.size, rgb + (255,))
    solid.putalpha(alpha)
    return solid


# Size of a 12pt em as a fraction of the terminal row height (1.1 read slightly large).
_LATEX_SIZE_RATIO = 1.05


def _latex_scaled(img, cell_height, fg=None):
    """Scale a 300dpi LaTeX page so a 12pt em is about one terminal row."""
    scale = (cell_height * _LATEX_SIZE_RATIO if cell_height else _LATEX_EM_PX / 2) / _LATEX_EM_PX
    from PIL import Image

    if _WEIGHT_BOOST:
        img = _embolden(img, fg)
    size = (max(1, round(img.width * scale)), max(1, round(img.height * scale)))
    return img.convert("RGBA").resize(size, Image.LANCZOS)


# --- Snapping small images to the terminal's row grid ----------------------
# Molten can only reserve whole terminal rows for an image, so a 21px image
# in 20px rows takes two rows while a 15px one takes one with a different
# leftover gap, which looks uneven. Small images (formulas, sympy output,
# floats after sympy.init_printing()) are rescaled toward the terminal's text
# size and centred in a whole number of rows, whichever library made them.
# Large images (plots, photos) are left alone.
_SNAP_MAX_ROWS = 6          # images taller than this many rows are not touched
_SNAP_SHAVE = 0.2           # allowed shrink (fraction of a row) to avoid an extra row
# sympy's PNG text is about 15% larger than a terminal row of text at the
# same cell height (measured: sympy's "x" is 11px, ours 9.5px at 20px rows).
_SNAP_TEXT_SCALE = 0.98
# A little more stroke weight for those images, which look thin next to the
# terminal font (0 = as drawn, 1 = about a pixel heavier at 1x).
_SNAP_WEIGHT_BOOST = 0.5
_SNAP_SUPERSAMPLE = 4
_snapping = {"skip": False}


def _snap_embolden(img):
    """Thicken strokes slightly, keeping the image's own colours: work at
    _SNAP_SUPERSAMPLE x, grow the alpha and spread the colour into the new
    pixels (taken from opaque pixels only, so a white or black transparent
    background can't tint the edges). The caller downsamples afterwards."""
    from PIL import Image, ImageChops, ImageFilter

    big = img.resize((img.width * _SNAP_SUPERSAMPLE, img.height * _SNAP_SUPERSAMPLE), Image.LANCZOS)
    alpha = big.getchannel("A")
    grown = alpha.filter(ImageFilter.MaxFilter(2 * _SNAP_SUPERSAMPLE // 2 + 1))
    alpha = ImageChops.blend(alpha, grown, _SNAP_WEIGHT_BOOST)
    on_black = Image.composite(big.convert("RGB"), Image.new("RGB", big.size, (0, 0, 0)), alpha.point(lambda v: 255 if v > 0 else 0))
    rgb = on_black.filter(ImageFilter.MaxFilter(2 * _SNAP_SUPERSAMPLE // 2 + 1))
    out = rgb.convert("RGBA")
    out.putalpha(alpha)
    return out


def _snap_png(data):
    """Returns the PNG (bytes or base64 str, as given) snapped to whole rows, or
    the input unchanged if it is large, unreadable, or there is no cell size."""
    import base64
    import io

    _bg, _fg, cell_height = _render_context()
    if not cell_height:
        return data
    try:
        from PIL import Image

        was_text = isinstance(data, str)
        raw = base64.b64decode(data) if was_text else data
        img = Image.open(io.BytesIO(raw)).convert("RGBA")
        if img.height > _SNAP_MAX_ROWS * cell_height:
            return data

        scale = _SNAP_TEXT_SCALE
        rows = max(1, int(img.height * scale / cell_height + _SNAP_SHAVE))
        target = rows * cell_height
        if img.height * scale > target:
            scale = target / img.height
        size = (max(1, round(img.width * scale)), max(1, round(img.height * scale)))
        if _SNAP_WEIGHT_BOOST:
            img = _snap_embolden(img)
        img = img.resize(size, Image.LANCZOS)

        canvas = Image.new("RGBA", (size[0], round(target)), (0, 0, 0, 0))
        canvas.paste(img, (0, (canvas.height - size[1]) // 2), img)
        out = io.BytesIO()
        canvas.save(out, format="PNG")
        png = out.getvalue()
        return base64.b64encode(png).decode("ascii") if was_text else png
    except Exception:
        return data


def _snap_bundle(bundle):
    if isinstance(bundle, dict) and "image/png" in bundle and not _snapping["skip"]:
        bundle = dict(bundle)
        bundle["image/png"] = _snap_png(bundle["image/png"])
    return bundle


def _install_snapping(ip):
    pub = ip.display_pub
    original_publish = pub.publish

    def publish(data, *args, **kwargs):
        return original_publish(_snap_bundle(data), *args, **kwargs)

    pub.publish = publish

    hook = ip.displayhook
    original_write = hook.write_format_data

    def write_format_data(format_dict, *args, **kwargs):
        return original_write(_snap_bundle(format_dict), *args, **kwargs)

    hook.write_format_data = write_format_data


# A thin border around the combined image, colored to match the rendered
# text (not the theme's own border/accent color) so it reads as "this output
# belongs together" without introducing a second color to track/desync from
# the active colorscheme.
_BORDER_WIDTH = 1
_BORDER_PADDING = 8


def _add_border(img, color_hex, fill_rgba):
    """Wraps img in a solid border the same color as the rendered text, with
    a padding gap so the border doesn't crowd the glyphs."""
    from PIL import Image

    rgb = tuple(int(color_hex.lstrip("#")[i:i + 2], 16) for i in (0, 2, 4))
    border_rgba = rgb + (255,)

    w, h = img.size
    inner = Image.new(
        "RGBA",
        (w + 2 * _BORDER_PADDING, h + 2 * _BORDER_PADDING),
        fill_rgba,
    )
    inner.paste(img, (_BORDER_PADDING, _BORDER_PADDING), img)

    bordered = Image.new(
        "RGBA",
        (inner.width + 2 * _BORDER_WIDTH, inner.height + 2 * _BORDER_WIDTH),
        border_rgba,
    )
    bordered.paste(inner, (_BORDER_WIDTH, _BORDER_WIDTH))
    return bordered


# Buffered (Math|Latex) objects for the currently-running cell. Module-level
# because IPython's events/formatters are called on this same shared state
# regardless of which cell is executing; cells run one at a time, so this
# is safe for the normal sequential-execution case. Registered on the
# _ipython_display_ formatter (not the per-mimetype text/plain, text/latex,
# image/png formatters): DisplayFormatter.format() checks this one first and
# short-circuits to an empty format_dict before any per-mimetype formatter
# runs, so nothing is ever published for a buffered call — no dedup needed
# either, since this fires exactly once per object regardless of mimetype.
# (An earlier per-mimetype-formatter version left a stray truthy-empty-string
# text/plain entry behind — PlainTextFormatter never returns None, only the
# empty string when its pretty-printer writes nothing — which was non-None
# and so still got published, showing up in Molten as a spurious
# "No usable MIMEtype" line for every buffered call.)
_pending_math = []


def _buffer_math(obj):
    _pending_math.append(obj)


def _clear_pending(_event=None):
    _pending_math.clear()


def _combine_pending(_event=None):
    if not _pending_math:
        return
    objs = list(_pending_math)
    _pending_math.clear()

    import io

    from PIL import Image

    bg, fg, cell_height = _render_context()

    # Real LaTeX first, then matplotlib mathtext, then plain text, so an item
    # is only ever shown as text when nothing could draw it.
    latex_images, latex_errors = _latex_images(objs, fg)
    rendered = []
    for obj, latex_image, latex_error in zip(objs, latex_images, latex_errors):
        if latex_image is not None:
            rendered.append(_latex_scaled(latex_image, cell_height, fg))
            continue
        png_bytes = _math_to_png(obj)
        if png_bytes:
            rendered.append(Image.open(io.BytesIO(png_bytes)))
        else:
            print(obj.data)
            if latex_error and "not installed" not in latex_error:
                print("  (LaTeX: " + latex_error + ")")

    if not rendered:
        return

    gap = 6
    width = max(im.width for im in rendered)
    height = sum(im.height for im in rendered) + gap * (len(rendered) - 1)
    fill = (0, 0, 0, 0)
    if bg:
        rgb = tuple(int(bg.lstrip("#")[i:i + 2], 16) for i in (0, 2, 4))
        fill = rgb + (255,)
    combined = Image.new("RGBA", (width, height), fill)

    y = 0
    for im in rendered:
        rgba = im.convert("RGBA")
        combined.paste(rgba, (0, y), rgba)
        y += im.height + gap

    combined = _add_border(combined, fg or "#000000", fill)

    out = io.BytesIO()
    combined.save(out, format="PNG")

    from IPython.display import Image as IPyImage
    from IPython.display import display

    # our image is already sized to the terminal; don't snap it again
    _snapping["skip"] = True
    try:
        display(IPyImage(data=out.getvalue(), format="png"))
    finally:
        _snapping["skip"] = False


_ip = get_ipython()
if _ip is not None:
    _ip.display_formatter.ipython_display_formatter.for_type(Math, _buffer_math)
    _ip.display_formatter.ipython_display_formatter.for_type(Latex, _buffer_math)
    _install_snapping(_ip)
    _ip.events.register("pre_run_cell", _clear_pending)
    _ip.events.register("post_run_cell", _combine_pending)
