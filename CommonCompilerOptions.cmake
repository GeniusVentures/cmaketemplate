# BOOST VERSION TO USE
set(BOOST_MAJOR_VERSION "1" CACHE STRING "Boost Major Version")
set(BOOST_MINOR_VERSION "85" CACHE STRING "Boost Minor Version")
set(BOOST_PATCH_VERSION "0" CACHE STRING "Boost Patch Version")

# convenience settings
set(BOOST_VERSION "${BOOST_MAJOR_VERSION}.${BOOST_MINOR_VERSION}.${BOOST_PATCH_VERSION}")
set(BOOST_VERSION_3U "${BOOST_MAJOR_VERSION}_${BOOST_MINOR_VERSION}_${BOOST_PATCH_VERSION}")
set(BOOST_VERSION_2U "${BOOST_MAJOR_VERSION}_${BOOST_MINOR_VERSION}")

# --------------------------------------------------------
# Set config of GTest
set(BUILD_TESTING "ON" CACHE BOOL "Build tests")

add_definitions(-D_USE_INSTALLED_BOOST_JSON_=TRUE)

set(CMAKE_EXPORT_COMPILE_COMMANDS ON)

set(CMAKE_C_STANDARD 17)
set(CMAKE_C_EXTENSIONS OFF)

set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)
set(CMAKE_CXX_EXTENSIONS OFF)

if (DEFINED SANITIZE_CODE)
    message(STATUS "Building with sanitizer: ${SANITIZE_CODE}")
    if ("${CMAKE_CXX_COMPILER_ID}" MATCHES "Clang" OR "${CMAKE_CXX_COMPILER_ID}" MATCHES "GNU")
        set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -fsanitize=${SANITIZE_CODE}")
        set(CMAKE_C_FLAGS "${CMAKE_C_FLAGS} -fsanitize=${SANITIZE_CODE}")
        set(CMAKE_EXE_LINKER_FLAGS "${CMAKE_EXE_LINKER_FLAGS} -fsanitize=${SANITIZE_CODE}")
        set(CMAKE_SHARED_LINKER_FLAGS "${CMAKE_SHARED_LINKER_FLAGS} -fsanitize=${SANITIZE_CODE}")
        add_compile_options("-fsanitize=${SANITIZE_CODE}")
        add_link_options("-fsanitize=${SANITIZE_CODE}")
    elseif (MSVC)
        set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} /fsanitize=${SANITIZE_CODE}")
        set(CMAKE_C_FLAGS "${CMAKE_C_FLAGS} /fsanitize=${SANITIZE_CODE}")
        add_compile_options("/fsanitize=${SANITIZE_CODE}")
    endif()
endif()

include(GNUInstallDirs)

set(CPACK_PACKAGE_VENDOR "Genius Ventures" CACHE STRING "The Package Vendor default")
set(CMAKE_INSTALL_PREFIX ${CMAKE_CURRENT_BINARY_DIR}/${PROJECT_NAME})

# these default options can be overridden by the user, but we want them on by default since most of our projects have tests and examples
option(BUILD_TESTING "Build Tests" ON)
option(BUILD_EXAMPLES "Build Examples" ON)

include(GNUInstallDirs)
include(GenerateExportHeader)
include(CMakePackageConfigHelpers)
include(CheckCXXCompilerFlag)
include(ExternalProject)
include(${CMAKE_CURRENT_LIST_DIR}/cmake/functions.cmake)
include(${CMAKE_CURRENT_LIST_DIR}/cmake/install.cmake)
include(${CMAKE_CURRENT_LIST_DIR}/cmake/definition.cmake)
include(${CMAKE_CURRENT_LIST_DIR}/CompilationFlags.cmake)

if(EXISTS "${CMAKE_CURRENT_LIST_DIR}/cmake/compile_option_by_platform/${CMAKE_SYSTEM_NAME}.cmake")
    print("add compile option: ${CMAKE_CURRENT_LIST_DIR}/cmake/compile_option_by_platform/${CMAKE_SYSTEM_NAME}.cmake")
    include("${CMAKE_CURRENT_LIST_DIR}/cmake/compile_option_by_platform/${CMAKE_SYSTEM_NAME}.cmake")
endif()

set(CMAKE_BUILD_TYPE "Release" CACHE STRING "CMake's build type, needs to be defined even for generators that use configs")

if(EXISTS "${CMAKE_TOOLCHAIN_FILE}")
    print("Using toolchain file: ${CMAKE_TOOLCHAIN_FILE}")
endif()

get_super_root(PROJECT_SUPER_ROOT)
if (NOT DEFINED PROJECT_ROOT_NAME)
    # Get absolute path
    cmake_path(SET PROJECT_ROOT_NAME NORMALIZE "${CMAKE_CURRENT_LIST_DIR}/../..")
