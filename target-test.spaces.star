"""
Test adding targets
"""

load("//@star/sdk/star/shell.star", "ls", "shell")
load(
    "//@star/sdk/star/info.star",
    "info_set_minimum_version",
)
load("//@star/sdk/star/run.star", "run_add_target", "run_add_exec")
load("//@star/sdk/star/checkout.star", 
    "checkout_add_repo",
)

load("//@star/sdk/star/spaces-env.star", "spaces_working_env")

info_set_minimum_version("0.14.11")

spaces_working_env()

ls(
    "ls_workspace",
    path = "./",
)

shell(
    "pwd_test",
    script = "echo $PWD",
)

run_add_exec(
    "ls_workspace2",
    command = "ls",
    args = ["-alt"],
    type = "Test"
)

run_add_exec(
    "ls_workspace3",
    command = "ls",
    args = ["-alt"],
    type = "Clean"
)

run_add_target(
    "ls1",
    deps = ["ls_workspace"],
)

run_add_target(
    "ls2",
    deps = ["ls1"],
)

checkout_add_repo(
    "spaces",
    url = "https://github.com/work-spaces/spaces",
    rev = "main",
    clone = "Blobless",
    type = "Optional",
)

