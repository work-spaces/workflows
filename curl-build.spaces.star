"""
Build Curl using spaces.
"""

load("//@packages/star/github.com/packages.star", github_packages = "packages")
load("//@sdk/star/checkout.star", "checkout_add_platform_archive", "checkout_add_repo", "checkout_update_env")
load(
    "//@sdk/star/gnu_autotools.star",
    "gnu_add_autotools_from_source",
    "gnu_add_repo",
    "gnu_add_source_archive",
)
load("//@sdk/star/openssl.star", "openssl_add")
load("//@sdk/star/cmake.star", "cmake_add", "cmake_add_repo")
load("//@sdk/star/run.star", "run_add_exec")
load("//@sdk/star/rpath.star", "rpath_update_macos_install_dir")

libiconv_version = "1.17"
libiconv_sha256 = "8f74213b56238c85a50a5329f77e06198771e70dd9a739779f4c02f65d971313"

libidn2_version = "2.3.7"
libidn2_sha256 = "4c21a791b610b9519b9d0e12b8097bf2f359b12f8dd92647611a929e6bfd7d64"

openldap_version = "2.6.9"
openldap_sha256 = "2cb7dc73e9c8340dff0d99357fbaa578abf30cc6619f0521972c555681e6b2ff"

groff_version = "1.23.0"
groff_sha256 = "6b9757f592b7518b4902eb6af7e54570bdccba37a871fddb2d30ae3863511c13"

#gettext_version = "0.22"
#gettext_sha256 = "0e60393a47061567b46875b249b7d2788b092d6457d656145bb0e7e6a3e26d93"

m4_version = "1.4.19"
m4_sha256 = "63aede5c6d33b6d9b13511cd0be2cac046f2e70fd0a07aa9573a04a82783af96"

workspace = info.get_absolute_path_to_workspace()
install_path = "{}/build/install".format(workspace)
gnu_autotools_deps = ["autoconf_install", "automake_install", "libtool_install"]

checkout_add_platform_archive(
    "m4-1",
    platforms = github_packages["xpack-dev-tools"]["m4-xpack"]["v1.4.19-3"],
)

checkout_add_platform_archive(
    "pkg_config0",
    platforms = github_packages["xpack-dev-tools"]["pkg-config-xpack"]["v0.29.2-3"],
)

cmake_add(
    "cmake3",
    version = "v3.31.1",
)

cmake_add_repo(
    "nghttp2",
    url = "https://github.com/nghttp2/nghttp2",
    rev = "v1.64.0",
    deps = ["libxml2_install"],
    checkout_submodules = True,
)

cmake_add_repo(
    "nghttp3",
    url = "https://github.com/ngtcp2/nghttp3",
    rev = "v1.6.0",
    checkout_submodules = True,
)

checkout_add_repo(
    "zstd",
    url = "https://github.com/facebook/zstd",
    rev = "v1.5.5",
    clone = "Blobless",
)

run_add_exec(
    "zstd_build",
    command = "make",
    args = ["-j{}".format(info.get_cpu_count())],
    working_directory = "zstd",
)

run_add_exec(
    "zstd_install",
    command = "make",
    args = ["install"],
    working_directory = "zstd",
    deps = ["zstd_build"],
    env = {
        "PREFIX": install_path,
    },
)

cmake_add_repo(
    "brotli",
    url = "https://github.com/google/brotli",
    rev = "v1.1.0",
)

#gnu_add_source_archive(
#    "gettext",
#    url = "https://ftp.gnu.org/gnu/gettext/gettext-{}.tar.xz".format(gettext_version),
#    sha256 = gettext_sha256,
#    source_directory = "gettext-{}".format(gettext_version),
#)

gnu_add_source_archive(
    "libiconv",
    url = "https://ftp.gnu.org/gnu/libiconv/libiconv-{}.tar.gz".format(libiconv_version),
    sha256 = libiconv_sha256,
    source_directory = "libiconv-{}".format(libiconv_version),
    deps = ["openssl_install"] + gnu_autotools_deps,
)

gnu_add_source_archive(
    "openldap",
    url = "https://www.openldap.org/software/download/OpenLDAP/openldap-release/openldap-{}.tgz".format(openldap_version),
    sha256 = openldap_sha256,
    source_directory = "openldap-{}".format(openldap_version),
    deps = ["groff_install"] + gnu_autotools_deps,
)

#https://ftp.gnu.org/gnu/groff/groff-1.23.0.tar.gz

gnu_add_source_archive(
    "groff",
    url = "https://ftp.gnu.org/gnu/groff/groff-{}.tar.gz".format(groff_version),
    sha256 = groff_sha256,
    source_directory = "groff-{}".format(groff_version),
    deps = gnu_autotools_deps,
)

gnu_add_source_archive(
    "libidn2",
    url = "https://ftp.gnu.org/gnu/libidn/libidn2-{}.tar.gz".format(libidn2_version),
    sha256 = libidn2_sha256,
    source_directory = "libidn2-{}".format(libidn2_version),
    deps = gnu_autotools_deps,
    configure_args = [ "--with-included-libunistring"]
)

checkout_add_platform_archive(
    "spaces0",
    platforms = github_packages["work-spaces"]["spaces"]["v0.10.4"],
)

gnu_add_autotools_from_source()

openssl_add(
    "openssl",
    tag = "openssl-3.3.0-quic1",
    url = "https://github.com/quictls/openssl",
)

cmake_add_repo(
    "zlib",
    url = "https://github.com/madler/zlib",
    rev = "v1.3.1",
)

cmake_add_repo(
    "libxml2",
    url = "https://github.com/GNOME/libxml2",
    rev = "v2.13.5",
    deps = ["libiconv_install"],
)

cmake_add_repo(
    "ngtcp2",
    url = "https://github.com/ngtcp2/ngtcp2",
    rev = "v1.9.1",
    deps = ["brotli_install", "nghttp3_install", "openssl_install"],
    checkout_submodules = True,
)

gnu_add_repo(
    "curl",
    deps = [
        "gnu_autotools_from_source",
        "openssl_install",
        "libxml2_install",
        "nghttp2_install",
        "brotli_install",
        "ngtcp2_install",
        "nghttp3_install",
        "zstd_install",
        "zlib_install",
        "libidn2_install",
        "openldap_install",
    ] + gnu_autotools_deps,
    autoreconf_args = ["-fi"],
    url = "https://github.com/curl/curl",
    rev = "curl-8_11_0",
    configure_args = [
        "--with-openssl={}".format(install_path),
        "--without-libpsl",
        "--with-nghttp2={}".format(install_path),
        "--with-nghttp3={}".format(install_path),
        "--with-ngtcp2={}".format(install_path),
        "--with-brotli={}".format(install_path),
        "--with-zstd={}".format(install_path),
        "--with-zlib={}".format(install_path),
        "--with-libidn2={}".format(install_path),
    ],
)

checkout_update_env(
    "update_build_env",
    vars = {
        "DYLD_FALLBACK_LIBRARY_PATH": "{}/lib".format(install_path),
        "LT_SYS_LIBRARY_PATH": "{}/lib".format(install_path),
        "PKG_CONFIG_PATH": "{}/lib/pkgconfig".format(install_path),
        "LDFLAGS": "-Wl,-rpath,{}/lib".format(install_path),
        "V": "1",
    },
    paths = ["{}/bin".format(install_path), "/usr/bin", "/bin"],
)

rpath_update_macos_install_dir(
    "update_macos_rpaths",
    install_path,
    deps = ["curl_install"],
)
