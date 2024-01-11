FUNCTION(CONFIGURE_COMPILER)
    # Enable compiler-specific compatibility flags and warnings.
    IF (CMAKE_CXX_COMPILER_ID STREQUAL "MSVC")
        INCLUDE(profiles/compatibility_msvc)
        INCLUDE(profiles/warnings_msvc)

        SET_COMPATIBILITY_FLAGS()
        SET_COMPILER_WARNINGS()
    ELSEIF (CMAKE_CXX_COMPILER_ID MATCHES ".*Clang")
        INCLUDE(profiles/compatibility_clang)
        INCLUDE(profiles/warnings_clang)

        SET_COMPATIBILITY_FLAGS()
        SET_COMPILER_WARNINGS()
    ELSEIF (CMAKE_CXX_COMPILER_ID STREQUAL "GNU")
        INCLUDE(profiles/warnings_gcc)

        SET_COMPILER_WARNINGS()
    ENDIF()
ENDFUNCTION()