"""
Update Packages
"""


load("//@star/sdk/star/run.star", "RUN_TYPE_ALL", "run_add_exec")
load("//@star/sdk/star/ws.star", "workspace_get_absolute_path")
load("//@star/sdk/star/spaces-env.star", "spaces_working_env")
load("//@star/packages/star/spaces-cli.star", "spaces_add")
load("//@star/packages/star/package.star", "package_add")


spaces_add("spaces0", "v0.14.6")
package_add("github.com", "cli", "cli", "v2.67.0")
spaces_working_env()

run_add_exec(
    "check_latest",
    type = RUN_TYPE_ALL,
    command = "./script/check-latest.star",
    working_directory = "//@star/packages",
)