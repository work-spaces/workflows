"""
Workflow to build git"
"""

load("//@star/sdk/star/checkout.star", "checkout_add_archive", "checkout_update_env")
load("//@star/sdk/star/run.star", "run_add_exec", "run_add_to_all")
load("//@star/sdk/star/info.star", "info_get_absolute_path_to_workspace", "info_get_cpu_count")
load("//@star/sdk/star/rpath.star", "rpath_update_macos_install_dir")
load("//@star/sdk/star/spaces-env.star", "spaces_working_env")
load(
    "//@star/sdk/star/capsule.star",
    "capsule",
    "capsule_checkout",
    "capsule_checkout_add_workflow_repo",
)

CAPSULE_CHECKOUT_RULE = "capsules"
GIT_VERSION = "2.45.1"
CPUS = info_get_cpu_count()
ENV_RULE = spaces_working_env(add_spaces_to_sysroot = True)
WORKSPACE = info_get_absolute_path_to_workspace()
LOCAL_INSTALL_PATH = "build/install"
INSTALL_PATH = "{}/{}".format(WORKSPACE, LOCAL_INSTALL_PATH)
SOURCE_DIRECTORY = "git-{}".format(GIT_VERSION)

capsule_checkout_add_workflow_repo(
    CAPSULE_CHECKOUT_RULE,
    url = "https://github.com/work-spaces/capsules",
    rev = "main",
)

def _checkout_capsule(domain, owner, name, version, extra_preload = []):
    capsule_checkout(
        name,
        descriptor = capsule(domain, owner, name),
        scripts = [
            "capsules/lock",
            "capsules/preload",
        ] + extra_preload + [
            "capsules/{}/{}/{}-{}".format(domain, owner, name, version),
        ],
        globs = ["+**", "-bin/**"],
        deps = [CAPSULE_CHECKOUT_RULE, ENV_RULE],
        prefix = "sysroot",
    )

def _checkout_gnu_capsule(name, version, owner = None):
    effective_owner = name if owner == None else owner
    capsule_checkout(
        name,
        descriptor = capsule("ftp.gnu.org", effective_owner, name),
        scripts = [
            "capsules/lock",
            "capsules/preload",
            "capsules/ftp.gnu.org/{}-{}".format(name, version),
        ],
        globs = ["+**", "-bin/**"],
        deps = [CAPSULE_CHECKOUT_RULE, ENV_RULE],
        prefix = LOCAL_INSTALL_PATH,
    )

_checkout_gnu_capsule("gettext", "v0")
_checkout_gnu_capsule("libiconv", "v1")
_checkout_capsule("github.com", "madler", "zlib", "v1")

checkout_add_archive(
    "git-{}".format(GIT_VERSION),
    url = "https://www.kernel.org/pub/software/scm/git/git-{}.tar.gz".format(GIT_VERSION),
    sha256 = "10acb581993061e616be9c5674469335922025a666318e0748cb8306079fef24",
)

checkout_update_env(
    "git-build-env",
    vars = {
        "CFLAGS": "-I{}/include".format(INSTALL_PATH),
        "CPPFLAGS": "-I{}/include".format(INSTALL_PATH),
        "LDFLAGS": "-L{}/lib".format(INSTALL_PATH),
    },
)

run_add_exec(
    "git-configure",
    command = "./configure".format(SOURCE_DIRECTORY),
    args = [
        "--prefix={}".format(INSTALL_PATH),
        "--with-zlib={}".format(INSTALL_PATH),
        "--with-iconv={}".format(INSTALL_PATH),
    ],
    working_directory = SOURCE_DIRECTORY,
    help = "Build git",
)

run_add_exec(
    "git-build",
    command = "make",
    args = ["-j{}".format(CPUS)],
    deps = ["git-configure"],
    working_directory = SOURCE_DIRECTORY,
    help = "Build git",
)

run_add_exec(
    "git-install",
    command = "make",
    args = ["install"],
    deps = ["git-build"],
    working_directory = SOURCE_DIRECTORY,
    help = "Install git",
)

rpath_update_macos_install_dir(
    "update_macos_rpath",
    install_path = INSTALL_PATH,
    deps = ["git-install"],
)


run_add_to_all("all", deps = ["update_macos_rpath", "git-install"])