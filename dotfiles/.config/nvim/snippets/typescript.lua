-- 📖 Tutorial: docs/neovim-tutorials-from-0-to-hero/07-lsp-and-completions.md
local ls = require("luasnip")
local s = ls.snippet
local t = ls.text_node
local i = ls.insert_node
local f = ls.function_node

local function mirror(index)
	return f(function(args) return args[1][1] end, {index})
end

return {
	-- ── Types ──────────────────────────────────────────────────────────────
	s({trig = ";type", name = "Type alias",
		desc = {"```ts", "type Name = ", "```"}}, {
		t("type "), i(1, "Name"), t(" = "), i(2, ""),
	}),
	s({trig = ";inter", name = "Interface",
		desc = {"```ts", "interface Name {", "  field: Type", "}", "```"}}, {
		t("interface "), i(1, "Name"), t({" {", "\t"}), i(2, ""), t({"", "}"}),
	}),
	s({trig = ";iext", name = "Interface extending",
		desc = {"```ts", "interface Name extends Base {", "  field: Type", "}", "```"}}, {
		t("interface "), i(1, "Name"), t(" extends "), i(2, "Base"), t({" {", "\t"}),
		i(3, ""), t({"", "}"}),
	}),
	s({trig = ";enum", name = "Enum",
		desc = {"```ts", "enum Name {", "  Value,", "}", "```"}}, {
		t("enum "), i(1, "Name"), t({" {", "\t"}), i(2, "Value"), t({"", "}"}),
	}),
	s({trig = ";cenum", name = "Const enum",
		desc = {"```ts", "const enum Name {", "  Value,", "}", "```"}}, {
		t("const enum "), i(1, "Name"), t({" {", "\t"}), i(2, "Value"), t({"", "}"}),
	}),
	s({trig = ";generic", name = "Generic function",
		desc = {"```ts", "function name<T>(arg: T): T {", "  ", "}", "```"}}, {
		t("function "), i(1, "name"), t("<"), i(2, "T"), t(">("), i(3, "arg: "),
		mirror(2), t("): "), i(4, "T"), t({" {", "\t"}), i(5, ""), t({"", "}"}),
	}),
	s({trig = ";record", name = "Record type",
		desc = {"```ts", "Record<string, unknown>", "```"}}, {
		t("Record<"), i(1, "string"), t(", "), i(2, "unknown"), t(">"),
	}),
	s({trig = ";partial", name = "Partial type",
		desc = {"```ts", "Partial<Type>", "```"}}, {
		t("Partial<"), i(1, "Type"), t(">"),
	}),
	s({trig = ";required", name = "Required type",
		desc = {"```ts", "Required<Type>", "```"}}, {
		t("Required<"), i(1, "Type"), t(">"),
	}),
	s({trig = ";pick", name = "Pick type",
		desc = {"```ts", "Pick<Type, 'key'>", "```"}}, {
		t("Pick<"), i(1, "Type"), t(", '"), i(2, "key"), t("'>"),
	}),
	s({trig = ";omit", name = "Omit type",
		desc = {"```ts", "Omit<Type, 'key'>", "```"}}, {
		t("Omit<"), i(1, "Type"), t(", '"), i(2, "key"), t("'>"),
	}),
	s({trig = ";readonly", name = "Readonly type",
		desc = {"```ts", "Readonly<Type>", "```"}}, {
		t("Readonly<"), i(1, "Type"), t(">"),
	}),
	s({trig = ";as", name = "Type assertion",
		desc = {"```ts", "value as Type", "```"}}, {
		i(1, "value"), t(" as "), i(2, "Type"),
	}),
	s({trig = ";satis", name = "satisfies operator",
		desc = {"```ts", "value satisfies Type", "```"}}, {
		i(1, "value"), t(" satisfies "), i(2, "Type"),
	}),
	s({trig = ";guard", name = "Type guard function",
		desc = {"```ts", "function isType(value: unknown): value is Type {", "  return ", "}", "```"}}, {
		t("function is"), i(1, "Type"), t("(value: unknown): value is "),
		i(2, "Type"), t({" {", "\treturn "}), i(3, ""), t({"", "}"}),
	}),
	-- ── Decorators ─────────────────────────────────────────────────────────
	s({trig = ";dec", name = "Decorator",
		desc = {"```ts", "@Decorator", "class ...", "```"}}, {
		t("@"), i(1, "Decorator"), t({"", ""}),
	}),
	-- ── Utility ────────────────────────────────────────────────────────────
	s({trig = ";nna", name = "Non-null assertion",
		desc = {"```ts", "value!", "```"}}, {
		i(1, "value"), t("!"),
	}),
	s({trig = ";opt", name = "Optional chaining",
		desc = {"```ts", "obj?.prop", "```"}}, {
		i(1, "obj"), t("?."), i(2, "prop"),
	}),
	s({trig = ";null", name = "Nullish coalescing",
		desc = {"```ts", "value ?? default", "```"}}, {
		i(1, "value"), t(" ?? "), i(2, "default"),
	}),
}
