cmake_minimum_required(VERSION 3.12)

# --------------------------------------------------------
# if on OSX Darwin system, build the OSX executables
if (NOT ${CMAKE_HOST_SYSTEM_NAME} MATCHES "Darwin")
    message(FATAL_ERROR "${CMAKE_HOST_SYSTEM_NAME} host system name does not match OSX Darwin - Please select the correct folder for configuring project")
endif()

set(CMAKE_OSX_DEPLOYMENT_TARGET "12.1" CACHE STRING "Minimum OS X deployment version" FORCE)

# --------------------------------------------------------
# include common compiler options
include(../CommonCompilerOptions.CMake)

# --------------------------------------------------------
# Project
project(${PROJECT_NAME} C CXX)

# ------------------------------------------
# Set OSX specific runtime options

option(CMAKE_OSX_ARCHITECTURES "x86_64;arm64")
option(CMAKE_MACOSX_RPATH 1)
option(CMAKE_FIND_ROOT_PATH_MODE_PROGRAM "BOTH")
option(CMAKE_XCODE_ATTRIBUTE_ONLY_ACTIVE_ARCH FALSE)
option(CMAKE_IOS_INSTALL_COMBINED TRUE)

# Assuming that xcode 12.0 is installed you most probably have ios sdk 14.0 or later installed (tested on Big Sur)
# if you don't set a deployment target it will be set the way you only get 64-bit builds
if(NOT DEFINED DEPLOYMENT_TARGET AND XCODE_VERSION_INT VERSION_GREATER 12.0)
  # Temporarily fix the arm64 issues in CMake install-combined by excluding arm64 for simulator builds (needed for Apple Silicon...)
  set(CMAKE_XCODE_ATTRIBUTE_EXCLUDED_ARCHS[sdk=iphonesimulator*] "arm64")
endif()

# --------------------------------------------------------
# Set toolchain file
set(CMAKE_TOOLCHAIN_FILE "../cmake/toolchain/cxx17.cmake")

# --------------------------------------------------------
# Set OS threading settings
option(CMAKE_THREAD_LIBS_INIT "-lpthread")
option(CMAKE_HAVE_THREADS_LIBRARY ON)
option(CMAKE_USE_WIN32_THREADS_INIT OFF)
option(CMAKE_USE_PTHREADS_INIT ON)
option(THREADS_PREFER_PTHREAD_FLAG ON)

# --------------------------------------------------------
# Allow multiple definitions
option(FORCE_MULTILE ON)
option(MULTIPLE_OPTION "-Xlink=-force:multiple")

# --------------------------------------------------------
# Set extra compiler flags
option(EXTRA_CXX_FLAGS)

option(TESTING ON)

# --------------------------------------------------------
# Set custom subfolder for ABI
option(ABI_SUBFOLDER_NAME "")

# --------------------------------------------------------
# Include common build parameters
include(../CommonBuildParameters.cmake)
