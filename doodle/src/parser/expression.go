package parser

import (
	"strconv"

	"github.com/dtasada/doodle/src/ast"
	"github.com/dtasada/doodle/src/helper"
	"github.com/dtasada/doodle/src/lexer"
	"github.com/kr/pretty"
)

func parseExpression(p *parser, bp bindingPower) ast.Expression {
	// First parse the NUD
	tokenKind := p.currentToken().Kind
	nudFunc, exists := nudLookup[tokenKind]

	if !exists {
		lexer.Panic("NUD handler expected for token", tokenKind.ToString())
	}

	left := nudFunc(p)

	for bpLookup[p.currentToken().Kind] > bp {
		tokenKind = p.currentToken().Kind
		pretty.Println("tokenkind", tokenKind)
		ledFunc, exists := ledLookup[tokenKind]

		if !exists {
			lexer.Panic("LED handler expected for token", tokenKind.ToString())
		}

		left = ledFunc(p, left, bpLookup[p.currentToken().Kind]) // recursion
	}

	return left
}

func parsePrimaryExpression(p *parser) ast.Expression {
	switch p.currentToken().Kind {
	case lexer.NUMBER:
		number, _ := strconv.ParseFloat(p.advance().Value, 64)
		return ast.NumberExpression{Value: number}
	case lexer.STRING:
		return ast.StringExpression{Value: p.advance().Value}
	case lexer.IDENTIFIER:
		return ast.SymbolExpression{Value: p.advance().Value}
	default:
		lexer.Panic("Cannot create primaryExpression from", p.currentToken().Kind.ToString())
		return nil
	}
}

func parseBinaryExpression(p *parser, left ast.Expression, bp bindingPower) ast.Expression {
	operatorToken := p.advance()
	right := parseExpression(p, bp)

	return ast.BinaryExpression{
		Left:     left,
		Operator: operatorToken,
		Right:    right,
	}
}

func parsePrefixExpression(p *parser) ast.Expression {
	operatorToken := p.advance()
	rightHand := parseExpression(p, BP_DEFAULT)

	return ast.PrefixExpression{
		Operator:        operatorToken,
		RightExpression: rightHand,
	}
}

func parseGroupingExpression(p *parser) ast.Expression {
	p.advance() // skip groupint start
	expression := parseExpression(p, BP_DEFAULT)
	p.expect(lexer.CLOSE_PAREN)
	return expression
}

func parseAssignmentExpression(p *parser, left ast.Expression, bp bindingPower) ast.Expression {
	operatorToken := p.advance()
	rightHand := parseExpression(p, BP_ASSIGNMENT)

	return ast.AssignmentExpression{
		Assignee:        left,
		Operator:        operatorToken,
		RightExpression: rightHand,
	}
}

func parseStructInstExpression(p *parser, left ast.Expression, bp bindingPower) ast.Expression {
	pretty.Println(939393939)
	structName := helper.ExpectType[ast.SymbolExpression](left).Value
	properties := map[string]ast.Expression{}

	p.expect(lexer.OPEN_BRACE)

	for p.hasTokens() && p.currentToken().Kind != lexer.CLOSE_BRACE {
		propertyName := p.expect(lexer.IDENTIFIER).Value
		p.expect(lexer.COLON)
		expression := parseExpression(p, BP_LOGICAL)

		properties[propertyName] = expression
		if p.currentToken().Kind != lexer.CLOSE_BRACE {
			p.expect(lexer.COMMA)
		}
	}

	p.expect(lexer.CLOSE_BRACE)

	return ast.StructInstExpression{
		Identifier: structName,
		Properties: properties,
	}
}

func parseArrayInstExpression(p *parser) ast.Expression {
	p.expect(lexer.OPEN_BRACKET)
	p.expect(lexer.CLOSE_BRACKET)

	contents := []ast.Expression{}
	underlyingType := parseType(p, BP_DEFAULT)

	p.expect(lexer.OPEN_BRACE)
	for p.hasTokens() && p.currentToken().Kind != lexer.CLOSE_BRACE {
		contents = append(contents, parseExpression(p, BP_LOGICAL))

		if p.currentToken().Kind != lexer.CLOSE_BRACE {
			p.expect(lexer.COMMA)
		}
	}
	p.expect(lexer.CLOSE_BRACE)

	return ast.ArrayInstExpression{
		Underlying: underlyingType,
		Contents:   contents,
	}
}

func parseCallExpression(p *parser, left ast.Expression, bp bindingPower) ast.Expression {
	p.advance()
	args := []ast.Expression{}

	for p.hasTokens() && p.currentToken().Kind != lexer.CLOSE_PAREN {
		args = append(args, parseExpression(p, BP_ASSIGNMENT))

		if p.currentToken().Kind != lexer.CLOSE_PAREN {
			p.expect(lexer.COMMA)
		}
	}

	p.expect(lexer.CLOSE_PAREN)
	return ast.CallExpression{
		Method:    left,
		Arguments: args,
	}
}

func parseMemberExpression(p *parser, left ast.Expression, bp bindingPower) ast.Expression {
	if p.advance().Kind == lexer.OPEN_BRACKET {
		rightHand := parseExpression(p, bp)
		p.expect(lexer.CLOSE_BRACKET)
		return ast.ComputedExpression{
			Member:   left,
			Property: rightHand,
		}
	}
	return ast.MemberExpression{
		Member:   left,
		Property: p.expect(lexer.IDENTIFIER).Value,
	}
}
