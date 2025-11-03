"""
Sample workflow that builds and flashes a Zephyr application for STM32.
"""


load("//@star/packages/star/spaces-cli.star", "spaces_isolate_workspace")
load("//@star/sdk/star/cmake.star", "cmake_add_configure_build_install")
load("//@star/packages/star/llvm.star", "llvm_add")
load("//@star/packages/star/starship.star", "starship_add_bash")
load("//@star/packages/star/cmake.star", "cmake_add")
load("//@star/packages/star/ccache.star", "ccache_add")
load("//@star/packages/star/package.star", "package_add")
load("//@star/packages/star/python.star", "python_add_uv")

load("//@star/sdk/star/info.star", "info_set_minimum_version")
load(
    "//@star/sdk/star/checkout.star",
    "checkout_add_repo",
    "checkout_update_env",
    "checkout_add_platform_archive"
)

load(
    "//@star/sdk/star/run.star",
    "run_add_exec_setup",
    "run_add_exec"
)

info_set_minimum_version("0.15.5")
cmake_add("cmake3", "v3.30.5")
ccache_add("ccache", "v4.10.2")
package_add("github.com", "ninja-build", "ninja", "v1.12.1")

spaces_isolate_workspace("spaces_isolated_workspace", version = "v0.15.5")

checkout_update_env(
    "use_system_path",
    system_paths = ["/bin", "/usr/bin"]
)

MACOS = {
    "url": "https://github.com/zephyrproject-rtos/sdk-ng/releases/download/v0.17.4/zephyr-sdk-0.17.4_macos-x86_64.tar.xz",
    "sha256": "5b813b5c3759412fdd68819023926f6db25ef26977e40db12edc0ab701196dca",
    "add_prefix": "sysroot",
    "strip_prefix": "",
    "link": "Hard"
}

checkout_add_platform_archive(
    "zephyr-sdk",
    platforms = {
        "macos-x86_64": MACOS,
        "macos-aarch64": MACOS,
        "linux-x86_64": {
            "url":"https://github.com/zephyrproject-rtos/sdk-ng/releases/download/v0.17.4/zephyr-sdk-0.17.4_linux-x86_64.tar.xz",
            "sha256": "83f2f327dba2d6cf2440f22f2f501041544d7f34ef8b878ecd83f4513d1116b6",
            "link": "Hard"
        },
    }
)
starship_add_bash("starship_bash", shortcuts = {
    "setup": "spaces run //:setup",
    "build_blinky": "spaces run //zephyr-stm32:west_build_blinky",
})

python_add_uv(
    "python3",
    uv_version = "0.4.29",
    ruff_version = "0.8.0",
    python_version = "3.13",
    packages = ["pip", "west==v1.5.0"])

run_add_exec_setup(
    "west_init_project",
    command = "west",
    args = ["init", "./zephyr-stm32"],
    deps = ["python3_packages"]
)

run_add_exec_setup(
    "west_update",
    command = "west",
    args = ["update"],
    deps = ["west_init_project"],
    working_directory = "//zephyr-stm32"
)

run_add_exec_setup(
    "west_packages_pip_install",
    command = "west",
    args = ["packages", "pip", "--install"],
    deps = ["west_update"],
    working_directory = "//zephyr-stm32"
)

run_add_exec_setup(
    "west_cmake_export",
    command = "west",
    args = ["zephyr-export"],
    deps = ["west_packages_pip_install"],
    working_directory = "//zephyr-stm32"
)

run_add_exec(
    "west_build_blinky",
    command = "west",
    args = ["build", "-p", "always", "-b", "nucleo_u575zi_q", "samples/basic/blinky"],
    working_directory = "//zephyr-stm32/zephyr"
)
