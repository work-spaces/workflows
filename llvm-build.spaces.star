"""
Building LLVM using Spaces

Use:

```
spaces checkout --script=workflows/preload --script=workflows/llvm16-config --script=workflows/llvm-build --name=llvm16-build
spaces checkout --script=workflows/preload --script=workflows/llvm17-config --script=workflows/llvm-build --name=llvm17-build
```

"""

load("//spaces-starlark-sdk/packages/github.com/Kitware/CMake/v3.30.5.star", cmake3_platforms = "platforms")
load("//spaces-starlark-sdk/star/cmake.star", "add_cmake")
load("//spaces-starlark-sdk/star/run.star", "run_add_exec")
load("//spaces-starlark-sdk/packages/github.com/cli/cli/v2.62.0.star", gh2_platforms = "platforms")
load("//spaces-starlark-sdk/star/gh.star", "add_publish_archive")
load("//spaces-starlark-sdk/packages/github.com/astral-sh/uv/0.4.29.star", uv_platforms = "platforms")
load("//spaces-starlark-sdk/packages/github.com/astral-sh/ruff/0.8.0.star", ruff_platforms = "platforms")
load("//spaces-starlark-sdk/star/python.star", "add_uv_python")
load(
    "//spaces-starlark-sdk/star/checkout.star",
    "checkout_add_archive",
    "checkout_add_platform_archive",
    "checkout_update_env",
)
load("//spaces-starlark-sdk/packages/github.com/ninja-build/ninja/v1.12.1.star", ninja1_platforms = "platforms")
load("//llvm-config.star", llvm_sha256 = "sha256", llvm_version = "version")

info.set_minimum_version("0.10.3")

# CMake is required to build LLVM
add_cmake(
    rule_name = "cmake3",
    platforms = cmake3_platforms,
)

# Used for publishing
checkout_add_platform_archive(
    "gh2",
    platforms = gh2_platforms,
)

# python with psutil is required for the test suite
add_uv_python(
    rule_name = "python3",
    uv_platforms = uv_platforms,
    ruff_platforms = ruff_platforms,
    python_version = "3.8",
    packages = ["psutil", "numpy"],
)

# LLVM could also be built with make but ninja is nicer
checkout_add_platform_archive(
    "ninja1",
    platforms = ninja1_platforms,
)

checkout_add_archive(
    "llvm-project",
    url = "https://github.com/llvm/llvm-project/archive/refs/tags/llvmorg-{}.zip".format(llvm_version),
    sha256 = llvm_sha256,
    strip_prefix = "llvm-project-llvmorg-{}".format(llvm_version),
    add_prefix = "llvm-project",
)

# This will add /usr/bin and /bin to the path so you can
# work in the command line after running `source env`
checkout_update_env(
    "llvm_env_update",
    paths = ["/usr/bin", "/usr/sbin", "/bin"],
)


workspace = info.get_absolute_path_to_workspace()

run_add_exec(
    "configure",
    command = "cmake",
    args = [
        "-GNinja",
        "-DPython3_EXECUTABLE={}/venv/bin/python3".format(workspace),
        "-Bbuild/llvm",
        "-Sllvm-project/llvm",
        "-DCMAKE_INSTALL_PREFIX={}/build/install/llvm".format(workspace),
        "-DLLVM_ENABLE_PROJECTS=clang;clang-tools-extra;lld",
        "-DCMAKE_BUILD_TYPE=MinSizeRel",
    ],
)

run_add_exec(
    "build",
    deps = ["configure"],
    command = "ninja",
    args = [
        "-Cbuild/llvm",
    ],
)

run_add_exec(
    "test",
    deps = ["build"],
    command = "ninja",
    args = [
        "-Cbuild/llvm",
        "check-all",
    ],
)

run_add_exec(
    "install",
    deps = ["test"],
    command = "ninja",
    args = [
        "-Cbuild/llvm",
        "install",
    ],
)

add_publish_archive(
    name = "llvm",
    input = "build/install/llvm",
    version = llvm_version,
    deploy_repo = "https://github.com/work-spaces/tools",
    deps = ["install"],
)
