cmake_minimum_required(VERSION 3.10)

set(PROJECT_NAME "entix-project")
set(SOURCE_FOLDER "src")
set(ASSET_FOLDER "assets") # DO NOT REMOVE
set(GENERATED_DIR "${CMAKE_BINARY_DIR}/generated")
set(SCENE_CONTENT_SEPARATOR "======") # DO NOT REMOVE
set(APP_CONFIG_FILE "app.cfg")

add_compile_definitions(ASSET_FOLDER="${ASSET_FOLDER}")
add_compile_definitions(SCENE_CONTENT_SEPARATOR="${SCENE_CONTENT_SEPARATOR}")

project(${PROJECT_NAME} VERSION 1.0)

set(CMAKE_CXX_STANDARD 20)
set(CMAKE_CXX_EXTENSIONS OFF)
set(CMAKE_CXX_STANDARD_REQUIRED True)

function(generate_header_file YAML_FILES OUTPUT_DIR OUTPUT_FILENAME SEPARATOR)
    set(HEADER_FILE "${OUTPUT_DIR}/${OUTPUT_FILENAME}.h")

    # generate header content
    add_custom_command(
        TARGET ${PROJECT_NAME}
        PRE_BUILD
        COMMAND ${CMAKE_COMMAND} -E echo -e "// Reference file : ${YAML_FILE}" > ${HEADER_FILE}
        COMMAND ${CMAKE_COMMAND} -E echo "#pragma once" > ${HEADER_FILE}
        COMMAND ${CMAKE_COMMAND} -E echo "namespace entix { constexpr const char* g_${OUTPUT_FILENAME} = R\"(" >> ${HEADER_FILE}
        VERBATIM
        COMMENT "Generating file ${HEADER_FILE}"
    )

    list(LENGTH YAML_FILES YAML_FILES_COUNT)

    if(YAML_FILES_COUNT EQUAL 1)
        set(SEPARATOR "")
    endif()

    foreach(YAML_FILE ${YAML_FILES})
        if(NOT EXISTS ${YAML_FILE})
            message(FATAL_ERROR "File ${YAML_FILE} does not exist!")
        endif()

        # generate header content
        add_custom_command(
            TARGET ${PROJECT_NAME}
            PRE_BUILD
            COMMAND ${CMAKE_COMMAND} -E cat ${YAML_FILE} >> ${HEADER_FILE}
            COMMAND ${CMAKE_COMMAND} -E echo "${SEPARATOR}" >> ${HEADER_FILE}
            DEPENDS ${YAML_FILES}
            VERBATIM
        )
    endforeach()

    # closing string and namespace
    add_custom_command(
        TARGET ${PROJECT_NAME}
        PRE_BUILD
        COMMAND ${CMAKE_COMMAND} -E echo ")\"; }" >> ${HEADER_FILE}
        DEPENDS ${YAML_FILE}
        VERBATIM
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

    set(GENERATED_HEADERS "")
    set(ASSET_DIR ${CMAKE_SOURCE_DIR}/${ASSET_FOLDER})

    if(NOT EXISTS ${ASSET_DIR})
        message(FATAL_ERROR "Assets folder ${ASSET_DIR} does not exist")
    endif()

    if(NOT EXISTS ${ASSET_DIR}/${APP_CONFIG_FILE})
        message(WARNING "Seems you have not setup a proper application and you're building in release mode. Check the entix-example to get started.")
        message(FATAL_ERROR "Application configuration file does not exist")
    endif()

    if(NOT EXISTS ${GENERATED_DIR})
        message(STATUS "Creating output directory ${GENERATED_DIR}")
        file(MAKE_DIRECTORY ${GENERATED_DIR})
    endif()

    generate_header_file(${ASSET_DIR}/${APP_CONFIG_FILE} ${GENERATED_DIR} app_config "")

    list(APPEND GENERATED_HEADERS ${GENERATED_DIR}/app_config.h)

    set(SCENE_DIR "${ASSET_DIR}/scenes")

    if(NOT EXISTS ${SCENE_DIR})
        message(WARNING "Scene folder ${SCENE_DIR} does not exist")
    endif()

    file(GLOB SCENE_FILES "${SCENE_DIR}/*.scn")

    if(NOT SCENE_FILES)
        message(WARNING "Seems you have not setup a proper application and you're building in release mode. Check the entix-example to get started.")
        message(FATAL_ERROR "Scene folder is empty. Make sure to create scenes to be ran.")
    endif()

    generate_header_file(${SCENE_FILES} ${GENERATED_DIR} scenes ${SCENE_CONTENT_SEPARATOR})

    include_directories(${GENERATED_DIR})
endif()

add_subdirectory(external/entix)

target_link_libraries(${PROJECT_NAME} PRIVATE entix)