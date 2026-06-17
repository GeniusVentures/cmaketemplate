cmake_minimum_required(VERSION 3.22)

include(../cmake/functions.cmake)
get_default_root()

if(NOT DEFINED PROJECT_NAME)
    set(PROJECT_NAME ${PROJECT_ROOT_NAME} CACHE STRING "Default Project Name")
endif()

project(${PROJECT_NAME} LANGUAGES C CXX)

set(CMAKE_MSVC_RUNTIME_LIBRARY MultiThreaded$<$<CONFIG:Debug>:Debug>)

include(../CommonCompilerOptions.cmake)

set(USER_ENV_LIBRARY userenv)
set(WIN_SOCK_LIBRARY wsock32 ws2_32)
set(WIN_CRYPT_LIBRARY crypt32)

include(../CommonBuildParameters.cmake)
