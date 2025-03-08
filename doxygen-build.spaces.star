"""


"""


load("//@star/sdk/star/checkout.star", "checkout_add_repo")
load("//@star/sdk/star/info.star", "info_set_minimum_version")
load("//@star/sdk/star/spaces-env.star", "spaces_working_env")
load("//@star/packages/star/package.star", "package_add")
load("//@star/packages/star/cmake.star", "cmake_add")

info_set_minimum_version("0.14.0")

spaces_working_env()
checkout_add_repo(
    "doxygen",
    url = "https://github.com/doxygen/doxygen",
    rev = "Release_1_13_2"
)

# requireds Bison 2.7 or newer
package_add("github.com", "xpack-dev-tools", "bison-xpack", "v3.8.2-1")
# requires flex 
package_add("github.com", "xpack-dev-tools", "flex-xpack", "v2.6.4-1")
package_add("github.com", "ninja-build","ninja", "v1.12.1")
cmake_add("cmake3", "v3.31.5")

# install python 3.11 or 3.12?
# install xmllint
# install graphviz

# install mactex (or don't use this)