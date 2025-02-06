include(vcpkg_common_functions)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO boostorg/program_options
    REF boost-1.80.0
    SHA512 995f957a5c8855f6ad868a68346c79399b46e7604b67ef3454f5e8d57686b0a09ba816b439a0151833167c5a259f4f6a7e6434a03a69e42079112cc099b0b457
    HEAD_REF master
)


vcpkg_cmake_configure(
    SOURCE_PATH ${SOURCE_PATH}
    VCPKG_POLICY_EMPTY_PACKAGE enabled  # This line is essential!
)

vcpkg_cmake_install()

vcpkg_cmake_config_fixup(CONFIG_PATH lib/cmake/boost_program_options-1.80.0)
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include)
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/share)

file(INSTALL ${SOURCE_PATH}/LICENSE_1_0.txt DESTINATION ${CURRENT_PACKAGES_DIR}/share/boost-program-options RENAME copyright)
