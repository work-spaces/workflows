"""

Create a workspace using the autotools capsule.

"""

load("//@star/sdk/star/spaces-env.star", "spaces_working_env")
load(
    "//@star/sdk/star/capsule.star",
    "capsule_checkout",
    "capsule_checkout_add_workflow_repo",
)

capsule_checkout_add_workflow_repo(
    "capsules",
    url = "https://github.com/work-spaces/capsules",
    rev = "main",
)

env_rule = spaces_working_env()

ignore = """

capsule_checkout(
    "autotools_capsule",
    scripts = ["capsules/ftp.gnu.org/preload", "capsules/ftp.gnu.org/autotools-v2024"],
    deps = ["@capsules/capsules"],
    prefix = "sysroot",
)

capsule_checkout(
    "m4_capsule",
    scripts = ["capsules/ftp.gnu.org/preload", "capsules/ftp.gnu.org/m4-v1"],
    deps = ["@capsules/capsules"],
    prefix = "sysroot",
)


capsule_checkout(
    "libiconv_capsule",
    scripts = ["capsules/ftp.gnu.org/preload", "capsules/ftp.gnu.org/libiconv-v1"],
    deps = ["@capsules/capsules"],
    prefix = "sysroot",
)


capsule_checkout(
    "gettext_capsule",
    scripts = ["capsules/ftp.gnu.org/preload", "capsules/ftp.gnu.org/gettext-v0"],
    deps = ["@capsules/capsules"],
    prefix = "sysroot",
)

capsule_checkout(
    "readline_capsule",
    scripts = ["capsules/ftp.gnu.org/preload", "capsules/ftp.gnu.org/readline-v8"],
    deps = ["@capsules/capsules"],
    prefix = "sysroot",
)

capsule_checkout(
    "ncurses_capsule",
    scripts = ["capsules/ftp.gnu.org/preload", "capsules/ftp.gnu.org/ncurses-v6"],
    deps = ["@capsules/capsules"],
    prefix = "sysroot",
)


capsule_checkout(
    "zlib_capsule",
    scripts = ["capsules/preload", "capsules/github.com/madler/zlib-v1"],
    deps = ["@capsules/capsules"],
    prefix = "sysroot",
)


"""

capsule_checkout(
    "zstd",
    scripts = ["capsules/lock", "capsules/preload", "capsules/github.com/facebook/zstd-v1"],
    deps = ["@capsules/capsules", env_rule],
    prefix = "sysroot",
)

capsule_checkout(
    "brotli_capsule",
    scripts = ["capsules/lock", "capsules/preload", "capsules/github.com/google/brotli-v1"],
    deps = ["@capsules/capsules"],
    prefix = "sysroot",
)

