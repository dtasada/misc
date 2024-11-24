package lexer

import "fmt"

// Tokens
type TokenKind int

const (
	EOF TokenKind = iota
	NUMBER
	STRING
	IDENTIFIER

	OPEN_BRACKET
	CLOSE_BRACKET
	OPEN_BRACE
	CLOSE_BRACE
	OPEN_PAREN
	CLOSE_PAREN

	ASSIGNMENT
	EQUALS
	NOT
	NOT_EQUALS

	LESS
	LESS_EQUALS
	GREATER
	GREATER_EQUALS

	OR
	AND

	DOT
	ELLIPSIS
	SEMICOLON
	COLON
	QUESTION
	COMMA
	AMPERSAND

	PLUS_PLUS
	MINUS_MINUS
	PLUS_EQUALS
	MINUS_EQUALS

	PLUS
	DASH
	SLASH
	ASTERISK
	PERCENT

	// Reserved keywords
	IMPORT
	PUB
	STRUCT
	ENUM
	INTERFACE
	FN
	LET
	MUT
	IF
	ELSE
	FOR
	IN
	TYPEOF
)

var reserved_keywords = map[string]TokenKind{
	"import":    IMPORT,
	"pub":       PUB,
	"struct":    STRUCT,
	"enum":      ENUM,
	"interface": INTERFACE,
	"fn":        FN,
	"let":       LET,
	"mut":       MUT,
	"if":        IF,
	"else":      ELSE,
	"for":       FOR,
	"in":        IN,
	"typeof":    TYPEOF,
}

type Token struct {
	Kind  TokenKind
	Value string
}

func (token *Token) Debug() {
	if token.Kind.IsOneOf(IDENTIFIER, NUMBER, STRING) {
		fmt.Printf("%s (%s)\n", token.Kind.ToString(), token.Value)
	} else {
		fmt.Printf("%s ()\n", token.Kind.ToString())
	}
}

func NewToken(kind TokenKind, value string) Token {
	return Token{
		kind, value,
	}
}

func (kind TokenKind) IsOneOf(expectedTokens ...TokenKind) bool {
	for _, expectedToken := range expectedTokens {
		if expectedToken == kind {
			return true
		}
	}

	return false
}

func (kind TokenKind) ToString() string {
	switch kind {
	case EOF:
		return "eof"
	case NUMBER:
		return "number"
	case STRING:
		return "string"
	case IDENTIFIER:
		return "identifier"

	case OPEN_BRACKET:
		return "open_bracket"
	case CLOSE_BRACKET:
		return "close_bracket"
	case OPEN_BRACE:
		return "open_curly"
	case CLOSE_BRACE:
		return "close_curly"
	case OPEN_PAREN:
		return "open_paren"
	case CLOSE_PAREN:
		return "close_paren"

	case ASSIGNMENT:
		return "assignment"
	case EQUALS:
		return "equals"
	case NOT:
		return "not"
	case NOT_EQUALS:
		return "not_equals"

	case LESS:
		return "less"
	case LESS_EQUALS:
		return "less_equals"
	case GREATER:
		return "greater"
	case GREATER_EQUALS:
		return "greater_equlaS"

	case OR:
		return "or"
	case AND:
		return "and"

	case DOT:
		return "dot"
	case ELLIPSIS:
		return "ellipsis"
	case SEMICOLON:
		return "semicolon"
	case COLON:
		return "colon"
	case QUESTION:
		return "question"
	case COMMA:
		return "comma"

	case PLUS_PLUS:
		return "plus_plus"
	case MINUS_MINUS:
		return "minus_minus"
	case PLUS_EQUALS:
		return "plus_equals"
	case MINUS_EQUALS:
		return "minus_equals"

	case PLUS:
		return "plus"
	case DASH:
		return "dash"
	case SLASH:
		return "slash"
	case ASTERISK:
		return "asterisk"
	case PERCENT:
		return "percent"

	// Reserved keywords
	case LET:
		return "let"
	case PUB:
		return "pub"
	case STRUCT:
		return "struct"
	case IMPORT:
		return "import"
	case FN:
		return "fn"
	case IF:
		return "if"
	case ELSE:
		return "else"
	case FOR:
		return "for"
	case TYPEOF:
		return "typeof"
	case IN:
		return "in"
	default:
		return "TOKEN DOES NOT EXIST!"
	}
}
