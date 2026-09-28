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
python3 -m pip show pynvim jupyter_client ipykernel jupytext pylatexenc
dpkg -l | grep libmagickwand-dev   # Debian/Ubuntu
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

## 3. Opening a Notebook

Open any `.ipynb` file normally:

```vim
:e notebook.ipynb
```

`jupytext.nvim` intercepts the read, converts the notebook to a percent-format
Markdown/Python buffer behind the scenes, and converts it back to valid
`.ipynb` JSON on save. You edit readable text; the file on disk stays a
real notebook any other tool (JupyterLab, VS Code, `nbconvert`) can open.

A percent-format cell looks like this:

```python
# %%
import numpy as np
import matplotlib.pyplot as plt

x = np.linspace(0, 2 * np.pi, 200)
plt.plot(x, np.sin(x))
```

The `# %%` marker is the cell boundary. Anything between two markers (or
before the first one) is one cell.

## 4. Running Cells

First, attach a kernel to the buffer (once per session):

```vim
:MoltenInit
```

Pick a kernel (usually `python3`) when prompted. Then:

| Key                   | Action                               |
| --------------------- | ------------------------------------ |
| `<leader>jr`          | Run/re-run the cell under the cursor |
| `<leader>jv` (visual) | Run only the selected lines          |
| `]j`                  | Jump to the next cell/output         |
| `[j`                  | Jump to the previous cell/output     |

That's the entire keymap surface on purpose — everything else below is a rare
enough action that it's invoked directly as an Ex command instead (same
philosophy as the rest of this config; see tutorial 13, section 4.6).

## 5. Viewing Output, Including Plots

Molten opens a virtual-text output area under the cell showing whatever the
kernel returned: printed text, a DataFrame's repr, a traceback, or — for
matplotlib/sympy plots — the actual rendered image, drawn inline via
`image.nvim` and the Kitty graphics protocol.

Rare/occasional output actions, invoked directly (no keymap):

```vim
:MoltenShowOutput
:MoltenHideOutput
:MoltenDelete
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
`plugins/render-markdown.lua`'s `opts.latex` block. If math isn't rendering,
confirm `pylatexenc` is installed (`python3 -m pip show pylatexenc`) and that
the buffer has the `latex` treesitter parser (`:TSInstall latex` if missing —
though it should already be in this config's `ensure_installed` list).

For anything beyond simple inline notation — derivations, multi-line proofs,
numbered equations — write a `.tex` file instead and lean on the existing
vimtex setup (see §11).

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
Read the explanation cells          -> render-markdown shows headings/math
Run the provided code cell          -> <leader>jr
Modify the code and re-run          -> edit, <leader>jr again
Try something in a new cell         -> insert a "# %%" line, write code, <leader>jr
Write your own notes/derivation     -> Markdown cell (render-markdown) or
                                        a .tex file for anything math-heavy
Save                                 -> :w (jupytext converts back to .ipynb)
```

## 10. Troubleshooting

### Blank output where a plot should be

1. Confirm `:checkhealth image` shows the `kitty` backend as OK.
2. Confirm you're actually inside Kitty or Ghostty (not a plain SSH session
   in an unsupported terminal — image.nvim only works in terminals that speak
   the Kitty graphics protocol).
3. If inside tmux, confirm `allow-passthrough` (see §2).

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
- [ ] Navigate between cells with `]j` / `[j`.
- [ ] Open (or create) a `.qmd` file and run a Python cell in it.
- [ ] Open a `.tex` file and compile it with vimtex.

Once these are routine, working through a Jupyter-based course becomes a
matter of `<leader>jr` and reading output — not context-switching to a
browser tab for every cell.
