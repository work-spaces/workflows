"""
This is an example of how to get python running in your workspace. This
uses https://github.com/astral-sh/uv for python binary and package management.

"""

load("//@star/sdk/star/spaces-env.star", "spaces_working_env")
load("//@star/packages/star/python.star", "python_add_uv")

python_add_uv(
    "python3",
    uv_version = "0.4.29",
    ruff_version = "0.8.0",
    python_version = "3.11",
    packages = ["numpy", "cmake-format", "pre-commit"])


# This will add /usr/bin and /bin to the path so you can
# work in the command line after running `source env`
spaces_working_env()

