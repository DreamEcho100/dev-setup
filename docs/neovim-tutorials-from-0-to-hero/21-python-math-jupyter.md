# 21 · Python, Math, and Jupyter Notebooks in Neovim

> This chapter is for anyone doing Python-based math/data work — numpy, pandas,
> matplotlib, sympy, and Jupyter notebooks — and wants to do it from inside
> Neovim instead of a browser tab. It was written alongside setting up this
> config to follow along with an external Jupyter-based math/Python course, but
> everything here applies to any notebook-driven Python work.

---

## 1. Why Notebooks in Neovim

VS Code's Jupyter extension gives you: edit a `.ipynb`, run a cell, see the
output (including plots) inline, all in one editor. This chapter wires up the
same experience in Neovim using four small, focused plugins instead of one
monolithic extension:

```text
.ipynb file
    │
    │  jupytext.nvim  (transparent .ipynb <-> text conversion)
    v
percent-format .py / markdown text
    │
    │  molten-nvim  (runs a real Jupyter kernel, evaluates cells)
    v
cell output (text, tables, errors, plots)
    │
    │  image.nvim  (renders images via the Kitty graphics protocol)
    v
inline plot, right in the buffer

quarto-nvim + otter.nvim (optional 5th piece, see §10)
    literate .qmd files: markdown prose + executable code cells,
    with per-cell LSP (completion/diagnostics) via otter
```

Each piece does one job. None of them replace pyright/ruff (still your Python
LSP/linter regardless of file format) or vimtex (still your LaTeX engine for
`.tex` files) — they compose with what this config already has.

## 2. One-Time Setup Verification

If you provisioned this machine with `neovim.yml` / `dev-env/runs/neovim`
after this chapter was added, the dependencies below are already installed.
If you're not sure, verify each:

```sh
python3 -m pip show pynvim jupyter_client ipykernel jupytext pylatexenc matplotlib sympy
dpkg -l | grep libmagickwand-dev   # Debian/Ubuntu
dpkg -l | grep dvipng              # Debian/Ubuntu — only for the optional ;sympymath snippet in §6a
which pdflatex pdftocairo          # real-LaTeX math rendering in §6a (texlive-latex-extra + poppler-utils)
```

Then, inside Neovim, run once (only needed after installing/updating
molten-nvim, since it registers a remote plugin):

```vim
:UpdateRemotePlugins
```

Restart Neovim, then check:

```vim
:checkhealth image
:MoltenInfo
```

`:checkhealth image` should report the `kitty` backend as available if you're
running inside Kitty or Ghostty. If you're inside tmux, also confirm your
`dotfiles/.config/tmux/tmux.conf` has:

```tmux
set -gq allow-passthrough on
set -ga update-environment TERM
```

Without this, tmux swallows the Kitty graphics protocol escape sequences and
plots render as blank space or garbled text instead of an image.

### Per-project environment (venv + kernel) for course work

The packages above are for the editor tooling. The code in a notebook runs in
whatever **kernel** you attach, and a kernel only sees the packages installed
into the Python it was started from. `import sympy` failing with
`ModuleNotFoundError` inside a cell means *that kernel's Python* lacks
`sympy`, regardless of what's installed elsewhere. Check which Python a
kernel uses:

```sh
python3 -m jupyter kernelspec list          # names and folders
cat ~/.local/share/jupyter/kernels/<name>/kernel.json   # "argv[0]" is its Python
```

For a course or project with its own dependencies, give it its own virtual
environment and kernel instead of installing into the system Python (Ubuntu
24.04 blocks that with `externally-managed-environment`, and
`--break-system-packages` risks breaking OS tools). From the project root:

```sh
sudo apt install python3-venv            # once per machine, if `python3 -m venv` complains
python3 -m venv .venv
.venv/bin/pip install -r requirements.txt
.venv/bin/python -m ipykernel install --user --name=my-project --display-name "My Project"
```

Then attach it in Neovim with `:MoltenInit my-project` and restart it with
`:MoltenRestart` after changing packages. Pyright finds the project's `.venv`
automatically (`:LspRestart` if the "import could not be resolved" warnings
stay). Things to know:

- `requirements.txt` is just a list; nothing is installed until you run
  `pip install -r` against it, and the venv has to exist before `source
  .venv/bin/activate` (or `.venv/bin/pip`) can work.
