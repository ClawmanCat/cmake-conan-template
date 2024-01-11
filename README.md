# CMake + Conan Project Template
A template for a C++ project using CMake and Conan. This is a standalone version of the CMake scaffolding used in my [VoxelEngine](https://github.com/ClawmanCat/VoxelEngine) project.
This template offers the following features:
- Easy generation of CMake targets using the `CREATE_TARGET` function.
- Easy generation of include-headers using the `CREATE_INCLUDE_HEADER` function.
- Easy generation of CMake targets for Conan dependencies (See below).
- Easy generation of CMake targets for external Git repositories containing a CMake project (See below).
- Easy generation of unit test targets which can be invoked through CTest (See below).
- Automatic copying or symlinking of assets for each subproject.
- Component/Plugin system for managing the output location of each target.
- Optional compiler profiles to easily enable extra compiler-specific warnings.
- Preconfigured Doxygen and clang-format configuration files.

Please check the root `CMakeLists.txt` or use a CMake GUI to see all configuration options.


### Building
You should install CMake (3.19 or newer), Conan (available through pip, currently Conan 2 is not supported) and have some generator (Visual Studio, Ninja, Makefile, etc.) installed.  

To set up and build your project (with Ninja):
```shell
mkdir out
cd out

cmake -G Ninja -DCMAKE_BUILD_TYPE=[DEBUG|RELEASE] -DENABLE_TESTS=[ON|OFF] -DCMAKE_C_COMPILER=[Compiler] -DCMAKE_CXX_COMPILER=[Compiler] ../
cmake --build ./[debug|release] --target all
```
(or just call CMake through your IDE)


### Creating Projects
To create a new project, create a subfolder in the project root directory and create a `CMakeLists.txt`. In the `CMakeLists.txt` file, use the `CREATE_TARGET` function from `create_target.cmake` to register your subproject:
```cmake
INCLUDE(create_target)


CREATE_TARGET(
    # Name
    MyProgram
    # Version (Major Minor Patch)
    1 0 0
    # CMake Target Type (EXECUTABLE|INTERFACE|OBJECT|SHARED|STATIC)
    EXECUTABLE
    # Project Component Type (COMPONENT|PLUGIN|TEST)
    # Plugins are output into the 'plugins' subfolder of the output directory.
    COMPONENT
    # Dependencies for the target
    PUBLIC MyDependencyLib
    PRIVATE MyOtherDependencyLib
    PUBLIC CONAN_PKG::SomeConanPackage
    PUBLIC GIT_PKG::SomeGitDependency
)
```


### Adding Dependencies
In the dependencies subfolder of this project, you will find a `conanfile.txt` and a `gitrepos.txt`. The conanfile [works as a normal conanfile](https://docs.conan.io/1/reference/conanfile_txt.html) and can be used to add Conan dependencies.
For libraries that do not provide a Conan package, you can use the gitrepos file to directly clone any Git repository containing a CMake project.
Your `gitrepos.txt` should contain one repository per line, formatted as `<Package Name> <Repository URL> <Tag or Revision> <CMake Target>`, where `<PACKAGE NAME>` is the resulting dependency name and `<CMake Target>` is the name of the CMake target in the original project.

After installing dependencies through one of the above methods, they can be added to a subproject by adding either `CONAN_PKG::PackageName` or `GIT_PKG::PackageName` to the dependency list passed to `CREATE_TARGET`. 

### Testing
Any cpp file in the `tests` subfolder of any project will automatically be compiled into a test using CTest.
You can use whatever testing framework you want, just provide (or have the framework provide) a `main` method in each test translation unit.  

To build and run your tests, simply invoke `ctest` after building your project with `-DENABLE_TESTS=ON`:
```shell
mkdir out
cd out

cmake -G Ninja -DENABLE_TESTS=ON -DCMAKE_BUILD_TYPE=[DEBUG|RELEASE] -DCMAKE_C_COMPILER=[Compiler] -DCMAKE_CXX_COMPILER=[Compiler] ../
cmake --build ./[debug|release] --target all

ctest
```