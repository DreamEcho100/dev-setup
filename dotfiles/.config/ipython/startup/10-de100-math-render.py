"""Auto-render IPython.display.Math/Latex as an actual image in Molten.

Molten (this Neovim setup's Jupyter runner) only shows real image mimetypes
(image/png, image/svg+xml) via image.nvim; Math()/Latex() only provide
text/latex plus a plain repr, so without this a cell showing
`display(Math("..."))` prints "<IPython.core.display.Math object>" instead
of rendered math. This registers an image/png formatter for both classes
using matplotlib's mathtext (no system LaTeX/dvipng required), so any
Math(...)/Latex(...) — via display() or as a cell's last expression —
renders as an image automatically, with no change needed to the calling
code. The rendered colors track the active Neovim colorscheme (see
_theme_colors()) rather than being hardcoded, falling back to
transparent/black when no theme data has been exported yet. Deployed via
neovim.yml / dev-env/runs/neovim into ~/.ipython/profile_default/startup/,
which IPython auto-runs at kernel startup for every profile.
"""
from IPython import get_ipython
from IPython.display import Math, Latex


def _theme_colors():
    """Reads {bg, fg} written by dotfiles/.config/nvim/lua/de100/utils/
    theme-colors.lua on every ColorScheme autocmd. Note the extra "nvim"
    segment: Neovim's own stdpath("state") is $XDG_STATE_HOME/nvim, not
    $XDG_STATE_HOME itself.
    """
    import json
    import os

    state_home = os.environ.get(
        "XDG_STATE_HOME", os.path.expanduser("~/.local/state")
    )
    path = os.path.join(state_home, "nvim", "de100", "theme", "colors.json")
    try:
        with open(path) as f:
            data = json.load(f)
        return data.get("bg"), data.get("fg")
    except Exception:
        return None, None


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

    bg, fg = _theme_colors()

    fig = Figure(figsize=(0.01, 0.01))
    FigureCanvasAgg(fig)
    try:
        fig.text(0, 0, text, fontsize=20, color=fg or "black")
        buf = io.BytesIO()
        fig.savefig(
            buf,
            format="png",
            dpi=150,
            bbox_inches="tight",
            pad_inches=0.15,
            facecolor=bg or "none",
            transparent=bg is None,
        )
        return buf.getvalue()
    except Exception:
        # Fall back to the plain-text repr (e.g. real LaTeX syntax outside
        # mathtext's supported subset) rather than breaking the display.
        return None


_ip = get_ipython()
if _ip is not None:
    _png_formatter = _ip.display_formatter.formatters["image/png"]
    _png_formatter.for_type(Math, _math_to_png)
    _png_formatter.for_type(Latex, _math_to_png)
