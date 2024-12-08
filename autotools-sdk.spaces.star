"""

Create a workspace using the autotools capsule.

"""

load(
    "//@sdk/star/checkout.star",
    "checkout_add_repo",
)
load("//@sdk/star/spaces-env.star", "spaces_working_env")
load("//@sdk/star/capsule.star", "capsule_dependency", "capsule_get_depedency_info", "capsule_add")

checkout_add_repo(
    "@capsules/workflows",
    url = "https://github.com/work-spaces/workflows",
    rev = "915043a2050d2354af20e3a33c4883d51ee40fc1",
    clone = "Default",
    is_evaluate_spaces_modules = False,
)

libtool2 = capsule_dependency("ftp.gnu.org", "libtool", "libtool", semver = "2")
automake1 = capsule_dependency("ftp.gnu.org", "automake", "automake", semver = "1")
autoconf2 = capsule_dependency("ftp.gnu.org", "autoconf", "autoconf", semver = ">=2.65")
m4_1 = capsule_dependency("ftp.gnu.org", "m4", "m4", semver = "1")
gettext0 = capsule_dependency("ftp.gnu.org", "m4", "m4", semver = "0")

capsule_add(
    "autotools_capsule",
    required = [libtool2, automake1, autoconf2],
    scripts = ["workflows/preload", "workflows/autotools-capsule"],
    deps = ["@capsules/workflows"],
    prefix = "sysroot"
)

capsule_add(
    "build_essential_capsule",
    required = [m4_1, gettext0],
    scripts = ["workflows/preload", "workflows/m4-capsule"],
    deps = ["@capsules/workflows"],
    prefix = "sysroot"
)

spaces_working_env()

