"""
This is an example of how to get conan running in your workspace.
"""

load("//@sdk/sdk/star/spaces-env.star", "spaces_working_env")
load("//@sdk/sdk/star/python.star", "python_add_uv")
load("//@sdk/packages/star/github.com/packages.star", github_packages = "packages")
load("//@sdk/sdk/star/cmake.star", "cmake_add")
load(
    "//@sdk/sdk/star/checkout.star",
    "checkout_add_asset",
    "checkout_add_platform_archive",
    "checkout_add_repo",
    "checkout_update_env",
)
load("//@sdk/sdk/star/run.star", "run_add_exec")

python_add_uv(
    "python3",
    uv_version = "0.5.4",
    ruff_version = "0.8.0",
    python_version = "3.12",
    packages = ["conan"],
)

cmake_add(
    "cmake3",
    version = "v3.30.5",
)

checkout_add_platform_archive(
    "ninja1",
    platforms = github_packages["ninja-build"]["ninja"]["v1.12.1"],
)

checkout_add_repo(
    "examples2",
    url = "https://github.com/conan-io/examples2",
    rev = "main",
    clone = "Worktree",
)

# This will add /usr/bin and /bin to the path so you can
# work in the command line after running `source env`
spaces_working_env()

workspace = info.get_absolute_path_to_workspace()

checkout_update_env(
    "conan_env",
    vars = {
        "CONAN_HOME": "{}/.conan".format(workspace),
    },
)

store_path = info.get_path_to_store()

conan_global_config = """
core.cache:storage_path = {}/conan_cache
""".format(store_path)

checkout_add_asset(
    "conan_global_config",
    destination = "{}/.conan/global.conf".format(workspace),
    content = conan_global_config,
)

profile_exists = fs.exists("{}/.conan/profiles/default".format(workspace))

run_add_exec(
    "conan_profile_detect",
    command = "conan",
    args = [
        "profile",
        "detect",
    ] if not profile_exists else ["--version"],
)

run_add_exec(
    "simple_cmake_project_conan_install",
    deps = ["conan_profile_detect"],
    command = "conan",
    args = [
        "install",
        ".",
        "--output-folder=build",
        "--build=missing",
    ],
    working_directory = "examples2/tutorial/consuming_packages/simple_cmake_project",
)

run_add_exec(
    "simple_cmake_project_configure",
    deps = ["simple_cmake_project_conan_install"],
    command = "cmake",
    args = [
        "-DCMAKE_TOOLCHAIN_FILE=conan_toolchain.cmake",
        "-DCMAKE_BUILD_TYPE=Release",
        "-GNinja",
        "-Sexamples2/tutorial/consuming_packages/simple_cmake_project",
        "-Bexamples2/tutorial/consuming_packages/simple_cmake_project/build",
    ],
)

run_add_exec(
    "simple_cmake_project_build",
    deps = ["simple_cmake_project_configure"],
    command = "ninja",
    args = [
        "-Cexamples2/tutorial/consuming_packages/simple_cmake_project/build",
    ],
)
