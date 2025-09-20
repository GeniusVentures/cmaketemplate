cmake_minimum_required(VERSION 3.22)

include(../cmake/functions.cmake)
get_default_root()

set(PROJECT_NAME ${PROJECT_ROOT_NAME} CACHE STRING "Project Name")

# Set OSX specific runtime options
if(NOT DEFINED CMAKE_TOOLCHAIN_FILE)
    set(_PLATFORM "MAC_UNIVERSAL" CACHE STRING "Setting the build for both x86_64 and arm64")

    set(NAMED_LANGUAGE_SUPPORT ON CACHE BOOL "Toolchain named language support parameter")
    set(ENABLE_BITCODE OFF CACHE BOOL "Toolchain bitcode enable parameter")
    set(ENABLE_ARC OFF CACHE BOOL "Toolchain enable arc parameter")
    set(ENABLE_VISIBILITY ON CACHE BOOL "Toolchain visibility parameter")
    set(ENABLE_STRICT_TRY_COMPILE OFF CACHE BOOL "Toolchain try_compile enable parameter")
    set(PLATFORM ${_PLATFORM} CACHE STRING "Toolchain platform parameter")
    set(DEPLOYMENT_TARGET "13.0" CACHE STRING "Minimum OSX version")
    set(CMAKE_TOOLCHAIN_FILE "${CMAKE_CURRENT_SOURCE_DIR}/../apple.toolchain.cmake" CACHE STRING "Toolchain file")
endif()

set(CMAKE_MACOSX_RPATH 1 CACHE BOOL
    "include rpath in shared library")

project(${PROJECT_NAME} LANGUAGES C CXX)

include(../CommonCompilerOptions.CMake)

set(EXTRA_CXX_FLAGS "" CACHE STRING "")

set(TESTING ON CACHE BOOL "Build tests")

# Include common build parameters
include(../CommonBuildParameters.cmake)
