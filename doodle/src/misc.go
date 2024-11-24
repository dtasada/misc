package src

import (
	"fmt"
	"os"
	"path/filepath"

	"github.com/dtasada/doodle/src/lexer"
	"github.com/dtasada/doodle/src/parser"
	"github.com/kr/pretty"

	"github.com/urfave/cli/v2"
)

var (
	rootPath     string
	srcPath      string
	mainFilePath string
)

func Panic(msg ...any) {
	fmt.Println(msg...)
	os.Exit(1)
}

func IsRunnable() {
	rootPath, _ = os.Getwd()
	srcPath = filepath.Join(rootPath, "src")
	mainFilePath = filepath.Join(srcPath, "main.dl")

	if _, err := os.Stat(srcPath); os.IsNotExist(err) {
		Panic("src/ folder does not exist!")
	}
	if _, err := os.Stat(mainFilePath); os.IsNotExist(err) {
		Panic("src/main.dl does not exist!")
	}
}

func BuildProject(ctx *cli.Context) error {
	IsRunnable()
	bytes, _ := os.ReadFile(mainFilePath)

	tokens := lexer.Tokenize(string(bytes))

	ast := parser.Parse(tokens)
	pretty.Println(ast)

	return nil
}

func RunProject(ctx *cli.Context) error {
	return nil
}
