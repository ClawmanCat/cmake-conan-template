#include <DemoLib/some_package/package.hpp>

#include <cstdlib>


int main() {
    return demolib::my_number == 3
        ? EXIT_SUCCESS
        : EXIT_FAILURE;
}