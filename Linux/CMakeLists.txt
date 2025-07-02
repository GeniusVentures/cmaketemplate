cmake_minimum_required(VERSION 3.22)

include(../cmake/functions.cmake)
get_default_root()

if(NOT DEFINED PROJECT_NAME)
    set(PROJECT_NAME ${PROJECT_ROOT_NAME} CACHE STRING "Default Project Name")
endif()

# Project
project(${PROJECT_NAME} LANGUAGES C CXX)

# if on Linux system, build the Linux executables
if(NOT ${CMAKE_HOST_SYSTEM_NAME} MATCHES "Linux")
    message(FATAL_ERROR "${CMAKE_HOST_SYSTEM_NAME} host system name does not match Linux - Please select the correct folder for configuring project")
endif()

# Set toolchain file before the project call
get_filename_component(_LINUX_FOLDER "${CMAKE_CURRENT_SOURCE_DIR}" DIRECTORY ABSOLUTE)
get_filename_component(_BUILD_FOLDER "${_LINUX_FOLDER}" DIRECTORY ABSOLUTE)

set(ARCH ${CMAKE_SYSTEM_PROCESSOR})

# Normalize architecture names
if(ARCH MATCHES "(x86_64|amd64|AMD64)")
    set(ARCH "x86_64")
elseif(ARCH MATCHES "(aarch64|arm64|ARM64)")
    set(ARCH "aarch64")
else()
    message(WARNING "Unknown Linux architecture: ${ARCH}, using as-is")
endif()

set(ABI_SUBFOLDER_NAME "/${ARCH}")

# include common compiler options
include(../CommonCompilerOptions.cmake)

# Set extra compiler flags
set(EXTRA_CXX_FLAGS)

# Include common build parameters
include(../CommonBuildParameters.cmake)
