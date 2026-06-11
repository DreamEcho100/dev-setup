-- 📖 Tutorial: docs/neovim-tutorials-from-0-to-hero/07-lsp-and-completions.md
local ls = require("luasnip")
local s = ls.snippet
local t = ls.text_node
local i = ls.insert_node
local f = ls.function_node

local function cap(index)
	return f(function(args)
		local str = args[1][1] or ""
		return str:sub(1, 1):upper() .. str:sub(2)
	end, {index})
end

local function mirror(index)
	return f(function(args) return args[1][1] end, {index})
end

return {
	-- ── JSX Elements ───────────────────────────────────────────────────────
	s({trig = ";el", name = "JSX element",
		desc = {"```jsx", "<div>", "  ", "</div>", "```"}}, {
		t("<"), i(1, "div"), t({">", "\t"}),
		i(2, ""),
		t({"", "</"}), mirror(1), t(">"),
	}),
	s({trig = ";elf", name = "JSX self-closing element",
		desc = {"```jsx", "<Component prop /> ", "```"}}, {
		t("<"), i(1, "Component"), t(" "), i(2, ""), t(" />"),
	}),
	s({trig = ";frag", name = "JSX Fragment",
		desc = {"```jsx", "<>", "  ", "</>", "```"}}, {
		t({"<>", "\t"}),
		i(1, ""),
		t({"", "</>"}),
	}),

	-- ── Conditional rendering ──────────────────────────────────────────────
	s({trig = ";cond", name = "Short-circuit render",
		desc = {"```jsx", "{condition && (", "  <div></div>", ")}", "```"}}, {
		t("{"), i(1, "condition"), t({" && (", "\t"}),
		i(2, "<div></div>"),
		t({"", ")}"}),
	}),
	s({trig = ";ternr", name = "Ternary render",
		desc = {"```jsx", "{", "  condition", "    ? <div></div>", "    : null", "}", "```"}}, {
		t({"{", "\t"}), i(1, "condition"),
		t({"", "\t\t? "}), i(2, "<div></div>"),
		t({"", "\t\t: "}), i(3, "null"),
		t({"", "}"}),
	}),
	s({trig = ";listr", name = "List render .map",
		desc = {"```jsx", "{items.map((item) => (", "  <li key={item.id}>{item.name}</li>", "))}", "```"}}, {
		t("{"), i(1, "items"), t({".map(("}), i(2, "item"), t({") => (", "\t"}),
		i(3, "<li key={item.id}>{item.name}</li>"),
		t({"", "))"}),
	}),

	-- ── Event handlers ─────────────────────────────────────────────────────
	s({trig = ";onclick", name = "onClick handler",
		desc = {"```jsx", "onClick={() => action}", "```"}}, {
		t("onClick={() => "), i(1, ""), t("}"),
	}),
	s({trig = ";onchange", name = "onChange handler",
		desc = {"```jsx", "onChange={(e) => setValue(e.target.value)}", "```"}}, {
		t("onChange={(e) => "), i(1, "setValue"), t("(e.target.value)}"),
	}),
	s({trig = ";onsubmit", name = "onSubmit handler",
		desc = {"```jsx", "onSubmit={(e) => {", "  e.preventDefault()", "  ", "}}", "```"}}, {
		t({"onSubmit={(e) => {", "\te.preventDefault()", "\t"}),
		i(1, ""),
		t({"", "}}"}),
	}),
	s({trig = ";handler", name = "Event handler function",
		desc = {"```jsx", "const handleEvent = (e) => {", "  ", "}", "```"}}, {
		t("const handle"), i(1, "Event"),
		t({" = ("}), i(2, "e"), t({") => {", "\t"}),
		i(3, ""),
		t({"", "}"}),
	}),

	-- ── Props & attributes ─────────────────────────────────────────────────
	s({trig = ";cn", name = "className",
		desc = {"```jsx", "className={styles.container}", "```"}}, {
		t("className={"), i(1, "styles.container"), t("}"),
	}),
	s({trig = ";cns", name = "className string",
		desc = {"```jsx", 'className="my-class"', "```"}}, {
		t('className="'), i(1, ""), t('"'),
	}),
	s({trig = ";style", name = "inline style",
		desc = {"```jsx", "style={{ key: value }}", "```"}}, {
		t("style={{ "), i(1, "key"), t(": "), i(2, "value"), t(" }}"),
	}),
	s({trig = ";key", name = "key prop",
		desc = {"```jsx", "key={item.id}", "```"}}, {
		t("key={"), i(1, "item.id"), t("}"),
	}),
	s({trig = ";ref", name = "ref prop",
		desc = {"```jsx", "ref={ref}", "```"}}, {
		t("ref={"), i(1, "ref"), t("}"),
	}),
	s({trig = ";disabled", name = "disabled conditional",
		desc = {"```jsx", "disabled={isLoading}", "```"}}, {
		t("disabled={"), i(1, "isLoading"), t("}"),
	}),

	-- ── Forms ──────────────────────────────────────────────────────────────
	s({trig = ";input", name = "Controlled input",
		desc = {"```jsx", '<input', '  type="text"', "  value={value}", "  onChange={(e) => setValue(e.target.value)}", "/>", "```"}}, {
		t({"<input", '\ttype="'}), i(1, "text"), t({'"', "\tvalue={"}),
		i(2, "value"), t({"}",
		"\tonChange={(e) => set"}),
		cap(2),
		t({"(e.target.value)}", "/>"}),
	}),
	s({trig = ";form", name = "Form element",
		desc = {"```jsx", "<form onSubmit={(e) => {", "  e.preventDefault()", "  ", "}}>", "  ", "</form>", "```"}}, {
		t({"<form onSubmit={(e) => {", "\te.preventDefault()", "\t"}),
		i(1, ""),
		t({"", "}}>", "\t"}),
		i(2, ""),
		t({"", "</form>"}),
	}),
	s({trig = ";select", name = "Select input",
		desc = {"```jsx", "<select", "  value={value}", "  onChange={(e) => setValue(e.target.value)}", ">", "  ", "</select>", "```"}}, {
		t({"<select", "\tvalue={"}), i(1, "value"),
		t({"}", "\tonChange={(e) => set"}), cap(1), t("(e.target.value)}"),
		t({">", "\t"}), i(2, ""),
		t({"", "</select>"}),
	}),

	-- ── Loading / Suspense ─────────────────────────────────────────────────
	s({trig = ";suspense", name = "Suspense wrapper",
		desc = {"```jsx", "<Suspense fallback={<div>Loading...</div>}>", "  ", "</Suspense>", "```"}}, {
		t("<Suspense fallback={"), i(1, "<div>Loading...</div>"), t({"}}>", "\t"}),
		i(2, ""),
		t({"", "</Suspense>"}),
	}),
	s({trig = ";lazy", name = "React.lazy import",
		desc = {"```jsx", "const Component = React.lazy(() => import('./Component'))", "```"}}, {
		t("const "), i(1, "Component"),
		t(" = React.lazy(() => import('"), i(2, "./Component"), t("'))"),
	}),
	s({trig = ";portal", name = "ReactDOM.createPortal",
		desc = {"```jsx", "ReactDOM.createPortal(", "  <div></div>,", "  document.getElementById('modal-root')", ")", "```"}}, {
		t("ReactDOM.createPortal(", "\t"), i(1, "<div></div>"),
		t({",", "\tdocument.getElementById('"}), i(2, "modal-root"), t("')", ")"),
	}),
}
