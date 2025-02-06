cmake_minimum_required(VERSION 3.15 FATAL_ERROR)
cmake_policy(SET CMP0048 NEW) # VERSION variables
cmake_policy(SET CMP0091 NEW) # CMAKE_MSVC_RUNTIME_LIBRARY
cmake_policy(SET CMP0167 NEW) # For Boost (still a good idea)

# Get the version number from Decompiler/Version.hpp
file(READ "${CMAKE_CURRENT_SOURCE_DIR}/Decompiler/Version.hpp" CHAMPOLLION_VERSION_FILE)
string(REGEX MATCH "define CHAMPOLLION_VERSION_MAJOR ([0-9]*)" _ ${CHAMPOLLION_VERSION_FILE})
math(EXPR CHAMPOLLION_VERSION_MAJOR "${CMAKE_MATCH_1}")
string(REGEX MATCH "define CHAMPOLLION_VERSION_MINOR ([0-9]*)" _ ${CHAMPOLLION_VERSION_FILE})
math(EXPR CHAMPOLLION_VERSION_MINOR "${CMAKE_MATCH_1}")
string(REGEX MATCH "define CHAMPOLLION_VERSION_PATCH ([0-9]*)" _ ${CHAMPOLLION_VERSION_FILE})
math(EXPR CHAMPOLLION_VERSION_PATCH "${CMAKE_MATCH_1}")
#Get the Champollion version as a semver number literal, not as a string
set(CHAMPOLLION_VERSION ${CHAMPOLLION_VERSION_MAJOR}.${CHAMPOLLION_VERSION_MINOR}.${CHAMPOLLION_VERSION_PATCH})

message(STATUS "Champollion version: ${CHAMPOLLION_VERSION}")

# package information
set(PACKAGE_NAME      "Champollion")
set(PACKAGE_VERSION   "${CHAMPOLLION_VERSION}")
set(PACKAGE_STRING    "${PACKAGE_NAME} ${PACKAGE_VERSION}")
set(PACKAGE_TARNAME   "${PACKAGE_NAME}-${PACKAGE_VERSION}")
set(PACKAGE_BUGREPORT "https://github.com/Orvid/Champollion/issues")

project(${PACKAGE_NAME} VERSION ${PACKAGE_VERSION} LANGUAGES CXX)
include(GNUInstallDirs)

option(CHAMPOLLION_STATIC_LIBRARY "Build Champollion as a static library" OFF)
option(CHAMPOLLION_USE_STATIC_RUNTIME "Compile Champollion with static runtime" OFF)

if (NOT CHAMPOLLION_STATIC_LIBRARY)
  set(CMAKE_CXX_STANDARD 20)
else()
  set(CMAKE_CXX_STANDARD 17)
endif()

# Improved auto_source_group function (same as before)
function(auto_source_group rootName rootDir)
  file(TO_CMAKE_PATH "${rootDir}" rootDir)
  foreach (fil ${ARGN})
    get_filename_component(filePath ${fil} DIRECTORY) # Get the directory
    if(filePath STREQUAL rootDir)
        set(fileGroup "\\${rootName}") # Files directly in rootDir
    else()
		string(CONCAT rel_path "${rootDir}/" "") # Ensure rootDir ends in '/'
        file(RELATIVE_PATH fileGroup "${rel_path}" "${filePath}")
        string(REPLACE "/" "\\" fileGroup "\\${rootName}\\${fileGroup}")
    endif()
    source_group("${fileGroup}" FILES "${fil}") # Directly add the file
  endforeach()
endfunction()

if (CHAMPOLLION_USE_STATIC_RUNTIME)
  if (MSVC)
    set(CMAKE_MSVC_RUNTIME_LIBRARY "MultiThreaded$<$<CONFIG:Debug>:Debug>")
    set(MSVC_RUNTIME_LIBRARY ${CMAKE_MSVC_RUNTIME_LIBRARY})
  else()
    set(USE_STATIC_RUNTIME ON)
  endif()
endif()

