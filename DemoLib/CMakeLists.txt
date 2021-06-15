include(create_target)
include(generate_include_header)


create_target(
    DemoLib
    OBJECT
    0 0 1
    # Dependencies:
    PUBLIC CONAN_PKG::boost
)

# Will generate a single-include header for all headers in some_package.
generate_include_header(DemoLib some_package package.hpp)