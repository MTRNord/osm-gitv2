list(APPEND CMAKE_MODULE_PATH "${CMAKE_CURRENT_SOURCE_DIR}/../cmake")

find_package(Osmium REQUIRED COMPONENTS io pbf xml)
include_directories(SYSTEM ${OSMIUM_INCLUDE_DIRS})

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
          git2
          spdlog::spdlog)

target_include_directories(osm_git PRIVATE "${CMAKE_BINARY_DIR}/configured_files/include")