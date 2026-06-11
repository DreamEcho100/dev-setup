local ls = require("luasnip")
local s = ls.snippet
local t = ls.text_node
local i = ls.insert_node

return {
	-- ── Functions ──────────────────────────────────────────────────────────
	s({trig = ";fn", name = "Function",
		desc = {"```python", "def name(args) -> None:", "    pass", "```"}}, {
		t("def "), i(1, "name"), t("("), i(2, ""), t({") -> "}), i(3, "None"),
		t({":", "    "}), i(4, "pass"),
	}),
	s({trig = ";afn", name = "Async function",
		desc = {"```python", "async def name(args) -> None:", "    pass", "```"}}, {
		t("async def "), i(1, "name"), t("("), i(2, ""), t({") -> "}), i(3, "None"),
		t({":", "    "}), i(4, "pass"),
	}),
	s({trig = ";main", name = "main guard",
		desc = {"```python", "if __name__ == '__main__':", "    main()", "```"}}, {
		t({"if __name__ == '__main__':", "    "}), i(1, "main()"),
	}),

	-- ── Classes ────────────────────────────────────────────────────────────
	s({trig = ";cls", name = "Class",
		desc = {"```python", "class Name:", "    def __init__(self, args):", "        pass", "```"}}, {
		t("class "), i(1, "Name"), t({":", "    def __init__(self"}),
		t(", "), i(2, ""), t({":", "        "}), i(3, "pass"),
	}),
	s({trig = ";clsi", name = "Class inheriting",
		desc = {"```python", "class Name(Base):", "    def __init__(self, args):", "        super().__init__()", "        ", "```"}}, {
		t("class "), i(1, "Name"), t("("), i(2, "Base"), t({":", "    def __init__(self, "}),
		i(3, ""), t({":", "        super().__init__()", "        "}), i(4, ""),
	}),
	s({trig = ";dc", name = "@dataclass",
		desc = {"```python", "@dataclass", "class Name:", "    field: type", "```"}}, {
		t({"@dataclass", "class "}), i(1, "Name"), t({":", "    "}), i(2, "field: type"),
	}),
	s({trig = ";prop", name = "@property",
		desc = {"```python", "@property", "def name(self):", "    return self._name", "```"}}, {
		t({"@property", "def "}), i(1, "name"), t({"(self):", "    return self._"}),
		i(2, "name"),
	}),

	-- ── Error handling ─────────────────────────────────────────────────────
	s({trig = ";try", name = "try/except",
		desc = {"```python", "try:", "    ", "except Exception as e:", "    raise", "```"}}, {
		t({"try:", "    "}), i(1, ""), t({"", "except "}), i(2, "Exception"),
		t({" as e:", "    "}), i(3, "raise"),
	}),
	s({trig = ";tryf", name = "try/except/finally",
		desc = {"```python", "try:", "    ", "except Exception as e:", "    raise", "finally:", "    ", "```"}}, {
		t({"try:", "    "}), i(1, ""), t({"", "except "}), i(2, "Exception"),
		t({" as e:", "    "}), i(3, "raise"),
		t({"", "finally:", "    "}), i(4, ""),
	}),

	-- ── Context managers ───────────────────────────────────────────────────
	s({trig = ";with", name = "with statement",
		desc = {"```python", "with open('file') as f:", "    ", "```"}}, {
		t("with "), i(1, "open('file')"), t(" as "), i(2, "f"), t({":", "    "}), i(3, ""),
	}),

	-- ── Comprehensions ─────────────────────────────────────────────────────
	s({trig = ";lc", name = "List comprehension",
		desc = {"```python", "[expr for x in iterable]", "```"}}, {
		t("["), i(1, "expr"), t(" for "), i(2, "x"), t(" in "), i(3, "iterable"), t("]"),
	}),
	s({trig = ";dc2", name = "Dict comprehension",
		desc = {"```python", "{k: v for k, v in items.items()}", "```"}}, {
		t("{"), i(1, "k"), t(": "), i(2, "v"), t(" for "), i(3, "k, v"),
		t(" in "), i(4, "items.items()"), t("}"),
	}),
	s({trig = ";gc", name = "Generator expression",
		desc = {"```python", "(expr for x in iterable)", "```"}}, {
		t("("), i(1, "expr"), t(" for "), i(2, "x"), t(" in "), i(3, "iterable"), t(")"),
	}),

	-- ── Async ──────────────────────────────────────────────────────────────
	s({trig = ";afor", name = "async for",
		desc = {"```python", "async for item in aiter:", "    ", "```"}}, {
		t("async for "), i(1, "item"), t(" in "), i(2, "aiter"), t({":", "    "}), i(3, ""),
	}),
	s({trig = ";awith", name = "async with",
		desc = {"```python", "async with ctx as val:", "    ", "```"}}, {
		t("async with "), i(1, "ctx"), t(" as "), i(2, "val"), t({":", "    "}), i(3, ""),
	}),

	-- ── Testing ────────────────────────────────────────────────────────────
	s({trig = ";test", name = "pytest test function",
		desc = {"```python", "def test_name():", "    # Arrange", "    # Act", "    # Assert", "    assert ", "```"}}, {
		t("def test_"), i(1, "name"), t({"():", "    # Arrange", "    "}), i(2, ""),
		t({"", "    # Act", "    "}), i(3, ""),
		t({"", "    # Assert", "    assert "}), i(4, ""),
	}),
	s({trig = ";fix", name = "pytest fixture",
		desc = {"```python", "@pytest.fixture", "def name():", "    yield value", "```"}}, {
		t({"@pytest.fixture", "def "}), i(1, "name"), t({"():", "    "}), i(2, ""),
		t({"", "    yield "}), i(3, "value"),
	}),

	-- ── Type hints ─────────────────────────────────────────────────────────
	s({trig = ";topt", name = "Optional type hint",
		desc = {"```python", "Optional[Type]", "```"}}, {
		t("Optional["), i(1, "Type"), t("]"),
	}),
	s({trig = ";tunion", name = "Union type hint",
		desc = {"```python", "Union[TypeA, TypeB]", "```"}}, {
		t("Union["), i(1, "TypeA"), t(", "), i(2, "TypeB"), t("]"),
	}),
}