endif()

print("Project root is ${PROJECT_ROOT_NAME}")
print("Project super root is ${PROJECT_SUPER_ROOT}")

if(NOT DEFINED ZKLLVM_BUILD_DIR AND NOT ${PROJECT_ROOT_NAME} STREQUAL "zkLLVM")
    get_filename_component(BUILD_PLATFORM_NAME ${CMAKE_CURRENT_SOURCE_DIR} NAME)
    if(EXISTS "${PROJECT_SUPER_ROOT}/../zkLLVM/build/${BUILD_PLATFORM_NAME}/${CMAKE_BUILD_TYPE}${ABI_SUBFOLDER_NAME}")
        message(STATUS "Setting default zkLLVM directory to same as build type")

        set(ZKLLVM_BUILD_DIR "${PROJECT_SUPER_ROOT}/../zkLLVM/build/${BUILD_PLATFORM_NAME}/${CMAKE_BUILD_TYPE}${ABI_SUBFOLDER_NAME}" CACHE STRING "Default zkLLVM Library")

        # Get absolute path
        cmake_path(SET ZKLLVM_BUILD_DIR NORMALIZE "${ZKLLVM_BUILD_DIR}")
    elseif((NOT WIN32 OR "${CMAKE_BUILD_TYPE}" STREQUAL "Release") AND EXISTS "${PROJECT_SUPER_ROOT}/../zkLLVM/build/${BUILD_PLATFORM_NAME}/Release${ABI_SUBFOLDER_NAME}")
        message(STATUS "Setting default zkLLVM directory to release as a fallback")

        set(ZKLLVM_BUILD_DIR "${PROJECT_SUPER_ROOT}/../zkLLVM/build/${BUILD_PLATFORM_NAME}/Release${ABI_SUBFOLDER_NAME}" CACHE STRING "Default zkLLVM Library")

        # Get absolute path
        cmake_path(SET ZKLLVM_BUILD_DIR NORMALIZE "${ZKLLVM_BUILD_DIR}")
    else()
        message(STATUS "zkLLVM directory not found, fetching latest release...")

        # Define GitHub repository information
        set(GITHUB_REPO "GeniusVentures/zkLLVM")
        set(GITHUB_API_URL "https://api.github.com/repos/${GITHUB_REPO}/releases")

        # Define the target branch
        set(TARGET_BRANCH "develop")

        # Construct the release download URL
        if(ANDROID)
            set(ZKLLVM_ARCHIVE_NAME "${BUILD_PLATFORM_NAME}-${ANDROID_ABI}-Release.tar.gz")
            set(ZKLLVM_RELEASE_URL "https://github.com/${GITHUB_REPO}/releases/download/${BUILD_PLATFORM_NAME}-${ANDROID_ABI}-${TARGET_BRANCH}-Release/${ZKLLVM_ARCHIVE_NAME}")
        elseif(DEFINED ARCH AND NOT "${ARCH}" STREQUAL "")
            set(ZKLLVM_ARCHIVE_NAME "${BUILD_PLATFORM_NAME}-${ARCH}-Release.tar.gz")
            set(ZKLLVM_RELEASE_URL "https://github.com/${GITHUB_REPO}/releases/download/${BUILD_PLATFORM_NAME}-${ARCH}-${TARGET_BRANCH}-Release/${ZKLLVM_ARCHIVE_NAME}")
        else()
            set(ZKLLVM_ARCHIVE_NAME "${BUILD_PLATFORM_NAME}-Release.tar.gz")
            set(ZKLLVM_RELEASE_URL "https://github.com/${GITHUB_REPO}/releases/download/${BUILD_PLATFORM_NAME}-${TARGET_BRANCH}-Release/${ZKLLVM_ARCHIVE_NAME}")
        endif()

        set(ZKLLVM_ARCHIVE "${CMAKE_BINARY_DIR}/${ZKLLVM_ARCHIVE_NAME}")
        set(ZKLLVM_EXTRACT_DIR "${PROJECT_SUPER_ROOT}/../zkLLVM")

        # Download the latest release
        execute_process(
                COMMAND curl -L -o ${ZKLLVM_ARCHIVE} ${ZKLLVM_RELEASE_URL}
                RESULT_VARIABLE DOWNLOAD_RESULT
        )

        if(NOT DOWNLOAD_RESULT EQUAL 0)
            message(FATAL_ERROR "Failed to download zkLLVM archive from ${ZKLLVM_RELEASE_URL}")
        endif()

        file(MAKE_DIRECTORY ${ZKLLVM_EXTRACT_DIR})
        # Extract the archive to the correct location
        execute_process(
                COMMAND ${CMAKE_COMMAND} -E tar xzf ${ZKLLVM_ARCHIVE}
                WORKING_DIRECTORY ${PROJECT_SUPER_ROOT}/zkLLVM/
                RESULT_VARIABLE EXTRACT_RESULT
        )

        if(NOT EXTRACT_RESULT EQUAL 0)
            message(FATAL_ERROR "Failed to extract zkLLVM archive")
        endif()

        # Set extracted directory as ZKLLVM_BUILD_DIR
        set(ZKLLVM_BUILD_DIR "${ZKLLVM_EXTRACT_DIR}/build/${BUILD_PLATFORM_NAME}/Release${ABI_SUBFOLDER_NAME}" CACHE STRING "Downloaded zkLLVM Library")
        # Get absolute path
        cmake_path(SET ZKLLVM_BUILD_DIR NORMALIZE "${ZKLLVM_BUILD_DIR}")
        message(STATUS "zkLLVM downloaded and extracted to ${ZKLLVM_BUILD_DIR}")
    endif()
