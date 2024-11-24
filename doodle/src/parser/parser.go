package parser

import (
	"fmt"

	"github.com/dtasada/doodle/src/ast"
	"github.com/dtasada/doodle/src/lexer"
)

type parser struct {
	errors []error
	pos    int
	tokens []lexer.Token
}

func newParser(tokens []lexer.Token) *parser {
	createTokenLookups()
	createTokenTypeLookups()

	return &parser{
		errors: []error{},
		pos:    0,
		tokens: tokens,
	}
}

func Parse(tokens []lexer.Token) ast.BlockStatement {
	body := []ast.Statement{}
	p := newParser(tokens)

	for p.hasTokens() {
		body = append(body, parseStatement(p))
	}

	return ast.BlockStatement{Body: body}
}

func (p *parser) currentToken() lexer.Token {
	return p.tokens[p.pos]
}

func (p *parser) advance() lexer.Token {
	// Returns current token and then advances
	tk := p.currentToken()
	p.pos++
	return tk
}

func (p *parser) hasTokens() bool {
	return p.pos < len(p.tokens) && p.currentToken().Kind != lexer.EOF
}

func (p *parser) expectError(expectedKind lexer.TokenKind, err any) lexer.Token {
	token := p.currentToken()
	kind := token.Kind

	if kind != expectedKind {
		if err == nil {
			err = fmt.Sprintf("Expected %s but received %s instead\n", expectedKind.ToString(), kind.ToString())
		}

		lexer.Panic(err)
	}

	return p.advance()
}

func (p *parser) expect(expectedKind lexer.TokenKind) lexer.Token {
	return p.expectError(expectedKind, nil)
}
