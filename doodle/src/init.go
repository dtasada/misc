package src

import (
	"os"
	"path/filepath"

	"github.com/urfave/cli/v2"
)

func InitProject(ctx *cli.Context) error {
	rootPath, _ = os.Getwd()
	if ctx.Args().Len() != 0 {
		rootPath = filepath.Join(rootPath, ctx.Args().Get(0))
	}
	if err := os.MkdirAll(rootPath, 0777); err != nil {
		Panic(err.Error())
		return err
	}

	srcPath = filepath.Join(rootPath, "src")
	if err := os.MkdirAll(srcPath, 0777); err != nil {
		Panic(err.Error())
		return err
	}

	helloWorld := []byte(
		"pub fn main() {\n" +
			"\tprint(\"Hello world!\")\n" +
			`}`,
	)

	mainFilePath = filepath.Join(srcPath, "main.dl")
	err := os.WriteFile(mainFilePath, helloWorld, 0666)
	if err != nil {
		Panic(err.Error())
		return err
	}

	return nil
}
