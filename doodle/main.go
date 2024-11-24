package main

import (
	"github.com/dtasada/doodle/src"
	"os"

	"github.com/urfave/cli/v2"
)

func main() {
	app := &cli.App{
		Name:   "doodle",
		Usage:  "my shitty programming language",
		Action: cli.ShowAppHelp,
		Commands: []*cli.Command{
			{
				Name:   "build",
				Usage:  "build current project",
				Action: src.BuildProject,
			},
			{
				Name:   "run",
				Usage:  "run current project",
				Action: src.RunProject,
			},
			{
				Name:   "init",
				Usage:  "target path",
				Action: src.InitProject,
			},
		},
	}

	if err := app.Run(os.Args); err != nil {
		src.Panic(err.Error())
	}
}
