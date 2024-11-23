"""
Building LLVM using Spaces
"""

load("spaces-starlark-sdk/star/spaces-env.star", "spaces_working_env")
load("spaces-starlark-sdk/packages/github.com/Kitware/CMake/v3.30.5.star", cmake3_platforms = "platforms")
load("spaces-starlark-sdk/star/cmake.star", "add_cmake")

load("spaces-starlark-sdk/packages/github.com/ninja-build/ninja/v1.12.1.star", ninja1_platforms = "platforms")

info.set_minimum_version("0.10.3")

add_cmake(
    rule_name = "cmake3",
    platforms = cmake3_platforms)

checkout.add_platform_archive(
    rule = {"name": "ninja1"},
    platforms = ninja1_platforms,
)

version = "17.0.6"
sha256 = "27b5c7c745ead7e9147c78471b9053d4f6fc3bed94baf45f4e8295439f564bb8"

checkout.add_archive(
    rule = {"name": "llvm-project"},
    archive = {
        "url": "https://github.com/llvm/llvm-project/archive/refs/tags/llvmorg-{}.zip".format(version),
        "sha256": sha256,
        "link": "Hard",
        "strip_prefix": "llvm-project-llvmorg-{}".format(version),
        "add_prefix": "llvm-project",
    },
)

# This will add /usr/bin and /bin to the path so you can
# work in the command line after running `source env`
spaces_working_env()

workspace = info.get_absolute_path_to_workspace()

run.add_exec(
    rule = {"name": "configure"},
    exec = {
        "command": "cmake",
        "args": [
            "-GNinja",
            "-Bbuild/llvm",
            "-Sllvm-project/llvm",
            "-DCMAKE_INSTALL_PREFIX={}/build/install/llvm".format(workspace),
            "-DLLVM_ENABLE_PROJECTS=clang;clang-tools-extra;lld",
            "-DCMAKE_BUILD_TYPE=MinSizeRel",
        ],
    },
)

run.add_exec(
    rule = {"name": "build", "deps": ["configure"]},
    exec = {
        "command": "ninja",
        "args": [
            "-Cbuild/llvm",
        ],
    },
)

run.add_exec(
    rule = {"name": "test", "deps": ["build"]},
    exec = {
        "command": "ninja",
        "args": [
            "-Cbuild/llvm",
            "check-all",
        ],
    },
)

run.add_exec(
    rule = {"name": "install", "deps": ["test"] },
    exec = {
        "command": "ninja",
        "args": [
            "-Cbuild/llvm",
            "install",
        ],
    },
)
