"""
This example adds the go compiler to your workspace.

This is a work in progress.

"""

load("//@star/sdk/star/spaces-env.star", "spaces_working_env")
load("//@star/packages/star/package.star", "package_add")
load("//@star/sdk/star/run.star", "RUN_INPUTS_ONCE", "run_add_exec", "RUN_TYPE_ALL")
load("//@star/sdk/star/shell.star", "cp")
load("//@star/sdk/star/checkout.star", "checkout_add_asset")
load("//@star/sdk/star/info.star", "info_set_minimum_version")

info_set_minimum_version("0.12.0")

package_add("go.dev", "go", "go", "1.23.3")

# This will add /usr/bin and /bin to the path so you can
# work in the command line after running `source env`
spaces_working_env()

HELLO_GO_CONTENT = """
package main

import "fmt"

func main() {
    fmt.Println("Hello, world.")
}
"""

checkout_add_asset(
    "hello_go",
    destination = "hello_go.txt",
    content = HELLO_GO_CONTENT,
)

run_add_exec(
    "mod_init",
    inputs = RUN_INPUTS_ONCE,
    help = "Initialize the go module",
    command = "go",
    args = ["mod", "init", "go/hello"],
)

run_add_exec(
    "mkdir_hello_go",
    inputs = RUN_INPUTS_ONCE,
    deps = ["mod_init"],
    help = "Copy the hello go file",
    command = "mkdir",
    args = ["-p", "go/hello"],
)

cp(
    "cp_hello_go",
    type = RUN_TYPE_ALL,
    deps = ["mkdir_hello_go"],
    options = ["-f"],
    source = "hello_go.txt",
    destination = "go/hello/hello.go",
)
