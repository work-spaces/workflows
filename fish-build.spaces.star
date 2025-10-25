"""
Build fish-shell from source and publish the binaries
"""

load("//@star/sdk/star/ws.star",
    "workspace_get_absolute_path")
load("//@star/sdk/star/spaces-env.star", "spaces_working_env")

load("//@star/packages/star/rust.star", "rust_add")
load("//@star/packages/star/cmake.star", "cmake_add")
load("//@star/packages/star/package.star", "package_add")
load("//@star/sources/star/gnu.star", "gnu_add_configure_make_install_from_source")

load("//@star/sdk/star/run.star", "run_add_exec")
load("//@star/sdk/star/cmake.star", "cmake_add_repo")
load("//@star/sdk/star/info.star", "info_is_platform_macos")

WORKSPACE = workspace_get_absolute_path()
LOCAL_INSTALL_PATH = "build/install"
INSTALL_PATH = "{}/{}".format(WORKSPACE, LOCAL_INSTALL_PATH)

spaces_working_env(add_spaces_to_sysroot=True, inherit_terminal=True)
cmake_add("cmake3", "v3.31.5")
rust_add("rust-toolchain", "1.91")
package_add("github.com", "ninja-build", "ninja", "v1.13.1")

gnu_add_configure_make_install_from_source(
    "libiconv",
    owner = "libiconv",
    repo = "libiconv",
    version = "1.17",
    configure_args = [
        "--enable-static=yes",
        "--enable-shared=no",
        "--without-libiconv-prefix",
        "--without-libintl-prefix",
        "--disable-nls",
        "--enable-extra-encodings",
        "--disable-rpath"
    ]
)

gnu_add_configure_make_install_from_source(
    "gettext",
    owner = "gettext",
    repo = "gettext",
    version = "0.22",
    configure_args = [
        "--disable-csharp",
        "--enable-relocatable",
        "--with-libiconv-prefix={}".format(INSTALL_PATH),
    ],
    deps = ["libiconv"],
)

cmake_add_repo(
    "pcre2",
    url = "https://github.com/PCRE2Project/pcre2",
    rev = "pcre2-10.47",
    configure_args = [
        "-DBUILD_SHARED_LIBS=OFF",
        "-GNinja"
    ],
    checkout_submodules = True,
)

cmake_add_repo(
    "fish-shell",
    url = "https://github.com/fish-shell/fish-shell",
    rev = "4.1.2",
    # This is required to find the Foundation framework on macOS
    find_using_cmake_system_path = info_is_platform_macos(),
    configure_args = [
        "-DBUILD_DOCS=OFF",
        "-DCMAKE_BUILD_TYPE=Release",
        "-GNinja",
        "-DFISH_USE_SYSTEM_PCRE2=OFF",
        "-DWITH_GETTEXT=ON"
    ],
    deps = ["pcre2", "libiconv", "gettext"]
)
