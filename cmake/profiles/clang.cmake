function(load_compiler_profile)
    include(profiles/gcclike_common)
    include(utility)

    load_common_profile()


    get_platform_name(os)

    if (${os} STREQUAL windows)
        # Clang does not support [[no_unique_address]] on Windows.
        # (https://bugs.llvm.org/show_bug.cgi?id=50014)
        set_compiler_option(-Wno-unknown-attributes)

        # Clang does not compile with the same default as MSVC for exceptions on Windows.
        set_compiler_option(-fexceptions)
        set_compiler_option(-fcxx-exceptions)
    endif()
endfunction()