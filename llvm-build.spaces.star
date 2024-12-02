"""
Building LLVM using Spaces

Use:

```
spaces checkout --script=workflows/preload --script=workflows/llvm16-config --script=workflows/llvm-build --name=llvm16-build
spaces checkout --script=workflows/preload --script=workflows/llvm17-config --script=workflows/llvm-build --name=llvm17-build
```

"""

load("//@packages/star/github.com/packages.star", github_packages = "packages")
load("//@sdk/star/cmake.star", "cmake_add")
load("//@sdk/star/run.star", "run_add_exec")
load("//@sdk/star/gh.star", "gh_add_publish_archive")
load("//@sdk/star/python.star", "python_add_uv")
load(
    "//@sdk/star/checkout.star",
    "checkout_add_archive",
    "checkout_add_platform_archive",
    "checkout_update_env",
)
load("//llvm-config.star", llvm_sha256 = "sha256", llvm_version = "version")

info.set_minimum_version("0.10.3")

# CMake is required to build LLVM
cmake_add(
    "cmake3",
    version = "v3.30.5",
)

# Used for publishing
checkout_add_platform_archive(
    "gh2",
    platforms = github_packages["cli"]["cli"]["v2.62.0"],
)

# python with psutil is required for the test suite
python_add_uv(
    "python3",
    uv_version = "0.4.29",
    ruff_version = "0.8.0",
    python_version = "3.8",
    packages = ["psutil", "numpy"],
)

# LLVM could also be built with make but ninja is nicer
checkout_add_platform_archive(
    "ninja1",
    platforms = github_packages["ninja-build"]["ninja"]["v1.12.1"],
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

gh_add_publish_archive(
    name = "llvm",
    input = "build/install/llvm",
    version = llvm_version,
    deploy_repo = "https://github.com/work-spaces/tools",
    deps = ["install"],
)
