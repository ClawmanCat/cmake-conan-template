INCLUDE(create_target)
INCLUDE(create_include_header)


CREATE_TARGET(
    DemoLib
    0 0 1
    OBJECT COMPONENT
    # Dependencies:
    PUBLIC CONAN_PKG::boost
)


# Will generate a single-include header for all headers in some_package.
CREATE_INCLUDE_HEADER(DemoLib some_package package.hpp)