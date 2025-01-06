"""

Create a workspace using the autotools capsule.

"""

load("//@star/sdk/star/spaces-env.star", "spaces_working_env")
load(
    "//@star/sdk/star/capsule.star",
    "capsule_checkout",
    "capsule",
    "capsule_checkout_add_workflow_repo",
)

info.set_max_queue_count(1)

capsules_repo_rule = "capsules"

capsule_checkout_add_workflow_repo(
    "capsules",
    url = "https://github.com/work-spaces/capsules",
    rev = "main",
)

env_rule = spaces_working_env()

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
        deps = [capsules_repo_rule, env_rule],
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
        deps = [capsules_repo_rule, env_rule],
        prefix = "sysroot",
    )

_checkout_gnu_capsule("gettext", "v0")
_checkout_gnu_capsule("gmp", "v6")
_checkout_gnu_capsule("groff", "v1")
_checkout_gnu_capsule("libiconv", "v1")
_checkout_gnu_capsule("libidn", "v2", "libidn2")
_checkout_gnu_capsule("m4", "v1")
_checkout_gnu_capsule("mpc", "v1")
_checkout_gnu_capsule("mpfr", "v4")
_checkout_gnu_capsule("ncurses", "v6")
_checkout_gnu_capsule("readline", "v8")

_checkout_capsule("github.com", "facebook", "zstd", "v1")
_checkout_capsule(
    "github.com",
    "gnome",
    "libxml", "v2",
)
_checkout_capsule("github.com", "google", "brotli", "v1")
_checkout_capsule("github.com", "lz4", "lz4", "v1")
_checkout_capsule("github.com", "madler", "zlib", "v1")
_checkout_capsule("github.com", "nghttp2", "nghttp2", "v1")
_checkout_capsule("github.com", "ngtcp2", "ngtcp2", "v1")
_checkout_capsule("github.com", "ngtcp2", "nghttp3", "v1")
_checkout_capsule("github.com", "quictls", "openssl", "v3")
_checkout_capsule("github.com", "tukaani-project", "xz", "v5")
_checkout_capsule("ruby-lang.org", "ruby", "ruby", "v3")
_checkout_capsule("github.com", "yaml", "libyaml", "v0")
_checkout_capsule("openldap.org", "openldap", "openldap", "v1")

