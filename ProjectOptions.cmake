include(cmake/SystemLink.cmake)
include(cmake/LibFuzzer.cmake)
include(CMakeDependentOption)
include(CheckCXXCompilerFlag)


macro(osm_gitv2_supports_sanitizers)
  if((CMAKE_CXX_COMPILER_ID MATCHES ".*Clang.*" OR CMAKE_CXX_COMPILER_ID MATCHES ".*GNU.*") AND NOT WIN32)
    set(SUPPORTS_UBSAN ON)
  else()
    set(SUPPORTS_UBSAN OFF)
  endif()

  if((CMAKE_CXX_COMPILER_ID MATCHES ".*Clang.*" OR CMAKE_CXX_COMPILER_ID MATCHES ".*GNU.*") AND WIN32)
    set(SUPPORTS_ASAN OFF)
  else()
    set(SUPPORTS_ASAN ON)
  endif()
endmacro()

macro(osm_gitv2_setup_options)
  option(osm_gitv2_ENABLE_HARDENING "Enable hardening" ON)
  option(osm_gitv2_ENABLE_COVERAGE "Enable coverage reporting" OFF)
  cmake_dependent_option(
    osm_gitv2_ENABLE_GLOBAL_HARDENING
    "Attempt to push hardening options to built dependencies"
    ON
    osm_gitv2_ENABLE_HARDENING
    OFF)

  osm_gitv2_supports_sanitizers()

  if(NOT PROJECT_IS_TOP_LEVEL OR osm_gitv2_PACKAGING_MAINTAINER_MODE)
    option(osm_gitv2_ENABLE_IPO "Enable IPO/LTO" OFF)
    option(osm_gitv2_WARNINGS_AS_ERRORS "Treat Warnings As Errors" OFF)
    option(osm_gitv2_ENABLE_USER_LINKER "Enable user-selected linker" OFF)
    option(osm_gitv2_ENABLE_SANITIZER_ADDRESS "Enable address sanitizer" OFF)
    option(osm_gitv2_ENABLE_SANITIZER_LEAK "Enable leak sanitizer" OFF)
    option(osm_gitv2_ENABLE_SANITIZER_UNDEFINED "Enable undefined sanitizer" OFF)
    option(osm_gitv2_ENABLE_SANITIZER_THREAD "Enable thread sanitizer" OFF)
    option(osm_gitv2_ENABLE_SANITIZER_MEMORY "Enable memory sanitizer" OFF)
    option(osm_gitv2_ENABLE_UNITY_BUILD "Enable unity builds" OFF)
    option(osm_gitv2_ENABLE_CLANG_TIDY "Enable clang-tidy" OFF)
    option(osm_gitv2_ENABLE_CPPCHECK "Enable cpp-check analysis" OFF)
    option(osm_gitv2_ENABLE_PCH "Enable precompiled headers" OFF)
    option(osm_gitv2_ENABLE_CACHE "Enable ccache" OFF)
  else()
    option(osm_gitv2_ENABLE_IPO "Enable IPO/LTO" ON)
    option(osm_gitv2_WARNINGS_AS_ERRORS "Treat Warnings As Errors" ON)
    option(osm_gitv2_ENABLE_USER_LINKER "Enable user-selected linker" OFF)
    option(osm_gitv2_ENABLE_SANITIZER_ADDRESS "Enable address sanitizer" ${SUPPORTS_ASAN})
    option(osm_gitv2_ENABLE_SANITIZER_LEAK "Enable leak sanitizer" OFF)
    option(osm_gitv2_ENABLE_SANITIZER_UNDEFINED "Enable undefined sanitizer" ${SUPPORTS_UBSAN})
    option(osm_gitv2_ENABLE_SANITIZER_THREAD "Enable thread sanitizer" OFF)
    option(osm_gitv2_ENABLE_SANITIZER_MEMORY "Enable memory sanitizer" OFF)
    option(osm_gitv2_ENABLE_UNITY_BUILD "Enable unity builds" OFF)
    option(osm_gitv2_ENABLE_CLANG_TIDY "Enable clang-tidy" ON)
    option(osm_gitv2_ENABLE_CPPCHECK "Enable cpp-check analysis" ON)
    option(osm_gitv2_ENABLE_PCH "Enable precompiled headers" OFF)
    option(osm_gitv2_ENABLE_CACHE "Enable ccache" ON)
  endif()

  if(NOT PROJECT_IS_TOP_LEVEL)
    mark_as_advanced(
      osm_gitv2_ENABLE_IPO
      osm_gitv2_WARNINGS_AS_ERRORS
      osm_gitv2_ENABLE_USER_LINKER
      osm_gitv2_ENABLE_SANITIZER_ADDRESS
      osm_gitv2_ENABLE_SANITIZER_LEAK
      osm_gitv2_ENABLE_SANITIZER_UNDEFINED
      osm_gitv2_ENABLE_SANITIZER_THREAD
      osm_gitv2_ENABLE_SANITIZER_MEMORY
      osm_gitv2_ENABLE_UNITY_BUILD
      osm_gitv2_ENABLE_CLANG_TIDY
      osm_gitv2_ENABLE_CPPCHECK
      osm_gitv2_ENABLE_COVERAGE
      osm_gitv2_ENABLE_PCH
      osm_gitv2_ENABLE_CACHE)
  endif()

  osm_gitv2_check_libfuzzer_support(LIBFUZZER_SUPPORTED)
  if(LIBFUZZER_SUPPORTED AND (osm_gitv2_ENABLE_SANITIZER_ADDRESS OR osm_gitv2_ENABLE_SANITIZER_THREAD OR osm_gitv2_ENABLE_SANITIZER_UNDEFINED))
    set(DEFAULT_FUZZER ON)
  else()
    set(DEFAULT_FUZZER OFF)
  endif()

  option(osm_gitv2_BUILD_FUZZ_TESTS "Enable fuzz testing executable" ${DEFAULT_FUZZER})

