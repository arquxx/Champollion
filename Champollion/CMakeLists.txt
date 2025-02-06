file(GLOB HEADER_FILES "*.hpp")  # You probably don't need this in the executable's directory
file(GLOB SOURCE_FILES "*.cpp")

add_executable(Champollion ${SOURCE_FILES} ${HEADER_FILES})  # Use both source and header

auto_source_group("Champollion" ${CMAKE_CURRENT_SOURCE_DIR} ${HEADER_FILES} ${SOURCE_FILES})

# NO target_link_libraries HERE.  All linking is done in the root CMakeLists.txt.
