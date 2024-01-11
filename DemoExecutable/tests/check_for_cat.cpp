#include <filesystem>
#include <cstdlib>


namespace fs = std::filesystem;


int main() {
    if (fs::exists(fs::path { DEMOEXECUTABLE_ASSETS_DIR "/cat_pictures/cat.png" })) return EXIT_SUCCESS;
    else return EXIT_FAILURE;
}
