add_subdirectory(diagnostic_msgs)
add_subdirectory(gazebo_msgs)
add_subdirectory(geometry_msgs)
add_subdirectory(lifecycle_msgs)
add_subdirectory(nav_msgs)
add_subdirectory(sensor_msgs)
add_subdirectory(shape_msgs)
add_subdirectory(builtin_interfaces)
add_subdirectory(std_msgs)
add_subdirectory(stereo_msgs)
add_subdirectory(test_msgs)
add_subdirectory(tf2_msgs)
add_subdirectory(trajectory_msgs)
add_subdirectory(visualization_msgs)
add_subdirectory(rcl_interfaces)

install(FILES ${CMAKE_CURRENT_SOURCE_DIR}/../scripts/update_headers.sh DESTINATION bin/)
