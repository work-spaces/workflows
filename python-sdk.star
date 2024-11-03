"""
This is an example of how to get python running in your workspace. This
uses https://github.com/astral-sh/uv for python binary and package management.

"""

load("sysroot-packages/star/spaces_env.star", "spaces_working_env")
load("sysroot-packages/packages/github.com/astral-sh/uv/0.4.29.star", uv_platforms = "platforms")
load("sysroot-packages/star/python.star", "add_uv_python")

add_uv_python(
    rule_name = "python3",
    uv_platforms = uv_platforms,
    python_version = "3.11",
    packages = ["numpy", "cmake-format"])


# This will add /usr/bin and /bin to the path so you can
# work in the command line after running `source env`
spaces_working_env()

