#include <filesystem>
#include <cstdlib>
#include <iostream>


namespace fs = std::filesystem;


int main() {
    const auto cat_path = fs::path { "./assets/test_check_for_cat/cat_pictures/cat.png" };
    std::cout << "Checking for the existence of " << cat_path.string() << std::endl;
    
    if (fs::exists(cat_path)) return EXIT_SUCCESS;
    else return EXIT_FAILURE;
}
