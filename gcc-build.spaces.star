"""
Checkout script to build and publish gcc binaries.

This script is a work in progress. It doesn't build GCC successfully.

"""

load(
    "//@packages/star/github.com/packages.star",
    github_packages = "packages",
)
load("//@sdk/star/spaces-env.star", "spaces_working_env")
load("//@sdk/star/checkout.star", "checkout_add_archive", "checkout_add_platform_archive")
load("//@sdk/star/run.star", "run_add_exec")
load("//@sdk/star/autotools.star", "autotools_add_source_archive")

gmp_version = "6.3.0"
gmp_sha256 = "a3c2b80201b89e68616f4ad30bc66aee4927c3ce50e33929ca819d5c43538898"
mpfr_version = "4.2.1"
mpfr_sha256 = "116715552bd966c85b417c424db1bbdf639f53836eb361549d1f8d6ded5cb4c6"
mpc_version = "1.3.1"
mpc_sha256 = "ab642492f5cf882b74aa0cb730cd410a81edcdbec895183ce930e706c1c759b8"

binutils_version = "2.43"
binutils_sha256 = "b53606f443ac8f01d1d5fc9c39497f2af322d99e14cea5c0b4b124d630379365"

gcc_version = "12.2.0"
gcc_sha256 = "ac6b317eb4d25444d87cf29c0d141dedc1323a1833ec9995211b13e1a851261c"


workspace_path = info.get_absolute_path_to_workspace()
cpu_count = info.get_cpu_count()
job_arg = "-j{}".format(cpu_count)
install_prefix = "{}/build/install".format(workspace_path)
prefix_arg = "--prefix={}".format(install_prefix)

checkout_add_platform_archive(
    "m4-1",
    platforms = github_packages["xpack-dev-tools"]["m4-xpack"]["v1.4.19-3"],
)

checkout_add_platform_archive(
    "spaces0",
    platforms = github_packages["work-spaces"]["spaces"]["v0.10.4"],
)

autotools_add_source_archive(
    "gmp",
    url = "https://gmplib.org/download/gmp/gmp-{}.tar.xz".format(gmp_version),
    sha256 = gmp_sha256,
    source_directory = "gmp-{}".format(gmp_version),
    configure_args = [prefix_arg, "--with-pic"],
)

autotools_add_source_archive(
    "mpfr",
    url = "https://www.mpfr.org/mpfr-current/mpfr-{}.tar.gz".format(mpfr_version),
    sha256 = mpfr_sha256,
    deps = ["gmp_install"],
    source_directory = "mpfr-{}".format(mpfr_version),
    configure_args = [
        prefix_arg,
        "--with-pic",
        "--with-gmp={}".format(install_prefix),
    ],
)

autotools_add_source_archive(
    "mpc",
    url = "https://ftp.gnu.org/gnu/mpc/mpc-{}.tar.gz".format(mpc_version),
    sha256 = mpc_sha256,
    deps = ["gmp_install", "mpfr_install"],
    source_directory = "mpc-{}".format(mpc_version),
    configure_args = [
        prefix_arg,
        "--with-pic",
        "--with-gmp={}".format(install_prefix),
        "--with-mpfr={}".format(install_prefix),
    ],
)

autotools_add_source_archive(
    "binutils",
    url = "https://ftp.gnu.org/gnu/binutils/binutils-{}.tar.xz".format(binutils_version),
    sha256 = binutils_sha256,
    deps = ["gmp_install", "mpfr_install", "mpc_install"],
    source_directory = "binutils-{}".format(binutils_version),
    configure_args = [
        prefix_arg,
        "--with-pic",
        "--with-gmp={}".format(install_prefix),
        "--with-mpfr={}".format(install_prefix),
        "--with-mpc={}".format(install_prefix),
    ],
)

spaces_working_env()

'''

# Download source for GCC
checkout_add_archive(
    "gcc",
    url = "http://mirrors.concertpass.com/gcc/releases/gcc-{}/gcc-{}.tar.gz".format(gcc_version, gcc_version),
    sha256 = gcc_sha256,
    add_prefix = "./",
)



with_sysroot = ["--with-sysroot=/Library/Developer/CommandLineTools/SDKs/MacOSX.sdk"] if info.is_platform_macos() else []

create_build_dir("gcc")
run_add_exec(
    "gcc_configure",
    deps = ["gcc_prepare", "mpc_install"],
    help = "Configure gcc",
    command = "../../gcc-{}/configure".format(gcc_version),
    args = [
        "AR=ar",
        prefix_arg,
        "--with-pic",
        "--with-gmp={}".format(install_prefix),
        "--with-mpfr={}".format(install_prefix),
        "--with-mpc={}".format(install_prefix),
        "--with-gcc-major-version-only",
        "--disable-nls",
        "--enable-languages=c,c++",
    ] + with_sysroot,
    working_directory = "build/gcc",
)
'''

