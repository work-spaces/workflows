"""
Checkout llvm, cmake, and ninja for a complete build system and toolchain.
"""

load("spaces-starlark-sdk/star/spaces-env.star", "spaces_working_env")

load("spaces-starlark-sdk/packages/github.com/llvm/llvm-project/llvmorg-19.1.3.star", llvm19_platforms = "platforms")
load("spaces-starlark-sdk/star/llvm.star", "add_llvm")

load("spaces-starlark-sdk/packages/github.com/Kitware/CMake/v3.30.5.star", cmake3_platforms = "platforms")
load("spaces-starlark-sdk/star/cmake.star", "add_cmake")

load("spaces-starlark-sdk/packages/github.com/ninja-build/ninja/v1.12.1.star", ninja1_platforms = "platforms")


add_cmake(
    rule_name = "cmake3",
    platforms = cmake3_platforms)

checkout.add_platform_archive(
    rule = {"name": "ninja1"},
    platforms = ninja1_platforms,
)

add_llvm(
    rule_name = "llvm19",
    platforms = llvm19_platforms,
    toolchain_name = "llvm-19-toolchain.cmake")


readme_content = """

To build and execute a simple program using llvm-19 and cmake/ninja:

```
spaces run
./build/hello
```

"""

checkout.add_asset(
    rule = {"name": "readme"},
    asset = {
        "destination": "llvm-19-README.md",
        "content": readme_content,
    },
)

cmakelists_content = """
cmake_minimum_required(VERSION 3.20)
set(CMAKE_TOOLCHAIN_FILE llvm-19-toolchain.cmake)
project(hello_world)
add_executable(hello main.cpp)
"""

checkout.add_asset(
    rule = {"name": "cmakelists"},
    asset = {
        "destination": "CMakeLists.txt",
        "content": cmakelists_content,
    },
)

main_cpp_content = """
#include <iostream>

int main(){
    std::cout << "Hello World!\\n";
    return 0;
}
"""

checkout.add_asset(
    rule = {"name": "main_cpp"},
    asset = {
        "destination": "main.cpp",
        "content": main_cpp_content,
    },
)

spaces_star_content = """
run.add_exec(
    rule = {"name": "configure", "help": "Configure the build system"},
    exec = {
        "command": "cmake",
        "args": ["-GNinja", "-Bbuild"],
    }
)

run.add_exec(
    rule = {"name": "build", "deps": ["configure"], "help": "Build the build/hello binary"},
    exec = {
        "command": "ninja",
        "args": ["-Cbuild"],
    }
)
"""

checkout.add_asset(
    rule = {"name": "spaces_star"},
    asset = {
        "destination": "spaces.star",
        "content": spaces_star_content,
    },
)

# basic spaces environment - adds /usr/bin and /bin to PATH
spaces_working_env()
