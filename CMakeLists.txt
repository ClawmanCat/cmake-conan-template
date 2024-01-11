CMAKE_MINIMUM_REQUIRED(VERSION 3.19)
PROJECT("CMake Conan Template")


# Prevent concurrent CMake runs.
FILE(LOCK ${CMAKE_SOURCE_DIR}/cmake.lock)


# Get compiler name and build type.
STRING(TOLOWER ${CMAKE_CXX_COMPILER_ID} CXX_COMPILER_ID_LOWER)
STRING(TOLOWER ${CMAKE_BUILD_TYPE} BUILD_TYPE_LOWER)

# RelWithDebInfo -> FastDebug
IF (${BUILD_TYPE_LOWER} STREQUAL "relwithdebinfo")
    SET(BUILD_TYPE_LOWER "fastdebug")
ENDIF()


# Command line options.
SET(SYMLINK_ASSETS ON CACHE BOOL "Generate symlinks for the assets folder rather than copying it.")
SET(ENABLE_TESTING ON CACHE BOOL "Generate test targets.")
SET(PROFILE_NAME "${CXX_COMPILER_ID_LOWER}-${BUILD_TYPE_LOWER}" CACHE STRING "Name of the current CMake profile. Will be used as the folder name for build artifacts.")
SET(COMPILER_PROFILE ON CACHE BOOL "Use a preconfigured profile with compiler-specific settings for e.g. warnings.")
SET(WARNINGS_ARE_ERRORS ON CACHE BOOL "Treat all warnings as errors.")


# Change to require a specific C++ version.
SET(CMAKE_CXX_STANDARD 17)
SET(CMAKE_CXX_STANDARD_REQUIRED ON)


# Export all symbols on Windows.
# TODO: Replace this with SymbolGenerator later!
SET(CMAKE_WINDOWS_EXPORT_ALL_SYMBOLS ON)


# Allow loading of scripts from cmake folder.
SET(CMAKE_MODULE_PATH ${CMAKE_MODULE_PATH} "${CMAKE_SOURCE_DIR}/cmake")
# Store builds in out folder.
SET(CMAKE_BINARY_DIR "${CMAKE_SOURCE_DIR}/out")
# Allow including from the root directory.
INCLUDE_DIRECTORIES(${CMAKE_SOURCE_DIR})


# Enable Testing
IF (ENABLE_TESTING)
    INCLUDE(CTest)
    ENABLE_TESTING()
ENDIF()


# Install Dependencies
INCLUDE(install_dependencies)
INSTALL_GIT_DEPENDENCIES()
INSTALL_CONAN_DEPENDENCIES()


# Enable compiler-specific compatibility flags and warnings.
IF (COMPILER_PROFILE)
    INCLUDE(compiler_config)
    CONFIGURE_COMPILER()
ENDIF()


# Add subprojects.
FILE(GLOB SUBFOLDERS CONFIGURE_DEPENDS LIST_DIRECTORIES ON "*")

FOREACH (SUBFOLDER IN ITEMS ${SUBFOLDERS})
    IF (IS_DIRECTORY "${SUBFOLDER}" AND EXISTS "${SUBFOLDER}/CMakeLists.txt")
        MESSAGE(STATUS "Found Target Subdirectory ${SUBFOLDER}.")
        ADD_SUBDIRECTORY(${SUBFOLDER})
    ENDIF()
ENDFOREACH()