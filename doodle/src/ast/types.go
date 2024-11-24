package ast

type SymbolType struct {
	Name string // T
}

type ArrayType struct {
	Underlying Type // []T
}

type FuncType struct {
	IsPublic    bool
	Identifier  string
	Arguments   []VarType
	ReturnValue Type
	Block       BlockStatement
}

type VarType struct {
	IsMutable     bool
	Identifier    string
	Type          Type
	AssignedValue Expression
}

func (t SymbolType) _type() {}
func (t ArrayType) _type()  {}
func (t FuncType) _type()   {}
func (t VarType) _type()    {}
