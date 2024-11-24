package ast

import (
	"github.com/dtasada/doodle/src/lexer"
)

type NumberExpression struct {
	Value float64
}

type StringExpression struct {
	Value string
}

type SymbolExpression struct {
	Value string
}

type BinaryExpression struct {
	Left     Expression
	Operator lexer.Token
	Right    Expression
}

type PrefixExpression struct {
	Operator        lexer.Token
	RightExpression Expression
}

type AssignmentExpression struct {
	Assignee        Expression
	Operator        lexer.Token
	RightExpression Expression
}

type StructInstExpression struct {
	Identifier string
	Properties map[string]Expression
}

type ArrayInstExpression struct {
	Underlying Type
	Contents   []Expression
}

type CallExpression struct {
	Method    Expression
	Arguments []Expression
}

type ComputedExpression struct {
	Member   Expression
	Property Expression
}

type MemberExpression struct {
	Member   Expression
	Property string
}

// Comply with Expression interface
func (n NumberExpression) expression()     {}
func (n StringExpression) expression()     {}
func (n SymbolExpression) expression()     {}
func (n BinaryExpression) expression()     {}
func (n PrefixExpression) expression()     {}
func (n AssignmentExpression) expression() {}
func (n StructInstExpression) expression() {}
func (n ArrayInstExpression) expression()  {}
func (n CallExpression) expression()       {}
func (n ComputedExpression) expression()   {}
func (n MemberExpression) expression()     {}
