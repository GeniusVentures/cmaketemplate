cmake_minimum_required(VERSION 3.22)

include(../cmake/functions.cmake)
get_default_root()

# Whole-archive linking style for cmake/functions.cmake (_whole_archive_link)
set(WHOLE_ARCHIVE_STYLE "FORCE_LOAD")
set(WHOLE_ARCHIVE_OPTION "LINKER:-force_load,")

set(PROJECT_NAME ${PROJECT_ROOT_NAME} CACHE STRING "Project Name")

# Set OSX specific runtime options
if(NOT DEFINED CMAKE_TOOLCHAIN_FILE)
    set(_PLATFORM "MAC_UNIVERSAL" CACHE STRING "Setting the build for both x86_64 and arm64")

    set(NAMED_LANGUAGE_SUPPORT ON CACHE BOOL "Toolchain named language support parameter")
    set(ENABLE_BITCODE OFF CACHE BOOL "Toolchain bitcode enable parameter")
    set(ENABLE_ARC OFF CACHE BOOL "Toolchain enable arc parameter")
    set(ENABLE_VISIBILITY ON CACHE BOOL "Toolchain visibility parameter")
    set(ENABLE_STRICT_TRY_COMPILE OFF CACHE BOOL "Toolchain try_compile enable parameter")
    set(PLATFORM ${_PLATFORM} CACHE STRING "Toolchain platform parameter")
    set(DEPLOYMENT_TARGET "13.0" CACHE STRING "Minimum OSX version")
    set(CMAKE_TOOLCHAIN_FILE "${CMAKE_CURRENT_SOURCE_DIR}/../apple.toolchain.cmake" CACHE STRING "Toolchain file")
endif()

set(CMAKE_MACOSX_RPATH 1 CACHE BOOL
    "include rpath in shared library")

project(${PROJECT_NAME} LANGUAGES C CXX)

include(../CommonCompilerOptions.cmake)

set(EXTRA_CXX_FLAGS "" CACHE STRING "")

# where to get vulkan from
set(Vulkan_INCLUDE_DIR "${THIRDPARTY_BUILD_DIR}/moltenvk/build/include")
set(Vulkan_LIBRARY "${THIRDPARTY_BUILD_DIR}/moltenvk/build/lib/MoltenVK.xcframework")
# where to put supporting shared libraries
set(APP_RUNTIME_LIB_DIR "lib")
set(APP_LINK_OPTIONS "LINKER:-no_warn_duplicate_libraries")
set(APP_LINK_LIBRARIES "")
set(APP_RPATH_EXE "@executable_path/../${APP_RUNTIME_LIB_DIR}")
set(APP_RPATH_LIB "@loader_path")

# Include common build parameters
include(../CommonBuildParameters.cmake)