add_definitions(-D_CRT_SECURE_NO_WARNINGS)
set(CHAMPOLLION_TARGET_NAME               ${PROJECT_NAME})
set(CHAMPOLLION_CONFIG_INSTALL_DIR        "${CMAKE_INSTALL_LIBDIR}/cmake/${PROJECT_NAME}" CACHE INTERNAL "")
set(CHAMPOLLION_INCLUDE_INSTALL_DIR       "${CMAKE_INSTALL_INCLUDEDIR}/Champollion")
set(CHAMPOLLION_TARGETS_EXPORT_NAME       "${PROJECT_NAME}-targets")
set(CHAMPOLLION_CMAKE_CONFIG_TEMPLATE     "cmake/Config.cmake.in")
set(CHAMPOLLION_CMAKE_CONFIG_DIR          "${CMAKE_CURRENT_BINARY_DIR}")
set(CHAMPOLLION_CMAKE_VERSION_CONFIG_FILE "${CHAMPOLLION_CMAKE_CONFIG_DIR}/${PROJECT_NAME}ConfigVersion.cmake")
set(CHAMPOLLION_CMAKE_PROJECT_CONFIG_FILE "${CHAMPOLLION_CMAKE_CONFIG_DIR}/${PROJECT_NAME}Config.cmake")
set(CHAMPOLLION_CMAKE_PROJECT_TARGETS_FILE "${CHAMPOLLION_CMAKE_CONFIG_DIR}/${PROJECT_NAME}-targets.cmake")

if(CHAMPOLLION_STATIC_LIBRARY)
  file(GLOB DECOMPILER_HEADER_FILES "Decompiler/*.hpp")
  file(GLOB PEX_HEADER_FILES "Pex/*.hpp")
  file(GLOB NODE_HEADER_FILES "Decompiler/Node/*.hpp")
  list(APPEND ALL_HEADERS ${DECOMPILER_HEADER_FILES} ${PEX_HEADER_FILES} ${NODE_HEADER_FILES})

  file(GLOB SOURCE_FILES "Pex/*.cpp" "Decompiler/*.cpp" "Decompiler/Node/*.cpp")

  add_library("${PROJECT_NAME}" STATIC ${ALL_HEADERS} ${SOURCE_FILES})

  target_include_directories(
    "${PROJECT_NAME}"
    PUBLIC
    $<BUILD_INTERFACE:${PROJECT_SOURCE_DIR}>
    $<INSTALL_INTERFACE:${CHAMPOLLION_INCLUDE_INSTALL_DIR}>
  )
  include(CMakePackageConfigHelpers)
  write_basic_package_version_file(
      ${CHAMPOLLION_CMAKE_VERSION_CONFIG_FILE} COMPATIBILITY SameMinorVersion
  )
  configure_package_config_file(
    ${CHAMPOLLION_CMAKE_CONFIG_TEMPLATE}
    "${CHAMPOLLION_CMAKE_PROJECT_CONFIG_FILE}"
    INSTALL_DESTINATION ${CHAMPOLLION_CONFIG_INSTALL_DIR}
  )

  install(
    TARGETS "${CHAMPOLLION_TARGET_NAME}"
    EXPORT "${CHAMPOLLION_TARGETS_EXPORT_NAME}"
  )

  install(
    EXPORT "${CHAMPOLLION_TARGETS_EXPORT_NAME}"
    NAMESPACE "${CHAMPOLLION_TARGET_NAME}::"
    DESTINATION "${CHAMPOLLION_CONFIG_INSTALL_DIR}"
  )
  install(
    FILES ${DECOMPILER_HEADER_FILES}
    DESTINATION "${CHAMPOLLION_INCLUDE_INSTALL_DIR}/Decompiler"
  )
  install(
    FILES ${PEX_HEADER_FILES}
    DESTINATION "${CHAMPOLLION_INCLUDE_INSTALL_DIR}/Pex"
  )
  install(
    FILES ${NODE_HEADER_FILES}
    DESTINATION "${CHAMPOLLION_INCLUDE_INSTALL_DIR}/Decompiler/Node"
  )
  install(FILES ${CHAMPOLLION_CMAKE_VERSION_CONFIG_FILE} ${CHAMPOLLION_CMAKE_PROJECT_CONFIG_FILE}
  DESTINATION ${CHAMPOLLION_CONFIG_INSTALL_DIR})
else()
  # --- Find Dependencies (Simplified with Manifest Mode) ---
  # In manifest mode, you *usually* don't need explicit find_package calls
  # for dependencies declared in vcpkg.json.  vcpkg handles this automatically.
  # However, we *do* need to find_package for Boost to get the correct target names.

  find_package(Boost REQUIRED COMPONENTS program_options) # Keep this!
  find_package(fmt CONFIG REQUIRED) # Keep this!

  add_subdirectory(Decompiler)
  add_subdirectory(Pex)
  add_subdirectory(Champollion)

  # Link to Decompiler, Pex, Boost, and fmt
  target_link_libraries(Champollion PRIVATE Decompiler Pex Boost::program_options fmt::fmt)

  install(
    TARGETS Champollion
  )
endif()
