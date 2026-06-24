function(disable_clang_tidy target)
    set_target_properties(${target} PROPERTIES
        C_CLANG_TIDY ""
        CXX_CLANG_TIDY ""
    )
endfunction()

function(addtest test_name)
    add_executable(${test_name} ${ARGN})
    target_sources(${test_name} PUBLIC
        ${ARGN}
    )
    target_link_libraries(${test_name}
        GTest::gtest_main
    )
    file(MAKE_DIRECTORY ${CMAKE_BINARY_DIR}/xunit)
    set(xml_output "--gtest_output=xml:${CMAKE_BINARY_DIR}/xunit/xunit-${test_name}.xml")
    add_test(
        NAME ${test_name}
        COMMAND $<TARGET_FILE:${test_name}> ${xml_output}
    )
    set_target_properties(${test_name} PROPERTIES
        RUNTIME_OUTPUT_DIRECTORY ${CMAKE_BINARY_DIR}/test_bin
        ARCHIVE_OUTPUT_PATH ${CMAKE_BINARY_DIR}/test_lib
        LIBRARY_OUTPUT_PATH ${CMAKE_BINARY_DIR}/test_lib
    )
    disable_clang_tidy(${test_name})
endfunction()

function(addtest_mock test_name)
    add_executable(${test_name} ${ARGN})
    target_sources(${test_name} PUBLIC
        ${ARGN}
    )
    target_link_libraries(${test_name}
        GTest::gmock_main
    )
    file(MAKE_DIRECTORY ${CMAKE_BINARY_DIR}/xunit)
    set(xml_output "--gtest_output=xml:${CMAKE_BINARY_DIR}/xunit/xunit-${test_name}.xml")
    add_test(
        NAME ${test_name}
        COMMAND $<TARGET_FILE:${test_name}> ${xml_output}
    )
    set_target_properties(${test_name} PROPERTIES
        RUNTIME_OUTPUT_DIRECTORY ${CMAKE_BINARY_DIR}/test_bin
        ARCHIVE_OUTPUT_PATH ${CMAKE_BINARY_DIR}/test_lib
        LIBRARY_OUTPUT_PATH ${CMAKE_BINARY_DIR}/test_lib
    )
    disable_clang_tidy(${test_name})
endfunction()

function(compile_proto_to_cpp PB_H PB_CC PB_REL_PATH PROTO)
    get_target_property(Protobuf_INCLUDE_DIR protobuf::libprotobuf INTERFACE_INCLUDE_DIRECTORIES)
    get_target_property(Protobuf_PROTOC_EXECUTABLE protobuf::protoc IMPORTED_LOCATION)

    if(NOT Protobuf_PROTOC_EXECUTABLE)
        message(FATAL_ERROR "Protobuf_PROTOC_EXECUTABLE is empty")
    endif()
    if(NOT Protobuf_INCLUDE_DIR)
        message(FATAL_ERROR "Protobuf_INCLUDE_DIR is empty")
    endif()

    get_filename_component(PROTO_ABS "${PROTO}" REALPATH)

    # get relative (to CMAKE_BINARY_DIR) path of current proto file
    file(RELATIVE_PATH SCHEMA_REL "${CMAKE_BINARY_DIR}/src" "${CMAKE_CURRENT_BINARY_DIR}")
    set(SCHEMA_OUT_DIR ${CMAKE_BINARY_DIR}/generated)
    file(MAKE_DIRECTORY ${SCHEMA_OUT_DIR})

    string(REGEX REPLACE "\\.proto$" ".pb.h" GEN_PB_HEADER ${PROTO})
    string(REGEX REPLACE "\\.proto$" ".pb.cc" GEN_PB ${PROTO})

    set(GEN_COMMAND ${Protobuf_PROTOC_EXECUTABLE})
    set(GEN_ARGS ${Protobuf_INCLUDE_DIR})

  add_custom_command(
          OUTPUT ${SCHEMA_OUT_DIR}/${SCHEMA_REL}/${GEN_PB_HEADER} ${SCHEMA_OUT_DIR}/${SCHEMA_REL}/${GEN_PB}
          COMMAND ${GEN_COMMAND}
          ARGS -I${PROJECT_ROOT}/src -I${GEN_ARGS} --cpp_out=${SCHEMA_OUT_DIR} ${PROTO_ABS}
          WORKING_DIRECTORY ${CMAKE_BINARY_DIR}
          DEPENDS ${PROTO_ABS} protobuf::protoc
          VERBATIM
  )
    
    set(${PB_H} ${SCHEMA_OUT_DIR}/${SCHEMA_REL}/${GEN_PB_HEADER} PARENT_SCOPE)
    set(${PB_CC} ${SCHEMA_OUT_DIR}/${SCHEMA_REL}/${GEN_PB} PARENT_SCOPE)
    set(${PB_REL_PATH} ${SCHEMA_REL} PARENT_SCOPE)
