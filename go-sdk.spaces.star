"""
This example adds the go compiler to your workspace.

This is a work in progress.

"""

load("//@sdk/star/spaces-env.star", "spaces_working_env")
load("//@packages/star/go.dev/go/go/1.23.3.star", go_platforms = "platforms")
load("//@sdk/star/run.star", "run_add_exec")
load(
    "//@sdk/star/checkout.star",
    "checkout_add_asset",
    "checkout_add_platform_archive",
)

checkout_add_platform_archive(
    "go1",
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

checkout_add_asset(
    "hello_go",
    destination = "hello_go.txt",
    content = hello_go_content,
)

run_add_exec(
    "mod_init",
    help = "Initiazlie the go module",
    command = "go",
    args = ["mod", "init", "go/hello"],
)

run_add_exec(
    "mkdir_hello_go",
    deps = ["mod_init"],
    help = "Copy the hello go file",
    command = "mkdir",
    args = ["-p", "go/hello"],
)

run_add_exec(
    "cp_hello_go",
    deps = ["mkdir_hello_go"],
    help = "Copy the hello go file",
    command = "cp",
    args = ["-f", "hello_go.txt", "go/hello/hello.go"],
)
