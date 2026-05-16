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
    IF(WIN32)
        FOREACH(arg ${ARGN})
            target_link_libraries(${target} ${arg})
            SET_TARGET_PROPERTIES(
                ${target} PROPERTIES LINK_FLAGS "/WHOLEARCHIVE:${arg}"
            )
        ENDFOREACH()
    ELSE()
        IF(APPLE)
            SET(LINK_FLAGS "-Wl,-force_load")
            SET(UNDO_FLAGS "")
        ELSE()
            SET(LINK_FLAGS "-Wl,--whole-archive")
            SET(UNDO_FLAGS "-Wl,--no-whole-archive")
        ENDIF()
        target_link_libraries(${target} ${LINK_FLAGS} ${ARGN} ${UNDO_FLAGS})
    ENDIF()
endfunction()

function(TARGET_LINK_LIBRARIES_WHOLE_ARCHIVE_PUB target)
    IF(WIN32)
        FOREACH(arg ${ARGN})
            target_link_libraries(${target} PUBLIC ${arg})
            SET_TARGET_PROPERTIES(
                ${target} PROPERTIES LINK_FLAGS "/WHOLEARCHIVE:${arg}"
            )
        ENDFOREACH()
    ELSE()
        IF(APPLE)
            SET(LINK_FLAGS "-Wl,-force_load")
            SET(UNDO_FLAGS "")
        ELSE()
            SET(LINK_FLAGS "-Wl,--whole-archive")
            SET(UNDO_FLAGS "-Wl,--no-whole-archive")
        ENDIF()
        target_link_libraries(${target} PUBLIC ${LINK_FLAGS} ${ARGN} ${UNDO_FLAGS})
    ENDIF()
endfunction()

# Finds the super root directory of the current Git repository (works inside nested submodules)
# returns the top level project that has this as a submodule
# Simple function to get the immediate superproject root (when this is a git submodule)
function(get_super_root RESULT_VAR)
    find_package(Git QUIET)
    if(NOT GIT_FOUND)
        set(${RESULT_VAR} "${CMAKE_CURRENT_SOURCE_DIR}" PARENT_SCOPE)
        message(WARNING "Git not found, using current source dir")
        return()
    endif()

  # Find the nearest repo containing the current source directory
  execute_process(
          COMMAND "${GIT_EXECUTABLE}" rev-parse --show-toplevel
          WORKING_DIRECTORY "${CMAKE_CURRENT_SOURCE_DIR}"
          OUTPUT_VARIABLE current_root
          OUTPUT_STRIP_TRAILING_WHITESPACE
          RESULT_VARIABLE result
          ERROR_QUIET
  )

  if(NOT result EQUAL 0 OR "${current_root}" STREQUAL "")
    set(${RESULT_VAR} "${CMAKE_CURRENT_SOURCE_DIR}/../" PARENT_SCOPE)
    message(WARNING "Not inside a git repo, using current source dir ../")
    return()
  endif()

  file(REAL_PATH "${current_root}" current_root)

  while(TRUE)
    execute_process(
        COMMAND "${GIT_EXECUTABLE}" rev-parse --show-toplevel
        WORKING_DIRECTORY "${CMAKE_CURRENT_SOURCE_DIR}"
        OUTPUT_VARIABLE current_root
        OUTPUT_STRIP_TRAILING_WHITESPACE
        RESULT_VARIABLE result
        ERROR_QUIET
    )

    if(NOT result EQUAL 0 OR "${current_root}" STREQUAL "")
        set(${RESULT_VAR} "${CMAKE_CURRENT_SOURCE_DIR}" PARENT_SCOPE)
        message(WARNING "Not inside a git repo, using current source dir")
        return()
    endif()

    file(REAL_PATH "${current_root}" current_root)

    while(TRUE)
        execute_process(
            COMMAND "${GIT_EXECUTABLE}" rev-parse --show-superproject-working-tree
            WORKING_DIRECTORY "${current_root}"
            OUTPUT_VARIABLE super_root
            OUTPUT_STRIP_TRAILING_WHITESPACE
            RESULT_VARIABLE result
            ERROR_QUIET
        )

        if(NOT result EQUAL 0 OR "${super_root}" STREQUAL "")
            break()
        endif()

        file(REAL_PATH "${super_root}" current_root)
    endwhile()

    set(${RESULT_VAR} "${current_root}" PARENT_SCOPE)
    message(STATUS "Found top-level project root: ${current_root}")
endfunction()
