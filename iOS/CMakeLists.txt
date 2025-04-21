cmake_minimum_required(VERSION 3.22)

include(../cmake/functions.cmake)
get_default_root()

if(NOT DEFINED CMAKE_TOOLCHAIN_FILE)
    set(NAMED_LANGUAGE_SUPPORT OFF CACHE BOOL "Toolchain named language support parameter")
    set(ENABLE_BITCODE OFF CACHE BOOL "Toolchain bitcode enable parameter")
    set(ENABLE_ARC OFF CACHE BOOL "Toolchain enable arc parameter")
    set(ENABLE_VISIBILITY ON CACHE BOOL "Toolchain visibility parameter")
    set(ENABLE_STRICT_TRY_COMPILE OFF CACHE BOOL "Toolchain try_compile enable parameter")
    set(PLATFORM OS64 CACHE STRING "Toolchain platform parameter")
    set(DEPLOYMENT_TARGET "16" CACHE STRING "Minimum iOS version")
    set(CMAKE_TOOLCHAIN_FILE "${CMAKE_CURRENT_SOURCE_DIR}/../apple.toolchain.cmake" CACHE STRING "Toolchain file")
endif()

set(PROJECT_NAME ${PROJECT_ROOT_NAME} CACHE STRING "Project name")

# Project
project(${PROJECT_NAME} C CXX)

set(CMAKE_FIND_ROOT_PATH_MODE_PROGRAM "BOTH")
set(CMAKE_TRY_COMPILE_TARGET_TYPE STATIC_LIBRARY)

# Turn off examples
set(BUILD_EXAMPLES OFF)

set(BUILD_TESTING OFF)

# include common compiler options
include(../CommonCompilerOptions.CMake)

# Include common build parameters
include(../CommonBuildParameters.cmake)