endfunction()

if(NOT TARGET generated)
    add_custom_target(generated
        COMMENT "Building generated files..."
    )
endif()

function(add_proto_library NAME)
    set(SOURCES "")
    set(HEADERS "")
    set(PB_REL_PATH "")
    foreach(PROTO IN ITEMS ${ARGN})
        compile_proto_to_cpp(H C PB_REL_PATH ${PROTO})
        list(APPEND SOURCES ${H} ${C})
        list(APPEND HEADERS ${H})
    endforeach()

    add_library(${NAME}
        ${SOURCES}
    )
    target_link_libraries(${NAME}
        protobuf::libprotobuf
    )
    target_include_directories(${NAME} PUBLIC
        $<BUILD_INTERFACE:${CMAKE_BINARY_DIR}/generated/>
        $<INSTALL_INTERFACE:include>
    )
    foreach(H IN ITEMS ${HEADERS})
        set_target_properties(${NAME} PROPERTIES PUBLIC_HEADER "${H}")
    endforeach()

    install(TARGETS ${NAME} EXPORT ${PROJECT_ROOT_NAME}Targets
        PUBLIC_HEADER DESTINATION ${CMAKE_INSTALL_INCLUDEDIR}/${PB_REL_PATH}
    )

    disable_clang_tidy(${NAME})

    add_dependencies(generated ${NAME})
endfunction()

# conditionally applies flag.
function(add_flag flag)
    check_cxx_compiler_flag(${flag} FLAG_${flag})
    if(FLAG_${flag} EQUAL 1)
        add_compile_options(${flag})
    endif()
endfunction()

function(print)
    message(STATUS "[${CMAKE_PROJECT_NAME}] ${ARGV}")
endfunction()

function(install_hfile dir_name)
    install(
        DIRECTORY ${dir_name}
        DESTINATION ${CMAKE_INSTALL_PREFIX}/include
        FILES_MATCHING # install only matched files
        PATTERN "*.h*" # select header files hpp or h file
    )
endfunction()

function(get_default_root)
    get_filename_component(CURRENT_SOURCE_PARENT "${CMAKE_CURRENT_SOURCE_DIR}" DIRECTORY ABSOLUTE)
    get_filename_component(PROJECT_ROOT "${CURRENT_SOURCE_PARENT}" DIRECTORY ABSOLUTE)
    # Get the full path of the parent directory
    get_filename_component(PROJECT_ROOT_NAME ${PROJECT_ROOT} NAME)
    set(CURRENT_SOURCE_PARENT ${CURRENT_SOURCE_PARENT} PARENT_SCOPE)
    set(PROJECT_ROOT ${PROJECT_ROOT} PARENT_SCOPE)
    set(PROJECT_ROOT_NAME ${PROJECT_ROOT_NAME} PARENT_SCOPE)
    message("Default Project name is ${PROJECT_ROOT_NAME}")

endfunction()


