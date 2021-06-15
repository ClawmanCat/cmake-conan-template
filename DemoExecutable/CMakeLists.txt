include(create_target)

create_target(
    DemoExecutable
    EXECUTABLE
    0 0 1
    # Dependencies:
    PUBLIC DemoLib
)