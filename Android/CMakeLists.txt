cmake_minimum_required(VERSION 3.15)



# --------------------------------------------------------
# Set cross compiling settings
set(CMAKE_SYSTEM_NAME Android)
set(CMAKE_SYSTEM_VERSION 28) # API level
set(ANDROID_NATIVE_API_LEVEL 28)



# --------------------------------------------------------
# Check Android NDK version
if(NOT CMAKE_ANDROID_NDK)
	message(FATAL_ERROR "Cannot find Android NDK, make sure you pass -DCMAKE_ANDROID_NDK=[path_to_NDK]")
endif()

file(READ "${CMAKE_ANDROID_NDK}/source.properties" SOURCE_PROPERTIES_CONTENT)
string(REGEX MATCH "Pkg\\.Revision = ([0-9]+)\\.([0-9]+)\\." NDK_VERSION_MATCH "${SOURCE_PROPERTIES_CONTENT}")
set(CMAKE_ANDROID_NDK_VERSION ${CMAKE_MATCH_1})
set(CMAKE_ANDROID_NDK_VERSION_MINOR ${CMAKE_MATCH_2})

message("--Android NDK version: ${CMAKE_ANDROID_NDK_VERSION}.${CMAKE_ANDROID_NDK_VERSION_MINOR}")

if (NOT CMAKE_ANDROID_NDK_VERSION EQUAL 25)
  message(FATAL_ERROR "Android NDK LTS Version (r25b) stable long term support version required")
endif()

# --------------------------------------------------------
# Check required input args
if(NOT ANDROID_ABI)
	message(FATAL_ERROR "Cannot find ANDROID_ABI, make sure you pass -DANDROID_ABI=[armeabi-v7a | arm64-v8a | x86 | x86_64]")
endif()
set(CMAKE_ANDROID_ARCH_ABI ${ANDROID_ABI})

if(NOT ANDROID_TOOLCHAIN)
	message(FATAL_ERROR "Cannot find ANDROID_TOOLCHAIN, make sure you pass -DANDROID_TOOLCHAIN=[e.g clang]")
endif()

# --------------------------------------------------------
# Config param for android
set(CMAKE_ANDROID_STL_TYPE c++_static)

# --------------------------------------------------------
# Set toolchain file
set(CMAKE_TOOLCHAIN_FILE "${CMAKE_ANDROID_NDK}/build/cmake/android.toolchain.cmake")
if(NOT EXISTS ${CMAKE_TOOLCHAIN_FILE})
  message(FATAL_ERROR "Android NDK toolchain file ${CMAKE_TOOLCHAIN_FILE} not found")
endif()

set(Boost_COMPILER "clang")

include(../cmake/functions.cmake)
get_default_root()
# --------------------------------------------------------
# Project
if (NOT DEFINED PROJECT_NAME)
  set(PROJECT_NAME ${PROJECT_ROOT_NAME} CACHE STRING "Default Project Name")
  endif()
# --------------------------------------------------------
# Project
project(${PROJECT_NAME} C CXX)

set(ANDROID_ABI_FOLDER "/${ANDROID_ABI}")
# --------------------------------------------------------
# include common compiler options
include(../CommonCompilerOptions.cmake)

# --------------------------------------------------------
# Turn off examples
set(BUILD_EXAMPLES OFF)

# --------------------------------------------------------
# Set custom subfolder for ABI
set(ABI_SUBFOLDER_NAME "/${ANDROID_ABI}")

# --------------------------------------------------------
# Allow multiple definitions
set(FORCE_MULTILE OFF)

# --------------------------------------------------------
# Set extra compiler flags
set(EXTRA_CXX_FLAGS -Wno-error)

set(TESTING OFF)

# --------------------------------------------------------
# Include common build parameters
include(../CommonBuildParameters.cmake)

message("Boost_LIBRARIES: ${Boost_LIBRARIES}")
