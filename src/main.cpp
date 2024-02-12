#include <CLI/CLI.hpp>
#include <spdlog/spdlog.h>

// This file will be generated automatically when you run the CMake
// configuration step. It creates a namespace called `osm_git`. You can modify
// the source template at `configured_files/config.hpp.in`.
#include <internal_use_only/config.hpp>

// NOLINTNEXTLINE(bugprone-exception-escape)
int main(int argc, char **argv)
{
  try {
    CLI::App app{ "A tool which converts regular osm files into yaml based git repos" };
    argv = app.ensure_utf8(argv);

    bool show_version = false;
    app.add_flag("--version", show_version, "Show version information");
    CLI11_PARSE(app, argc, argv);

    if (show_version) {
      fmt::print("{}\n", osm_git::cmake::project_version);
      return EXIT_SUCCESS;
    }
  } catch (const std::exception &e) {
    spdlog::error("Unhandled exception in main: {}", e.what());
  }
  return EXIT_SUCCESS;
}