"""
Checkout llvm, cmake, and ninja for a complete build system and toolchain.
"""

load("spaces-starlark-sdk/star/spaces-env.star", "spaces_working_env")
load("spaces-starlark-sdk/packages/github.com/llvm/llvm-project/llvmorg-19.1.3.star", llvm19_platforms = "platforms")
load("spaces-starlark-sdk/star/llvm.star", "add_llvm")
load("spaces-starlark-sdk/packages/github.com/Kitware/CMake/v3.30.5.star", cmake3_platforms = "platforms")
load("spaces-starlark-sdk/star/cmake.star", "add_cmake")
load("spaces-starlark-sdk/packages/github.com/ninja-build/ninja/v1.12.1.star", ninja1_platforms = "platforms")
load("spaces-starlark-sdk/star/checkout.star", "checkout_add_asset", "checkout_add_platform_archive")
load("spaces-starlark-sdk/star/run.star", "run_add_exec")

info.set_minimum_version("0.10.3")

add_cmake(
    rule_name = "cmake3",
    platforms = cmake3_platforms,
)

checkout_add_platform_archive(
    "ninja1",
    platforms = ninja1_platforms,
)

add_llvm(
    rule_name = "llvm19",
    platforms = llvm19_platforms,
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