function(TARGET_LINK_LIBRARIES_WHOLE_ARCHIVE target)
    if(MSVC)
        foreach(arg ${ARGN})
            target_link_options(${target} PRIVATE
                "LINKER:/WHOLEARCHIVE:$<TARGET_FILE:${arg}>"
            )
        endforeach()
    elseif(APPLE)
        foreach(arg ${ARGN})
            target_link_options(${target} PRIVATE
                "LINKER:-force_load,$<TARGET_FILE:${arg}>"
            )
        endforeach()
    else()
        target_link_libraries(${target}
            "-Wl,--whole-archive" ${ARGN} "-Wl,--no-whole-archive"
        )
    endif()
    target_link_libraries(${target} ${ARGN})
endfunction()

function(TARGET_LINK_LIBRARIES_WHOLE_ARCHIVE_PUB target)
    if(MSVC)
        foreach(arg ${ARGN})
            target_link_options(${target} PUBLIC
                "LINKER:/WHOLEARCHIVE:$<TARGET_FILE:${arg}>"
            )
        endforeach()
    elseif(APPLE)
        foreach(arg ${ARGN})
            target_link_options(${target} PUBLIC
                "LINKER:-force_load,$<TARGET_FILE:${arg}>"
            )
        endforeach()
    else()
        target_link_libraries(${target} PUBLIC
            "-Wl,--whole-archive" ${ARGN} "-Wl,--no-whole-archive"
        )
    endif()
    target_link_libraries(${target} PUBLIC ${ARGN})
endfunction()

# Finds the thirdparty subdirectory.  Walks up until it locates
#   <root>/../thirdparty  with the GeniusVentures/thirdparty git remote.
# If thirdparty is not on disk, falls back to the parent of the
# current git repository (repo-root/../) — enough to let the build
# proceed to the point where it can download thirdparty itself.
function(get_third_party_dir RESULT_VAR)
    find_package(Git REQUIRED)

    # ── Resolve the current git repo root (for fallback) ──────────
    execute_process(
        COMMAND "${GIT_EXECUTABLE}" rev-parse --show-toplevel
        WORKING_DIRECTORY "${CMAKE_CURRENT_LIST_DIR}"
        OUTPUT_VARIABLE _repo_root
        OUTPUT_STRIP_TRAILING_WHITESPACE
        RESULT_VARIABLE _repo_result
        ERROR_QUIET
    )
    if(_repo_result EQUAL 0 AND NOT "${_repo_root}" STREQUAL "")
        file(REAL_PATH "${_repo_root}/../" _fallback)
    else()
        file(REAL_PATH "${CMAKE_CURRENT_LIST_DIR}/../" _fallback)
    endif()

    # ── Walk up looking for the canonical thirdparty ──────────────
    cmake_path(SET _current "${CMAKE_CURRENT_LIST_DIR}" NORMALIZE)

    while(TRUE)
        cmake_path(SET _candidate "${_current}/../thirdparty" NORMALIZE)
        if(EXISTS "${_candidate}" AND IS_DIRECTORY "${_candidate}")
            execute_process(
                COMMAND "${GIT_EXECUTABLE}" -C "${_candidate}" remote get-url origin
                OUTPUT_VARIABLE _remote
                OUTPUT_STRIP_TRAILING_WHITESPACE
                RESULT_VARIABLE _result
                ERROR_QUIET
            )
            if(_result EQUAL 0 AND _remote MATCHES "GeniusVentures/thirdparty")
                set(${RESULT_VAR} "${_candidate}" PARENT_SCOPE)
                message(STATUS "Found thirdparty: ${_candidate}")
                return()
            endif()
        endif()

        cmake_path(SET _prev "${_current}")
        cmake_path(SET _current "${_current}/../" NORMALIZE)
        if("${_current}" STREQUAL "${_prev}")
            # Reached the filesystem root — can't go any higher.
            # On Unix the root normalises to "/"; on Windows repeated
            # "../" on e.g. "C:/" stays at "C:/", so we detect the
            # stall instead of looping forever.
            message(WARNING "Thirdparty directory not found (reached filesystem root), using fallback: ${_fallback}")
            set(${RESULT_VAR} "${_fallback}" PARENT_SCOPE)
            return()
        endif()
    endwhile()
endfunction()
