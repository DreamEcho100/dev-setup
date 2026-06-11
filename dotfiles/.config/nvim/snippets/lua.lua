local ls = require("luasnip")
local s = ls.snippet
local t = ls.text_node
local i = ls.insert_node

return {
	-- ── Functions ──────────────────────────────────────────────────────────
	s({trig = ";fn", name = "Local function",
		desc = {"```lua", "local function name(args)", "  ", "end", "```"}}, {
		t("local function "), i(1, "name"), t("("), i(2, ""), t({") ", "\t"}),
		i(3, ""), t({"", "end"}),
	}),
	s({trig = ";fnm", name = "Module method",
		desc = {"```lua", "function M.name(args)", "  ", "end", "```"}}, {
		t("function M."), i(1, "name"), t("("), i(2, ""), t({") ", "\t"}),
		i(3, ""), t({"", "end"}),
	}),

	-- ── Variables ──────────────────────────────────────────────────────────
	s({trig = ";loc", name = "Local variable",
		desc = {"```lua", "local name = value", "```"}}, {
		t("local "), i(1, "name"), t(" = "), i(2, ""),
	}),
	s({trig = ";req", name = "require",
		desc = {"```lua", 'local name = require("module")', "```"}}, {
		t("local "), i(1, "name"), t(' = require("'), i(2, "module"), t('")'),
	}),

	-- ── Module ─────────────────────────────────────────────────────────────
	s({trig = ";mod", name = "Module pattern",
		desc = {"```lua", "local M = {}", "", "-- ...", "", "return M", "```"}}, {
		t({"local M = {}", "", ""}), i(1, ""), t({"", "", "return M"}),
	}),

	-- ── Control flow ───────────────────────────────────────────────────────
	s({trig = ";ife", name = "if/else",
		desc = {"```lua", "if condition then", "  ", "else", "  ", "end", "```"}}, {
		t("if "), i(1, "condition"), t({" then", "\t"}), i(2, ""),
		t({"", "else", "\t"}), i(3, ""), t({"", "end"}),
	}),
	s({trig = ";ifn", name = "if not",
		desc = {"```lua", "if not condition then", "  ", "end", "```"}}, {
		t("if not "), i(1, "condition"), t({" then", "\t"}), i(2, ""), t({"", "end"}),
	}),
	s({trig = ";for", name = "numeric for loop",
		desc = {"```lua", "for i = 1, 10 do", "  ", "end", "```"}}, {
		t("for "), i(1, "i"), t(" = "), i(2, "1"), t(", "), i(3, "10"), t({" do", "\t"}),
		i(4, ""), t({"", "end"}),
	}),
	s({trig = ";fori", name = "ipairs for loop",
		desc = {"```lua", "for i, v in ipairs(table) do", "  ", "end", "```"}}, {
		t("for "), i(1, "i"), t(", "), i(2, "v"), t(" in ipairs("), i(3, "table"),
		t({") do", "\t"}), i(4, ""), t({"", "end"}),
	}),
	s({trig = ";forp", name = "pairs for loop",
		desc = {"```lua", "for k, v in pairs(table) do", "  ", "end", "```"}}, {
		t("for "), i(1, "k"), t(", "), i(2, "v"), t(" in pairs("), i(3, "table"),
		t({") do", "\t"}), i(4, ""), t({"", "end"}),
	}),

	-- ── Neovim specific ────────────────────────────────────────────────────
	s({trig = ";map", name = "vim.keymap.set",
		desc = {"```lua", 'vim.keymap.set("n", "<key>", action, { desc = "desc" })', "```"}}, {
		t('vim.keymap.set("'), i(1, "n"), t('", "'), i(2, ""), t('", '),
		i(3, ""), t(', { desc = "'), i(4, ""), t('" })'),
	}),
	s({trig = ";au", name = "nvim_create_autocmd",
		desc = {"```lua", 'vim.api.nvim_create_autocmd("BufReadPost", {', "  pattern = '*',", "  callback = function()", "    ", "  end,", "})", "```"}}, {
		t('vim.api.nvim_create_autocmd("'), i(1, "BufReadPost"),
		t({'", {', "\tpattern = "}), i(2, '"*"'),
		t({",", "\tcallback = function()", "\t\t"}), i(3, ""),
		t({"", "\tend,", "})"}),
	}),
	s({trig = ";aug", name = "nvim_create_augroup",
		desc = {"```lua", 'local group = vim.api.nvim_create_augroup("GroupName", { clear = true })', "```"}}, {
		t("local "), i(1, "group"), t(' = vim.api.nvim_create_augroup("'),
		i(2, "GroupName"), t('", { clear = true })'),
	}),
	s({trig = ";notify", name = "vim.notify",
		desc = {"```lua", 'vim.notify("message", vim.log.levels.INFO)', "```"}}, {
		t("vim.notify("), i(1, '"message"'), t(", vim.log.levels."), i(2, "INFO"), t(")"),
	}),
	s({trig = ";tbl", name = "vim.tbl_extend",
		desc = {"```lua", 'vim.tbl_extend("force", base, override)', "```"}}, {
		t('vim.tbl_extend("force", '), i(1, "base"), t(", "), i(2, "override"), t(")"),
	}),
	s({trig = ";pcall", name = "pcall",
		desc = {"```lua", "local ok, result = pcall(fn)", "if not ok then", "  return", "end", "```"}}, {
		t("local ok, "), i(1, "result"), t(" = pcall("), i(2, "fn"), t(")"),
		t({"", "if not ok then", "\t"}), i(3, "return"), t({"", "end"}),
	}),
}
