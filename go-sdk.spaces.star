"""
This example adds the go compiler to your workspace.

"""

load("spaces-starlark-sdk/star/spaces-env.star", "spaces_working_env")
load("spaces-starlark-sdk/packages/go.dev/go/go/1.23.3.star", go_platforms = "platforms")

checkout.add_platform_archive(
    rule = {"name": "go1"},
    platforms = go_platforms,
)

# This will add /usr/bin and /bin to the path so you can
# work in the command line after running `source env`
spaces_working_env()

