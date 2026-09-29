;; extends
;; Captures a fenced code block as a "code cell" text object, for
;; jupytext/quarto notebooks. Matches plain ```lang fences (jupytext's
;; markdown style) and curly ```{lang} fences (real .qmd files) alike, since
;; it doesn't filter on the info string's content at all.
(fenced_code_block (code_fence_content) @code_cell.inner) @code_cell.outer
