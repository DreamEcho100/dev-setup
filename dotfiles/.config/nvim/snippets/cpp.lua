-- 📖 Tutorial: docs/neovim-tutorials-from-0-to-hero/18-cpp-development.md
-- C++-specific snippets (C snippets are also available via filetype_extend in luasnip.lua)
local ls = require("luasnip")
local s = ls.snippet
local t = ls.text_node
local i = ls.insert_node
local f = ls.function_node

local function mirror(index)
    return f(function(args) return args[1][1] end, { index })
end

return {
    -- ── Classes ────────────────────────────────────────────────────────────────
    s({trig = ";class", name = "Class definition",
        desc = {"```cpp", "class Name {", "public:", "    Name();", "    ~Name();", "private:", "    ", "};", "```"}}, {
        t("class "), i(1, "Name"), t({" {", "public:", "\t"}),
        mirror(1), t("();"), t({"", "\t~"}), mirror(1), t("();"),
        t({"", "private:", "\t"}), i(2, ""),
        t({"", "};"}),
    }),
    s({trig = ";classt", name = "Template class",
        desc = {"```cpp", "template <typename T>", "class Name {", "public:", "    ", "};", "```"}}, {
        t({"template <typename "}), i(1, "T"), t({">", "class "}), i(2, "Name"),
        t({" {", "public:", "\t"}), i(3, ""),
        t({"", "};"}),
    }),
    s({trig = ";ctor", name = "Constructor",
        desc = {"```cpp", "Name::Name(args) : member(value) {", "  ", "}", "```"}}, {
        i(1, "Name"), t("::"), mirror(1), t("("), i(2, ""), t(") : "),
        i(3, "member_(value)"), t({" {", "\t"}), i(4, ""), t({"", "}"}),
    }),
    s({trig = ";dtor", name = "Destructor",
        desc = {"```cpp", "Name::~Name() {", "  ", "}", "```"}}, {
        i(1, "Name"), t("::~"), mirror(1), t({" {", "\t"}),
        i(2, ""), t({"", "}"}),
    }),
    s({trig = ";copy", name = "Copy constructor + assignment",
        desc = {"```cpp", "Name(const Name& other);", "Name& operator=(const Name& other);", "```"}}, {
        i(1, "Name"), t("(const "), mirror(1), t({" &other);", ""}),
        mirror(1), t(" &operator=(const "), mirror(1), t(" &other);"),
    }),
    s({trig = ";move", name = "Move constructor + assignment",
        desc = {"```cpp", "Name(Name&& other) noexcept;", "Name& operator=(Name&& other) noexcept;", "```"}}, {
        i(1, "Name"), t("("), mirror(1), t({" &&other) noexcept;", ""}),
        mirror(1), t(" &operator=("), mirror(1), t(" &&other) noexcept;"),
    }),
    s({trig = ";rule5", name = "Rule of 5 declarations",
        desc = {"```cpp", "Name(const Name&);", "Name& operator=(const Name&);", "Name(Name&&) noexcept;", "Name& operator=(Name&&) noexcept;", "~Name();", "```"}}, {
        i(1, "Name"), t("(const "), mirror(1), t({" &);", ""}),
        mirror(1), t(" &operator=(const "), mirror(1), t({" &);", ""}),
        mirror(1), t("("), mirror(1), t({" &&) noexcept;", ""}),
        mirror(1), t(" &operator=("), mirror(1), t({" &&) noexcept;", ""}),
        t("~"), mirror(1), t("();"),
    }),

    -- ── Inheritance ────────────────────────────────────────────────────────────
    s({trig = ";inherit", name = "Class with inheritance",
        desc = {"```cpp", "class Child : public Base {", "public:", "    Child();", "};", "```"}}, {
        t("class "), i(1, "Child"), t(" : public "), i(2, "Base"),
        t({" {", "public:", "\t"}), mirror(1), t("();"),
        t({"", "};"}),
    }),
    s({trig = ";virtual", name = "Virtual method",
        desc = {"```cpp", "virtual ReturnType method(args);", "```"}}, {
        t("virtual "), i(1, "void"), t(" "), i(2, "method"), t("("), i(3, ""), t(");"),
    }),
    s({trig = ";override", name = "Override method",
        desc = {"```cpp", "ReturnType method(args) override;", "```"}}, {
        i(1, "void"), t(" "), i(2, "method"), t("("), i(3, ""), t(") override;"),
    }),
    s({trig = ";pure", name = "Pure virtual method",
        desc = {"```cpp", "virtual ReturnType method(args) = 0;", "```"}}, {
        t("virtual "), i(1, "void"), t(" "), i(2, "method"), t("("), i(3, ""), t(") = 0;"),
    }),

    -- ── Templates ──────────────────────────────────────────────────────────────
    s({trig = ";tmpl", name = "Template function",
        desc = {"```cpp", "template <typename T>", "ReturnType name(T arg) {", "  ", "}", "```"}}, {
        t({"template <typename "}), i(1, "T"), t({">", ""}),
        i(2, "void"), t(" "), i(3, "name"), t("("), mirror(1), t(" "), i(4, "arg"),
        t({") {", "\t"}), i(5, ""), t({"", "}"}),
    }),
    s({trig = ";tmplspec", name = "Template specialization",
        desc = {"```cpp", "template <>", "ReturnType name<SpecialType>(args) {", "  ", "}", "```"}}, {
        t({"template <>", ""}),
        i(1, "void"), t(" "), i(2, "name"), t("<"), i(3, "SpecialType"), t(">("),
        i(4, ""), t({") {", "\t"}), i(5, ""), t({"", "}"}),
    }),
    s({trig = ";concept", name = "C++20 concept",
        desc = {"```cpp", "template <typename T>", "concept Name = requires(T t) {", "    { t.method() } -> std::convertible_to<ReturnType>;", "};", "```"}}, {
        t({"template <typename "}), i(1, "T"), t({">", "concept "}),
        i(2, "Name"), t({" = requires("}), mirror(1), t({" t) {", "\t"}),
        i(3, "{ t.method() } -> std::convertible_to<int>"),
        t({"", "};"}),
    }),

    -- ── STL Containers ─────────────────────────────────────────────────────────
    s({trig = ";vec", name = "std::vector",
        desc = {"```cpp", "std::vector<Type> name;", "```"}}, {
        t("std::vector<"), i(1, "int"), t("> "), i(2, "v"), t(";"),
    }),
    s({trig = ";map", name = "std::map",
        desc = {"```cpp", "std::map<Key, Value> name;", "```"}}, {
        t("std::map<"), i(1, "std::string"), t(", "), i(2, "int"), t("> "), i(3, "m"), t(";"),
    }),
    s({trig = ";umap", name = "std::unordered_map",
        desc = {"```cpp", "std::unordered_map<Key, Value> name;", "```"}}, {
        t("std::unordered_map<"), i(1, "std::string"), t(", "), i(2, "int"), t("> "), i(3, "m"), t(";"),
    }),
    s({trig = ";set", name = "std::set",
        desc = {"```cpp", "std::set<Type> name;", "```"}}, {
        t("std::set<"), i(1, "int"), t("> "), i(2, "s"), t(";"),
    }),
    s({trig = ";arr", name = "std::array",
        desc = {"```cpp", "std::array<Type, N> name;", "```"}}, {
        t("std::array<"), i(1, "int"), t(", "), i(2, "10"), t("> "), i(3, "arr"), t("{};"),
    }),
    s({trig = ";pair", name = "std::pair",
        desc = {"```cpp", "std::pair<T1, T2> name = {a, b};", "```"}}, {
        t("std::pair<"), i(1, "int"), t(", "), i(2, "int"), t("> "), i(3, "p"), t(" = {"), i(4, ""), t("};"),
    }),
    s({trig = ";opt", name = "std::optional",
        desc = {"```cpp", "std::optional<Type> name;", "```"}}, {
        t("std::optional<"), i(1, "int"), t("> "), i(2, "opt"), t(";"),
    }),
    s({trig = ";var", name = "std::variant",
        desc = {"```cpp", "std::variant<T1, T2> name;", "```"}}, {
        t("std::variant<"), i(1, "int"), t(", "), i(2, "std::string"), t("> "), i(3, "v"), t(";"),
    }),

    -- ── Smart Pointers ─────────────────────────────────────────────────────────
    s({trig = ";uptr", name = "unique_ptr declaration",
        desc = {"```cpp", "std::unique_ptr<Type> name;", "```"}}, {
        t("std::unique_ptr<"), i(1, "Type"), t("> "), i(2, "ptr"), t(";"),
    }),
    s({trig = ";sptr", name = "shared_ptr declaration",
        desc = {"```cpp", "std::shared_ptr<Type> name;", "```"}}, {
        t("std::shared_ptr<"), i(1, "Type"), t("> "), i(2, "ptr"), t(";"),
    }),
    s({trig = ";mkun", name = "make_unique",
        desc = {"```cpp", "auto name = std::make_unique<Type>(args);", "```"}}, {
        t("auto "), i(1, "ptr"), t(" = std::make_unique<"), i(2, "Type"), t(">("), i(3, ""), t(");"),
    }),
    s({trig = ";mksh", name = "make_shared",
        desc = {"```cpp", "auto name = std::make_shared<Type>(args);", "```"}}, {
        t("auto "), i(1, "ptr"), t(" = std::make_shared<"), i(2, "Type"), t(">("), i(3, ""), t(");"),
    }),

    -- ── Lambdas ────────────────────────────────────────────────────────────────
    s({trig = ";lam", name = "Lambda expression",
        desc = {"```cpp", "[](args) { body }", "```"}}, {
        t("[]("), i(1, ""), t({") {", "\t"}), i(2, ""), t({"", "}"}),
    }),
    s({trig = ";lamc", name = "Lambda capture by value",
        desc = {"```cpp", "[=](args) { body }", "```"}}, {
        t("[=]("), i(1, ""), t({") {", "\t"}), i(2, ""), t({"", "}"}),
    }),
    s({trig = ";lamr", name = "Lambda capture by reference",
        desc = {"```cpp", "[&](args) { body }", "```"}}, {
        t("[&]("), i(1, ""), t({") {", "\t"}), i(2, ""), t({"", "}"}),
    }),
    s({trig = ";lamat", name = "Lambda with auto param (C++14+)",
        desc = {"```cpp", "[](auto arg) { return arg; }", "```"}}, {
        t("[](auto "), i(1, "arg"), t({") {", "\t return "}), mirror(1), t({"", "}"}),
    }),

    -- ── Range-for ──────────────────────────────────────────────────────────────
    s({trig = ";fore", name = "Range-based for (auto&)",
        desc = {"```cpp", "for (auto& elem : container) {", "  ", "}", "```"}}, {
        t("for (auto& "), i(1, "elem"), t(" : "), i(2, "container"),
        t({") {", "\t"}), i(3, ""), t({"", "}"}),
    }),
    s({trig = ";forc", name = "Range-based for (const auto&)",
        desc = {"```cpp", "for (const auto& elem : container) {", "  ", "}", "```"}}, {
        t("for (const auto& "), i(1, "elem"), t(" : "), i(2, "container"),
        t({") {", "\t"}), i(3, ""), t({"", "}"}),
    }),

    -- ── Exceptions ─────────────────────────────────────────────────────────────
    s({trig = ";try", name = "try/catch block",
        desc = {"```cpp", "try {", "  ", "} catch (const std::exception& e) {", "  std::cerr << e.what();", "}", "```"}}, {
        t({"try {", "\t"}), i(1, ""),
        t({"", "} catch (const "}), i(2, "std::exception"), t(" &"), i(3, "e"),
        t({") {", "\tstd::cerr << "}), mirror(3), t({".what() << '\\n';", "}"}),
    }),
    s({trig = ";throw", name = "throw exception",
        desc = {"```cpp", "throw std::runtime_error(\"message\");", "```"}}, {
        t("throw "), i(1, "std::runtime_error"), t("("), i(2, '"message"'), t(");"),
    }),
    s({trig = ";excl", name = "Custom exception class",
        desc = {"```cpp", "class MyError : public std::runtime_error {", "public:", "  explicit MyError(const std::string& msg) : std::runtime_error(msg) {}", "};", "```"}}, {
        t("class "), i(1, "MyError"), t(" : public "), i(2, "std::runtime_error"),
        t({" {", "public:", "\texplicit "}), mirror(1),
        t("(const std::string &msg) : "), mirror(2), t({"(msg) {}", "};"}),
    }),

    -- ── Namespace ──────────────────────────────────────────────────────────────
    s({trig = ";ns", name = "Namespace block",
        desc = {"```cpp", "namespace name {", "", "} // namespace name", "```"}}, {
        t("namespace "), i(1, "name"), t({" {", "", "} // namespace "}), mirror(1),
    }),
    s({trig = ";nsi", name = "Inline namespace",
        desc = {"```cpp", "inline namespace v1 {", "", "}", "```"}}, {
        t("inline namespace "), i(1, "v1"), t({" {", "", "}"}),
    }),
    s({trig = ";using", name = "Type alias",
        desc = {"```cpp", "using Alias = Type;", "```"}}, {
        t("using "), i(1, "Alias"), t(" = "), i(2, "Type"), t(";"),
    }),

    -- ── Modern C++ ─────────────────────────────────────────────────────────────
    s({trig = ";sb", name = "Structured binding (C++17)",
        desc = {"```cpp", "auto [a, b] = pair;", "```"}}, {
        t("auto ["), i(1, "a"), t(", "), i(2, "b"), t("] = "), i(3, "pair"), t(";"),
    }),
    s({trig = ";ifcx", name = "if constexpr (C++17)",
        desc = {"```cpp", "if constexpr (condition) {", "  ", "}", "```"}}, {
        t("if constexpr ("), i(1, "condition"), t({") {", "\t"}),
        i(2, ""), t({"", "}"}),
    }),
    s({trig = ";noex", name = "noexcept specifier",
        desc = {"```cpp", "void method() noexcept {", "  ", "}", "```"}}, {
        i(1, "void"), t(" "), i(2, "method"), t("("), i(3, ""), t({") noexcept {", "\t"}),
        i(4, ""), t({"", "}"}),
    }),

    -- ── I/O ────────────────────────────────────────────────────────────────────
    s({trig = ";cout", name = "std::cout",
        desc = {"```cpp", 'std::cout << value << "\\n";', "```"}}, {
        t("std::cout << "), i(1, ""), t([[ << "\n";]]),
    }),
    s({trig = ";cerr", name = "std::cerr",
        desc = {"```cpp", 'std::cerr << "error: " << msg << "\\n";', "```"}}, {
        t([[std::cerr << "error: " << ]]), i(1, "msg"), t([[ << "\n";]]),
    }),
    s({trig = ";cin", name = "std::cin",
        desc = {"```cpp", "std::cin >> variable;", "```"}}, {
        t("std::cin >> "), i(1, "var"), t(";"),
    }),

    -- ── Testing ────────────────────────────────────────────────────────────────
    s({trig = ";gtest", name = "Google Test TEST()",
        desc = {"```cpp", "TEST(SuiteName, TestName) {", "  EXPECT_EQ(left, right);", "}", "```"}}, {
        t("TEST("), i(1, "SuiteName"), t(", "), i(2, "TestName"),
        t({") {", "\tEXPECT_EQ("}), i(3, "left"), t(", "), i(4, "right"), t(");"),
        t({"", "}"}),
    }),
    s({trig = ";gtest_f", name = "Google Test TEST_F() with fixture",
        desc = {"```cpp", "TEST_F(FixtureName, TestName) {", "  EXPECT_EQ(left, right);", "}", "```"}}, {
        t("TEST_F("), i(1, "FixtureName"), t(", "), i(2, "TestName"),
        t({") {", "\tEXPECT_EQ("}), i(3, "left"), t(", "), i(4, "right"), t(");"),
        t({"", "}"}),
    }),
    s({trig = ";assert", name = "ASSERT_EQ",
        desc = {"```cpp", "ASSERT_EQ(left, right);", "```"}}, {
        t("ASSERT_EQ("), i(1, "left"), t(", "), i(2, "right"), t(");"),
    }),
    s({trig = ";expect", name = "EXPECT_EQ",
        desc = {"```cpp", "EXPECT_EQ(left, right);", "```"}}, {
        t("EXPECT_EQ("), i(1, "left"), t(", "), i(2, "right"), t(");"),
    }),
}
