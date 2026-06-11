local ls = require("luasnip")
local s = ls.snippet
local t = ls.text_node
local i = ls.insert_node
local f = ls.function_node

local function mirror(index)
	return f(function(args) return args[1][1] end, {index})
end

return {
	s({trig = ";main", name = "main function",
		desc = {"```c", "int main(int argc, char *argv[]) {", "  ", "  return 0;", "}", "```"}}, {
		t({"int main(int argc, char *argv[]) {", "\t"}), i(1, ""),
		t({"", "\treturn 0;", "}"}),
	}),
	s({trig = ";fn", name = "Function",
		desc = {"```c", "void name(args) {", "  ", "}", "```"}}, {
		i(1, "void"), t(" "), i(2, "name"), t("("), i(3, ""), t({") {", "\t"}),
		i(4, ""), t({"", "}"}),
	}),
	s({trig = ";guard", name = "Header include guard",
		desc = {"```c", "#ifndef HEADER_H", "#define HEADER_H", "", "// ...", "", "#endif // HEADER_H", "```"}}, {
		t("#ifndef "), i(1, "HEADER_H"),
		t({"", "#define "}), mirror(1), t({"", ""}),
		i(2, ""), t({"", "", "#endif // "}), mirror(1),
	}),
	s({trig = ";inc", name = "#include <>",
		desc = {"```c", "#include <stdio.h>", "```"}}, {
		t("#include <"), i(1, "stdio.h"), t(">"),
	}),
	s({trig = ";incs", name = '#include ""',
		desc = {"```c", '#include "header.h"', "```"}}, {
		t('#include "'), i(1, "header.h"), t('"'),
	}),
	s({trig = ";printf", name = "printf",
		desc = {"```c", 'printf("%s\\n", value)', "```"}}, {
		t('printf("'), i(1, "%s\\n"), t('", '), i(2, ""), t(")"),
	}),
	s({trig = ";scanf", name = "scanf",
		desc = {"```c", 'scanf("%d", &var)', "```"}}, {
		t('scanf("'), i(1, "%d"), t('", &'), i(2, "var"), t(")"),
	}),
	s({trig = ";struct", name = "Struct",
		desc = {"```c", "typedef struct {", "  ", "} Name;", "```"}}, {
		t("typedef struct {", "\t"), i(1, ""), t({"", "} "}), i(2, "Name"), t(";"),
	}),
	s({trig = ";malloc", name = "malloc with cast",
		desc = {"```c", "Type *ptr = (Type *)malloc(sizeof(Type) * n);", "if (!ptr) { perror(\"malloc\"); exit(1); }", "```"}}, {
		i(1, "Type"), t(" *"), i(2, "ptr"), t(" = ("), mirror(1),
		t(" *)malloc(sizeof("), mirror(1), t(") * "), i(3, "n"), t(");"),
		t({"", "if (!"}), mirror(2), t(') { perror("malloc"); exit(1); }'),
	}),
	s({trig = ";free", name = "free and null",
		desc = {"```c", "free(ptr); ptr = NULL;", "```"}}, {
		t("free("), i(1, "ptr"), t("); "), mirror(1), t(" = NULL;"),
	}),
	s({trig = ";for", name = "for loop",
		desc = {"```c", "for (int i = 0; i < n; i++) {", "  ", "}", "```"}}, {
		t("for ("), i(1, "int i = 0"), t("; "), i(2, "i < n"), t("; "),
		i(3, "i++"), t({") {", "\t"}), i(4, ""), t({"", "}"}),
	}),
	s({trig = ";switch", name = "switch",
		desc = {"```c", "switch (var) {", "case value:", "  ", "  break;", "default:", "  break;", "}", "```"}}, {
		t("switch ("), i(1, "var"), t({") {", "case "}), i(2, "value"),
		t({":", "\t"}), i(3, ""), t({"", "\tbreak;", "default:", "\t"}),
		i(4, "break;"), t({"", "}"}),
	}),
}
