cmake_minimum_required(VERSION 3.22)

include(../cmake/functions.cmake)
get_default_root()

if(NOT DEFINED PROJECT_NAME)
    set(PROJECT_NAME ${PROJECT_ROOT_NAME} CACHE STRING "Default Project Name")
endif()

project(${PROJECT_NAME} LANGUAGES C CXX)

# Speedup build
if(CMAKE_GENERATOR MATCHES "Visual Studio")
    if(NOT CMAKE_VS_GLOBALS MATCHES "(^|;)UseMultiToolTask=")
        list(APPEND CMAKE_VS_GLOBALS UseMultiToolTask=true)
    endif()

    if(NOT CMAKE_VS_GLOBALS MATCHES "(^|;)EnforceProcessCountAcrossBuilds=")
        list(APPEND CMAKE_VS_GLOBALS EnforceProcessCountAcrossBuilds=true)
    endif()
endif()

set(CMAKE_MSVC_RUNTIME_LIBRARY MultiThreaded$<$<CONFIG:Debug>:Debug>)

# This is so that the SDK knows which version of Windows to target.
# Current set to Windows 10
add_compile_definitions(_WIN32_WINNT=0x0A00)

include(../CommonCompilerOptions.cmake)

set(Protobuf_DIR "${_THIRDPARTY_BUILD_DIR}/grpc/cmake")
set(Protobuf_INCLUDE_DIR "${_THIRDPARTY_BUILD_DIR}/grpc/include/google/protobuf")

set(USER_ENV_LIBRARY userenv)
set(WIN_SOCK_LIBRARY wsock32 ws2_32)
set(WIN_CRYPT_LIBRARY crypt32)

include(../CommonBuildParameters.cmake)