endmacro()

macro(osm_gitv2_global_options)
  if(osm_gitv2_ENABLE_IPO)
    include(cmake/InterproceduralOptimization.cmake)
    osm_gitv2_enable_ipo()
  endif()

  osm_gitv2_supports_sanitizers()

  if(osm_gitv2_ENABLE_HARDENING AND osm_gitv2_ENABLE_GLOBAL_HARDENING)
    include(cmake/Hardening.cmake)
    if(NOT SUPPORTS_UBSAN 
       OR osm_gitv2_ENABLE_SANITIZER_UNDEFINED
       OR osm_gitv2_ENABLE_SANITIZER_ADDRESS
       OR osm_gitv2_ENABLE_SANITIZER_THREAD
       OR osm_gitv2_ENABLE_SANITIZER_LEAK)
      set(ENABLE_UBSAN_MINIMAL_RUNTIME FALSE)
    else()
      set(ENABLE_UBSAN_MINIMAL_RUNTIME TRUE)
    endif()
    message("${osm_gitv2_ENABLE_HARDENING} ${ENABLE_UBSAN_MINIMAL_RUNTIME} ${osm_gitv2_ENABLE_SANITIZER_UNDEFINED}")
    osm_gitv2_enable_hardening(osm_gitv2_options ON ${ENABLE_UBSAN_MINIMAL_RUNTIME})
  endif()
endmacro()

macro(osm_gitv2_local_options)
  if(PROJECT_IS_TOP_LEVEL)
    include(cmake/StandardProjectSettings.cmake)
  endif()

  add_library(osm_gitv2_warnings INTERFACE)
  add_library(osm_gitv2_options INTERFACE)

  include(cmake/CompilerWarnings.cmake)
  osm_gitv2_set_project_warnings(
    osm_gitv2_warnings
    ${osm_gitv2_WARNINGS_AS_ERRORS}
    ""
    ""
    ""
    "")

  if(osm_gitv2_ENABLE_USER_LINKER)
    include(cmake/Linker.cmake)
    configure_linker(osm_gitv2_options)
  endif()

  include(cmake/Sanitizers.cmake)
  osm_gitv2_enable_sanitizers(
    osm_gitv2_options
    ${osm_gitv2_ENABLE_SANITIZER_ADDRESS}
    ${osm_gitv2_ENABLE_SANITIZER_LEAK}
    ${osm_gitv2_ENABLE_SANITIZER_UNDEFINED}
    ${osm_gitv2_ENABLE_SANITIZER_THREAD}
    ${osm_gitv2_ENABLE_SANITIZER_MEMORY})

  set_target_properties(osm_gitv2_options PROPERTIES UNITY_BUILD ${osm_gitv2_ENABLE_UNITY_BUILD})

  if(osm_gitv2_ENABLE_PCH)
    target_precompile_headers(
      osm_gitv2_options
      INTERFACE
      <vector>
      <string>
      <utility>)
  endif()

  if(osm_gitv2_ENABLE_CACHE)
    include(cmake/Cache.cmake)
    osm_gitv2_enable_cache()
  endif()

  include(cmake/StaticAnalyzers.cmake)
  if(osm_gitv2_ENABLE_CLANG_TIDY)
    osm_gitv2_enable_clang_tidy(osm_gitv2_options ${osm_gitv2_WARNINGS_AS_ERRORS})
  endif()

  if(osm_gitv2_ENABLE_CPPCHECK)
    osm_gitv2_enable_cppcheck(${osm_gitv2_WARNINGS_AS_ERRORS} "" # override cppcheck options
    )
  endif()

  if(osm_gitv2_ENABLE_COVERAGE)
    include(cmake/Tests.cmake)
    osm_gitv2_enable_coverage(osm_gitv2_options)
  endif()

  if(osm_gitv2_WARNINGS_AS_ERRORS)
    check_cxx_compiler_flag("-Wl,--fatal-warnings" LINKER_FATAL_WARNINGS)
    if(LINKER_FATAL_WARNINGS)
      # This is not working consistently, so disabling for now
      # target_link_options(osm_gitv2_options INTERFACE -Wl,--fatal-warnings)
    endif()
  endif()

  if(osm_gitv2_ENABLE_HARDENING AND NOT osm_gitv2_ENABLE_GLOBAL_HARDENING)
    include(cmake/Hardening.cmake)
    if(NOT SUPPORTS_UBSAN 
       OR osm_gitv2_ENABLE_SANITIZER_UNDEFINED
       OR osm_gitv2_ENABLE_SANITIZER_ADDRESS
       OR osm_gitv2_ENABLE_SANITIZER_THREAD
       OR osm_gitv2_ENABLE_SANITIZER_LEAK)
      set(ENABLE_UBSAN_MINIMAL_RUNTIME FALSE)
    else()
      set(ENABLE_UBSAN_MINIMAL_RUNTIME TRUE)
    endif()
    osm_gitv2_enable_hardening(osm_gitv2_options OFF ${ENABLE_UBSAN_MINIMAL_RUNTIME})
  endif()

endmacro()
