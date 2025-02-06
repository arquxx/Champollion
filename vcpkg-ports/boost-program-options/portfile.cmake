include(vcpkg_common_functions)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO boostorg/program_options
    REF boost-1.80.0
    SHA512 995f957a5c8855f6ad868a68346c79399b46e7604b67ef3454f5e8d57686b0a09ba816b439a0151833167c5a259f4f6a7e6434a03a69e42079112cc099b0b457
    HEAD_REF master
)
# --- New: Pre-build Boost ---
vcpkg_configure_boost(
    SOURCE_PATH ${SOURCE_PATH}
    PACKAGES program_options # Specify ONLY the needed component
    WITH_PROGRAM_OPTIONS
)
file(MAKE_DIRECTORY ${CURRENT_PACKAGES_DIR}/lib/cmake)

file(COPY ${SOURCE_PATH}/lib/cmake/boost_program_options-1.80.0 DESTINATION ${CURRENT_PACKAGES_DIR}/lib/cmake)

vcpkg_cmake_config_fixup(CONFIG_PATH lib/cmake/boost_program_options-1.80.0)

# --- End New Section ---

file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include)
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/share)
file(INSTALL ${SOURCE_PATH}/LICENSE_1_0.txt DESTINATION ${CURRENT_PACKAGES_DIR}/share/boost-program-options RENAME copyright)

set(VCPKG_POLICY_EMPTY_PACKAGE enabled) # Keep this here
