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
	-- ── Functions ──────────────────────────────────────────────────────────
	s({trig = ";fn", name = "Function",
		desc = {"```go", "func name(args) returnType {", "  ", "}", "```"}}, {
		t("func "), i(1, "name"), t("("), i(2, ""), t(") "), i(3, ""), t({" {", "\t"}),
		i(4, ""), t({"", "}"}),
	}),
	s({trig = ";mfn", name = "Method",
		desc = {"```go", "func (r *Receiver) Name(args) returnType {", "  ", "}", "```"}}, {
		t("func ("), i(1, "r"), t(" *"), i(2, "Receiver"), t(") "), i(3, "Name"),
		t("("), i(4, ""), t(") "), i(5, ""), t({" {", "\t"}),
		i(6, ""), t({"", "}"}),
	}),
	s({trig = ";main", name = "main function",
		desc = {"```go", "func main() {", "  ", "}", "```"}}, {
		t({"func main() {", "\t"}), i(1, ""), t({"", "}"}),
	}),

	-- ── Error handling ─────────────────────────────────────────────────────
	s({trig = ";ife", name = "if err != nil",
		desc = {"```go", "if err != nil {", "  return err", "}", "```"}}, {
		t({"if err != nil {", "\treturn "}), i(1, "err"),
		t({"", "}"}),
	}),
	s({trig = ";ifew", name = "if err != nil with wrap",
		desc = {"```go", "if err != nil {", [[  return fmt.Errorf("operation: %w", err)]], "}", "```"}}, {
		t({"if err != nil {", "\treturn fmt.Errorf(\""}),
		i(1, "operation"), t(": %w\", err)"), t({"", "}"}),
	}),
	s({trig = ";ifen", name = "err := call; if err != nil",
		desc = {"```go", "if err := call; err != nil {", "  return err", "}", "```"}}, {
		t("if err := "), i(1, "call"), t({"; err != nil {", "\treturn "}),
		i(2, "err"), t({"", "}"}),
	}),
	s({trig = ";errorf", name = "fmt.Errorf with wrap",
		desc = {"```go", [[fmt.Errorf("message: %w", err)]], "```"}}, {
		t("fmt.Errorf(\""), i(1, "message"), t(": %w\", "), i(2, "err"), t(")"),
	}),
	s({trig = ";errors", name = "errors.New",
		desc = {"```go", [[errors.New("message")]], "```"}}, {
		t("errors.New(\""), i(1, "message"), t("\")"),
	}),

	-- ── Types ──────────────────────────────────────────────────────────────
	s({trig = ";struct", name = "Struct",
		desc = {"```go", "type Name struct {", "  Field Type", "}", "```"}}, {
		t("type "), i(1, "Name"), t({" struct {", "\t"}), i(2, "Field Type"),
		t({"", "}"}),
	}),
	s({trig = ";iface", name = "Interface",
		desc = {"```go", "type Name interface {", "  Method() Type", "}", "```"}}, {
		t("type "), i(1, "Name"), t({" interface {", "\t"}), i(2, "Method() Type"),
		t({"", "}"}),
	}),
	s({trig = ";impl", name = "Implement interface (method)",
		desc = {"```go", "func (r *Type) Method(args) returnType {", "  ", "}", "```"}}, {
		t("func ("), i(1, "r"), t(" *"), i(2, "Type"), t(") "), i(3, "Method"),
		t("("), i(4, ""), t(") "), i(5, ""), t({" {", "\t"}),
		i(6, ""), t({"", "}"}),
	}),

	-- ── Testing ────────────────────────────────────────────────────────────
	s({trig = ";test", name = "Test function",
		desc = {"```go", "func TestName(t *testing.T) {", "  ", "}", "```"}}, {
		t("func Test"), i(1, "Name"), t({"(t *testing.T) {", "\t"}),
		i(2, ""), t({"", "}"}),
	}),
	s({trig = ";bench", name = "Benchmark function",
		desc = {"```go", "func BenchmarkName(b *testing.B) {", "  for range b.N {", "    ", "  }", "}", "```"}}, {
		t("func Benchmark"), i(1, "Name"), t({"(b *testing.B) {", "\tfor range b.N {", "\t\t"}),
		i(2, ""), t({"", "\t}", "}"}),
	}),
	s({trig = ";trun", name = "t.Run subtest",
		desc = {"```go", 't.Run("name", func(t *testing.T) {', "  ", "})", "```"}}, {
		t("t.Run(\""), i(1, "name"), t({"\", func(t *testing.T) {", "\t"}),
		i(2, ""), t({"", "})"}),
	}),

	-- ── Concurrency ────────────────────────────────────────────────────────
	s({trig = ";go", name = "goroutine",
		desc = {"```go", "go func() {", "  ", "}()", "```"}}, {
		t({"go func() {", "\t"}), i(1, ""), t({"", "}()"}),
	}),
	s({trig = ";ch", name = "channel declaration",
		desc = {"```go", "ch := make(chan Type, 0)", "```"}}, {
		t("ch := make(chan "), i(1, "Type"), t(", "), i(2, "0"), t(")"),
	}),
	s({trig = ";select", name = "select statement",
		desc = {"```go", "select {", "case v := <-ch:", "  ", "case <-ctx.Done():", "  return ctx.Err()", "}", "```"}}, {
		t({"select {", "case "}), i(1, "v := <-ch"), t({":", "\t"}), i(2, ""),
		t({"", "case <-ctx.Done():", "\treturn ctx.Err()", "}"}),
	}),
	s({trig = ";wg", name = "WaitGroup",
		desc = {"```go", "var wg sync.WaitGroup", "wg.Add(1)", "go func() {", "  defer wg.Done()", "  ", "}()", "wg.Wait()", "```"}}, {
		t({"var wg sync.WaitGroup", "wg.Add("}), i(1, "1"),
		t({")", "go func() {", "\tdefer wg.Done()", "\t"}),
		i(2, ""), t({"", "}()", "wg.Wait()"}),
	}),

	-- ── I/O & formatting ───────────────────────────────────────────────────
	s({trig = ";fmtp", name = "fmt.Printf",
		desc = {"```go", [[fmt.Printf("%v\n", value)]], "```"}}, {
		t("fmt.Printf(\""), i(1, "%v\\n"), t("\", "), i(2, "value"), t(")"),
	}),
	s({trig = ";fmtpl", name = "fmt.Println",
		desc = {"```go", "fmt.Println(value)", "```"}}, {
		t("fmt.Println("), i(1, ""), t(")"),
	}),
	s({trig = ";fmts", name = "fmt.Sprintf",
		desc = {"```go", [[fmt.Sprintf("format", args)]], "```"}}, {
		t("fmt.Sprintf(\""), i(1, ""), t("\", "), i(2, ""), t(")"),
	}),
	s({trig = ";logf", name = "log.Printf",
		desc = {"```go", [[log.Printf("format", args)]], "```"}}, {
		t("log.Printf(\""), i(1, ""), t("\", "), i(2, ""), t(")"),
	}),

	-- ── HTTP ───────────────────────────────────────────────────────────────
	s({trig = ";handler", name = "HTTP handler func",
		desc = {"```go", "func nameHandler(w http.ResponseWriter, r *http.Request) {", "  ", "}", "```"}}, {
		t("func "), i(1, "name"), t("Handler(w http.ResponseWriter, r *http.Request) {", ""),
		t({"\t"}), i(2, ""), t({"", "}"}),
	}),
	s({trig = ";hroute", name = "http.HandleFunc",
		desc = {"```go", 'http.HandleFunc("/path", handlerFunc)', "```"}}, {
		t("http.HandleFunc(\""), i(1, "/path"), t("\", "), i(2, "handlerFunc"), t(")"),
	}),

	-- ── Misc ───────────────────────────────────────────────────────────────
	s({trig = ";defer", name = "defer statement",
		desc = {"```go", "defer func()", "```"}}, {
		t("defer "), i(1, "func()"),
	}),
	s({trig = ";sw", name = "switch statement",
		desc = {"```go", "switch value {", "case pattern:", "  ", "default:", "  ", "}", "```"}}, {
		t("switch "), i(1, ""), t({" {", "case "}), i(2, "value"), t({":", "\t"}),
		i(3, ""), t({"", "default:", "\t"}), i(4, ""), t({"", "}"}),
	}),
	s({trig = ";ctx", name = "context.WithCancel",
		desc = {"```go", "ctx, cancel := context.WithCancel(context.Background())", "defer cancel()", "```"}}, {
		t({"ctx, cancel := context.WithCancel("}), i(1, "context.Background()"), t({")", "defer cancel()"}),
	}),
	s({trig = ";ctxt", name = "context.WithTimeout",
		desc = {"```go", "ctx, cancel := context.WithTimeout(context.Background(), 5*time.Second)", "defer cancel()", "```"}}, {
		t("ctx, cancel := context.WithTimeout("), i(1, "context.Background()"),
		t(", "), i(2, "5*time.Second"), t({")", "defer cancel()"}),
	}),
}
