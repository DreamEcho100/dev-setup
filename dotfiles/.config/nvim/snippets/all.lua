-- 📖 Tutorial: docs/neovim-tutorials-from-0-to-hero/07-lsp-and-completions.md
local ls = require("luasnip")
local s = ls.snippet
local t = ls.text_node
local i = ls.insert_node

return {
	s({trig = ";todo", name = "TODO comment",
		desc = {"```", "TODO: description", "```"}}, {
		t("TODO: "), i(1, "description"),
	}),
	s({trig = ";fixme", name = "FIXME comment",
		desc = {"```", "FIXME: description", "```"}}, {
		t("FIXME: "), i(1, "description"),
	}),
	s({trig = ";note", name = "NOTE comment",
		desc = {"```", "NOTE: description", "```"}}, {
		t("NOTE: "), i(1, "description"),
	}),
	s({trig = ";hack", name = "HACK comment",
		desc = {"```", "HACK: description", "```"}}, {
		t("HACK: "), i(1, "description"),
	}),
	s({trig = ";bug", name = "BUG comment",
		desc = {"```", "BUG: description", "```"}}, {
		t("BUG: "), i(1, "description"),
	}),
	s({trig = ";perf", name = "PERF comment",
		desc = {"```", "PERF: description", "```"}}, {
		t("PERF: "), i(1, "description"),
	}),
	s({trig = ";warn", name = "WARNING comment",
		desc = {"```", "WARNING: description", "```"}}, {
		t("WARNING: "), i(1, "description"),
	}),
}
