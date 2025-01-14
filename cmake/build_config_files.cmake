function(generate_header_file YAML_FILES OUTPUT_DIR OUTPUT_FILENAME)
    set(HEADER_FILE "${OUTPUT_DIR}/${OUTPUT_FILENAME}.h")

    list(LENGTH YAML_FILES YAML_FILES_COUNT)

    # generate header content
    add_custom_command(
        OUTPUT ${HEADER_FILE}
        COMMAND ${CMAKE_COMMAND} -E echo "// Auto-generated file ${OUTPUT_FILENAME}" > ${HEADER_FILE}
        COMMAND ${CMAKE_COMMAND} -E echo "#pragma once" >> ${HEADER_FILE}
        COMMAND ${CMAKE_COMMAND} -E echo "namespace entix { constexpr unsigned int g_${OUTPUT_FILENAME}_len = ${YAML_FILES_COUNT};" >> ${HEADER_FILE}
        COMMAND ${CMAKE_COMMAND} -E echo "const char* g_${OUTPUT_FILENAME}[g_${OUTPUT_FILENAME}_len] = {" >> ${HEADER_FILE}
        VERBATIM
        DEPENDS ${YAML_FILES}
        COMMENT "Generating file ${HEADER_FILE}"
    )

    set(FIRST_FILE TRUE)

    foreach(YAML_FILE ${YAML_FILES})
        if(NOT EXISTS ${YAML_FILE})
            message(FATAL_ERROR "File ${YAML_FILE} does not exist!")
        endif()

        if (NOT FIRST_FILE)
            add_custom_command(
                OUTPUT ${HEADER_FILE}
                COMMAND ${CMAKE_COMMAND} -E echo_append ", " >> ${HEADER_FILE}
                APPEND
            )
        endif()

        # generate header content
        add_custom_command(
            OUTPUT ${HEADER_FILE}
            COMMAND ${CMAKE_COMMAND} -E echo_append "R\"(" >> ${HEADER_FILE}
            COMMAND ${CMAKE_COMMAND} -E cat ${YAML_FILE} >> ${HEADER_FILE}
            COMMAND ${CMAKE_COMMAND} -E echo_append ")\"" >> ${HEADER_FILE}
            APPEND
            VERBATIM
        )

        set(FIRST_FILE FALSE)
    endforeach()

    add_custom_command(
        OUTPUT ${HEADER_FILE}
        COMMAND ${CMAKE_COMMAND} -E echo "};" >> ${HEADER_FILE}
        COMMAND ${CMAKE_COMMAND} -E echo "} // entix" >> ${HEADER_FILE}
        APPEND
        VERBATIM
    )

    set(CUSTOM_TARGET generate_${OUTPUT_FILENAME})
    add_custom_target(${CUSTOM_TARGET} DEPENDS ${HEADER_FILE})

    add_dependencies(${PROJECT_NAME} ${CUSTOM_TARGET})
endfunction()

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

generate_header_file(${ASSET_DIR}/${APP_CONFIG_FILE} ${GENERATED_DIR} app_config)

list(APPEND GENERATED_HEADERS ${GENERATED_DIR}/app_config.h)

set(SCENE_DIR "${ASSET_DIR}/scenes")

if(NOT EXISTS ${SCENE_DIR})
    message(WARNING "Scene folder ${SCENE_DIR} does not exist")
endif()

file(GLOB SCENE_FILES "${SCENE_DIR}/*.scn")

if(NOT SCENE_FILES)
    message(WARNING "Seems you have not setup a proper application and you're building in release mode. Check the entix-example to get started.")
    message(FATAL_ERROR "Scene folder is empty. Make sure to create scenes to be run.")
endif()

generate_header_file("${SCENE_FILES}" ${GENERATED_DIR} scenes)

include_directories(${GENERATED_DIR})
