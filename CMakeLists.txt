cmake_minimum_required(VERSION 3.10)

set(PROJECT_NAME "entix-project")
set(SOURCE_FOLDER "src")
set(ASSET_FOLDER "assets")
set(GENERATED_DIR "${CMAKE_BINARY_DIR}/generated")
set(APP_CONFIG_FILENAME "app" CACHE STRING "Application configuration filename")

project(${PROJECT_NAME} VERSION 1.0)

set(CMAKE_CXX_STANDARD 20)
set(CMAKE_CXX_EXTENSIONS OFF)
set(CMAKE_CXX_STANDARD_REQUIRED True)

function(generate_header_file YAML_FILE OUTPUT_DIR OUTPUT_FILENAME)
    if(NOT EXISTS ${YAML_FILE})
        message(FATAL_ERROR "File ${YAML_FILE} does not exist!")
    endif()

    if(NOT EXISTS ${OUTPUT_DIR})
        message(STATUS "Creating output directory ${OUTPUT_DIR}")
        file(MAKE_DIRECTORY ${OUTPUT_DIR})
    endif()

    set(HEADER_FILE "${OUTPUT_DIR}/${OUTPUT_FILENAME}.h")

    # generate header content
    add_custom_command(
        TARGET ${PROJECT_NAME}
        PRE_BUILD
        COMMAND ${CMAKE_COMMAND} -E echo "// Auto-generated header file" > ${HEADER_FILE}
        COMMAND ${CMAKE_COMMAND} -E echo "constexpr const char* g_${OUTPUT_FILENAME} = R\"(" >> ${HEADER_FILE}
        COMMAND ${CMAKE_COMMAND} -E cat ${YAML_FILE} >> ${HEADER_FILE}
        COMMAND ${CMAKE_COMMAND} -E echo ")\";" >> ${HEADER_FILE}
        DEPENDS ${YAML_FILE}
        VERBATIM
        COMMENT "Generating file ${HEADER_FILE}"
    )
endfunction()

file(
    GLOB_RECURSE
    SOURCES
    "${SOURCE_FOLDER}/*.cpp" "${SOURCE_FOLDER}/*.h" "${SOURCE_FOLDER}/*.hpp" "${SOURCE_FOLDER}/*.hh" "${SOURCE_FOLDER}/*.cc"
)

add_executable(${PROJECT_NAME} ${SOURCES})

# Checking program assets
if(TRUE) # CMAKE_BUILD_TYPE STREQUAL "Release")
    message(STATUS "Checking program assets...")

    set(ASSET_DIR ${CMAKE_SOURCE_DIR}/${ASSET_FOLDER})

    if(NOT EXISTS ${ASSET_DIR})
        message(FATAL_ERROR "Assets folder ${ASSET_DIR} does not exist")
    endif()

    set(SCENE_DIR "${ASSET_DIR}/scenes")

    if(NOT EXISTS ${SCENE_DIR})
        message(WARNING "Scene folder ${SCENE_DIR} does not exist")
    endif()

    file(GLOB SCENE_FILES "${SCENE_DIR}/*.scn")

    # add_custom_target(generate_headers)
    set(GENERATED_HEADERS "")

    foreach(SCENE_FILE ${SCENE_FILES})
        message(STATUS ${SCENE_FILE})
        get_filename_component(FILENAME ${SCENE_FILE} NAME_WE)
        generate_header_file(${SCENE_FILE} ${GENERATED_DIR} scene_${FILENAME})
        list(APPEND GENERATED_HEADERS "${GENERATED_DIR}/scene_${FILENAME}.h")
    endforeach(SCENE_FILE ${SCENE_FILES})

    include_directories(${GENERATED_DIR})
endif()

add_subdirectory(external/entix)

target_link_libraries(${PROJECT_NAME} PRIVATE entix)