endif()

if(NOT DEFINED THIRDPARTY_BUILD_DIR)
    get_filename_component(BUILD_PLATFORM_NAME ${CMAKE_CURRENT_SOURCE_DIR} NAME)
    # define third party directory
    if(NOT DEFINED THIRDPARTY_DIR)
        if(EXISTS "${PROJECT_SUPER_ROOT}/../thirdparty/build/${BUILD_PLATFORM_NAME}/${CMAKE_BUILD_TYPE}${ABI_SUBFOLDER_NAME}")
            print("Found third party directory as super root")
            set(THIRDPARTY_DIR "${PROJECT_SUPER_ROOT}/../thirdparty" CACHE STRING "Default ThirdParty Library")
        else()
            message(STATUS "Cannot find thirdparty directory required to build, will attempt to obtain from releases")
            message(WARNING "${PROJECT_SUPER_ROOT}/../thirdparty/build/${BUILD_PLATFORM_NAME}/${CMAKE_BUILD_TYPE}${ABI_SUBFOLDER_NAME}")
            # Define GitHub repository information
            set(GITHUB_REPO "GeniusVentures/thirdparty")

            # Define the target branch
            set(TARGET_BRANCH "${BUILD_PLATFORM_NAME}-develop-${CMAKE_BUILD_TYPE}")
            if(ANDROID)
                set(TARGET_BRANCH "${BUILD_PLATFORM_NAME}-${ANDROID_ABI}-develop-${CMAKE_BUILD_TYPE}")
            elseif(CMAKE_SYSTEM_NAME STREQUAL "Linux" AND DEFINED ARCH)
                set(TARGET_BRANCH "${BUILD_PLATFORM_NAME}-${ARCH}-develop-${CMAKE_BUILD_TYPE}")
            endif()
            if(DEFINED GENIUS_DEPENDENCY_BRANCH)
                set(TARGET_BRANCH "${BUILD_PLATFORM_NAME}-develop-${CMAKE_BUILD_TYPE}")
                if(ANDROID)
                    set(TARGET_BRANCH "${BUILD_PLATFORM_NAME}-${ANDROID_ABI}-${GENIUS_DEPENDENCY_BRANCH}-${CMAKE_BUILD_TYPE}")
                elseif(CMAKE_SYSTEM_NAME STREQUAL "Linux" AND DEFINED ARCH)
                    set(TARGET_BRANCH "${BUILD_PLATFORM_NAME}-${ARCH}-${GENIUS_DEPENDENCY_BRANCH}-${CMAKE_BUILD_TYPE}")
                else()
                    set(TARGET_BRANCH "${BUILD_PLATFORM_NAME}-${GENIUS_DEPENDENCY_BRANCH}-${CMAKE_BUILD_TYPE}")
                endif()
            endif()

            set(GITHUB_BASE_URL "https://github.com/${GITHUB_REPO}/releases/download")
            if(DEFINED BRANCH_IS_TAG AND BRANCH_IS_TAG)
                set(TARGET_BRANCH ${GENIUS_DEPENDENCY_BRANCH})
            endif()
            # Construct the release download URL
            if(ANDROID)
                set(THIRDPARTY_ARCHIVE_NAME "${BUILD_PLATFORM_NAME}-${ANDROID_ABI}-${CMAKE_BUILD_TYPE}.tar.gz")
                set(THIRDPARTY_RELEASE_URL "${GITHUB_BASE_URL}/$TARGET_BRANCH}/${THIRDPARTY_ARCHIVE_NAME}")
            elseif(CMAKE_SYSTEM_NAME STREQUAL "Linux")
                set(THIRDPARTY_ARCHIVE_NAME "${BUILD_PLATFORM_NAME}-${ARCH}-${CMAKE_BUILD_TYPE}.tar.gz")
                set(THIRDPARTY_RELEASE_URL "${GITHUB_BASE_URL}/${TARGET_BRANCH}/${THIRDPARTY_ARCHIVE_NAME}")
            else()
                set(THIRDPARTY_ARCHIVE_NAME "${BUILD_PLATFORM_NAME}-${CMAKE_BUILD_TYPE}.tar.gz")
                set(THIRDPARTY_RELEASE_URL "${GITHUB_BASE_URL}/${TARGET_BRANCH}/${THIRDPARTY_ARCHIVE_NAME}")
            endif()
            set(THIRDPARTY_ARCHIVE "${CMAKE_BINARY_DIR}/thirdparty-${THIRDPARTY_ARCHIVE_NAME}")
            set(THIRDPARTY_EXTRACT_DIR "${PROJECT_SUPER_ROOT}/../thirdparty")
            # Download the latest release
            execute_process(
                COMMAND curl -L -o ${THIRDPARTY_ARCHIVE} ${THIRDPARTY_RELEASE_URL}
                RESULT_VARIABLE DOWNLOAD_RESULT
            )

            if(NOT DOWNLOAD_RESULT EQUAL 0)
                message(FATAL_ERROR "Failed to download thirdparty archive from ${THIRDPARTY_RELEASE_URL}")
            endif()

            file(MAKE_DIRECTORY ${THIRDPARTY_EXTRACT_DIR})
            # Extract the archive to the correct location
            execute_process(
                COMMAND ${CMAKE_COMMAND} -E tar xzf ${THIRDPARTY_ARCHIVE}
                WORKING_DIRECTORY ${THIRDPARTY_EXTRACT_DIR}
                RESULT_VARIABLE EXTRACT_RESULT
            )

            if(NOT EXTRACT_RESULT EQUAL 0)
                message(FATAL_ERROR "Failed to extract thirdparty archive")
            endif()
            set(THIRDPARTY_DIR "${THIRDPARTY_EXTRACT_DIR}" CACHE STRING "Default ThirdParty Library")
        endif()
    endif()
    print("Setting third party build directory default")
    get_filename_component(BUILD_PLATFORM_NAME ${CMAKE_CURRENT_SOURCE_DIR} NAME)
    set(THIRDPARTY_BUILD_DIR "${THIRDPARTY_DIR}/build/${BUILD_PLATFORM_NAME}/${CMAKE_BUILD_TYPE}${ABI_SUBFOLDER_NAME}" CACHE STRING "Default Third Party Build Directory")
