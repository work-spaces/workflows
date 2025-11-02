"""
Shell Test workflow
"""

load("//@star/sdk/star/checkout.star", "checkout_add_asset")
load(
    "//@star/sdk/star/run.star",
    "RUN_LOG_LEVEL_APP",
    "RUN_TYPE_ALL",
    "run_add_exec",
)
load("//@star/packages/star/spaces-cli.star", "spaces_add")
load("//@star/packages/star/starship.star", "starship_add_bash")
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

SCRIPT = """#!/usr/bin/env spaces

script.print("Hello!!")

"""

starship_add_bash("starship_bash")
spaces_add("spaces0", "v0.15.4")
spaces_working_env()

checkout_add_asset(
    "file.txt",
    destination = "README.md",
    content = "Hello!!\n",
)

checkout_add_asset(
    "hello.star",
    destination = "hello.star",
    content = SCRIPT,
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
    log_level = RUN_LOG_LEVEL_APP,
    type = RUN_TYPE_ALL,
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
    type = RUN_TYPE_ALL,
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
    type = RUN_TYPE_ALL,
)

mv(
    "move_file",
    source = "README.md",
    destination = "README2.md",
    deps = ["copy_file", "copy_file2"],
    options = ["-f"],
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
    options = ["-f"],
    type = RUN_TYPE_ALL,
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
    options = ["-f"],
    type = RUN_TYPE_ALL,
)

ls(
    "check_new_dir",
    path = "new_dir/README2.md",
    deps = ["copy_file2"],
    type = RUN_TYPE_ALL,
)
