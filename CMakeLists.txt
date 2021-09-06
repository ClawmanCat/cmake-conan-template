cmake_minimum_required(VERSION 3.19)
project("CMake Conan Demo")


# Allow loading of scripts from cmake folder.
set(CMAKE_MODULE_PATH ${CMAKE_MODULE_PATH} "${CMAKE_SOURCE_DIR}/cmake")

# Allow including from the root directory.
include_directories(${CMAKE_SOURCE_DIR})

# Store builds in out folder.
set(CMAKE_BINARY_DIR "${CMAKE_SOURCE_DIR}/out")

# Output to out directory.
set(CMAKE_ARCHIVE_OUTPUT_DIRECTORY ${CMAKE_SOURCE_DIR}/out/${CMAKE_BUILD_TYPE}/lib)
set(CMAKE_LIBRARY_OUTPUT_DIRECTORY ${CMAKE_SOURCE_DIR}/out/${CMAKE_BUILD_TYPE}/lib)
set(CMAKE_RUNTIME_OUTPUT_DIRECTORY ${CMAKE_SOURCE_DIR}/out/${CMAKE_BUILD_TYPE}/bin)


# Install Dependencies
include(run_conan)

select_conan_profile(conan_profile)
run_conan(${conan_profile})

# Enable compiler-specific warnings
include(compiler_profile)
set_compiler_profile()


# Make sure symbols are exported on Windows.
# (This prevents requiring specifying dllexport / dllimport everywhere.)
set(CMAKE_WINDOWS_EXPORT_ALL_SYMBOLS ON)


# Copy required directories to binary folder.
add_custom_target(
    COPY_OUT_DIRS ALL
    COMMAND ${CMAKE_COMMAND} -E copy_directory
        ${CMAKE_SOURCE_DIR}/out_dirs
        ${CMAKE_RUNTIME_OUTPUT_DIRECTORY}
)

# Copy shared libraries from conan folder to binary folder.
if (EXISTS ${CMAKE_SOURCE_DIR}/out/conan/bin)
    add_custom_target(
        COPY_SHARED_LIBS ALL
        COMMAND ${CMAKE_COMMAND} -E copy_directory
            ${CMAKE_SOURCE_DIR}/out/conan/bin
            ${CMAKE_RUNTIME_OUTPUT_DIRECTORY}
    )
endif()


# Enable testing (Each subproject can add its own tests.)
if (${ENABLE_TESTING})
    message(STATUS "Test generation is enabled.")
    enable_testing()
endif()


# Add subprojects.
add_subdirectory(DemoLib)
add_subdirectory(DemoExecutable)