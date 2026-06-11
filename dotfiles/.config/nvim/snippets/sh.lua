local ls = require("luasnip")
local s = ls.snippet
local t = ls.text_node
local i = ls.insert_node

return {
	s({trig = ";shebang", name = "Bash shebang",
		desc = {"```bash", "#!/usr/bin/env bash", "set -euo pipefail", "```"}}, {
		t({"#!/usr/bin/env bash", "set -euo pipefail", ""}),
	}),
	s({trig = ";fn", name = "Function",
		desc = {"```bash", "name() {", "  ", "}", "```"}}, {
		i(1, "name"), t({"() {", "\t"}), i(2, ""), t({"", "}"}),
	}),
	s({trig = ";if", name = "if statement",
		desc = {"```bash", "if [[ condition ]]; then", "  ", "fi", "```"}}, {
		t("if [[ "), i(1, "condition"), t({" ]]; then", "\t"}), i(2, ""),
		t({"", "fi"}),
	}),
	s({trig = ";ife", name = "if/else",
		desc = {"```bash", "if [[ condition ]]; then", "  ", "else", "  ", "fi", "```"}}, {
		t("if [[ "), i(1, "condition"), t({" ]]; then", "\t"}), i(2, ""),
		t({"", "else", "\t"}), i(3, ""), t({"", "fi"}),
	}),
	s({trig = ";for", name = "for loop",
		desc = {"```bash", "for item in ${array[@]}; do", "  ", "done", "```"}}, {
		t("for "), i(1, "item"), t(" in "), i(2, "${array[@]}"), t({"; do", "\t"}),
		i(3, ""), t({"", "done"}),
	}),
	s({trig = ";while", name = "while loop",
		desc = {"```bash", "while true; do", "  ", "done", "```"}}, {
		t("while "), i(1, "true"), t({"; do", "\t"}), i(2, ""), t({"", "done"}),
	}),
	s({trig = ";case", name = "case statement",
		desc = {"```bash", 'case "$var" in', "  pattern)", "    ;;", "  *)", "    ;;", "esac", "```"}}, {
		t('case "'), i(1, "$var"), t({'\" in', "\t"}), i(2, "pattern"),
		t({")", "\t\t"}), i(3, ";;"), t({"", "\t*)", "\t\t"}), i(4, ";;"),
		t({"", "esac"}),
	}),
	s({trig = ";log", name = "log function",
		desc = {"```bash", "log() {", "  echo \"[$(date '+%Y-%m-%d %H:%M:%S')] $*\"", "}", "```"}}, {
		t({"log() {", "\techo \"[$(date '+%Y-%m-%d %H:%M:%S')] $*\"", "}"}),
	}),
	s({trig = ";die", name = "die function",
		desc = {"```bash", "die() {", "  echo \"ERROR: $*\" >&2", "  exit 1", "}", "```"}}, {
		t({"die() {", "\techo \"ERROR: $*\" >&2", "\texit 1", "}"}),
	}),
	s({trig = ";check", name = "check command exists",
		desc = {"```bash", 'command -v cmd &>/dev/null || die "cmd is not installed"', "```"}}, {
		t("command -v "), i(1, "cmd"), t(' &>/dev/null || die "'),
		i(2, "cmd"), t(' is not installed"'),
	}),
	s({trig = ";args", name = "Positional args check",
		desc = {"```bash", "if [[ $# -lt 1 ]]; then", "  echo \"Usage: $0 <arg>\" >&2", "  exit 1", "fi", "```"}}, {
		t("if [[ $# -lt "), i(1, "1"), t({" ]]; then", "\techo \"Usage: $0 "}),
		i(2, "<arg>"), t({"\" >&2", "\texit 1", "fi"}),
	}),
	s({trig = ";trap", name = "trap on EXIT",
		desc = {"```bash", "cleanup() {", "  ", "}", "trap cleanup EXIT", "```"}}, {
		t({"cleanup() {", "\t"}), i(1, ""), t({"", "}", "trap cleanup EXIT"}),
	}),
	s({trig = ";tmpdir", name = "Create temp dir with cleanup",
		desc = {"```bash", 'TMPDIR=$(mktemp -d)', 'trap \'rm -rf "$TMPDIR"\' EXIT', "```"}}, {
		t({'TMPDIR=$(mktemp -d)', "trap 'rm -rf \"$TMPDIR\"' EXIT"}),
	}),
	s({trig = ";readonly", name = "Declare readonly variable",
		desc = {"```bash", 'readonly VAR="value"', "```"}}, {
		t("readonly "), i(1, "VAR"), t('="'), i(2, "value"), t('"'),
	}),
}
