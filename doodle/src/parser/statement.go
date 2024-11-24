package parser

import (
	"github.com/dtasada/doodle/src/ast"
	"github.com/dtasada/doodle/src/helper"
	"github.com/dtasada/doodle/src/lexer"
)

func parseStatement(p *parser) ast.Statement {
	statementFunc, exists := statementLookup[p.currentToken().Kind]

	if exists {
		return statementFunc(p)
	}

	expression := parseExpression(p, BP_DEFAULT)
	p.expect(lexer.SEMICOLON)

	return ast.ExpressionStatement{
		Expression: expression,
	}
}

func parseBlockStatement(p *parser) ast.Statement {
	p.expect(lexer.OPEN_BRACE)

	body := []ast.Statement{}

	for p.hasTokens() && p.currentToken().Kind != lexer.CLOSE_BRACE {
		body = append(body, parseStatement(p))
	}

	p.expect(lexer.CLOSE_BRACE)
	return ast.BlockStatement{
		Body: body,
	}
}

func parseVarDeclStatement(p *parser) ast.Statement {
	var explicitType ast.Type
	var assignedValue ast.Expression

	isMutable := p.advance().Kind == lexer.MUT
	varName := p.expectError(lexer.IDENTIFIER, "Inside variable declaration: expected to find variable name").Value

	if p.currentToken().Kind == lexer.COLON {
		p.advance()
		explicitType = parseType(p, BP_DEFAULT)
	}

	if p.currentToken().Kind != lexer.SEMICOLON {
		p.expect(lexer.ASSIGNMENT)
		assignedValue = parseExpression(p, BP_ASSIGNMENT)
	} else if explicitType == nil {
		lexer.Panic("Missing either right-hand side or type declaration in var declaration")
	}

	p.expect(lexer.SEMICOLON)

	if !isMutable && assignedValue == nil {
		lexer.Panic("Cannot define immutable variable without providing value")
	}

	return ast.VarDeclStatement{
		IsMutable:     isMutable,
		Identifier:    varName,
		AssignedValue: assignedValue,
		ExplicitType:  explicitType,
	}
}

func parseStructDeclStatement(p *parser) ast.Statement {
	p.expect(lexer.STRUCT) // advance past struct keyword

	properties := map[string]ast.StructProperty{}
	methods := map[string]ast.FuncType{}
	structName := p.expect(lexer.IDENTIFIER).Value

	p.expect(lexer.OPEN_BRACE)

	for p.hasTokens() && p.currentToken().Kind != lexer.CLOSE_BRACE {
		var isPublic bool
		switch p.currentToken().Kind {
		case lexer.PUB:
			// pub keyword
			isPublic = true
			p.expect(lexer.PUB)
		case lexer.IDENTIFIER:
			// struct property/variable
			propertyName := p.expect(lexer.IDENTIFIER).Value
			p.expectError(lexer.COLON, "Expected to find colon after property name inside struct declaration")
			propertyType := parseType(p, BP_DEFAULT)
			p.expect(lexer.SEMICOLON)

			if _, exists := properties[propertyName]; exists {
				lexer.Panic("Duplicate struct property", propertyName)
			}

			properties[propertyName] = ast.StructProperty{
				IsPublic: isPublic,
				InnerVariable: ast.VarType{
					Identifier: propertyName,
					Type:       propertyType,
				},
			}

			continue
		case lexer.FN:
			p.advance()
			funcName := p.expect(lexer.IDENTIFIER).Value
			p.expect(lexer.OPEN_PAREN)

			args := []ast.VarType{}
			for p.hasTokens() && p.currentToken().Kind != lexer.CLOSE_PAREN {
				argName := p.expect(lexer.IDENTIFIER).Value
				p.expect(lexer.COLON)
				argType := parseType(p, BP_DEFAULT)

				args = append(args, ast.VarType{
					Identifier: argName,
					Type:       argType,
				})

				p.expect(lexer.COMMA)
			}

			p.expect(lexer.CLOSE_PAREN)
			p.expect(lexer.COLON)

			returnType := parseType(p, BP_DEFAULT)
			funcBody := helper.ExpectType[ast.BlockStatement](parseBlockStatement(p))

			methods[funcName] = ast.FuncType{
				Arguments:   args,
				ReturnValue: returnType,
				Block:       funcBody,
			}

		default:
			lexer.Panic("Expected property or function identifier in struct declaration")
		}
	}

	p.expect(lexer.CLOSE_BRACE)

	return ast.StructDeclStatement{
		Properties: properties,
		Methods:    methods,
		Identifier: structName,
	}
}
