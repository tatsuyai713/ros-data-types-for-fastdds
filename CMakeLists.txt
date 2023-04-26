cmake_minimum_required(VERSION 3.1)

project(ros_data_types VERSION 1.0.0 LANGUAGES CXX)

include(${PROJECT_SOURCE_DIR}/cmake/dds_utils.cmake)

set(CMAKE_CXX_STANDARD 14)
set(CMAKE_CXX_STANDARD_REQUIRED ON)
set(CMAKE_CXX_EXTENSIONS OFF)
set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -Wno-error=deprecated-declarations -Wno-error=unused-result -Wnon-virtual-dtor -ggdb -MMD -MP -fPIC -fno-strict-aliasing -Wall -W -Wpointer-arith -D_GNU_SOURCE")

set(CMAKE_ARCHIVE_OUTPUT_DIRECTORY ${CMAKE_BINARY_DIR}/lib)
set(CMAKE_LIBRARY_OUTPUT_DIRECTORY ${CMAKE_BINARY_DIR}/lib)
set(CMAKE_RUNTIME_OUTPUT_DIRECTORY ${CMAKE_BINARY_DIR}/bin)

# include_directories("${CMAKE_SOURCE_DIR}/src/idl_generated"
# )

# link_directories("${CMAKE_CURRENT_SOURCE_DIR}/libraries"
# )

add_subdirectory(src)


# Create a config file of the library
# configure_package_config_file(
#     "cmake/Config.cmake.in"
#     "${project_config}"
#     INSTALL_DESTINATION "${CMAKE_INSTALL_PREFIX}/lib/cmake/${PROJECT_NAME}"
# )

# # Install target
# install(TARGETS RosDataTypes
#     EXPORT "${TARGETS_EXPORT_NAME}"
#     LIBRARY DESTINATION "${CMAKE_INSTALL_PREFIX}/lib"
#     ARCHIVE DESTINATION "${CMAKE_INSTALL_PREFIX}/lib"
#     RUNTIME DESTINATION "${CMAKE_INSTALL_PREFIX}/bin"
#     INCLUDES DESTINATION "${CMAKE_INSTALL_PREFIX}/include"
# )

# # Install config files
# install(
#     FILES "${project_config}" "${version_config}"
#     DESTINATION "${CMAKE_INSTALL_PREFIX}/lib/cmake/${PROJECT_NAME}"
# )

# install(
#     EXPORT "${TARGETS_EXPORT_NAME}"
#     NAMESPACE "${PROJECT_NAME}::"
#     DESTINATION "${CMAKE_INSTALL_PREFIX}/lib/cmake/${PROJECT_NAME}"
# )

