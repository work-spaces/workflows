"""
Checkout llvm, cmake, and ninja for a complete build system and toolchain.
"""

load("//@star/sdk/star/spaces-env.star", "spaces_working_env")
load("//@star/sdk/star/cmake.star", "cmake_add_configure_build_install")
load("//@star/sdk/star/shell.star", "ls")
load("//@star/packages/star/llvm.star", "llvm_add")
load("//@star/packages/star/cmake.star", "cmake_add")
load("//@star/packages/star/ccache.star", "ccache_add")
load("//@star/packages/star/package.star", "package_add")
load(
    "//@star/sdk/star/checkout.star",
    "checkout_add_asset",
)
load(
    "//@star/sdk/star/run.star",
    "RUN_LOG_LEVEL_APP",
    "RUN_TYPE_ALL",
    "run_add_exec",
)
load("//@star/sdk/star/info.star", "info_set_minimum_version")

info_set_minimum_version("0.14.0")

cmake_add("cmake3", "v3.30.5")
ccache_add("ccache", "v4.10.2")
package_add("github.com", "ninja-build", "ninja", "v1.12.1")

llvm_add(
    "llvm19",
    version = "llvmorg-19.1.3",
    toolchain_name = "llvm-19-toolchain.cmake",
)

README_CONTENT = """

To build and execute a simple program using llvm-19 and cmake/ninja:

```
spaces run
./build/hello
```

"""

checkout_add_asset(
    "readme",
    destination = "llvm-19-README.md",
    content = README_CONTENT,
)

CMAKELISTS_CONTENT = """
cmake_minimum_required(VERSION 3.20)
set(CMAKE_TOOLCHAIN_FILE $ENV{SPACES_WORKSPACE}/llvm-19-toolchain.cmake)
project(hello_world)
add_executable(hello main.cpp)
"""

checkout_add_asset(
    "cmakelists",
    destination = "hello/CMakeLists.txt",
    content = CMAKELISTS_CONTENT,
)

MAIN_CPP_CONTENT = """
#include <iostream>

int main(){
    std::cout << "Hello World!\\n";
    return 0;
}
"""

checkout_add_asset(
    "main_cpp",
    destination = "hello/main.cpp",
    content = MAIN_CPP_CONTENT,
)

# basic spaces environment - adds /usr/bin and /bin to PATH
spaces_working_env()

cmake_add_configure_build_install(
    "hello",
    source_directory = "hello",
    skip_install = True,
    configure_args = [
        "-DCMAKE_CXX_COMPILER_LAUNCHER=ccache",
    ],
)

# This is just here to verify that the extensions.json
# file was checkout out correctly
ls(
    "check_vscode",
    path = ".vscode/extensions.json",
)

run_add_exec(
    "run",
    type = RUN_TYPE_ALL,
    deps = ["hello", "check_vscode"],
    help = "Run the build/hello binary",
    log_level = RUN_LOG_LEVEL_APP,
    redirect_stdout = "hello.txt",
    command = "build/hello/hello",
)
