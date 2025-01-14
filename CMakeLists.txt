cmake_minimum_required(VERSION 3.10)

project(entix_project VERSION 1.0)

set(SOURCE_FOLDER "src")
set(ASSET_FOLDER "assets") # DO NOT REMOVE
set(GENERATED_DIR "${CMAKE_BINARY_DIR}/generated")
set(APP_CONFIG_FILE "app.cfg")

add_compile_definitions(ASSET_FOLDER="${ASSET_FOLDER}")
add_compile_definitions(SCENE_CONTENT_SEPARATOR="${SCENE_CONTENT_SEPARATOR}")

set(CMAKE_CXX_STANDARD 20)
set(CMAKE_CXX_EXTENSIONS OFF)
set(CMAKE_CXX_STANDARD_REQUIRED True)

file(
    GLOB_RECURSE
    SOURCES
    "${SOURCE_FOLDER}/*.cpp" "${SOURCE_FOLDER}/*.h" "${SOURCE_FOLDER}/*.hpp" "${SOURCE_FOLDER}/*.hh" "${SOURCE_FOLDER}/*.cc"
)

add_executable(${PROJECT_NAME} ${SOURCES})

if (CMAKE_BUILD_TYPE STREQUAL "Release")
    include(cmake/build_config_files.cmake)
endif()

add_subdirectory(external/entix)

target_link_libraries(${PROJECT_NAME} PRIVATE entix)