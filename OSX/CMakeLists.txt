cmake_minimum_required(VERSION 3.22)

include(../cmake/functions.cmake)
get_default_root()

set(PROJECT_NAME ${PROJECT_ROOT_NAME} CACHE STRING "Project Name")

# if on OSX Darwin system, build the OSX executables
if(NOT ${CMAKE_HOST_SYSTEM_NAME} MATCHES "Darwin")
    message(FATAL_ERROR "${CMAKE_HOST_SYSTEM_NAME} host system name does not match OSX Darwin - Please select the correct folder for configuring project")
endif()

set(CMAKE_OSX_DEPLOYMENT_TARGET "12.1" CACHE STRING "Minimum OS X deployment version" FORCE)

# Set OSX specific runtime options
if(NOT DEFINED CMAKE_TOOLCHAIN_FILE)
    set(_PLATFORM "MAC_UNIVERSAL" CACHE STRING "Setting the build for both x86_64 and arm64")

    # set(_PLATFORM "MAC" CACHE STRING "Setting the default build for x86_64")
    set(NAMED_LANGUAGE_SUPPORT OFF CACHE BOOL "Toolchain named language support parameter")
    set(ENABLE_BITCODE OFF CACHE BOOL "Toolchain bitcode enable parameter")
    set(ENABLE_ARC OFF CACHE BOOL "Toolchain enable arc parameter")
    set(ENABLE_VISIBILITY ON CACHE BOOL "Toolchain visibility parameter")
    set(ENABLE_STRICT_TRY_COMPILE OFF CACHE BOOL "Toolchain try_compile enable parameter")
    set(PLATFORM ${_PLATFORM} CACHE STRING "Toolchain platform parameter")
    set(DEPLOYMENT_TARGET "12.1" CACHE STRING "Minimum OSX version")
    set(CMAKE_TOOLCHAIN_FILE "${CMAKE_CURRENT_SOURCE_DIR}/../apple.toolchain.cmake" CACHE STRING "Toolchain file")
endif()

set(CMAKE_MACOSX_RPATH 1 CACHE BOOL
    "include rpath in shared library")
set(ARCHS "x86_64;arm64" CACHE STRING "Default build for OSX is only x86_64 until boost can build universal image")

# Project
project(${PROJECT_NAME} LANGUAGES C CXX)

# include common compiler options
include(../CommonCompilerOptions.CMake)

# Assuming that xcode 12.0 is installed you most probably have ios sdk 14.0 or later installed (tested on Big Sur)
# if you don't set a deployment target it will be set the way you only get 64-bit builds
if(NOT DEFINED DEPLOYMENT_TARGET AND XCODE_VERSION_INT VERSION_GREATER 12.0)
    # Temporarily fix the arm64 issues in CMake install-combined by excluding arm64 for simulator builds (needed for Apple Silicon...)
    set(CMAKE_XCODE_ATTRIBUTE_EXCLUDED_ARCHS[sdk=iphonesimulator*] "arm64")
endif()

set(EXTRA_CXX_FLAGS "" CACHE STRING "")

set(TESTING ON CACHE BOOL "Build tests")

# Set custom subfolder for ABI
set(ABI_SUBFOLDER_NAME "" CACHE STRING "Set custom ABI subfolder")

# Include common build parameters
include(../CommonBuildParameters.cmake)
