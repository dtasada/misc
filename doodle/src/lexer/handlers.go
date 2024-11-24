package lexer

import (
	"regexp"
)

func defaultHandler(kind TokenKind, value string) handler {
	return func(lex *lexer, regex *regexp.Regexp) {
		lex.pos += len(value)
		lex.Tokens = append(lex.Tokens, NewToken(kind, value))
	}
}

func skipHandler(lex *lexer, regex *regexp.Regexp) {
	match := regex.FindStringIndex(lex.remainder())
	lex.pos += match[1]
}

func commentHandler(lex *lexer, regex *regexp.Regexp) {
	// Advance past the entire comment.
	if match := regex.FindStringIndex(lex.remainder()); match != nil {
		lex.pos += match[1]
		lex.line++
	}
}

func stringHandler(lex *lexer, regex *regexp.Regexp) {
	match := regex.FindStringIndex(lex.remainder())
	stringLiteral := lex.remainder()[match[0]:match[1]]

	lex.Tokens = append(lex.Tokens, NewToken(STRING, stringLiteral))
	lex.pos += len(stringLiteral)
}

func numberHandler(lex *lexer, regex *regexp.Regexp) {
	match := regex.FindString(lex.remainder())

	lex.Tokens = append(lex.Tokens, NewToken(NUMBER, match))
	lex.pos += len(match)
}

func symbolHandler(lex *lexer, regex *regexp.Regexp) {
	symbol := regex.FindString(lex.remainder())

	if kind, exists := reserved_keywords[symbol]; exists {
		lex.Tokens = append(lex.Tokens, NewToken(kind, symbol))
	} else {
		lex.Tokens = append(lex.Tokens, NewToken(IDENTIFIER, symbol))
	}

	lex.pos += len(symbol)
}
