"""
Workflow to build git

Currently broken: needs to be ported to the new capsule system

"""

load("//@star/sdk/star/checkout.star", "checkout_add_archive", "checkout_update_env")
load("//@star/sdk/star/run.star", "run_add_exec", "run_add_to_all")
load("//@star/packages/star/cmake.star", "cmake_add")
load("//@star/packages/star/spaces-cli.star", "spaces_add")
load("//@star/packages/star/package.star", "package_add")
load("//@star/sdk/star/info.star", "info_get_cpu_count")
load("//@star/sdk/star/ws.star",
    "workspace_get_absolute_path",
    "workspace_get_env_var")
load("//@star/sdk/star/rpath.star", "rpath_update_macos_install_dir")
load("//@star/sources/star/gnu.star", "gnu_add_configure_make_install_from_source")
load("//@star/sdk/star/cmake.star", "cmake_add_repo")
load("//@star/sdk/star/spaces-env.star", "spaces_working_env")

GIT_VERSION = "2.45.1"
GIT_SHA256 = "10acb581993061e616be9c5674469335922025a666318e0748cb8306079fef24"
CPUS = info_get_cpu_count()
WORKSPACE = workspace_get_absolute_path()
LOCAL_INSTALL_PATH = "build/install"
INSTALL_PATH = "{}/{}".format(WORKSPACE, LOCAL_INSTALL_PATH)
SOURCE_DIRECTORY = "git-{}".format(GIT_VERSION)
JOB_ARGS = ["-j{}".format(CPUS)]

spaces_working_env()
cmake_add("cmake3", "v3.31.5")
spaces_add("spaces0", "v0.14.7")
package_add("github.com", "ninja-build", "ninja", "v1.12.1")

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
    "zlib",
    url = "https://github.com/madler/zlib",
    rev = "v1.3.1",
    configure_args = [
        "-GNinja"
    ]
)


checkout_add_archive(
    "git-{}".format(GIT_VERSION),
    url = "https://www.kernel.org/pub/software/scm/git/git-{}.tar.gz".format(GIT_VERSION),
    sha256 = GIT_SHA256,
)

checkout_update_env(
    "git-build-env",
    vars = {
        "CFLAGS": "-I{}/include".format(INSTALL_PATH),
        "CPPFLAGS": "-I{}/include".format(INSTALL_PATH),
        "LDFLAGS": "-L{}/lib".format(INSTALL_PATH),
    },
)

GIT_ENV = {
    "PATH": "{}/bin:{}".format(INSTALL_PATH, workspace_get_env_var("PATH")),
}

run_add_exec(
    "git-configure",
    command = "./configure".format(SOURCE_DIRECTORY),
    args = [
        "--prefix={}".format(INSTALL_PATH),
        "--with-zlib={}".format(INSTALL_PATH),
        "--with-iconv={}".format(INSTALL_PATH),
    ],
    deps = ["gettext", "libiconv", "zlib"],
    working_directory = SOURCE_DIRECTORY,
    help = "Build git",
    env = GIT_ENV,
)

run_add_exec(
    "git-build",
    command = "make",
    args = JOB_ARGS,
    deps = ["git-configure"],
    working_directory = SOURCE_DIRECTORY,
    help = "Build git",
    env = GIT_ENV,
)

run_add_exec(
    "git-install",
    command = "make",
    args = ["install"],
    deps = ["git-build"],
    working_directory = SOURCE_DIRECTORY,
    help = "Install git",
    env = GIT_ENV,
)

rpath_update_macos_install_dir(
    "update_macos_rpath",
    install_path = INSTALL_PATH,
    deps = ["git-install"],
)

run_add_to_all("all", deps = ["update_macos_rpath"])
