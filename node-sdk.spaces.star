"""
This is an example of how to get python running in your workspace. This
uses https://github.com/astral-sh/uv for python binary and package management.

"""

load("spaces-starlark-sdk/star/spaces-env.star", "spaces_working_env")
load("spaces-starlark-sdk/packages/nodejs.org/node/nodejs/v23.3.0.star", node_platforms = "platforms")

checkout.add_platform_archive(
    rule = {"name": "nodejs23"},
    platforms = node_platforms,
)

# This will add /usr/bin and /bin to the path so you can
# work in the command line after running `source env`
spaces_working_env()

