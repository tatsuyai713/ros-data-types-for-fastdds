cmake_minimum_required(VERSION 3.1)

project(unique_identifier_msgs VERSION 1.0.0 LANGUAGES CXX)

include(${PROJECT_SOURCE_DIR}/../../cmake/dds_utils.cmake)

set(CMAKE_CXX_STANDARD 14)
set(CMAKE_CXX_STANDARD_REQUIRED ON)
set(CMAKE_CXX_EXTENSIONS OFF)
set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -Wno-error=deprecated-declarations -Wno-error=unused-result -Wnon-virtual-dtor -ggdb -MMD -MP -fPIC -fno-strict-aliasing -Wall -W -Wpointer-arith -D_GNU_SOURCE")

set(CMAKE_ARCHIVE_OUTPUT_DIRECTORY ${CMAKE_BINARY_DIR}/lib)
set(CMAKE_LIBRARY_OUTPUT_DIRECTORY ${CMAKE_BINARY_DIR}/lib)
set(CMAKE_RUNTIME_OUTPUT_DIRECTORY ${CMAKE_BINARY_DIR}/bin)

file(GLOB_RECURSE Original_IDL_Files
  "${CMAKE_CURRENT_SOURCE_DIR}/*/*.idl"
)

COMPILE_IDL_FILES(${Original_IDL_Files})
file(GLOB_RECURSE in1_files
  "${CMAKE_CURRENT_BINARY_DIR}/*.cxx"
  "${CMAKE_CURRENT_BINARY_DIR}/*.hpp"
)

add_custom_command(
    OUTPUT update_headers_done
    COMMAND ${CMAKE_COMMAND} -E echo "Running update_headers.sh"
    COMMAND ${CMAKE_COMMAND} -E env bash ${PROJECT_SOURCE_DIR}/../../scripts/update_headers.sh
    WORKING_DIRECTORY ${CMAKE_CURRENT_BINARY_DIR}
    COMMENT "Updating header files"
    VERBATIM
)

add_custom_target(unique_identifier_msgs_CompileIDLFiles ALL
    DEPENDS ${ALL_IDL_SRCS} update_headers_done)
add_definitions(${DDS_DEFINITIONS})
add_library(unique_identifier_msgs SHARED
    ${in1_files}
)
add_dependencies(unique_identifier_msgs unique_identifier_msgs_CompileIDLFiles)

include_directories("${CMAKE_CURRENT_BINARY_DIR}"
  "${CMAKE_CURRENT_BINARY_DIR}/../builtin_interfaces"
  "${CMAKE_CURRENT_BINARY_DIR}/../unique_identifier_msgs"
  ${PROJECT_BINARY_DIR}
)

if(DEFINED USE_FASTDDS3)
    target_link_libraries(unique_identifier_msgs LINK_PUBLIC -Wl,--allow-multiple-definition fastdds)
else()
    target_link_libraries(unique_identifier_msgs LINK_PUBLIC -Wl,--allow-multiple-definition fastrtps)
endif()

target_include_directories(unique_identifier_msgs PUBLIC
  $<BUILD_INTERFACE:${CMAKE_CURRENT_BINARY_DIR}>
  $<INSTALL_INTERFACE:include>
)

install(TARGETS unique_identifier_msgs
  ARCHIVE DESTINATION lib
  LIBRARY DESTINATION lib
  RUNTIME DESTINATION bin
)

install(DIRECTORY ${CMAKE_CURRENT_BINARY_DIR}/unique_identifier_msgs DESTINATION include/)
