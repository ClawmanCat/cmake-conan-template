# Create a new target with the given name, version and type.
# Pass list of dependency targets as ARGN.
FUNCTION(CREATE_TARGET NAME MAJOR MINOR PATCH CMAKE_TARGET_TYPE COMPONENT_TYPE)
    FILE(GLOB_RECURSE SOURCES CONFIGURE_DEPENDS LIST_DIRECTORIES FALSE "*.cpp" "*.hpp")
    LIST(FILTER SOURCES EXCLUDE REGEX "${CMAKE_CURRENT_SOURCE_DIR}\\/tests\\/.*")

    CREATE_TARGET_FROM_SOURCES(
        ${NAME}
        ${MAJOR} ${MINOR} ${PATCH}
        ${CMAKE_TARGET_TYPE} ${COMPONENT_TYPE}
        "${SOURCES}"
        ${ARGN}
    )
ENDFUNCTION()




# Create a new target with the given name, version and type, using the provided source files.
# Pass list of dependency targets as ARGN.
FUNCTION(CREATE_TARGET_FROM_SOURCES NAME MAJOR MINOR PATCH CMAKE_TARGET_TYPE COMPONENT_TYPE SOURCES)
    # Assert target types have valid values.
    SET(ALLOWED_CMAKE_TARGET_TYPES "EXECUTABLE" "INTERFACE" "OBJECT" "SHARED" "STATIC")
    SET(ALLOWED_COMPONENT_TYPES "COMPONENT" "PLUGIN" "TEST")

    IF (NOT "${CMAKE_TARGET_TYPE}" IN_LIST ALLOWED_CMAKE_TARGET_TYPES)
        MESSAGE(FATAL_ERROR "Unknown CMake target type: ${CMAKE_TARGET_TYPE}. Value must be one of: ${ALLOWED_CMAKE_TARGET_TYPES}")
    ENDIF()

    IF (NOT "${COMPONENT_TYPE}" IN_LIST ALLOWED_COMPONENT_TYPES)
        MESSAGE(FATAL_ERROR "Unknown VoxelEngine target type: ${COMPONENT_TYPE}. Value must be one of: ${ALLOWED_COMPONENT_TYPES}")
    ENDIF()


    # Create CMake target.
    IF (${CMAKE_TARGET_TYPE} STREQUAL "EXECUTABLE")
        ADD_EXECUTABLE(${NAME} ${SOURCES})
        # Required for linking the tests.
        SET_TARGET_PROPERTIES(${NAME} PROPERTIES ENABLE_EXPORTS ON)
    ELSEIF (${CMAKE_TARGET_TYPE} STREQUAL "INTERFACE")
        ADD_LIBRARY(${NAME} ${CMAKE_TARGET_TYPE})
        TARGET_SOURCES(${NAME} ${SOURCES})
    ELSE()
        ADD_LIBRARY(${NAME} ${CMAKE_TARGET_TYPE} ${SOURCES})
    ENDIF()

    SET_TARGET_PROPERTIES(${NAME} PROPERTIES LINKER_LANGUAGE CXX)


    # Add dependencies.
    TARGET_LINK_LIBRARIES(${NAME} ${ARGN})


    # Set output directories depending on COMPONENT_TYPE (Either the root output directory or the plugins or test folder in said directory).
    IF ("${COMPONENT_TYPE}" STREQUAL "COMPONENT")
        SET(OUTPUT_DIRECTORY "${CMAKE_SOURCE_DIR}/out/${PROFILE_NAME}/bin")
    ELSEIF ("${COMPONENT_TYPE}" STREQUAL "PLUGIN")
        SET(OUTPUT_DIRECTORY "${CMAKE_SOURCE_DIR}/out/${PROFILE_NAME}/bin/plugins/${NAME}")
    ELSE ()
        SET(OUTPUT_DIRECTORY "${CMAKE_SOURCE_DIR}/out/${PROFILE_NAME}/bin/tests/${NAME}")
    ENDIF()

    SET_TARGET_PROPERTIES(${NAME} PROPERTIES ARCHIVE_OUTPUT_DIRECTORY ${OUTPUT_DIRECTORY})
    SET_TARGET_PROPERTIES(${NAME} PROPERTIES LIBRARY_OUTPUT_DIRECTORY ${OUTPUT_DIRECTORY})
    SET_TARGET_PROPERTIES(${NAME} PROPERTIES RUNTIME_OUTPUT_DIRECTORY ${OUTPUT_DIRECTORY})


    # Set CMake information for target.
    SET(${NAME}_SOURCE_DIR        ${CMAKE_CURRENT_SOURCE_DIR} CACHE INTERNAL "")
    SET(${NAME}_OUTPUT_DIR        ${OUTPUT_DIRECTORY}         CACHE INTERNAL "")
    SET(${NAME}_CMAKE_TARGET_TYPE ${CMAKE_TARGET_TYPE}        CACHE INTERNAL "")
    SET(${NAME}_COMPONENT_TYPE    ${COMPONENT_TYPE}           CACHE INTERNAL "")
    SET(${NAME}_VERSION_MAJOR     ${MAJOR}                    CACHE INTERNAL "")
    SET(${NAME}_VERSION_MINOR     ${MINOR}                    CACHE INTERNAL "")
    SET(${NAME}_VERSION_PATCH     ${PATCH}                    CACHE INTERNAL "")
    SET(${NAME}_SOURCE_LIST       "${SOURCES}"                CACHE INTERNAL "")


    # Create test targets.
    CREATE_TESTS_FOR_TARGET(${NAME} GENERATED_TEST_LIST ${ARGN})
    SET(${NAME}_TEST_LIST "${GENERATED_TEST_LIST}" CACHE INTERNAL "")


    # Set preprocessor information for target.
    STRING(TOUPPER ${NAME} NAME_UPPER)
    TARGET_COMPILE_DEFINITIONS(${NAME} PUBLIC "${NAME_UPPER}_VERSION_MAJOR=${MAJOR}")
    TARGET_COMPILE_DEFINITIONS(${NAME} PUBLIC "${NAME_UPPER}_VERSION_MINOR=${MINOR}")
    TARGET_COMPILE_DEFINITIONS(${NAME} PUBLIC "${NAME_UPPER}_VERSION_PATCH=${PATCH}")


    # Symlink or copy assets folder.
    IF (EXISTS "${CMAKE_CURRENT_SOURCE_DIR}/assets" AND IS_DIRECTORY "${CMAKE_CURRENT_SOURCE_DIR}/assets")
        IF (SYMLINK_ASSETS)
            FILE(MAKE_DIRECTORY "${OUTPUT_DIRECTORY}/assets")

            # On Windows, creating a symlink requires administrator privileges, so create a directory junction instead.
            IF (WIN32)
                IF (NOT EXISTS "${OUTPUT_DIRECTORY}/assets/${NAME}")
                    ADD_CUSTOM_TARGET(
                        "SYMLINK_ASSETS_FOR_${NAME}"
                        COMMAND mklink /j "\"${OUTPUT_DIRECTORY}/assets/${NAME}\"" "\"${CMAKE_CURRENT_SOURCE_DIR}/assets\""
                    )


                    ADD_DEPENDENCIES("${NAME}" "SYMLINK_ASSETS_FOR_${NAME}")
                ENDIF()
            ELSE()
                ADD_CUSTOM_TARGET(
                    "SYMLINK_ASSETS_FOR_${NAME}"
                    COMMAND ${CMAKE_COMMAND} -E create_symlink "\"${CMAKE_CURRENT_SOURCE_DIR}/assets\"" "\"${OUTPUT_DIRECTORY}/assets/${NAME}\""
                    VERBATIM
                )


                ADD_DEPENDENCIES("${NAME}" "SYMLINK_ASSETS_FOR_${NAME}")
            ENDIF()
        ELSE()
            FILE(GLOB_RECURSE ASSETS CONFIGURE_DEPENDS LIST_DIRECTORIES OFF "${CMAKE_CURRENT_SOURCE_DIR}/assets/*")


            FOREACH (ASSET IN ITEMS ${ASSETS})
                FILE(RELATIVE_PATH RELATIVE_ASSET_PATH "${CMAKE_CURRENT_SOURCE_DIR}/assets" "${ASSET}")
                CONFIGURE_FILE("${CMAKE_CURRENT_SOURCE_DIR}/assets/${RELATIVE_ASSET_PATH}" "${OUTPUT_DIRECTORY}/assets/${RELATIVE_ASSET_PATH}" COPYONLY)
            ENDFOREACH()
        ENDIF()
    ENDIF()


    # Print debug message that target was created.
    LIST(LENGTH SOURCES NUM_SOURCES)
    MESSAGE(STATUS "Created target ${NAME} (${COMPONENT_TYPE}/${CMAKE_TARGET_TYPE}) with ${NUM_SOURCES} sources.")
