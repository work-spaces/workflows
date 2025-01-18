"""
Shell Test workflow
"""

load("//@star/sdk/star/checkout.star", "checkout_add_asset")
load("//@star/sdk/star/run.star", "run_add_exec")
load("//@star/packages/star/spaces-cli.star", "spaces_add")
load("//@star/sdk/star/spaces-env.star", "spaces_working_env")
load(
    "//@star/sdk/star/shell.star",
    "chmod",
    "cp",
    "ln",
    "ls",
    "mkdir",
    "mv",
)

script = """#!/usr/bin/env spaces

script.print("Hello!!")

"""

spaces_add("spaces0", "v0.11.14")
spaces_working_env()

checkout_add_asset(
    "file.txt",
    destination = "README.md",
    content = "Hello!!\n",
)

checkout_add_asset(
    "hello.star",
    destination = "hello.star",
    content = script,
)

chmod(
    "chmod_file",
    path = "hello.star",
    mode = "755",
)

run_add_exec(
    "run_script",
    command = "./hello.star",
    deps = ["chmod_file"],
    log_level = "App"
)

cp(
    "copy_file",
    source = "README.md",
    destination = "README2.md",
    options = ["-f"],
)

ls(
    "check_copy_file",
    path = "README2.md",
    deps = ["copy_file"],
)

ln(
    "ln_symbolic_file",
    source = "README2.md",
    destination = "README3.md",
    options = ["-s", "-f"],
    deps = ["copy_file"],
)

ls(
    "check_ln_file",
    path = "README2.md",
    deps = ["ln_symbolic_file"],
)

mv(
    "move_file",
    source = "README.md",
    destination = "README2.md",
    deps = ["copy_file", "copy_file2"],
    options = ["-f"]
)

ls(
    "check_move_file",
    path = "README2.md",
    deps = ["move_file"],
)

ls(
    "check_move_file2",
    path = "README.md",
    deps = ["move_file"],
    expect = "Failure",
)

cp(
    "copy_back",
    source = "README2.md",
    destination = "README.md",
    deps = ["check_move_file2", "check_move_file"],
    options = ["-f"]
)

mkdir(
    "create_dir",
    path = "new_dir",
    options = ["-p"],
)

cp(
    "copy_file2",
    source = "README.md",
    destination = "new_dir/README2.md",
    deps = ["create_dir"],
    options = ["-f"]
)

ls(
    "check_new_dir",
    path = "new_dir/README2.md",
    deps = ["copy_file2"],
)
