package parser

import (
	"github.com/dtasada/doodle/src/ast"
	"github.com/dtasada/doodle/src/lexer"
)

type (
	type_nudHandler func(p *parser) ast.Type
	type_ledHandler func(p *parser, left ast.Type, bp bindingPower) ast.Type
)

var (
	type_nudLookup = map[lexer.TokenKind]type_nudHandler{}
	type_ledLookup = map[lexer.TokenKind]type_ledHandler{}
	type_bpLookup  = map[lexer.TokenKind]bindingPower{}
)

func type_led(kind lexer.TokenKind, bp bindingPower, ledFunc type_ledHandler) {
	type_bpLookup[kind] = bp
	type_ledLookup[kind] = ledFunc
}

func type_nud(kind lexer.TokenKind, nudFunc type_nudHandler) {
	type_nudLookup[kind] = nudFunc
}

func createTokenTypeLookups() {
	type_nud(lexer.IDENTIFIER, parseSymbolType)
	type_nud(lexer.OPEN_BRACKET, parseArrayType)
}

func parseSymbolType(p *parser) ast.Type {
	return ast.SymbolType{
		Name: p.expect(lexer.IDENTIFIER).Value,
	}
}

func parseArrayType(p *parser) ast.Type {
	p.advance()
	p.expect(lexer.CLOSE_BRACKET)
	underlyingType := parseType(p, BP_DEFAULT)
	return ast.ArrayType{
		Underlying: underlyingType,
	}
}

func parseType(p *parser, bp bindingPower) ast.Type {
	// First parse the NUD
	tokenKind := p.currentToken().Kind
	nudFunc, exists := type_nudLookup[tokenKind]

	if !exists {
		lexer.Panic("TYPE_NUD handler expected for token", tokenKind.ToString())
	}

	left := nudFunc(p)

	for type_bpLookup[p.currentToken().Kind] > bp {
		tokenKind = p.currentToken().Kind
		ledFunc, exists := type_ledLookup[tokenKind]

		if !exists {
			lexer.Panic("TYPE_LED handler expected for token", tokenKind.ToString())
		}

		left = ledFunc(p, left, type_bpLookup[p.currentToken().Kind]) // recursion
	}

	return left
}
