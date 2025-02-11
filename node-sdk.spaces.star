"""
This is an example of how to use the nodejs sdk in your workspace.

"""

load("//@star/sdk/star/spaces-env.star", "spaces_working_env")
load("//@star/packages/star/nodejs.org/node/nodejs/packages.star", node_packages = "packages")
load("//@star/sdk/star/checkout.star", "checkout_add_platform_archive")
load("//@star/sdk/star/run.star", "run_add_exec", "RUN_TYPE_ALL")

checkout_add_platform_archive(
    "nodejs23",
    platforms = node_packages["v23.3.0"],
)

# This will add /usr/bin and /bin to the path so you can
# work in the command line after running `source env`
spaces_working_env()

run_add_exec(
    "node_version",
    type = RUN_TYPE_ALL,
    command = "node",
    args = ["--version"],
)
