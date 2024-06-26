cmake_minimum_required(VERSION 3.15)

# --------------------------------------------------------
# if on OSX Darwin system, build the iOS executables
if (NOT ${CMAKE_HOST_SYSTEM_NAME} MATCHES "Darwin")
    message(FATAL_ERROR "${CMAKE_HOST_SYSTEM_NAME} host system name does not match OSX Darwin for iOS cross compiling - Please select the correct folder for configuring project")
endif()

if(POLICY CMP0025)
	#NEW: report OS X version of Clang as "AppleClang"
  cmake_policy(SET CMP0025 NEW)
endif()
if(POLICY CMP0042)
  #NEW: set TARGET PROPERTY MACOSX_RPATH to on by default
  cmake_policy(SET CMP0042 NEW)
endif()

set(IOS_DEPLOYMENT_TARGET 12.0)

include(../cmake/functions.cmake)
get_default_root()

set(PROJECT_NAME "Default Project Name" ${PROJECT_ROOT_NAME})
# --------------------------------------------------------
# Project
project(${PROJECT_NAME} C CXX)

# --------------------------------------------------------
# Set cross compiling settings
set(CMAKE_SYSTEM_NAME "iOS")

# --------------------------------------------------------
# include common compiler options
include(../CommonCompilerOptions.CMake)

# --------------------------------------------------------
# Project
project(${PROJECT_NAME} C CXX)

set(CMAKE_FIND_ROOT_PATH_MODE_PROGRAM "BOTH")
set(CMAKE_TRY_COMPILE_TARGET_TYPE STATIC_LIBRARY)

# --------------------------------------------------------
# Turn off examples
set(BUILD_EXAMPLES OFF)

# --------------------------------------------------------
# Set toolchain file
set(CMAKE_TOOLCHAIN_FILE "${CMAKE_CURRENT_SOURCE_DIR}/iOS.cmake")

# --------------------------------------------------------
# Check required input args
if(NOT CMAKE_TOOLCHAIN_FILE)
	message(FATAL_ERROR "Cannot find CMAKE_TOOLCHAIN_FILE, make sure you pass -DCMAKE_TOOLCHAIN_FILE=[arm64]")
endif()

if(NOT iOS_ABI)
	message(FATAL_ERROR "Cannot find iOS_ABI, make sure you pass -DiOS_ABI=[arm64-v8a]")
endif()

if(NOT IOS_ARCH)
	message(FATAL_ERROR "Cannot find IOS_ARCH, make sure you pass -DIOS_ARCH=[arm64]")
endif()

if(NOT CMAKE_OSX_ARCHITECTURES)
	message(FATAL_ERROR "Cannot find CMAKE_OSX_ARCHITECTURES, make sure you pass -DCMAKE_OSX_ARCHITECTURES=[arm64]")
endif()

if(NOT CMAKE_SYSTEM_PROCESSOR)
	message(FATAL_ERROR "Cannot find CMAKE_SYSTEM_PROCESSOR, make sure you pass -DCMAKE_SYSTEM_PROCESSOR=[arm64]")
endif()

# --------------------------------------------------------
# Config param for iOS
set(ENABLE_ARC "0")
set(ENABLE_BITCODE NO)
set(CMAKE_XCODE_ATTRIBUTE_ONLY_ACTIVE_ARCH YES)

# --------------------------------------------------------
# Set custom protobuf path for iOS
#set(Protobuf_DIR  "${THIRDPARTY_BUILD_DIR}/protobuf/lib/cmake/protobuf")
#set(Protobuf_INCLUDE_DIR "${THIRDPARTY_BUILD_DIR}/protobuf/include/google/protobuf")
#set(Protobuf_LIBRARIES "${THIRDPARTY_BUILD_DIR}/protobuf/lib")

# --------------------------------------------------------
# Set OS threading settings
set(CMAKE_THREAD_LIBS_INIT "-lpthread")
set(CMAKE_HAVE_THREADS_LIBRARY ON)
set(CMAKE_USE_WIN32_THREADS_INIT OFF)
set(CMAKE_USE_PTHREADS_INIT ON)
set(THREADS_PREFER_PTHREAD_FLAG ON)

# --------------------------------------------------------
# Allow multiple definitions
set(FORCE_MULTILE ON)
set(MULTIPLE_OPTION "-Xlink=-force:multiple")

# --------------------------------------------------------
# Set extra compiler flags
set(EXTRA_CXX_FLAGS -std=c++17)

# --------------------------------------------------------
# Set custom subfolder for ABI
set(ABI_SUBFOLDER_NAME "/${iOS_ABI}")

set(TESTING OFF)

# --------------------------------------------------------
# Include common build parameters
include(../CommonBuildParameters.cmake)
