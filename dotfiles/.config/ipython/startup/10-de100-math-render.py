"""Auto-render IPython.display.Math/Latex as an actual image in Molten.

Molten (this Neovim setup's Jupyter runner) only shows real image mimetypes
(image/png, image/svg+xml) via image.nvim; Math()/Latex() only provide
text/latex plus a plain repr, so without this a cell showing
`display(Math("..."))` prints "<IPython.core.display.Math object>" instead
of rendered math. This registers a formatter for both classes using
matplotlib's mathtext (no system LaTeX/dvipng required), so any
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
displayed) as it happens, and combined into a single vertically-stacked
image shown once the cell finishes running (via IPython's post_run_cell
event) — trading exact inline interleaving with other output for a
guaranteed non-overlapping result while staying fully inline (no floating
window).
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


# A thin border around the combined image, colored to match the rendered
# text (not the theme's own border/accent color) so it reads as "this output
# belongs together" without introducing a second color to track/desync from
# the active colorscheme.
_BORDER_WIDTH = 2
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
# is safe for the normal sequential-execution case. _pending_math_ids
# dedupes: text/plain, text/latex, and image/png formatters all fire for
# the *same* display() call, so without this each object would be
# buffered — and rendered into the combined image — once per mimetype.
_pending_math = []
_pending_math_ids = set()


def _buffer_math(obj, *_args, **_kwargs):
    # *_args/**_kwargs: text/plain's formatter uses IPython's pretty-print
    # protocol (printer(obj, pretty_printer, cycle)), not the single-arg
    # convention image/png and text/latex formatters use — accept either.
    if id(obj) not in _pending_math_ids:
        _pending_math_ids.add(id(obj))
        _pending_math.append(obj)
    return None  # suppress this mimetype's own immediate representation


def _clear_pending(_event=None):
    _pending_math.clear()
    _pending_math_ids.clear()


def _combine_pending(_event=None):
    if not _pending_math:
        return
    objs = list(_pending_math)
    _pending_math.clear()
    _pending_math_ids.clear()

    import io

    from PIL import Image

    bg, fg, _cell_height = _render_context()

    rendered = []
    for obj in objs:
        png_bytes = _math_to_png(obj)
        if png_bytes:
            rendered.append(Image.open(io.BytesIO(png_bytes)))

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

    display(IPyImage(data=out.getvalue(), format="png"))


_ip = get_ipython()
if _ip is not None:
    for _mimetype in ("text/plain", "text/latex", "image/png"):
        _formatter = _ip.display_formatter.formatters[_mimetype]
        _formatter.for_type(Math, _buffer_math)
        _formatter.for_type(Latex, _buffer_math)
    _ip.events.register("pre_run_cell", _clear_pending)
    _ip.events.register("post_run_cell", _combine_pending)
