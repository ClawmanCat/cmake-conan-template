# This script automatically generates single-include headers that include all files inside of a given directory.
# It is possible to exclude headers by passing one or more regexes as variadic parameters.
#
# E.g. generate_include_header(MyLib graphics graphics.hpp graphics/?.*/detail.hpp)
# will generate the file MyLib/graphics/graphics.hpp containing include statements for all headers in MyLib/graphics,
# except those named detail.hpp.
function(generate_include_header target directory header_name)
    set(target_path "${CMAKE_SOURCE_DIR}/${target}/${directory}/${header_name}")
    file(GLOB_RECURSE headers CONFIGURE_DEPENDS "${CMAKE_SOURCE_DIR}/${target}/${directory}/*.hpp")


    list(REMOVE_ITEM headers ${target_path}) # Header should not include itself.

    foreach (filter IN ITEMS ${ARGN})
        list(FILTER headers EXCLUDE REGEX ".*${filter}")
    endforeach()


    message(STATUS "Updating auto-generated header list at ${target_path}.")

    file(
        WRITE
        ${target_path}
        "// This file is automatically generated by CMake.\n"
        "// Do not edit it, as your changes will be overwritten the next time CMake is run.\n"
        "// This file includes headers from ${target}/${directory}.\n\n"
        "#pragma once\n\n"
    )

    foreach(header IN ITEMS ${headers})
        file(RELATIVE_PATH header_path "${CMAKE_SOURCE_DIR}" "${header}")
        file(APPEND ${target_path} "#include <${header_path}>\n")
    endforeach()
endfunction()