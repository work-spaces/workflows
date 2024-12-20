"""
Checkout script to build and publish gcc binaries.

This script is a work in progress. It doesn't build GCC successfully.

"""

load("//@sdk/sdk/star/spaces-env.star", "spaces_working_env")

load(
    "//@sdk/sdk/star/capsule.star",
    "capsule_checkout",
    "capsule_checkout_add_workflow_repo",
)

capsules_workflow_checkout_rule = capsule_checkout_add_workflow_repo(
    "capsules",
    url = "https://github.com/work-spaces/capsules",
    rev = "main",
)

env_rule = spaces_working_env()

def gnu_capsule_checkout(name, version):
    capsule_checkout(
        name,
        scripts = [
            "capsules/ftp.gnu.org/preload",
            "capsules/ftp.gnu.org/{}-{}".format(name, version),
        ],
        deps = [capsules_workflow_checkout_rule],
        prefix = "build/install",
    )

gnu_capsule_checkout("gmp", "v6")
gnu_capsule_checkout("mpfr", "v4")
gnu_capsule_checkout("mpc", "v1")

_ignore = '''
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

gnu_add_configure_make_install_from_source(
    "binutils",
    url = "https://ftp.gnu.org/gnu/binutils/binutils-{}.tar.xz".format(binutils_version),
    sha256 = binutils_sha256,
    source_directory = "binutils-{}".format(binutils_version),
    configure_args = [
        prefix_arg,
        "--with-pic",
        "--with-gmp={}".format(install_prefix),
        "--with-mpfr={}".format(install_prefix),
        "--with-mpc={}".format(install_prefix),
    ],
)

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

