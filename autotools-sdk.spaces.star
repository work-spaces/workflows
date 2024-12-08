"""

Create a workspace using the autotools capsule.

"""

load(
    "//@sdk/star/checkout.star",
    "checkout_add_repo",
    "checkout_update_env",
)
load("//@sdk/star/capsule.star", "capsule_dependency", "capsule_get_depedency_info", "capsule_add")

checkout_add_repo(
    "@capsules/workflows",
    url = "https://github.com/work-spaces/workflows",
    rev = "bc66ca5c2bcbad2d248bfd0acc00ebe6401976e7",
    clone = "Default",
    is_evaluate_spaces_modules = False,
)

libtool2 = capsule_dependency("ftp.gnu.org", "libtool", "libtool", semver = "2")
automake1 = capsule_dependency("ftp.gnu.org", "automake", "automake", semver = "1")
autoconf2 = capsule_dependency("ftp.gnu.org", "autoconf", "autoconf", semver = ">=2.65")


capsule_add(
    "autotools_capsule",
    required = [libtool2, automake1, autoconf2],
    scripts = ["workflows/preload", "workflows/autotools-capsule"],
    deps = ["@capsules/workflows"],
    prefix = "sysroot"
)

libtool2_info = capsule_get_depedency_info(libtool2)

checkout_update_env(
    "update_env",
    system_path = ["/usr/bin", "/bin"],
)

