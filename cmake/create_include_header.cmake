# Generates a header file within the given target which includes all files from the given directory.
# Regex filters may be passed as ARGN to exclude certain items.
FUNCTION(CREATE_INCLUDE_HEADER TARGET DIRECTORY HEADER_NAME)
    # Find all headers in provided directory.
    SET(TARGET_DIR  "${${TARGET}_SOURCE_DIR}/${DIRECTORY}")
    SET(TARGET_PATH "${TARGET_DIR}/${HEADER_NAME}")

    FILE(GLOB_RECURSE HEADERS CONFIGURE_DEPENDS LIST_DIRECTORIES FALSE "${TARGET_DIR}/*.hpp")


    # Header should not include itself.
    LIST(REMOVE_ITEM HEADERS ${TARGET_PATH})


    # Exclude any items matching filters in argn.
    FOREACH (FILTER IN ITEMS ${ARGN})
        LIST(FILTER HEADERS EXCLUDE REGEX ".*${FILTER}")
    ENDFOREACH()


    # Generate header.
    FILE(
        WRITE
        ${TARGET_PATH}
        "// This file is automatically generated by CMake.\n"
        "// Do not edit it, as your changes will be overwritten the next time CMake is run.\n"
        "// This file includes headers from ${TARGET}/${DIRECTORY}.\n\n"
        "#pragma once\n\n"
    )

    FOREACH (HEADER IN ITEMS ${HEADERS})
        FILE(RELATIVE_PATH HEADER_PATH "${CMAKE_SOURCE_DIR}" "${HEADER}")
        FILE(APPEND ${TARGET_PATH} "#include <${HEADER_PATH}>\n")
    ENDFOREACH()


    # Print debug message with generated file and folder name and number of included files.
    LIST(LENGTH HEADERS NUM_HEADERS)
    MESSAGE(STATUS "Generated include-header for target ${TARGET}: ./${DIRECTORY} -> ${HEADER_NAME} (${NUM_HEADERS} headers).")
ENDFUNCTION()