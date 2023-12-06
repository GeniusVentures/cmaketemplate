

# Package config ######################################################################################
set(CPACK_PACKAGE_VERSION_MAJOR "21" CACHE STRING "Package config major")
set(CPACK_PACKAGE_VERSION_MINOR "0" CACHE STRING "Package config minor")
set(CPACK_PACKAGE_VERSION_PATCH "0" CACHE STRING "Package config patch")
set(CPACK_PACKAGE_VERSION_PRE_RELEASE "12" CACHE STRING "Package config pre-release")
set(CPACK_PACKAGE_VENDOR "Genius Ventures" CACHE STRING "The Package Vendor default")

set(CMAKE_INSTALL_PREFIX ${CMAKE_CURRENT_BINARY_DIR}/${PROJECT_NAME} CACHE STRING "prefix of directory to install to")

set(CMAKE_POSITION_INDEPENDENT_CODE ON CACHE BOOL
 "")

include(GNUInstallDirs)
include(GenerateExportHeader)
include(CMakePackageConfigHelpers)
include(CheckCXXCompilerFlag)
include(${CMAKE_CURRENT_LIST_DIR}/cmake/functions.cmake)
include(${CMAKE_CURRENT_LIST_DIR}/cmake/install.cmake)
include(${CMAKE_CURRENT_LIST_DIR}/cmake/definition.cmake)
include(${CMAKE_CURRENT_LIST_DIR}/CompilationFlags.cmake)

check_cxx_compiler_flag(-std=c++14 CXX14_SUPPORT)
check_cxx_compiler_flag(-std=c++17 CXX17_SUPPORT)

if(EXISTS "${CMAKE_CURRENT_LIST_DIR}/cmake/compile_option_by_platform/${CMAKE_SYSTEM_NAME}.cmake")
  print("add compile option: ${CMAKE_CURRENT_LIST_DIR}/cmake/compile_option_by_platform/${CMAKE_SYSTEM_NAME}.cmake")
  include("${CMAKE_CURRENT_LIST_DIR}/cmake/compile_option_by_platform/${CMAKE_SYSTEM_NAME}.cmake")
endif()

set(CMAKE_BUILD_TYPE "Release" CACHE STRING "The default build type")
set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} ${EXTRA_CXX_FLAGS}" CACHE STRING "default CXX_Flags")

if (NOT EXISTS "${CMAKE_TOOLCHAIN_FILE}")
  # https://cgold.readthedocs.io/en/latest/tutorials/toolchain/globals/cxx-standard.html#summary
  print("CMAKE_TOOLCHAIN_FILE not found, setting CMAKE_POSITION_INDEPENDENT_CODE ON")
  set(CMAKE_POSITION_INDEPENDENT_CODE TRUE CACHE BOOL "Position Independent Code")
else()
  print("Using toolchain file: ${CMAKE_TOOLCHAIN_FILE}")
endif ()

# --------------------------------------------------------
# define third party directory
if (NOT DEFINED THIRDPARTY_DIR)
  if(EXISTS "${CMAKE_CURRENT_LIST_DIR}/../../thirdparty/README.md")
    print("Setting default third party directory")
    set(THIRDPARTY_DIR "${CMAKE_CURRENT_LIST_DIR}/../../thirdparty" CACHE STRING "Default ThirdParty Library")
    ## get absolute path
    cmake_path(SET THIRDPARTY_DIR NORMALIZE "${THIRDPARTY_DIR}")
  else()
    message( FATAL_ERROR "Cannot find thirdparty directory required to build" )
  endif()
endif()

if (NOT DEFINED THIRDPARTY_BUILD_DIR)
  print("Setting third party build directory default")
  get_filename_component(BUILD_PLATFORM_NAME ${CMAKE_CURRENT_SOURCE_DIR} NAME)
  set(THIRDPARTY_BUILD_DIR "${THIRDPARTY_DIR}/build/${BUILD_PLATFORM_NAME}/${CMAKE_BUILD_TYPE}" CACHE STRING "Default Third Party Build Directory")
endif()

set(_THIRDPARTY_BUILD_DIR "${THIRDPARTY_BUILD_DIR}" CACHE STRING "Local ThirdParty Build Directory")
print("THIRDPARTY BUILD DIR: ${_THIRDPARTY_BUILD_DIR}")

set(_THIRDPARTY_DIR "${THIRDPARTY_DIR}" CACHE STRING "Local ThirdParty Directory")
print("THIRDPARTY SRC DIR: ${_THIRDPARTY_DIR}")

if (${CMAKE_HOST_SYSTEM_NAME} MATCHES "Darwin")
  set(TP_HOST_BUILD_SUBDIR "OSX" CACHE STRING "ThirdParty Host directory")
else()
  set(TP_HOST_BUILD_SUBDIR ${CMAKE_HOST_SYSTEM_NAME} CACHE STRING "ThirdParty Host directory")
endif()

set(TESTING ON CACHE BOOL "Build Tests Flag")
set(BUILD_EXAMPLES ON CACHE BOOL "Build Examples Flag")

