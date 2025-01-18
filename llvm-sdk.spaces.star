"""
Checkout llvm, cmake, and ninja for a complete build system and toolchain.
"""

load("//@star/sdk/star/spaces-env.star", "spaces_working_env")
load("//@star/sdk/star/cmake.star", "cmake_add_configure_build_install")
load("//@star/packages/star/llvm.star", "llvm_add")
load("//@star/packages/star/cmake.star", "cmake_add")
load("//@star/packages/star/package.star", "package_add")
load(
    "//@star/sdk/star/checkout.star",
    "checkout_add_asset",
)
load("//@star/sdk/star/run.star", "run_add_exec")

info.set_minimum_version("0.11.6")

cmake_add("cmake3","v3.30.5")
package_add("github.com", "ninja-build", "ninja", "v1.12.1")

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
set(CMAKE_TOOLCHAIN_FILE $ENV{SPACES_WORKSPACE}/llvm-19-toolchain.cmake)
project(hello_world)
add_executable(hello main.cpp)
"""

checkout_add_asset(
    "cmakelists",
    destination = "hello/CMakeLists.txt",
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
    destination = "hello/main.cpp",
    content = main_cpp_content,
)

# basic spaces environment - adds /usr/bin and /bin to PATH
spaces_working_env()

cmake_add_configure_build_install(
    "hello",
    source_directory = "hello",
    skip_install = True
)

run_add_exec(
    "run",
    deps = ["hello"],
    help = "Run the build/hello binary",
    log_level = "App",
    command = "build/hello/hello",
)