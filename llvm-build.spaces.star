"""
Building LLVM using Spaces

Use:

```
spaces checkout --workflow=workflows:preload,llvm16-config,llvm-build --name=llvm16-build
spaces checkout --workflow=workflows:preload,llvm17-config,llvm-build --name=llvm17-build
```

"""

load("//@star/packages/star/cmake.star", "cmake_add")
load("//@star/sdk/star/run.star", "run_add_exec")
load("//@star/sdk/star/gh.star", "gh_add_publish_archive")
load("//@star/packages/star/python.star", "python_add_uv")
load("//@star/packages/star/package.star", "package_add")
load(
    "//@star/sdk/star/checkout.star",
    "checkout_add_archive",
    "checkout_update_env",
)
load(
    "//llvm-config.star",
    llvm_sha256 = "sha256",
    llvm_deploy_repo = "deploy_repo",
    llvm_version = "version",
)

info.set_minimum_version("0.11.6")

# CMake is required to build LLVM
cmake_add("cmake3", "v3.30.5")

# python with psutil is required for the test suite
python_add_uv(
    "python3",
    uv_version = "0.4.29",
    ruff_version = "0.8.0",
    python_version = "3.8",
    packages = ["psutil", "numpy"],
)

# LLVM could also be built with make but ninja is nicer
package_add("github.com", "ninja-build", "ninja", "v1.12.1")

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

install_path = "{}/build/install/llvm".format(workspace)

run_add_exec(
    "configure",
    command = "cmake",
    args = [
        "-GNinja",
        "-DPython3_EXECUTABLE={}/venv/bin/python3".format(workspace),
        "-Bbuild/llvm",
        "-Sllvm-project/llvm",
        "-DCMAKE_INSTALL_PREFIX={}".format(install_path),
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
    "llvm",
    deploy_repo = llvm_deploy_repo,
    version = llvm_version,
    input = install_path,
    deps = ["install"],
)
