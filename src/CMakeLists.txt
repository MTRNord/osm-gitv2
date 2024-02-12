add_executable(osm_git main.cpp)

target_link_libraries(
  osm_git
  PRIVATE osm_git::osm_git_options
          osm_git::osm_git_warnings)

target_link_system_libraries(
  osm_git
  PRIVATE
          CLI11::CLI11
          fmt::fmt
          spdlog::spdlog)

target_include_directories(osm_git PRIVATE "${CMAKE_BINARY_DIR}/configured_files/include")
