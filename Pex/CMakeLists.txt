file(GLOB HEADER_FILES "*.hpp")
file(GLOB SOURCE_FILES "*.cpp")

add_library(Pex STATIC ${HEADER_FILES} ${SOURCE_FILES})
target_include_directories(Pex PUBLIC ${CMAKE_CURRENT_SOURCE_DIR})

auto_source_group("Pex" ${CMAKE_CURRENT_SOURCE_DIR} ${HEADER_FILES} ${SOURCE_FILES})
