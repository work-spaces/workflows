"""
Build Ruby using ruby-build.
"""

load("//@sdk/packages/star/github.com/packages.star", github_packages = "packages")
load("//@sdk/sdk/star/checkout.star", "checkout_add_platform_archive", "checkout_add_repo", "checkout_update_env")
load("//@sdk/sdk/star/autotools.star", "autotools_add_source_archive")
load("//@sdk/sdk/star/cmake.star", "add_cmake", "cmake_add_repo")
load("//@sdk/sdk/star/openssl.star", "openssl_add")
load("//@sdk/sdk/star/run.star", "run_add_exec")
load("//@sdk/sdk/star/rpath.star", "rpath_update_macos_install_dir")

checkout_add_platform_archive(
    "spaces0",
    platforms = github_packages["work-spaces"]["spaces"]["v0.10.4"],
)

openssl_add("openssl", "openssl-3.4.0", configure_args = ["-no-apps"])

gmp_version = "6.3.0"
gmp_sha256 = "a3c2b80201b89e68616f4ad30bc66aee4927c3ce50e33929ca819d5c43538898"

readline_version = "8.2"
readline_sha256 = "3feb7171f16a84ee82ca18a36d7b9be109a52c04f492a053331d7d1095007c35"

ruby_version = "3.1.5"

add_cmake(
    "cmake3",
    platforms = github_packages["Kitware"]["CMake"]["v3.31.1"],
)

checkout_add_platform_archive(
    "ninja1",
    platforms = github_packages["ninja-build"]["ninja"]["v1.12.1"],
)

autotools_add_source_archive(
    "readline",
    url = "https://ftp.gnu.org/gnu/readline/readline-{}.tar.gz".format(readline_version),
    sha256 = readline_sha256,
    source_directory = "readline-{}".format(readline_version),
    configure_args = ["--with-pic", "--enable-static"],
)

autotools_add_source_archive(
    "gmp",
    url = "https://gmplib.org/download/gmp/gmp-{}.tar.xz".format(gmp_version),
    sha256 = gmp_sha256,
    source_directory = "gmp-{}".format(gmp_version),
    configure_args = ["--with-pic", "--enable-static"],
)

cmake_add_repo(
    "libyaml",
    url = "https://github.com/yaml/libyaml",
    rev = "0.2.5",
    configure_args = ["-GNinja"],
    build_artifact_globs = [
        "+build/libyaml/**/libyaml.a",
        "+libyaml/**/yaml.h",
        "+build/libyaml/**/yaml*.cmake",
    ],
)

checkout_add_repo(
    "ruby-build",
    url = "https://github.com/rbenv/ruby-build",
    rev = "v20241105",
    clone = "Blobless",
)

checkout_update_env(
    "update_build_env",
    paths = ["/usr/bin", "/bin"],
)

workspace = info.get_absolute_path_to_workspace()
install_dir = "{}/build/install".format(workspace)

run_add_exec(
    "build_ruby",
    command = "./ruby-build/bin/ruby-build",
    inputs = [
        "+ruby-build/**",
        "+build/install/include/**",
        "+build/install/lib/**/*.a",
        "-build/install/**/ruby/**",
    ],
    deps = ["gmp_install", "readline_install", "libyaml_install", "openssl_install"],
    args = [
        ruby_version,
        "{}/build/install".format(workspace),
        "--",
        "--with-gmp-dir={}".format(install_dir),
        "--with-libyaml-dir={}".format(install_dir),
        "--with-openssl-dir={}".format(install_dir),
        "--with-readline-dir={}".format(install_dir),
    ],
)

rpath_update_macos_install_dir(
    "update_macos_rpaths",
    install_dir,
    deps = ["build_ruby"],
)
