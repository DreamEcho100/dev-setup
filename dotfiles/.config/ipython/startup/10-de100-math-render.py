"""Auto-render IPython.display.Math/Latex as an actual image in Molten.

Molten (this Neovim setup's Jupyter runner) only shows real image mimetypes
(image/png, image/svg+xml) via image.nvim; Math()/Latex() only provide
text/latex plus a plain repr, so without this a cell showing
`display(Math("..."))` prints "<IPython.core.display.Math object>" instead
of rendered math. This registers an image/png formatter for both classes
using matplotlib's mathtext (no system LaTeX/dvipng required), so any
Math(...)/Latex(...) — via display() or as a cell's last expression —
renders as an image automatically, with no change needed to the calling
code. The rendered colors and size track the active Neovim colorscheme and
the terminal's real font size (see _render_context()) rather than being
hardcoded, falling back to a fixed DPI/transparent-black when no render
context has been exported yet. Deployed via neovim.yml / dev-env/runs/neovim
into ~/.ipython/profile_default/startup/, which IPython auto-runs at kernel
startup for every profile.
"""
from IPython import get_ipython
from IPython.display import Math, Latex

_FALLBACK_DPI = 150
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
        # Fall back to the plain-text repr (e.g. real LaTeX syntax outside
        # mathtext's supported subset) rather than breaking the display.
        return None


_ip = get_ipython()
if _ip is not None:
    _png_formatter = _ip.display_formatter.formatters["image/png"]
    _png_formatter.for_type(Math, _math_to_png)
    _png_formatter.for_type(Latex, _math_to_png)
