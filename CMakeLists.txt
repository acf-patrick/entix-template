cmake_minimum_required(VERSION 3.10)

set(PROJECT_NAME "entix-project")

project(${PROJECT_NAME} VERSION 1.0)

set(CMAKE_CXX_STANDARD 20)
set(CMAKE_CXX_EXTENSIONS OFF)
set(CMAKE_CXX_STANDARD_REQUIRED True)

file(GLOB_RECURSE SOURCES "src/*.cpp" "src/*.h" "src/*.hpp" "src/*.hh" "src/*.cc")

add_executable(${PROJECT_NAME} ${SOURCES})

add_subdirectory(external/entix)

target_link_libraries(${PROJECT_NAME} PRIVATE entix)