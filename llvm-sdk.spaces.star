"""
Checkout llvm, cmake, and ninja for a complete build system and toolchain.
"""

load("//@sdk/sdk/star/spaces-env.star", "spaces_working_env")
load("//@sdk/sdk/star/llvm.star", "llvm_add")
load("//@sdk/sdk/star/cmake.star", "cmake_add")
load(
    "//@sdk/sdk/star/checkout.star",
    "checkout_add_asset",
    "checkout_add_platform_archive",
)
load("//@sdk/sdk/star/run.star", "run_add_exec")
load("//@sdk/packages/star/github.com/packages.star", github_packages = "packages")

info.set_minimum_version("0.10.3")

cmake_add(
    "cmake3",
    version = "v3.30.5",
)

checkout_add_platform_archive(
    "ninja1",
    platforms = github_packages["ninja-build"]["ninja"]["v1.12.1"],
)

llvm_add(
    "llvm19",
    version = "llvmorg-19.1.3",
    toolchain_name = "llvm-19-toolchain.cmake",
)

readme_content = """

To build and execute a simple program using llvm-19 and cmake/ninja:

```
spaces run
./build/hello
```

"""

checkout_add_asset(
    "readme",
    destination = "llvm-19-README.md",
    content = readme_content,
)

cmakelists_content = """
cmake_minimum_required(VERSION 3.20)
set(CMAKE_TOOLCHAIN_FILE llvm-19-toolchain.cmake)
project(hello_world)
add_executable(hello main.cpp)
"""

checkout_add_asset(
    "cmakelists",
    destination = "CMakeLists.txt",
    content = cmakelists_content,
)

main_cpp_content = """
#include <iostream>

int main(){
    std::cout << "Hello World!\\n";
    return 0;
}
"""

checkout_add_asset(
    "main_cpp",
    destination = "main.cpp",
    content = main_cpp_content,
)

# basic spaces environment - adds /usr/bin and /bin to PATH
spaces_working_env()

run_add_exec(
    "configure",
    help = "Configure the build system",
    command = "cmake",
    args = ["-GNinja", "-Bbuild"],
)

run_add_exec(
    "build",
    deps = ["configure"],
    help = "Build the build/hello binary",
    command = "ninja",
    args = ["-Cbuild"],
)
