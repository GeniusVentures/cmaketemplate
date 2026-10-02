cmake_minimum_required(VERSION 3.22)

include(../cmake/functions.cmake)
get_default_root()

# Whole-archive linking style for cmake/functions.cmake (_whole_archive_link)
set(WHOLE_ARCHIVE_STYLE "FORCE_LOAD")
set(WHOLE_ARCHIVE_OPTION "LINKER:/WHOLEARCHIVE:")

if(NOT DEFINED PROJECT_NAME)
    set(PROJECT_NAME ${PROJECT_ROOT_NAME} CACHE STRING "Default Project Name")
endif()

project(${PROJECT_NAME} LANGUAGES C CXX)

# Platform defines must come after project(): set before it they never reach
# the compile commands (verified — 0/57 entries carried either define), so
# boost pragma-warned "Please define _WIN32_WINNT" on every Windows TU.
# 0x0601 = Windows 7, the same value boost assumes in that warning.
if(WIN32)
    add_definitions(-D_WIN32_WINNT=0x0601)
endif()
add_definitions(-DBOOST_BIND_GLOBAL_PLACEHOLDERS)

set(CMAKE_MSVC_RUNTIME_LIBRARY MultiThreaded$<$<CONFIG:Debug>:Debug>)

include(../CommonCompilerOptions.cmake)

set(USER_ENV_LIBRARY userenv)
set(WIN_SOCK_LIBRARY wsock32 ws2_32)
set(WIN_CRYPT_LIBRARY crypt32)

# where to add shared libraries for and executable package
set(APP_RUNTIME_LIB_DIR "bin")
set(APP_LINK_OPTIONS "")
set(APP_LINK_LIBRARIES "")
set(APP_RPATH_EXE "")
set(APP_RPATH_LIB "")

include(../CommonBuildParameters.cmake)
