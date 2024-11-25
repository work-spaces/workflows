"""
This is an example of how to use the nodejs sdk in your workspace.

"""

load("//spaces-starlark-sdk/star/spaces-env.star", "spaces_working_env")
load("//spaces-starlark-sdk/packages/nodejs.org/node/nodejs/v23.3.0.star", node_platforms = "platforms")
load("//spaces-starlark-sdk/star/checkout.star", "checkout_add_platform_archive")
load("//spaces-starlark-sdk/star/run.star", "run_add_exec")

checkout_add_platform_archive(
    "nodejs23",
    platforms = node_platforms,
)

# This will add /usr/bin and /bin to the path so you can
# work in the command line after running `source env`
spaces_working_env()

run_add_exec(
    "node_version",
    command = "node",
    args = ["--version"],
)
