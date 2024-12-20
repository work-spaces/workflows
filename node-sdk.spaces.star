"""
This is an example of how to use the nodejs sdk in your workspace.

"""

load("//@sdk/sdk/star/spaces-env.star", "spaces_working_env")
load("//@sdk/packages/star/nodejs.org/node/nodejs/packages.star", node_packages = "packages")
load("//@sdk/sdk/star/checkout.star", "checkout_add_platform_archive")
load("//@sdk/sdk/star/run.star", "run_add_exec")

checkout_add_platform_archive(
    "nodejs23",
    platforms = node_packages["v23.3.0"],
)

# This will add /usr/bin and /bin to the path so you can
# work in the command line after running `source env`
spaces_working_env()

run_add_exec(
    "node_version",
    command = "node",
    args = ["--version"],
)
