"""
This example adds the go compiler to your workspace.

"""

load("spaces-starlark-sdk/star/spaces-env.star", "spaces_working_env")
load("spaces-starlark-sdk/packages/go.dev/go/go/1.23.3.star", go_platforms = "platforms")

checkout.add_platform_archive(
    rule = {"name": "go1"},
    platforms = go_platforms,
)

# This will add /usr/bin and /bin to the path so you can
# work in the command line after running `source env`
spaces_working_env()


hello_go_content = """
package main

import "fmt"

func main() {
    fmt.Println("Hello, world.")
}
"""

checkout.add_asset(
    rule = {"name": "hello_go"},
    asset = {
        "destination": "hello_go.txt",
        "content": hello_go_content,
    },
)

run.add_exec(
    rule = {"name": "mod_init", "help": "Initiazlie the go module"},
    exec = {
        "command": "go",
        "args": ["mod", "init", "go/hello"],
    }
)

run.add_exec(
    rule = {"name": "mkdir_hello_go", "deps": ["mod_init"], "help": "Copy the hello go file"},
    exec = {
        "command": "mkdir",
        "args": ["-p", "go/hello"],
    }
)

run.add_exec(
    rule = {"name": "cp_hello_go", "deps": ["mkdir_hello_go"], "help": "Copy the hello go file"},
    exec = {
        "command": "cp",
        "args": ["-f", "hello_go.txt", "go/hello/hello.go"],
    }
)
