cmake_minimum_required(VERSION 3.12)

include(../cmake/functions.cmake)
get_default_root()

set(PROJECT_NAME ${PROJECT_ROOT_NAME} CACHE STRING "Project Name")

# Project
project(${PROJECT_NAME} C CXX)

# if on OSX Darwin system, build the OSX executables
if(NOT ${CMAKE_HOST_SYSTEM_NAME} MATCHES "Darwin")
    message(FATAL_ERROR "${CMAKE_HOST_SYSTEM_NAME} host system name does not match OSX Darwin - Please select the correct folder for configuring project")
endif()

set(CMAKE_OSX_DEPLOYMENT_TARGET "12.1" CACHE STRING "Minimum OS X deployment version" FORCE)

# include common compiler options
include(../CommonCompilerOptions.CMake)

# Set OSX specific runtime options
set(CMAKE_OSX_ARCHITECTURES "x86_64;arm64" CACHE STRING "OSX Architectures")

set(CMAKE_MACOSX_RPATH 1 CACHE BOOL
    "include rpath in shared library")

set(CMAKE_FIND_ROOT_PATH_MODE_PROGRAM "BOTH" CACHE STRING "Find Program Paths")

set(CMAKE_XCODE_ATTRIBUTE_ONLY_ACTIVE_ARCH FALSE CACHE BOOL
    "Build only active archicture in Xcode")

set(CMAKE_IOS_INSTALL_COMBINED TRUE CACHE BOOL
    "Install all iOS architectures")

# Assuming that xcode 12.0 is installed you most probably have ios sdk 14.0 or later installed (tested on Big Sur)
# if you don't set a deployment target it will be set the way you only get 64-bit builds
if(NOT DEFINED DEPLOYMENT_TARGET AND XCODE_VERSION_INT VERSION_GREATER 12.0)
    # Temporarily fix the arm64 issues in CMake install-combined by excluding arm64 for simulator builds (needed for Apple Silicon...)
    set(CMAKE_XCODE_ATTRIBUTE_EXCLUDED_ARCHS[sdk=iphonesimulator*] "arm64")
endif()

# Set toolchain file
set(CMAKE_TOOLCHAIN_FILE "../cmake/toolchain/cxx17.cmake")

# Set OS threading settings
set(CMAKE_THREAD_LIBS_INIT "-lpthread" CACHE STRING "use pthread library init")

set(CMAKE_HAVE_THREADS_LIBRARY ON CACHE BOOL
    "if this OS has threads library")

set(CMAKE_USE_WIN32_THREADS_INIT OFF CACHE BOOL
    "If can use WIN32 Threads")

set(CMAKE_USE_PTHREADS_INIT ON CACHE BOOL
    "Use pThread init")

set(THREADS_PREFER_PTHREAD_FLAG ON CACHE BOOL
    "prefer pThreads")

# Allow multiple definitions
set(FORCE_MULTILE ON CACHE BOOL
    "Allow multiple definitions")

set(MULTIPLE_OPTION "-Xlink=-force:multiple" CACHE STRING "The option to allow multiple")

# Set extra compiler flags
set(EXTRA_CXX_FLAGS "" CACHE STRING "")

set(TESTING ON CACHE BOOL
    "Build tests")

# Set custom subfolder for ABI
set(ABI_SUBFOLDER_NAME "" CACHE STRING "Set custom ABI subfolder")

# Include common build parameters
include(../CommonBuildParameters.cmake)
