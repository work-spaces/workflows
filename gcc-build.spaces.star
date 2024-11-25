"""
Checkout script to build and publish gcc binaries.

This script is a work in progress. It doesn't currently build GCC successfully.

"""

load("//spaces-starlark-sdk/star/spaces-env.star", "spaces_working_env")
load("//spaces-starlark-sdk/star/checkout.star", "checkout_add_archive")
load("//spaces-starlark-sdk/star/run.star", "run_add_exec")

gmp_version = "6.3.0"
gmp_sha256 = "a3c2b80201b89e68616f4ad30bc66aee4927c3ce50e33929ca819d5c43538898"
mpfr_version = "4.2.1"
mpfr_sha256 = "116715552bd966c85b417c424db1bbdf639f53836eb361549d1f8d6ded5cb4c6"
mpc_version = "1.3.1"
mpc_sha256 = "ab642492f5cf882b74aa0cb730cd410a81edcdbec895183ce930e706c1c759b8"
gcc_version = "12.2.0"
gcc_sha256 = "ac6b317eb4d25444d87cf29c0d141dedc1323a1833ec9995211b13e1a851261c"

# Download source for GMP
checkout_add_archive(
    "gmp",
    url = "https://gmplib.org/download/gmp/gmp-{}.tar.xz".format(gmp_version),
    sha256 = gmp_sha256,
    add_prefix = "./",
)

# Download source for MPFR
checkout_add_archive(
    "mpfr",
    url = "https://www.mpfr.org/mpfr-current/mpfr-{}.tar.gz".format(mpfr_version),
    sha256 = mpfr_sha256,
    add_prefix = "./",
)

# Download source for MPC
checkout_add_archive(
    "mpc",
    url = "https://ftp.gnu.org/gnu/mpc/mpc-{}.tar.gz".format(mpc_version),
    sha256 = mpc_sha256,
    add_prefix = "./",
)

# Download source for GCC
checkout_add_archive(
    "gcc",
    url = "http://mirrors.concertpass.com/gcc/releases/gcc-{}/gcc-{}.tar.gz".format(gcc_version, gcc_version),
    sha256 = gcc_sha256,
    add_prefix = "./",
)

spaces_working_env()

workspace_path = info.get_absolute_path_to_workspace()
cpu_count = info.get_cpu_count()
job_arg = "-j{}".format(cpu_count)
install_prefix = "{}/build/install".format(workspace_path)
prefix_arg = "--prefix={}".format(install_prefix)

def create_build_dir(rule_name_base):
    run_add_exec(
        "{}_prepare".format(rule_name_base),
        command = "mkdir",
        args = ["-p", "build/{}".format(rule_name_base)],
    )

create_build_dir("gmp")

run_add_exec(
    "gmp_configure",
    deps = ["gmp_prepare"],
    command = "../../gmp-{}/configure".format(gmp_version),
    args = [prefix_arg, "--with-pic"],
    working_directory = "build/gmp",
)

def build_and_install(rule_name_base):
    build_dir = "build/{}".format(rule_name_base)
    run_add_exec(
        "{}_build".format(rule_name_base),
        deps = ["{}_configure".format(rule_name_base)],
        command = "make",
        args = [job_arg],
        working_directory = build_dir,
    )

    run_add_exec(
        "{}_install".format(rule_name_base),
        deps = ["{}_build".format(rule_name_base)],
        command = "make",
        args = ["install"],
        working_directory = build_dir,
    )

build_and_install("gmp")

create_build_dir("mpfr")
run_add_exec(
    "mpfr_configure",
    deps = ["mpfr_prepare", "gmp_install"],
    help = "Configure mpfr",
    command = "../../mpfr-{}/configure".format(mpfr_version),
    args = [
        prefix_arg,
        "--with-pic",
        "--with-gmp={}".format(install_prefix),
    ],
    working_directory = "build/mpfr",
)

build_and_install("mpfr")

create_build_dir("mpc")
run_add_exec(
    "mpc_configure",
    deps = ["mpc_prepare", "gmp_install", "mpfr_install"],
    help = "Configure mpc",
    command = "../../mpc-{}/configure".format(mpc_version),
    args = [
        prefix_arg,
        "--with-pic",
        "--with-gmp={}".format(install_prefix),
        "--with-mpfr={}".format(install_prefix),
    ],
    working_directory = "build/mpc",
)

build_and_install("mpc")

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

#build_and_install("gcc")
