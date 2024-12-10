"""

Create a workspace using the autotools capsule.

"""

load("//@sdk/star/spaces-env.star", "spaces_working_env")
load(
    "//@sdk/star/capsule.star",
    "capsule_add",
    "capsule_add_workflow_repo",
    "capsule_dependency",
)

capsule_add_workflow_repo(
    "capsules",
    url = "https://github.com/work-spaces/capsules",
    rev = "3ecfa93cc09004c9f0006e5f6367949ba6a1b1bd",
)

libtool2 = capsule_dependency("ftp.gnu.org", "libtool", "libtool", semver = "2")
automake1 = capsule_dependency("ftp.gnu.org", "automake", "automake", semver = "1")
autoconf2 = capsule_dependency("ftp.gnu.org", "autoconf", "autoconf", semver = ">=2.65")
libiconv = capsule_dependency("ftp.gnu.org", "libiconv", "libiconv", semver = "1")
m4_1 = capsule_dependency("ftp.gnu.org", "m4", "m4", semver = "1")
gettext0 = capsule_dependency("ftp.gnu.org", "gettext", "gettext", semver = "0")
readline8 = capsule_dependency("ftp.gnu.org", "readline", "readline", semver = "8")
ncurses6 = capsule_dependency("ftp.gnu.org", "ncurses", "ncurses", semver = "6")
zlib1 = capsule_dependency("github.com", "madler", "zlib", semver = "1")

ignore = """
capsule_add(
    "autotools_capsule",
    required = [libtool2, automake1, autoconf2],
    scripts = ["capsules/ftp.gnu.org/preload", "capsules/ftp.gnu.org/autotools-v2024-capsule"],
    deps = ["@capsules/capsules"],
    prefix = "sysroot",
)

capsule_add(
    "libiconv_capsule",
    required = [libiconv],
    scripts = ["capsules/ftp.gnu.org/preload", "capsules/ftp.gnu.org/libiconv-v1-capsule"],
    deps = ["@capsules/capsules"],
    prefix = "sysroot",
)

capsule_add(
    "m4_capsule",
    required = [m4_1],
    scripts = ["capsules/ftp.gnu.org/preload", "capsules/ftp.gnu.org/m4-v1-capsule"],
    deps = ["@capsules/capsules"],
    prefix = "sysroot",
)

capsule_add(
    "gettext_capsule",
    required = [gettext0],
    scripts = ["capsules/ftp.gnu.org/preload", "capsules/ftp.gnu.org/gettext-v0-capsule"],
    deps = ["@capsules/capsules"],
    prefix = "sysroot",
)

capsule_add(
    "readline_capsule",
    required = [readline8],
    scripts = ["capsules/ftp.gnu.org/preload", "capsules/ftp.gnu.org/readline-v8-capsule"],
    deps = ["@capsules/capsules"],
    prefix = "sysroot",
)

capsule_add(
    "ncurses_capsule",
    required = [ncurses6],
    scripts = ["capsules/ftp.gnu.org/preload", "capsules/ftp.gnu.org/ncurses-v6-capsule"],
    deps = ["@capsules/capsules"],
    prefix = "sysroot",
)
"""

capsule_add(
    "zlib_capsule",
    required = [zlib1],
    scripts = ["capsules/preload", "capsules/github.com/madler/zlib-v1-capsule"],
    deps = ["@capsules/capsules"],
)


spaces_working_env()
