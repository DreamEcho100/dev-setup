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
	-- ── Functions ──────────────────────────────────────────────────────────
	s({trig = ";fn", name = "Arrow function",
		desc = {"```js", "const name = (args) => {", "  ", "}", "```"}}, {
		t("const "), i(1, "name"), t(" = ("), i(2, ""), t({") => {", "\t"}),
		i(3, ""),
		t({"", "}"}),
	}),
	s({trig = ";afn", name = "Async arrow function",
		desc = {"```js", "const name = async (args) => {", "  ", "}", "```"}}, {
		t("const "), i(1, "name"), t(" = async ("), i(2, ""), t({") => {", "\t"}),
		i(3, ""),
		t({"", "}"}),
	}),
	s({trig = ";fun", name = "Named function",
		desc = {"```js", "function name(args) {", "  ", "}", "```"}}, {
		t("function "), i(1, "name"), t("("), i(2, ""), t({") {", "\t"}),
		i(3, ""),
		t({"", "}"}),
	}),
	s({trig = ";afun", name = "Async named function",
		desc = {"```js", "async function name(args) {", "  ", "}", "```"}}, {
		t("async function "), i(1, "name"), t("("), i(2, ""), t({") {", "\t"}),
		i(3, ""),
		t({"", "}"}),
	}),

	-- ── Console ────────────────────────────────────────────────────────────
	s({trig = ";cl", name = "console.log",
		desc = {"```js", "console.log(value)", "```"}}, {
		t("console.log("), i(1, ""), t(")"),
	}),
	s({trig = ";cle", name = "console.error",
		desc = {"```js", "console.error(value)", "```"}}, {
		t("console.error("), i(1, ""), t(")"),
	}),
	s({trig = ";clw", name = "console.warn",
		desc = {"```js", "console.warn(value)", "```"}}, {
		t("console.warn("), i(1, ""), t(")"),
	}),
	s({trig = ";clt", name = "console.table",
		desc = {"```js", "console.table(value)", "```"}}, {
		t("console.table("), i(1, ""), t(")"),
	}),
	s({trig = ";clj", name = "console.log JSON.stringify",
		desc = {"```js", "console.log(JSON.stringify(value, null, 2))", "```"}}, {
		t("console.log(JSON.stringify("), i(1, "value"), t(", null, 2))"),
	}),

	-- ── Imports ────────────────────────────────────────────────────────────
	s({trig = ";imp", name = "Named import",
		desc = {"```js", "import { name } from 'module'", "```"}}, {
		t("import { "), i(1, "name"), t(" } from '"), i(2, "module"), t("'"),
	}),
	s({trig = ";impa", name = "Namespace import",
		desc = {"```js", "import * as name from 'module'", "```"}}, {
		t("import * as "), i(1, "name"), t(" from '"), i(2, "module"), t("'"),
	}),
	s({trig = ";imd", name = "Default import",
		desc = {"```js", "import name from 'module'", "```"}}, {
		t("import "), i(1, "name"), t(" from '"), i(2, "module"), t("'"),
	}),

	-- ── Control flow ───────────────────────────────────────────────────────
	s({trig = ";ife", name = "if/else",
		desc = {"```js", "if (condition) {", "  ", "} else {", "  ", "}", "```"}}, {
		t("if ("), i(1, "condition"), t({") {", "\t"}),
		i(2, ""),
		t({"", "} else {", "\t"}),
		i(3, ""),
		t({"", "}"}),
	}),
	s({trig = ";tern", name = "Ternary",
		desc = {"```js", "condition ? ifTrue : ifFalse", "```"}}, {
		i(1, "condition"), t(" ? "), i(2, "ifTrue"), t(" : "), i(3, "ifFalse"),
	}),
	s({trig = ";try", name = "try/catch",
		desc = {"```js", "try {", "  ", "} catch (error) {", "  console.error(error)", "}", "```"}}, {
		t({"try {", "\t"}),
		i(1, ""),
		t({"", "} catch ("}), i(2, "error"), t({") {", "\t"}),
		i(3, "console.error(error)"),
		t({"", "}"}),
	}),
	s({trig = ";tryf", name = "try/catch/finally",
		desc = {"```js", "try {", "  ", "} catch (error) {", "  console.error(error)", "} finally {", "  ", "}", "```"}}, {
		t({"try {", "\t"}),
		i(1, ""),
		t({"", "} catch ("}), i(2, "error"), t({") {", "\t"}),
		i(3, "console.error(error)"),
		t({"", "} finally {", "\t"}),
		i(4, ""),
		t({"", "}"}),
	}),

	-- ── Arrays ─────────────────────────────────────────────────────────────
	s({trig = ";map", name = "Array.map",
		desc = {"```js", "array.map((item) => {", "  return ", "})", "```"}}, {
		i(1, "array"), t({".map(("}), i(2, "item"), t({") => {", "\t"}),
		t("return "), i(3, ""),
		t({"", "})"}),
	}),
	s({trig = ";filter", name = "Array.filter",
		desc = {"```js", "array.filter((item) => {", "  return condition", "})", "```"}}, {
		i(1, "array"), t(".filter(("), i(2, "item"), t({") => {", "\t"}),
		t("return "), i(3, "condition"),
		t({"", "})"}),
	}),
	s({trig = ";reduce", name = "Array.reduce",
		desc = {"```js", "array.reduce((acc, item) => {", "  return acc", "}, initialValue)", "```"}}, {
		i(1, "array"), t(".reduce(("), i(2, "acc"), t(", "), i(3, "item"),
		t({") => {", "\t"}),
		t("return "), i(4, "acc"),
		t({"", "}, "}), i(5, "initialValue"), t(")"),
	}),
	s({trig = ";foreach", name = "Array.forEach",
		desc = {"```js", "array.forEach((item) => {", "  ", "})", "```"}}, {
		i(1, "array"), t(".forEach(("), i(2, "item"), t({") => {", "\t"}),
		i(3, ""),
		t({"", "})"}),
	}),
	s({trig = ";find", name = "Array.find",
		desc = {"```js", "array.find((item) => condition)", "```"}}, {
		i(1, "array"), t(".find(("), i(2, "item"), t(") => "), i(3, "condition"), t(")"),
	}),
	s({trig = ";findi", name = "Array.findIndex",
		desc = {"```js", "array.findIndex((item) => condition)", "```"}}, {
		i(1, "array"), t(".findIndex(("), i(2, "item"), t(") => "), i(3, "condition"), t(")"),
	}),

	-- ── Promises / Async ───────────────────────────────────────────────────
	s({trig = ";prom", name = "new Promise",
		desc = {"```js", "new Promise((resolve, reject) => {", "  ", "})", "```"}}, {
		t({"new Promise((resolve, reject) => {", "\t"}),
		i(1, ""),
		t({"", "})"}),
	}),
	s({trig = ";fetch", name = "fetch with await",
		desc = {"```js", "const data = await fetch('url')", "const json = await data.json()", "```"}}, {
		t("const "), i(1, "data"), t(" = await fetch('"), i(2, "url"), t("')"),
		t({"", "const "}), i(3, "json"), t(" = await "), mirror(1), t(".json()"),
	}),
	s({trig = ";await", name = "await expression",
		desc = {"```js", "const result = await promise", "```"}}, {
		t("const "), i(1, "result"), t(" = await "), i(2, "promise"),
	}),

	-- ── Objects ────────────────────────────────────────────────────────────
	s({trig = ";obj", name = "Object destructure",
		desc = {"```js", "const { key } = object", "```"}}, {
		t("const { "), i(1, "key"), t(" } = "), i(2, "object"),
	}),
	s({trig = ";spread", name = "Spread object",
		desc = {"```js", "{ ...obj, key: value }", "```"}}, {
		t("{ ..."), i(1, "obj"), t(", "), i(2, "key"), t(": "), i(3, "value"), t(" }"),
	}),

	-- ── Classes ────────────────────────────────────────────────────────────
	s({trig = ";cls", name = "Class",
		desc = {"```js", "class Name {", "  constructor(args) {", "    ", "  }", "}", "```"}}, {
		t("class "), i(1, "Name"), t({" {", "\tconstructor("}),
		i(2, ""),
		t({") {", "\t\t"}),
		i(3, ""),
		t({"", "\t}", "}"}),
	}),

	-- ── Timers ─────────────────────────────────────────────────────────────
	s({trig = ";timeout", name = "setTimeout",
		desc = {"```js", "setTimeout(() => {", "  ", "}, 1000)", "```"}}, {
		t({"setTimeout(() => {", "\t"}),
		i(1, ""),
		t({"", "}, "}), i(2, "1000"), t(")"),
	}),
	s({trig = ";interval", name = "setInterval",
		desc = {"```js", "const id = setInterval(() => {", "  ", "}, 1000)", "```"}}, {
		t("const "), i(1, "id"), t({" = setInterval(() => {", "\t"}),
		i(2, ""),
		t({"", "}, "}), i(3, "1000"), t(")"),
	}),
	s({trig = ";debounce", name = "debounce helper",
		desc = {"```js", "function debounce(fn, delay) {", "  let timer", "  return (...args) => {", "    clearTimeout(timer)", "    timer = setTimeout(() => fn(...args), delay)", "  }", "}", "```"}}, {
		t({"function debounce(fn, delay) {",
			"\tlet timer",
			"\treturn (...args) => {",
			"\t\tclearTimeout(timer)",
			"\t\ttimer = setTimeout(() => fn(...args), delay)",
			"\t}",
		"}"}),
	}),

	-- ── React Hooks ────────────────────────────────────────────────────────
	s({trig = ";useState", name = "useState hook",
		desc = {"```jsx", "const [state, setState] = useState(initialValue)", "```"}}, {
		t("const ["), i(1, "state"), t(", set"), cap(1),
		t("] = useState("), i(2, ""), t(")"),
	}),
	s({trig = ";useEffect", name = "useEffect hook",
		desc = {"```jsx", "useEffect(() => {", "  ", "}, [deps])", "```"}}, {
		t({"useEffect(() => {", "\t"}),
		i(1, ""),
		t({"", "}, ["}), i(2, ""), t("])"),
	}),
	s({trig = ";useCallback", name = "useCallback hook",
		desc = {"```jsx", "const callback = useCallback((args) => {", "  ", "}, [deps])", "```"}}, {
		t("const "), i(1, "callback"), t(" = useCallback(("), i(2, ""),
		t({") => {", "\t"}),
		i(3, ""),
		t({"", "}, ["}), i(4, ""), t("])"),
	}),
	s({trig = ";useMemo", name = "useMemo hook",
		desc = {"```jsx", "const value = useMemo(() => {", "  return ", "}, [deps])", "```"}}, {
		t("const "), i(1, "value"), t({" = useMemo(() => {", "\t"}),
		t("return "), i(2, ""),
		t({"", "}, ["}), i(3, ""), t("])"),
	}),
	s({trig = ";useRef", name = "useRef hook",
		desc = {"```jsx", "const ref = useRef(null)", "```"}}, {
		t("const "), i(1, "ref"), t(" = useRef("), i(2, "null"), t(")"),
	}),
	s({trig = ";useContext", name = "useContext hook",
		desc = {"```jsx", "const value = useContext(Context)", "```"}}, {
		t("const "), i(1, "value"), t(" = useContext("), i(2, "Context"), t(")"),
	}),

	-- ── React Components ───────────────────────────────────────────────────
	s({trig = ";comp", name = "React component",
		desc = {"```jsx", "export default function Component() {", "  return (", "    <div></div>", "  )", "}", "```"}}, {
		t("export default function "), i(1, "Component"),
		t({"() {", "\treturn (", "\t\t"}),
		i(2, "<div></div>"),
		t({"", "\t)", "}"}),
	}),
	s({trig = ";compp", name = "React component with props",
		desc = {"```tsx", "interface ComponentProps {", "  prop: Type", "}", "", "export default function Component({ prop }: ComponentProps) {", "  return (", "    <div></div>", "  )", "}", "```"}}, {
		t("interface "), i(1, "Component"), t({"Props {", "\t"}),
		i(2, ""),
		t({"", "}", "", "export default function "}), mirror(1),
		t("({ "), i(3, ""), t(" }: "), mirror(1),
		t({"Props) {", "\treturn (", "\t\t"}),
		i(4, "<div></div>"),
		t({"", "\t)", "}"}),
	}),
	s({trig = ";hook", name = "Custom React hook",
		desc = {"```jsx", "export function useName(args) {", "  ", "  return {", "    ", "  }", "}", "```"}}, {
		t("export function use"), i(1, "Name"), t("("), i(2, ""),
		t({") {", "\t"}),
		i(3, ""),
		t({"", "\treturn {", "\t\t"}),
		i(4, ""),
		t({"", "\t}", "}"}),
	}),
	s({trig = ";ctx", name = "React context + provider",
		desc = {"```jsx", "const NameContext = createContext(null)", "", "export function NameProvider({ children }) {", "  return (", "    <NameContext.Provider>{children}</NameContext.Provider>", "  )", "}", "```"}}, {
		t("const "), i(1, "Name"),
		t({"Context = createContext(null)", "", "export function "}),
		mirror(1),
		t({"Provider({ children }) {", "\treturn (", "\t\t<"}),
		mirror(1),
		t({"Context.Provider>", "\t\t\t{children}", "\t\t</"}),
		mirror(1),
		t({"Context.Provider>", "\t)", "}"}),
	}),
}
