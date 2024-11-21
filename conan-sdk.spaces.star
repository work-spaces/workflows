"""
This is an example of how to get conan running in your workspace.
"""

load("spaces-starlark-sdk/star/spaces-env.star", "spaces_working_env")
load("spaces-starlark-sdk/packages/github.com/astral-sh/uv/0.4.29.star", uv_platforms = "platforms")
load("spaces-starlark-sdk/star/python.star", "add_uv_python")
load("spaces-starlark-sdk/packages/github.com/Kitware/CMake/v3.30.5.star", cmake3_platforms = "platforms")
load("spaces-starlark-sdk/star/cmake.star", "add_cmake")
load("spaces-starlark-sdk/packages/github.com/ninja-build/ninja/v1.12.1.star", ninja1_platforms = "platforms")

add_uv_python(
    rule_name = "python3",
    uv_platforms = uv_platforms,
    python_version = "3.12",
    packages = ["conan"],
)

add_cmake(
    rule_name = "cmake3",
    platforms = cmake3_platforms,
)

checkout.add_platform_archive(
    rule = {"name": "ninja1"},
    platforms = ninja1_platforms,
)

checkout.add_repo(
    rule = {"name": "examples2"},
    repo = {
        "url": "https://github.com/conan-io/examples2",
        "rev": "main",
        "checkout": "Revision",
        "clone": "Worktree"
    },
)

# This will add /usr/bin and /bin to the path so you can
# work in the command line after running `source env`
spaces_working_env()

workspace = info.get_absolute_path_to_workspace()

checkout.update_env(
    rule = {"name": "conan_env"},
    env = {
        "vars": {
            "CONAN_HOME": "{}/.conan".format(workspace),
        },
        "paths": []
    }
)

store_path = info.get_path_to_store()

conan_global_config = """
core.cache:storage_path = {}/conan_cache
""".format(store_path)

checkout.add_asset(
    rule = {"name": "conan_global_config"},
    asset = {
        "destination": "{}/.conan/global.conf".format(workspace),
        "content": conan_global_config
    }
)

profile_exists = fs.exists("{}/.conan/profiles/default".format(workspace))

run.add_exec(
    rule = {"name": "conan_profile_detect"},
    exec = {
        "command": "conan",
        "args": [
            "profile",
            "detect",
        ] if not profile_exists else ["--version"],
    },
)

run.add_exec(
    rule = {"name": "simple_cmake_project_conan_install", "deps": ["conan_profile_detect"]},
    exec = {
        "command": "conan",
        "args": [
            "install",
            ".",
            "--output-folder=build",
            "--build=missing",
        ],
        "working_directory": "examples2/tutorial/consuming_packages/simple_cmake_project",
    },
)

run.add_exec(
    rule = {"name": "simple_cmake_project_configure", "deps": ["simple_cmake_project_conan_install"]},
    exec = {
        "command": "cmake",
        "args": [
            "-DCMAKE_TOOLCHAIN_FILE=conan_toolchain.cmake",
            "-DCMAKE_BUILD_TYPE=Release",
            "-GNinja",
            "-Sexamples2/tutorial/consuming_packages/simple_cmake_project",
            "-Bexamples2/tutorial/consuming_packages/simple_cmake_project/build",
        ],
    },
)

run.add_exec(
    rule = {"name": "simple_cmake_project_build", "deps": ["simple_cmake_project_configure"]},
    exec = {
        "command": "ninja",
        "args": [
            "-Cexamples2/tutorial/consuming_packages/simple_cmake_project/build",
        ],
    },
)
