"""
Test adding targets
"""

load("//@star/sdk/star/shell.star", "ls")
load(
    "//@star/sdk/star/info.star",
    "info_assert_member_revision",
    "info_assert_member_semver",
    "info_set_minimum_version",
)
load("//@star/sdk/star/run.star", "run_add_target")
load("//@star/sdk/star/spaces-env.star", "spaces_working_env")

info_set_minimum_version("0.12.6")
info_assert_member_semver(
    "https://github.com/work-spaces/sdk",
    ">=0.1",
)

info_assert_member_revision(
    "https://github.com/work-spaces/packages",
    "v0.1.0",
)

spaces_working_env()

ls(
    "ls_workspace",
    path = "./",
)

run_add_target(
    "ls1",
    deps = ["ls_workspace"],
)

run_add_target(
    "ls2",
    deps = ["ls1"],
)