ENDFUNCTION()




# Generates new targets for every .cpp file in the given target's tests folder,
# and returns a list of generated targets into the provided variable.
FUNCTION(CREATE_TESTS_FOR_TARGET TARGET TEST_LIST_OUTPUT_VAR)
    # Skip if testing is not enabled.
    IF (NOT ${ENABLE_TESTING})
        RETURN()
    ENDIF()

    # Test targets cannot have tests themselves.
    IF (${TARGET} MATCHES "test_*")
        RETURN()
    ENDIF()

    # Skip if there is no tests folder.
    IF (NOT EXISTS "${${TARGET}_SOURCE_DIR}/tests")
        RETURN()
    ENDIF()


    # Find test sources.
    FILE(GLOB_RECURSE TESTS CONFIGURE_DEPENDS LIST_DIRECTORIES FALSE "${${TARGET}_SOURCE_DIR}/tests/*.cpp")


    # Generate test targets.
    INCLUDE(CTest)

    FOREACH(TEST IN ITEMS ${TESTS})
        GET_FILENAME_COMPONENT(TEST_NAME ${TEST} NAME_WE)
        SET(TEST_NAME test_${TEST_NAME})


        CREATE_TARGET_FROM_SOURCES(
            ${TEST_NAME}
            ${${TARGET}_VERSION_MAJOR} ${${TARGET}_VERSION_MINOR} ${${TARGET}_VERSION_PATCH}
            EXECUTABLE TEST
            "${TEST}"
            PUBLIC ${TARGET}
            ${ARGN}
        )


        ADD_TEST(NAME ${TEST_NAME} COMMAND ${TEST_NAME} WORKING_DIRECTORY "${${NAME}_OUTPUT_DIRECTORY}")
    ENDFOREACH()


    # Return list of tests to parent.
    SET(${TEST_LIST_OUTPUT_VAR} "${TESTS}" PARENT_SCOPE)
ENDFUNCTION()