endif()

set(_THIRDPARTY_BUILD_DIR "${THIRDPARTY_BUILD_DIR}" CACHE STRING "Local ThirdParty Build Directory")
print("THIRDPARTY BUILD DIR: ${_THIRDPARTY_BUILD_DIR}")

set(_THIRDPARTY_DIR "${THIRDPARTY_DIR}" CACHE STRING "Local ThirdParty Directory")
print("THIRDPARTY SRC DIR: ${_THIRDPARTY_DIR}")

if(${CMAKE_HOST_SYSTEM_NAME} MATCHES "Darwin")
    set(TP_HOST_BUILD_SUBDIR "OSX" CACHE STRING "ThirdParty Host directory")
else()
    set(TP_HOST_BUILD_SUBDIR ${CMAKE_HOST_SYSTEM_NAME} CACHE STRING "ThirdParty Host directory")
endif()

set(TESTING ON CACHE BOOL "Build Tests Flag")
set(BUILD_EXAMPLES ON CACHE BOOL "Build Examples Flag")

# zlib is here to appear before boost in the dependency graph, as some boost libraries depend on it. We need to build it first to be able to link it statically in boost and avoid issues with shared library loading on some platforms.
ExternalProject_Add(zlib
        PREFIX zlib
        SOURCE_DIR "${THIRDPARTY_DIR}/zlib"
        CMAKE_CACHE_ARGS
        ${_CMAKE_COMMON_CACHE_ARGS}
        -DCMAKE_INSTALL_PREFIX:PATH=<INSTALL_DIR>
        -DPLATFORM:STRING=${PLATFORM}
        -DZLIB_BUILD_TESTING:BOOL=OFF
        -DZLIB_BUILD_EXAMPLES:BOOL=OFF
        -DZLIB_BUILD_SHARED:BOOL=OFF
        -Dzlib_DIR:PATH=${zlib_DIR}
        -DZLIB_FIND_COMPONENTS:STRING=static
)
ExternalProject_Get_Property(zlib INSTALL_DIR)
set(zlib_DIR "${_THIRDPARTY_BUILD_DIR}/zlib/lib/cmake/zlib")
set(ZLIB_FIND_COMPONENTS "static")