- Add a package by appending its name to `requirements.txt` and re-running
  `.venv/bin/pip install -r requirements.txt`. Avoid `pip freeze >
  requirements.txt`: it overwrites the short list with every package in
  whatever Python is active (and the `>` empties the file even if `pip`
  then fails).
- Re-running `ipykernel install` with an existing `--name` replaces that
  kernel, which is how you point an old kernel at a new venv.
- The `udemy-master-math-by-coding-in-python` course repo follows exactly
  this layout; its README has the course-specific commands.
- To remove a project's setup, unregister the kernel and delete the venv
  (they're separate): `python3 -m jupyter kernelspec remove -f <name>` and
  `rm -rf .venv`. Removing only the venv leaves a kernel that can't start.

## 3. Opening a Notebook

Open any existing `.ipynb` file normally:

```vim
:e notebook.ipynb
```

To create a brand-new, empty notebook, use `:JupytextNew` or `<leader>jn`
instead of just touching a file (a genuinely empty `.ipynb` isn't valid JSON,
so a plain `:e new.ipynb` on a file that doesn't exist yet, or one created
empty by something like oil.nvim, would otherwise be nothing to convert).
You only type a **name** — the directory is inferred from where you are:

| You're in | New notebook goes in |
|---|---|
| oil, cursor on a directory | that directory |
| oil, cursor on a file (or `..`) | the directory oil is listing |
| mini.files / snacks explorer, on a directory | that directory |
| mini.files / snacks explorer, on a file | that file's directory |
| a normal buffer | that buffer's directory (cwd if it has no file) |

```vim
:JupytextNew lesson1            " <dir>/lesson1.ipynb
:JupytextNew week2/lesson1.qmd  " <dir>/week2/lesson1.qmd (Quarto, with front matter)
:JupytextNew ~/notes/scratch    " absolute / ~ paths ignore the inferred dir
```

The format follows the extension: `.qmd` creates a Quarto file, `.ipynb` a
notebook, and anything else (including no extension, or something like
`.py`) gets `.ipynb` appended. Missing directories are created, and an
existing file is never overwritten. `<leader>jn` prompts for just the name
(the prompt shows the inferred directory); completion
(`<C-x><C-u>`) lists the entries relative to that directory; `:JupytextNew`
completes the same way on the command line.

`jupytext.nvim` intercepts the read, converts the notebook to a Markdown
buffer behind the scenes (this config uses jupytext's `"markdown"` style, not
percent-format — see `plugins/jupytext.lua`), and converts it back to valid
`.ipynb` JSON on save. You edit readable text; the file on disk stays a real
notebook any other tool (JupyterLab, VS Code, `nbconvert`) can open.

A code cell is a fenced code block with the language and the cell's id as
attributes:

````markdown
```{python id="9voiYnfRbiZC"}
import numpy as np
import matplotlib.pyplot as plt

x = np.linspace(0, 2 * np.pi, 200)
plt.plot(x, np.sin(x))
```
````

`render-markdown.nvim` restyles that fence line into a compact header in the
buffer (you'll see something like `♦ python id="9voiYnfRbiZC"` instead of the
raw triple-backtick line) — this is just display, the underlying file still
has real markdown fences. Markdown/prose cells are plain markdown text
between code fences, rendered normally (headings, etc.).

`render-markdown.nvim` is off by default (live rendering could get visually
jumbled) — press `<leader>ur` to turn it on for the session when you want
this restyling; without it, you'll see the raw markdown/fence syntax
instead.

## 4. Running Cells

First, attach a kernel to the buffer (once per session):

```vim
:MoltenInit
```

Pick a kernel (usually `python3`) when prompted. Then:

| Key                   | Action                                          |
| --------------------- | ------------------------------------------------ |
| `<leader>jr`          | Create/run the cell under the cursor (works on a cell you've never run before) |
| `<leader>jv` (visual) | Create/run a cell from the selected lines         |
| `]b` / `[b`           | Jump to the next/previous code block, **run or not** |
| `]j` / `[j`           | Jump to the next/previous **already-run** cell/output |

**Important distinction, worth understanding, not just memorizing:** a
"Molten cell" only exists once you've actually evaluated some code —
molten-nvim has no built-in concept of the markdown fenced code blocks
jupytext generates. `<leader>jr` doesn't call Molten's own
`:MoltenReevaluateCell` (that command only *re-runs a cell that already
exists* — it silently does nothing on code you've never evaluated).
Instead, `<leader>jr` calls quarto-nvim's `require("quarto.runner").run_cell()`,
which uses treesitter to find the code block under your cursor, creates a
Molten cell from it, and evaluates it — this is what actually works the
first time. `]j`/`[j` (`:MoltenNext`/`:MoltenPrev`) only navigate between
cells that already exist, so on a fresh notebook they'll have nothing to do
until you've run at least one cell with `<leader>jr`.

For linear "step through the notebook top to bottom" work — the normal way
to follow a course video — use `]b`/`[b` instead: these come from
`nvim-treesitter-textobjects` (`plugins/treesitter-textobjects.lua`) and
jump between *every* fenced code block structurally, regardless of whether
Molten has ever seen it. This is the documented pattern from molten-nvim's
own `docs/Notebook-Setup.md` ("Treesitter Text Objects" section), adapted
for this config's newer main-branch `nvim-treesitter` (the
`nvim-treesitter-textobjects.move` module, not the older
`nvim-treesitter.configs` API that doc's own snippet assumes). Typical flow:
`]b` to the next block, `<leader>jr` to run it, `]b` again, repeat.

That's the entire keymap surface on purpose — everything else below is a rare
enough action that it's invoked directly as an Ex command instead (same
philosophy as the rest of this config; see tutorial 13, section 4.6).

## 5. Viewing Output, Including Plots

Molten opens a virtual-text output area under the cell showing whatever the
kernel returned: printed text, a DataFrame's repr, a traceback, or — for
matplotlib/sympy plots — the actual rendered image, drawn inline via
`image.nvim` and the Kitty graphics protocol.

Clearing output has keymaps (and the commands behind them):

```text
<leader>jc   :MoltenClear     clear the output of the cell under the cursor
<leader>jC   :MoltenClearAll  clear the output of every cell in this file
<leader>jd   :MoltenDelete    Molten's own delete (what :MoltenClear wraps; prefer jc)
<leader>jx   :MoltenInterrupt stop the running cell (like Jupyter's "interrupt kernel")
```

Saving outputs into the file has commands only (no keymaps):

```text
:MoltenSaveOutput     save the output of the cell under the cursor
:MoltenSaveOutputAll  save every cell's output
```

They write into the notebook that belongs to the file, next to it: the `.ipynb`
itself when you are editing one, otherwise `<name>.ipynb` beside a `.qmd`/`.py`
(created if missing; the `jupytext` CLI makes it, and for `.qmd` it needs the
`quarto` binary). The buffer is saved first and the notebook's cells are
refreshed from it with `jupytext --update`, because Molten matches each cell to
the notebook by its code, so unsaved edits would not match. Outputs already in
the notebook stay for cells you did not save. `:MoltenSaveOutputAll` is
Molten's `:MoltenExportOutput!`; `:MoltenSaveOutput` is `:MoltenExportCellOutput!`,
a command added in the molten-nvim fork (identical cells are matched in order,
as in the full export).

`<leader>jx` sends the kernel an interrupt, so an infinite loop or a slow
computation stops with a `KeyboardInterrupt`, and the kernel's variables
survive (unlike `:MoltenRestart`). If several kernels are attached to the
buffer it asks which one. Clearing a cell that is still running isn't allowed
by Molten, so interrupt first, then clear.

Rare/occasional output actions, invoked directly (no keymap):

```vim
:MoltenShowOutput
:MoltenHideOutput
:MoltenExportOutput
:MoltenImportOutput
:MoltenOpenInBrowser
```

**Inside tmux:** if a plot renders as blank space or a broken image icon
instead of the actual chart, re-check the `allow-passthrough` tmux setting
from §2 first — this is the single most common cause.

## 6. Writing Math Notes in Markdown

`render-markdown.nvim` converts inline LaTeX math (`$...$` or `$$...$$`) to
readable unicode directly in the buffer, using the `latex2text` converter from
the `pylatexenc` Python package. This is configured in
`plugins/render-markdown.lua`'s `opts.latex` block. Remember it's off by
default (`<leader>ur` to enable, see §3) — nothing renders until you toggle
it on. If math still isn't rendering with it enabled, confirm `pylatexenc`
is installed (`python3 -m pip show pylatexenc`) and that the buffer has the
`latex` treesitter parser (`:TSInstall latex` if missing — though it should
already be in this config's `ensure_installed` list).

For anything beyond simple inline notation — derivations, multi-line proofs,
numbered equations — write a `.tex` file instead and lean on the existing
vimtex setup (see §11).

## 6a. Rendering Math *Output* (Code Cells, Not Markdown)

§6 is for prose — text you write in a Markdown cell. This section is
different: it's for math that comes back as **code-cell output**, e.g.
`display(Math("..."))` or a bare `sympy` expression left as a cell's last
line. That output only carries a `text/latex` mimetype (plus a plain-text
repr) by default — Molten only rasterizes real image mimetypes (`image/png`,
`image/svg+xml`) through image.nvim, so it can't turn `text/latex` into a
picture on its own. Without help, that would just show:

```text
Out[7]: <IPython.core.display.Math object>
```

**`Math(...)`/`Latex(...)` already auto-render — no extra code needed.**
`dotfiles/.config/ipython/startup/10-de100-math-render.py` (deployed by
`neovim.yml`/`dev-env/runs/neovim` into
`~/.ipython/profile_default/startup/`, which every IPython/Jupyter kernel
runs at startup) takes over both classes and renders them with **real
LaTeX**: one `pdflatex` run per cell (a `standalone` document, one cropped
page per item, with `amsmath`/`amssymb`/`xcolor` loaded), then `pdftocairo`
turns the pages into transparent PNGs. So `display(Math("x^2 + y^2 = z^2"))`
just works, exactly as called, and so does anything LaTeX can typeset:
matrices (`pmatrix`), `aligned` blocks, `\operatorname`, `\text{...}`, and so
on — there is no "supported subset". `Latex(...)` may mix prose and `$...$`.
The glyph weight is nudged up (about half as much again in ink, `_WEIGHT_BOOST`) and the text is a little larger than one terminal row per em (`_LATEX_SIZE_RATIO`, 1.15). The combined image is padded to whole rows with a little spare space (`_ROW_MARGIN`) because LaTeX's thin strokes look light next to the terminal font after downscaling; tune or disable it with `_WEIGHT_BOOST` in the script. Results are cached under `~/.cache/de100/math/` (keyed by the LaTeX source
and your theme colour), so re-running a cell is instant; a cold cell of five
items takes about a third of a second.

Fallbacks, in order, so something is always shown: if `pdflatex` or
`pdftocairo` isn't installed, or one item fails to compile, that item is drawn
with matplotlib's mathtext (a smaller subset of LaTeX); if even that can't,
its source text is printed, followed by the first LaTeX error line (for
example `! Missing } inserted. l.1`) so you can fix the string. One bad item
never takes the rest of the cell with it. The usual LaTeX rule still holds:
spaces inside math mode are ignored, so write words as `\text{some words}`.

The rendered image's colors and size track your active Neovim setup rather
than being hardcoded: `dotfiles/.config/nvim/lua/de100/utils/render-context.lua`
exports the current `Normal` highlight's bg/fg *and* the terminal's real cell
pixel dimensions to `~/.local/state/nvim/de100/theme/render-context.json`
on every colorscheme change *and* terminal resize, and the render hook reads
that file fresh on every call (cached for a couple of seconds so it isn't
re-read on every single render). The cell-size query is a direct
`ioctl(TIOCGWINSZ)` read done fresh on every export (the same approach
image.nvim itself uses internally, but not depending on *its* cache, which
only refreshes on a `VimResized` event this config doesn't want to assume
every terminal fires for e.g. a font-zoom that doesn't change the row/col
grid). Most of this config's themes set a
transparent `Normal` background (no `bg` in that file), so the image falls
back to a transparent background with themed text color in that case — a
theme that does set an explicit background renders fully opaque, matching
it exactly.

Sizing: `image.nvim` (Molten's image provider) turns a PNG's raw pixel
height into terminal rows as `rows = png_height_px / real_cell_height_px` —
it has no notion of "render this at 1 line tall," so a naive fixed DPI
renders wildly oversized (measured: a plain one-line expression came out
3-4 terminal rows tall). The hook always rasterizes at a fixed
high-quality DPI first, then downscales to the real target pixel height
(derived from `cell_height`) with Pillow's Lanczos filter, rather than
rendering natively at a tiny DPI — the latter looks blurry, since
matplotlib's rasterizer has no font hinting to fall back on at very small
native sizes the way a terminal's own text renderer does. The result is
crisp text sized to match roughly one terminal row for simple expressions,
scaling up proportionally for taller content (fractions, stacked terms).

Considered but **not** using `molten-nvim`'s own native `text/latex`
rendering path (the `pnglatex` package, real `pdflatex`) as an alternative:
`pnglatex` compiles through a fixed `\documentclass{article}` template with
no `xcolor`/color package loaded, so there's no clean way to make it
theme-aware without patching `molten-nvim`'s own `_from_latex` — the same
"fragile against `:Lazy update`" problem that rules out most third-party
plugin patches. The custom hook here, where colors are fully under our
control, is the better fit for this config's needs.

For math that isn't already wrapped in `Math()`/`Latex()`, or when you want
a different pipeline than the automatic one (the `Math()`/`Latex()` hook
above already uses real LaTeX), two more options:

- **`;mathimg`** (LuaSnip snippet, no extra system dependencies) — the same
  matplotlib mathtext approach, spelled out manually for a one-off plot-style
  render:
  ```python
  import matplotlib.pyplot as plt
  fig = plt.figure(figsize=(0.01, 0.01))
  fig.text(0, 0, r"$x^2 + y^2 = z^2$", fontsize=20)
  plt.axis("off")
  plt.show()
  ```

- **`;sympymath`** (needs the `dvipng` package from §2) — full LaTeX fidelity,
  using the same `pdflatex` this config already installs for vimtex:
  ```python
  import sympy
  sympy.init_printing(use_latex="dvipng")
  ```
  Run once per session; after that, any bare `sympy` expression left as a
  cell's last line auto-renders as a real rasterized-LaTeX image.

### Math output isn't rendering

If a cell running `Math(...)`/`Latex(...)` still shows
`<IPython.core.display.Math object>` instead of an image, confirm the
startup script actually loaded for this kernel: `:MoltenInfo` or check
`~/.ipython/profile_default/startup/10-de100-math-render.py` exists and
`pdflatex`/`pdftocairo` are on `PATH` (`which pdflatex pdftocairo`;
`sudo apt install texlive-latex-extra poppler-utils`). Without them the hook
falls back to matplotlib's smaller mathtext subset (so `matplotlib` must be
installed for the kernel's Python: `python3 -m pip show matplotlib`), and an
item neither can draw prints its source plus a `(LaTeX: ! ...)` error line —
that line is the LaTeX compiler's first complaint about your string.

### All output displays inline, below the cell — no floating window

`dotfiles/.config/nvim/lua/de100/plugins/molten.lua` sets
`g:molten_auto_open_output = false`: every run cell's output (text, images,
plots) is pinned directly below it, all visible at once as you scroll
through the notebook — Molten never opens a separate floating popup window
on its own (only `<leader>jo`, below, opens one deliberately).

### Multiple `Math()`/`Latex()` calls in one cell: combined into one image

`molten-nvim`'s inline path gives every image chunk in one cell's output
the same vertical position (`outputbuffer.py`'s `build_output_text`), so
two separate `display(Math(...))` images would render on top of each other
if each showed up immediately on its own — not fixable from this config
without patching `molten-nvim`'s own source.

Instead, `10-de100-math-render.py` buffers every `Math()`/`Latex()` call
made during a cell's execution — registered on IPython's
`_ipython_display_` formatter protocol, which fully bypasses the normal
per-mimetype publishing path so nothing is shown for it at all — and, once
the cell finishes running (IPython's `post_run_cell` event), renders and
vertically stacks all of them into a single combined image, shown once. No
overlap is possible, since Molten only ever sees one image chunk for that
output. The trade-off: math no longer appears exactly where you called
`display()` interleaved with other output (`print()` calls, etc.) — it all
appears together, once, at the end of the cell's output. `print()`/stream
output itself is untouched, since only `Math`/`Latex` objects are buffered.

(An earlier version registered on the `text/plain`/`text/latex`/`image/png`
formatters directly instead, each returning `None` to suppress its own
mimetype. `text/latex`/`image/png` disappeared correctly, but
`PlainTextFormatter` never actually returns `None` — when its pretty-printer
writes nothing, the result is `""`, and IPython only drops a formatter's
result when it's exactly `None`, so `format_dict = {"text/plain": ""}` still
went out as a real, near-empty `publish_display_data` call. Molten correctly
had nothing useful to render from that and printed
`<No usable MIMEtype! Received mimetypes ['text/plain']>` once per buffered
call. `_ipython_display_` avoids this entirely: it short-circuits before any
per-mimetype formatter runs, for both `display()` calls and a bare trailing
`Math(...)` expression, so zero messages go out for a buffered call.)

**sympy and other small images are snapped to the row grid.** sympy results
(and, after `sympy.init_printing()`, even plain floats and ints) emit their
own tiny images in sympy's own style. Molten can only reserve whole terminal
rows for an image, so a 21px image in 20px rows took two rows while a 15px one
took one with a different leftover gap, and the spacing looked uneven. The
hook wraps the kernel's output publisher and re-encodes any `image/png` up to
`_SNAP_MAX_ROWS` (6) rows tall: text is scaled toward terminal size
(`_SNAP_TEXT_SCALE`, 1.0, set by eye against `Math()` output), given
extra stroke weight (`_SNAP_WEIGHT_BOOST`, keeping their own colours), their
edges rebuilt at 4x resolution through a steep alpha curve
(`_SNAP_EDGE_STEEPNESS`, `_SNAP_EDGE_SHIFT`) so the stair-steps of sympy's tiny
PNGs become smooth edges instead of blur or pixels,
and the image is centred in a whole number of rows. Rows are whole, so spacing
comes from fitting the image into them with a small gap (`_ROW_GAP`, a fraction
of a row) rather than adding a spare row: a 21px sympy image in 20px rows takes
one row, scaled a little to leave the gap (an image only takes another row once
it overflows one by `_ROW_OVERFLOW`). Larger images (plots, photos) are untouched,
and so is the combined `Math()` image. sympy keeps its own colours; if you want
the themed, bordered style use `display(Math(sympy.latex(expr)))`. Images no
longer overlap each other or the text above them because Molten reserves each
inline image's rows (see "The Molten fork" below).

The combined image also gets a thin (1px) border, colored to match the
rendered text (not a separate theme accent color, so it can't desync from
whatever colorscheme is active) — a visual cue that everything inside it is
one grouped math output, distinct from surrounding `print()`/stream text.

`g:molten_output_show_exec_time` is also off (`molten.lua`): the
"`Out[2]: ✓ Done 1.50s`" execution-time header Molten normally prepends to
every output has no way to auto-hide after a delay — checked
`molten-nvim`'s source directly, the only timers in the plugin are
kernel-message polling loops, nothing display-related — so it's just
persistent noise on top of an already-inline, always-visible view. It's a
single global option (no per-cell or per-location override anywhere in
`molten-nvim`), so this also applies to the `<leader>jo` popup below.

### The Molten fork and keeping it current

`plugins/molten.lua` installs `DreamEcho100/molten-nvim` (branch
`de100-integration`) instead of `benlubas/molten-nvim`. The fork is upstream
`main` plus two small fixes, each also sent upstream as its own PR from its own
branch (`fix/inline-image-offset`, #365, and `fix/float-after-done`):

- inline images no longer cover the `Out[n]` header and the text above them
  (Molten now reserves the image's rows itself);
- a finished cell can show and hide its floating output window again (upstream
  commit `81aa71b` broke that: `<leader>jo` and `:MoltenShowOutput` did nothing).

Molten's author has said he no longer fixes bugs himself (issue #324), so the
branch is kept current by hand:

- Every 10th Neovim start (`vim.g.de100_molten_upstream_check_every`, `0`
  turns it off) a background check asks GitHub whether upstream `main` has
  commits the fork branch lacks and shows a toast listing the newest ones. It
  never changes anything, stays quiet offline, and doesn't repeat for the same
  upstream state. `:MoltenUpstreamCheck` runs it on demand.
- `de100-molten-fork-sync --check` lists the missing commits;
  `de100-molten-fork-sync` rebases the branch onto upstream `main` in a cache
  clone (`~/.cache/de100/molten-fork`), compiles the Python, and asks before
  force-pushing that one branch. On a conflict it changes nothing and says
  where to resolve it. Afterwards run `:Lazy update`, `:UpdateRemotePlugins`
  and restart Neovim.
- Once the PR is merged and released, point the spec back at
  `benlubas/molten-nvim` with `version = "^1.0.0"`.

### `<leader>jo`: floating output popup for one cell at a time

The always-inline default above trades exact placement for zero floating
windows — but sometimes you want a distraction-free popup with *just* one
cell's output, front and center, without turning that behavior on
everywhere. `<leader>jo` toggles Molten's own floating output window
(`:MoltenShowOutput`/`:MoltenHideOutput`) for whichever cell the cursor is
on: press it once to opt that cell in, and from then on entering it shows
the popup while leaving it hides the popup again — repeating every time you
re-enter, until you press `<leader>jo` on that same cell again to opt it
back out. It shows exactly what the inline view shows (same chunks, same
`molten_output_show_exec_time = false`) — just in a floating window instead
of pinned below the cell.

Molten has no native per-cell scoping for this (`auto_open_output` is a
single global flag shared by every cell, confirmed by reading
`molten-nvim`'s Python source — one `MoltenOptions` instance, shared by
reference everywhere), so `de100/utils/molten-popup.lua` tracks the toggled
cells itself and drives the show/hide calls off a `CursorMoved` autocmd.
Cell identity comes from `otter.nvim`'s code-chunk ranges — the same
mechanism `<leader>jr` (`quarto.runner.run_cell()`) already uses internally
to find "the cell the cursor is in" — since neither `quarto-nvim` nor
`molten-nvim` expose a public query for that.

`molten.lua` sets `image_location = "both"`, not `"virt"`: under `"virt"`,
`ImageOutputChunk.place()` (`outputchunks.py`) never actually places an
image for the popup's build call, and — because that early return happens
*before* the chunk claims its own Kitty-image identifier — closing the
popup would delete the *inline* image's identifier instead of a
popup-only one (they were the same shared identifier), permanently killing
it. `"both"` gives the popup a real image with its own separate identifier,
so it shows correctly and closing it only ever removes its own copy.

### Images and floating windows

`image.nvim` (`plugins/image.lua`) hides any image whose screen position is
covered by a window (Kitty images paint over the whole terminal regardless of
Neovim's window layering) and re-renders it later. That is wanted for real
popups, but it also fired for the small floating UI that is nearly always on
screen: noice's notification toasts, the incline filename label, blink.cmp's
menus and which-key. A toast over the rows under a cell made the images
vanish, and they came back from stale positions, which looked like images that
refuse to clear or stick around after edits. Those windows are now exempt
(`window_overlap_clear_ft_ignore`, noice and incline added to blink and
which-key). Any other floating window still hides the images under it until it
closes; `window_overlap_clear_enabled = false` would remove that entirely, at
the price of images drawing over popups.

Separately, the Molten fork gives every inline image its own anchor, because
`image.nvim` tracks an image's movement with one extmark per (row, column) and
all of a cell's images share the same anchor, so after an edit only one of them
followed. With the fork, adding, removing, replacing and undoing lines in or
above a cell keeps every image on its reserved rows.

One separate, unrelated caveat remains: inline images are placed via
Kitty-graphics-protocol escape codes at an absolute screen row computed
once, when a cell's output is (re)shown. There's no `WinScrolled` handling
anywhere in `molten-nvim`'s Python plugin, so scrolling the window without
moving the cursor to a new cell never re-triggers that placement — the
image (combined or not) stays visually pinned to its old screen row while
the text scrolls under it. Not fixable here either.

## 7. When to Reach for `.qmd` Instead of `.ipynb`

`.ipynb` is the right format when:

- The course/source material hands you notebooks directly.
- You want a format every notebook tool (JupyterLab, Colab, nbconvert) reads.

A `.qmd` (Quarto) file is the right format when you're writing your own
literate document — markdown prose interleaved with executable code cells —
and want it to render to a clean HTML/PDF report later, or want per-cell LSP
features (completion, diagnostics) via `otter.nvim` while you write. A Quarto
code cell looks like:

````markdown
​`{python}
import numpy as np
np.array([1, 2, 3]).sum()
​`
````

`quarto-nvim` reuses Molten for execution — same `<leader>jr` cell-run keymap
works in `.qmd` buffers too. Rare/occasional Quarto actions, again invoked
directly:

```vim
:QuartoPreview
:QuartoRun
```

The `quarto` CLI binary is only required for `:QuartoPreview`/rendering to
HTML/PDF — basic cell editing and execution works without it.

## 8. LaTeX Math Notation Quick Reference

Ties into the existing `lervag/vimtex` setup (see `plugins/languages.lua`) —
nothing new to configure, just a cheat sheet for notation you'll use
constantly in a math course:

| Notation              | LaTeX                                           |
| --------------------- | ----------------------------------------------- |
| Fraction              | `\frac{a}{b}`                                   |
| Square root           | `\sqrt{x}`, `\sqrt[n]{x}`                       |
| Sum                   | `\sum_{i=1}^{n} x_i`                            |
| Integral              | `\int_a^b f(x)\,dx`                             |
| Limit                 | `\lim_{x \to \infty} f(x)`                      |
| Matrix                | `\begin{pmatrix} a & b \\ c & d \end{pmatrix}`  |
| Greek letters         | `\alpha \beta \gamma \theta \lambda \pi \sigma` |
| Subscript/superscript | `x_i`, `x^2`, `x_i^2`                           |
| Vector                | `\vec{v}` or `\mathbf{v}`                       |

Open a `.tex` file and press `<leader>ll` (vimtex's default compile-and-view
leader sequence — check `:VimtexCompile` if it's not bound the way you
expect) to build and preview with `latexmk`/`zathura`.

## 9. Mapping This to a Jupyter-Based Math Course

A typical course workflow, translated to this config:

```text
Course gives you a .ipynb           -> :e notebook.ipynb
Read the explanation cells          -> <leader>ur, then render-markdown shows
                                        headings/math
Run the provided code cell          -> <leader>jr
Modify the code and re-run          -> edit, <leader>jr again
Try something in a new cell         -> insert a "# %%" line, write code, <leader>jr
Write your own notes/derivation     -> Markdown cell (render-markdown, off by
                                        default) or a .tex file for anything
                                        math-heavy
Save                                 -> :w (jupytext converts back to .ipynb)
```

## 10. Troubleshooting

### Blank output where a plot should be

1. Confirm `:checkhealth image` shows the `kitty` backend as OK.
2. Confirm you're actually inside Kitty or Ghostty (not a plain SSH session
   in an unsupported terminal — image.nvim only works in terminals that speak
   the Kitty graphics protocol).
3. If inside tmux, confirm `allow-passthrough` (see §2).

### `ModuleNotFoundError` inside a cell

The kernel's Python doesn't have the package. See "Per-project environment"
in §2: find the kernel's Python (`kernel.json`), install into the project's
venv (not system Python), and `:MoltenRestart`.

### `:MoltenInit` can't find a kernel

```sh
python3 -m jupyter kernelspec list
```

If `python3` isn't listed, install the kernel spec:

```sh
python3 -m ipykernel install --user
```

### jupytext conversion fails or the notebook looks wrong on save

Check the `jupytext` CLI directly outside Neovim:

```sh
jupytext --to py:percent notebook.ipynb -o -
```

If this errors, the problem is jupytext/the notebook itself, not the Neovim
plugin.

### Math not rendering as unicode in Markdown

Confirm `pylatexenc` is installed for the same Python interpreter Neovim's
provider uses:

```sh
python3 -m pip show pylatexenc
:checkhealth provider
```

## 11. Practice Checklist

- [ ] Run `:checkhealth image` and confirm the Kitty backend is available.
- [ ] Open a test `.ipynb`, confirm it converts via jupytext.
- [ ] `:MoltenInit`, run a cell with `<leader>jr`, see text output.
- [ ] Run a cell that produces a matplotlib plot, confirm it renders inline.
- [ ] Repeat the plot test inside tmux to confirm passthrough works.
- [ ] Write a Markdown cell with inline math (`$x^2 + y^2 = z^2$`) and confirm
      it renders as unicode.
- [ ] Run a cell with `;mathimg` or `;sympymath` and confirm real rendered
      math output (an image), not `<... object>` repr text.
- [ ] Run `:JupytextNew scratch/test`, confirm it opens as an empty converted
      notebook with no error.
- [ ] From an oil buffer with the cursor on a directory, press `<leader>jn`,
      type only a name, and confirm the notebook lands in that directory.
- [ ] Run a cell, then `:MoltenClear` (that cell's output goes away) and
      `:MoltenClearAll` (every cell's output goes away; the kernel and its
      variables are untouched).
- [ ] Run two cells, then `:MoltenSaveOutput` on one: only that cell's output
      appears in the `.ipynb` next to the file; `:MoltenSaveOutputAll` writes both.
- [ ] Navigate between already-run cells with `]j` / `[j`.
- [ ] Navigate between all code blocks (run or not) with `]b` / `[b`.
- [ ] Open (or create) a `.qmd` file and run a Python cell in it.
- [ ] Open a `.tex` file and compile it with vimtex.

Once these are routine, working through a Jupyter-based course becomes a
matter of `<leader>jr` and reading output — not context-switching to a
browser tab for every cell.
