package parser

import (
	"github.com/dtasada/doodle/src/ast"
	"github.com/dtasada/doodle/src/lexer"
)

type bindingPower int

const (
	// Do not change order of iota
	BP_DEFAULT bindingPower = iota
	BP_COMMA
	BP_ASSIGNMENT
	BP_LOGICAL
	BP_RELATIONAL
	BP_ADDITIVE
	BP_MULTIPLICATIVE
	BP_UNARY
	BP_CALL
	BP_MEMBER
	BP_PRIMARY
)

type (
	ledHandler       func(p *parser, left ast.Expression, bp bindingPower) ast.Expression
	nudHandler       func(p *parser) ast.Expression
	statementHandler func(p *parser) ast.Statement
)

var (
	bpLookup        = map[lexer.TokenKind]bindingPower{}
	ledLookup       = map[lexer.TokenKind]ledHandler{}
	nudLookup       = map[lexer.TokenKind]nudHandler{}
	statementLookup = map[lexer.TokenKind]statementHandler{}
)

func led(kind lexer.TokenKind, bp bindingPower, ledFunc ledHandler) {
	bpLookup[kind] = bp
	ledLookup[kind] = ledFunc
}

func nud(kind lexer.TokenKind, nudFunc nudHandler) {
	nudLookup[kind] = nudFunc
}

func statement(kind lexer.TokenKind, statementFunc statementHandler) {
	bpLookup[kind] = BP_DEFAULT
	statementLookup[kind] = statementFunc
}

func createTokenLookups() {
	led(lexer.ASSIGNMENT, BP_ASSIGNMENT, parseAssignmentExpression)
	led(lexer.PLUS_EQUALS, BP_ASSIGNMENT, parseAssignmentExpression)
	led(lexer.MINUS_EQUALS, BP_ASSIGNMENT, parseAssignmentExpression)
	// add *=, /= and %=

	// Logical
	led(lexer.AND, BP_LOGICAL, parseBinaryExpression)
	led(lexer.OR, BP_LOGICAL, parseBinaryExpression)
	led(lexer.ELLIPSIS, BP_LOGICAL, parseBinaryExpression)

	// Relational
	led(lexer.LESS, BP_RELATIONAL, parseBinaryExpression)
	led(lexer.LESS_EQUALS, BP_RELATIONAL, parseBinaryExpression)
	led(lexer.GREATER, BP_RELATIONAL, parseBinaryExpression)
	led(lexer.GREATER_EQUALS, BP_RELATIONAL, parseBinaryExpression)
	led(lexer.EQUALS, BP_RELATIONAL, parseBinaryExpression)
	led(lexer.NOT_EQUALS, BP_RELATIONAL, parseBinaryExpression)

	// Additive & Multiplicative
	led(lexer.PLUS, BP_ADDITIVE, parseBinaryExpression)
	led(lexer.DASH, BP_ADDITIVE, parseBinaryExpression)
	led(lexer.ASTERISK, BP_MULTIPLICATIVE, parseBinaryExpression)
	led(lexer.SLASH, BP_MULTIPLICATIVE, parseBinaryExpression)
	led(lexer.PERCENT, BP_MULTIPLICATIVE, parseBinaryExpression)

	// Literals & Symbols
	nud(lexer.NUMBER, parsePrimaryExpression)
	nud(lexer.STRING, parsePrimaryExpression)
	nud(lexer.IDENTIFIER, parsePrimaryExpression)
	nud(lexer.OPEN_PAREN, parseGroupingExpression)
	nud(lexer.DASH, parsePrefixExpression)
	nud(lexer.OPEN_BRACKET, parseArrayInstExpression)

	// Member, computed, call, instantiation
	led(lexer.DOT, BP_MEMBER, parseMemberExpression)
	led(lexer.OPEN_BRACKET, BP_MEMBER, parseMemberExpression)
	led(lexer.OPEN_PAREN, BP_CALL, parseCallExpression)
	led(lexer.OPEN_BRACE, BP_CALL, parseStructInstExpression)

	// Statements
	statement(lexer.LET, parseVarDeclStatement)
	statement(lexer.MUT, parseVarDeclStatement)
	statement(lexer.STRUCT, parseStructDeclStatement)
	statement(lexer.OPEN_BRACE, parseBlockStatement)
}
