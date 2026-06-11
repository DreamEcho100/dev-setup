local ls = require("luasnip")
local s = ls.snippet
local t = ls.text_node
local i = ls.insert_node

return {
	-- ── Functions ──────────────────────────────────────────────────────────
	s({trig = ";fn", name = "Function",
		desc = {"```rust", "fn name(args) -> () {", "  ", "}", "```"}}, {
		t("fn "), i(1, "name"), t("("), i(2, ""), t(") -> "), i(3, "()"),
		t({" {", "\t"}), i(4, ""), t({"", "}"}),
	}),
	s({trig = ";pfn", name = "pub fn",
		desc = {"```rust", "pub fn name(args) -> () {", "  ", "}", "```"}}, {
		t("pub fn "), i(1, "name"), t("("), i(2, ""), t(") -> "), i(3, "()"),
		t({" {", "\t"}), i(4, ""), t({"", "}"}),
	}),
	s({trig = ";afn", name = "async fn",
		desc = {"```rust", "async fn name(args) -> () {", "  ", "}", "```"}}, {
		t("async fn "), i(1, "name"), t("("), i(2, ""), t(") -> "), i(3, "()"),
		t({" {", "\t"}), i(4, ""), t({"", "}"}),
	}),
	s({trig = ";main", name = "main function",
		desc = {"```rust", "fn main() {", "  ", "}", "```"}}, {
		t({"fn main() {", "\t"}), i(1, ""), t({"", "}"}),
	}),

	-- ── Types ──────────────────────────────────────────────────────────────
	s({trig = ";struct", name = "Struct",
		desc = {"```rust", "struct Name {", "  field: Type,", "}", "```"}}, {
		t("struct "), i(1, "Name"), t({" {", "\t"}), i(2, "field: Type"),
		t({"", "}"}),
	}),
	s({trig = ";pstruct", name = "pub struct",
		desc = {"```rust", "#[derive(Debug)]", "pub struct Name {", "  pub field: Type,", "}", "```"}}, {
		t({"#[derive(Debug)]", "pub struct "}), i(1, "Name"), t({" {", "\tpub "}),
		i(2, "field"), t(": "), i(3, "Type"), t({"", "}"}),
	}),
	s({trig = ";enum", name = "Enum",
		desc = {"```rust", "enum Name {", "  Variant,", "}", "```"}}, {
		t("enum "), i(1, "Name"), t({" {", "\t"}),
		i(2, "Variant"), t({"", "}"}),
	}),
	s({trig = ";penum", name = "pub enum",
		desc = {"```rust", "#[derive(Debug)]", "pub enum Name {", "  Variant,", "}", "```"}}, {
		t({"#[derive(Debug)]", "pub enum "}), i(1, "Name"), t({" {", "\t"}),
		i(2, "Variant"), t({"", "}"}),
	}),
	s({trig = ";impl", name = "impl block",
		desc = {"```rust", "impl Type {", "  ", "}", "```"}}, {
		t("impl "), i(1, "Type"), t({" {", "\t"}), i(2, ""),
		t({"", "}"}),
	}),
	s({trig = ";trait", name = "Trait",
		desc = {"```rust", "trait Name {", "  fn method(&self);", "}", "```"}}, {
		t("trait "), i(1, "Name"), t({" {", "\t"}), i(2, "fn method(&self);"),
		t({"", "}"}),
	}),
	s({trig = ";implfor", name = "impl Trait for Type",
		desc = {"```rust", "impl Trait for Type {", "  ", "}", "```"}}, {
		t("impl "), i(1, "Trait"), t(" for "), i(2, "Type"), t({" {", "\t"}),
		i(3, ""), t({"", "}"}),
	}),

	-- ── Error handling ─────────────────────────────────────────────────────
	s({trig = ";res", name = "Result return type",
		desc = {"```rust", "Result<T, Box<dyn std::error::Error>>", "```"}}, {
		t("Result<"), i(1, "T"), t(", "), i(2, "Box<dyn std::error::Error>"), t(">"),
	}),
	s({trig = ";opt", name = "Option return type",
		desc = {"```rust", "Option<T>", "```"}}, {
		t("Option<"), i(1, "T"), t(">"),
	}),
	s({trig = ";qm", name = "? operator",
		desc = {"```rust", "expr?", "```"}}, {
		i(1, "expr"), t("?"),
	}),
	s({trig = ";ok", name = "Ok(...)",
		desc = {"```rust", "Ok(value)", "```"}}, {
		t("Ok("), i(1, ""), t(")"),
	}),
	s({trig = ";err", name = "Err(...)",
		desc = {"```rust", "Err(error)", "```"}}, {
		t("Err("), i(1, ""), t(")"),
	}),
	s({trig = ";some", name = "Some(...)",
		desc = {"```rust", "Some(value)", "```"}}, {
		t("Some("), i(1, ""), t(")"),
	}),
	s({trig = ";match", name = "match expression",
		desc = {"```rust", "match value {", "  pattern => ,", "  _ => unimplemented!(),", "}", "```"}}, {
		t("match "), i(1, "value"), t({" {", "\t"}), i(2, "pattern"),
		t(" => "), i(3, ""), t({",", "\t_ => "}), i(4, "unimplemented!()"),
		t({"", "}"}),
	}),
	s({trig = ";iflet", name = "if let",
		desc = {"```rust", "if let Some(val) = option {", "  ", "}", "```"}}, {
		t("if let "), i(1, "Some(val)"), t(" = "), i(2, "option"),
		t({" {", "\t"}), i(3, ""), t({"", "}"}),
	}),
	s({trig = ";wlet", name = "while let",
		desc = {"```rust", "while let Some(val) = iter.next() {", "  ", "}", "```"}}, {
		t("while let "), i(1, "Some(val)"), t(" = "), i(2, "iter.next()"),
		t({" {", "\t"}), i(3, ""), t({"", "}"}),
	}),

	-- ── Macros ─────────────────────────────────────────────────────────────
	s({trig = ";pl", name = "println!",
		desc = {"```rust", 'println!("{}", value)', "```"}}, {
		t('println!("'), i(1, "{}"), t('", '), i(2, ""), t(")"),
	}),
	s({trig = ";ep", name = "eprintln!",
		desc = {"```rust", 'eprintln!("{}", value)', "```"}}, {
		t('eprintln!("'), i(1, "{}"), t('", '), i(2, ""), t(")"),
	}),
	s({trig = ";dbg", name = "dbg!",
		desc = {"```rust", "dbg!(value)", "```"}}, {
		t("dbg!("), i(1, ""), t(")"),
	}),
	s({trig = ";vec", name = "vec!",
		desc = {"```rust", "vec![item1, item2]", "```"}}, {
		t("vec!["), i(1, ""), t("]"),
	}),

	-- ── Derive ─────────────────────────────────────────────────────────────
	s({trig = ";derive", name = "#[derive]",
		desc = {"```rust", "#[derive(Debug, Clone, PartialEq)]", "```"}}, {
		t("#[derive("), i(1, "Debug, Clone, PartialEq"), t(")]"),
	}),

	-- ── Testing ────────────────────────────────────────────────────────────
	s({trig = ";test", name = "Test function",
		desc = {"```rust", "#[test]", "fn test_name() {", "  ", "}", "```"}}, {
		t({"#[test]", "fn test_"}), i(1, "name"), t({"() {", "\t"}), i(2, ""),
		t({"", "}"}),
	}),
	s({trig = ";testmod", name = "Test module",
		desc = {"```rust", "#[cfg(test)]", "mod tests {", "  use super::*;", "", "  #[test]", "  fn test_name() {", "    ", "  }", "}", "```"}}, {
		t({"#[cfg(test)]", "mod tests {", "\tuse super::*;", "", "\t#[test]", "\tfn test_"}),
		i(1, "name"), t({"() {", "\t\t"}), i(2, ""), t({"", "\t}", "}"}),
	}),
	s({trig = ";assert", name = "assert_eq!",
		desc = {"```rust", "assert_eq!(left, right)", "```"}}, {
		t("assert_eq!("), i(1, "left"), t(", "), i(2, "right"), t(")"),
	}),

	-- ── Async ──────────────────────────────────────────────────────────────
	s({trig = ";spawn", name = "tokio::spawn",
		desc = {"```rust", "tokio::spawn(async move {", "  ", "})", "```"}}, {
		t({"tokio::spawn(async move {", "\t"}), i(1, ""), t({"", "})"}),
	}),
	s({trig = ";amain", name = "#[tokio::main] async main",
		desc = {"```rust", "#[tokio::main]", "async fn main() -> Result<(), Box<dyn std::error::Error>> {", "  ", "  Ok(())", "}", "```"}}, {
		t({"#[tokio::main]", "async fn main() -> Result<(), Box<dyn std::error::Error>> {", "\t"}),
		i(1, ""), t({"", "\tOk(())", "}"}),
	}),
}
