cmake_minimum_required(VERSION 3.12)

include(../cmake/functions.cmake)
get_default_root()

if (NOT DEFINED PROJECT_NAME)
set(PROJECT_NAME ${PROJECT_ROOT_NAME} CACHE STRING "Default Project Name")
endif()

set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)
set(CMAKE_CXX_EXTENSIONS OFF)

# Project
project(${PROJECT_NAME} LANGUAGES C CXX)

# if on Windows system, build the windows executables
if (NOT ${CMAKE_HOST_SYSTEM_NAME} MATCHES "Windows")
    message(FATAL_ERROR "${CMAKE_HOST_SYSTEM_NAME} host system name does not match Windows - Please select the correct folder for configuring project")
endif()




set(CMAKE_CXX_FLAGS_RELEASE "${CMAKE_CXX_FLAGS_RELEASE} /MT")
set(CMAKE_CXX_FLAGS_DEBUG "${CMAKE_CXX_FLAGS_DEBUG} /MTd")
set(CMAKE_C_FLAGS_RELEASE "${CMAKE_C_FLAGS_RELEASE} /MT")
set(CMAKE_C_FLAGS_DEBUG "${CMAKE_C_FLAGS_DEBUG} /MTd")

if (CMAKE_BUILD_TYPE EQUAL Debug)
    set(CMAKE_C_FLAGS "${CMAKE_C_FLAGS} /MTd")
    set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} /MTd")
    set(MSVC_RUNTIME_LIBRARY_OPTION "MultiThreaded$<$<CONFIG:Debug>:Debug>")
endif (CMAKE_BUILD_TYPE EQUAL Debug)

if (CMAKE_BUILD_TYPE EQUAL Release)
    set(CMAKE_C_FLAGS "${CMAKE_C_FLAGS} /MT")
    set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} /MT")
    set(MSVC_RUNTIME_LIBRARY_OPTION "MultiThreaded$<$<CONFIG:Release>:Release>")
endif (CMAKE_BUILD_TYPE EQUAL Release)

print("CMAKE_BUILD_TYPE: ${CMAKE_BUILD_TYPE}")
set(CompilerFlags
        CMAKE_CXX_FLAGS
        CMAKE_CXX_FLAGS_DEBUG
        CMAKE_CXX_FLAGS_RELEASE
        CMAKE_C_FLAGS
        CMAKE_C_FLAGS_DEBUG
        CMAKE_C_FLAGS_RELEASE
)
foreach(CompilerFlag ${CompilerFlags})
    string(REPLACE "/MD" "/MT" ${CompilerFlag} "${${CompilerFlag}}")
endforeach()

# TODO: Check grpc install on Windows
# set(Protobuf_DIR  "${_THIRDPARTY_BUILD_DIR}/grpc/build/third_party/protobuf/cmake")
# set(Protobuf_INCLUDE_DIR "${_THIRDPARTY_BUILD_DIR}/grpc/build/third_party/protobuf/include/google/protobuf")

# build common libraries by platforms
include(../CommonCompilerOptions.CMake)

set(Protobuf_DIR "${_THIRDPARTY_BUILD_DIR}/grpc/cmake")
set(Protobuf_INCLUDE_DIR "${_THIRDPARTY_BUILD_DIR}/grpc/include/google/protobuf")

# Set Windows crypto and socket library
set(USER_ENV_LIBRARY userenv)
set(WIN_SOCK_LIBRARY wsock32 ws2_32)
set(WIN_CRYPT_LIBRARY crypt32)

# Allow multiple definitions
set(FORCE_MULTILE ON)
set(MULTIPLE_OPTION /FORCE:MULTIPLE)

# Set extra compiler flags
set(EXTRA_CXX_FLAGS)

# Set custom subfolder for ABI
set(ABI_SUBFOLDER_NAME "")

# Include common build paramaeters
include(../CommonBuildParameters.cmake)
