include(cmake/CPM.cmake)

# Done as a function so that updates to variables like
# CMAKE_CXX_FLAGS don't propagate out to other
# targets
function(osm_git_setup_dependencies)

  # For each dependency, see if it's
  # already been provided to us by a parent project

  if(NOT TARGET fmtlib::fmtlib)
    cpmaddpackage("gh:fmtlib/fmt#10.2.1")
  endif()

  if(NOT TARGET spdlog::spdlog)
    cpmaddpackage(
      NAME
      spdlog
      VERSION
      1.13.0
      GITHUB_REPOSITORY
      "gabime/spdlog"
      OPTIONS
      "SPDLOG_FMT_EXTERNAL ON")
  endif()

  if(NOT TARGET Catch2::Catch2WithMain)
    cpmaddpackage("gh:catchorg/Catch2@3.5.2")
  endif()

  if(NOT TARGET CLI11::CLI11)
    cpmaddpackage("gh:CLIUtils/CLI11@2.4.1")
  endif()

  if(NOT TARGET libgit2cpp::git2cpp)
    cpmaddpackage(
      NAME libgit2cpp
      GITHUB_REPOSITORY AndreyG/libgit2cpp
      GIT_TAG master
      OPTIONS
        "BUILD_LIBGIT2CPP_EXAMPLES OFF")
  endif()

endfunction()