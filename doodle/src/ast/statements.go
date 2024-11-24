package ast

type BlockStatement struct {
	Body []Statement
}

type ExpressionStatement struct {
	Expression Expression
}

type VarDeclStatement struct {
	Identifier    string
	IsMutable     bool
	AssignedValue Expression
	ExplicitType  Type
}

type StructDeclStatement struct {
	Identifier string
	Properties map[string]StructProperty
	Methods    map[string]FuncType
}

type StructProperty struct {
	IsPublic      bool
	InnerVariable VarType
}

type FuncStatement struct {
	IsPublic   bool
	Identifier string
	Type       FuncType
}

func (n BlockStatement) statement()      {}
func (n ExpressionStatement) statement() {}
func (n VarDeclStatement) statement()    {}
func (n StructDeclStatement) statement() {}
