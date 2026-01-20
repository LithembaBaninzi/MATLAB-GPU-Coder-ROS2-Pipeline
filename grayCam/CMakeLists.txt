cmake_minimum_required(VERSION 3.5)
project(graycameraros2)
set(CMAKE_VERBOSE_MAKEFILE ON)
# Set CMAKE_BUILD_TYPE
set(CMAKE_BUILD_TYPE Release)
# Default to C99
if(NOT CMAKE_C_STANDARD)
  set(CMAKE_C_STANDARD 99)
endif()
# Default to C++17
if(NOT CMAKE_CXX_STANDARD)
  set(CMAKE_CXX_STANDARD 17)
endif()
if(ALIAS_ROS2_TF2)
  add_definitions(-Dtf2=ros2_tf2)
  add_definitions(-Dtf2_ros=ros2_tf2_ros)
  add_definitions(-Dmessage_filters=ros2_message_filters)
endif()
find_package(PkgConfig REQUIRED)
pkg_check_modules(GSTREAMER_APP_1_0GSTREAMER_VIDEO_1_0 REQUIRED gstreamer-app-1.0 gstreamer-video-1.0)
# find dependencies
find_package(ament_cmake REQUIRED)
find_package(ament_cmake_ros REQUIRED)
find_package( builtin_interfaces REQUIRED)
find_package( rclcpp REQUIRED)
find_package( sensor_msgs REQUIRED)
find_package( std_msgs REQUIRED)
include_directories("${GSTREAMER_APP_1_0GSTREAMER_VIDEO_1_0_INCLUDE_DIRS}")
include_directories("include/graycameraros2/C/ProgramData/MATLAB/SupportPackages/R2024b/toolbox/realtime/targets/linux/include")
include_directories("include/graycameraros2/C/ProgramData/MATLAB/SupportPackages/R2024b/toolbox/target/supportpackages/nvidia/sources/server")
include_directories("include/graycameraros2/C/Users/lithe/OneDrive/BNNLIT002/Documents/MATLAB/2025_Dec_Vac_Work/project3/codegen/dll/gpuGrayscale")
include_directories("include/graycameraros2")
set (CMAKE_SKIP_BUILD_RPATH false)
set (CMAKE_BUILD_WITH_INSTALL_RPATH true)
set (CMAKE_INSTALL_RPATH "${CMAKE_INSTALL_PREFIX}/lib")
set (CMAKE_INSTALL_RPATH_USE_LINK_PATH TRUE)
add_library(coder_custom_lib_1 UNKNOWN IMPORTED)
set_property(TARGET coder_custom_lib_1 PROPERTY IMPORTED_LOCATION "${PROJECT_SOURCE_DIR}/src/gpuGrayscale.so")
link_directories("${GSTREAMER_APP_1_0GSTREAMER_VIDEO_1_0_LIBRARY_DIRS}")
# Node
add_executable(grayCameraRos2 
src/MW_SDL_video_display.c
src/frameReader.c
src/getCameraProps.c
src/builtin_interfaces_TimeStruct.cpp
src/camera.cpp
src/coder_posix_time.c
src/grayCameraRos2.cpp
src/grayCameraRos2_data.cpp
src/grayCameraRos2_initialize.cpp
src/grayCameraRos2_terminate.cpp
src/imageDisplay.cpp
src/main.cpp
src/pause.cpp
src/ros2_structmsg_conversion.cpp
src/ros2publisher.cpp
src/sensor_msgs_ImageStruct.cpp
src/std_msgs_HeaderStruct.cpp
)
if(CMAKE_COMPILER_IS_GNUCXX OR CMAKE_CXX_COMPILER_ID MATCHES "Clang")
target_compile_options(grayCameraRos2 PUBLIC 
  $<$<OR:$<COMPILE_LANGUAGE:CXX>,$<COMPILE_LANGUAGE:C>>:
  -Wall -Wextra -Wpedantic
  >)
endif()
target_compile_options(grayCameraRos2 PRIVATE
  $<$<OR:$<COMPILE_LANGUAGE:CXX>,$<COMPILE_LANGUAGE:C>>:
  ${GSTREAMER_APP_1_0GSTREAMER_VIDEO_1_0_CFLAGS} -D_MW_MATLABTGT_
  -D_CAMERA_DEP_
  -D__MW_TARGET_USE_HARDWARE_RESOURCES_H__
  -DROS2_PROJECT
  -DSTACK_SIZE=200000
  -DMODEL=grayCameraRos2
  $(XCOMPILERFLAG) `pkg-config --cflags gstreamer-app-1.0 gstreamer-video-1.0`  >
  )
ament_target_dependencies(
  grayCameraRos2
  "builtin_interfaces"
  "rclcpp"
  "sensor_msgs"
  "std_msgs"
)
target_include_directories(grayCameraRos2 PUBLIC
  $<BUILD_INTERFACE:${CMAKE_CURRENT_SOURCE_DIR}/include>
  $<INSTALL_INTERFACE:include>)
target_link_libraries(grayCameraRos2 
	${GSTREAMER_APP_1_0GSTREAMER_VIDEO_1_0_LIBRARIES}
    coder_custom_lib_1
    SDL cublas cufft curand cusolver cusparse
	${CMAKE_DL_LIBS}
    )
install(TARGETS grayCameraRos2
  EXPORT export_${PROJECT_NAME}
  DESTINATION lib/${PROJECT_NAME})
ament_export_include_directories(
  include
)
foreach(file_i ${CUDA_BINS})
add_custom_command(
                   TARGET grayCameraRos2
                   POST_BUILD
                   COMMAND ${CMAKE_COMMAND}
                   ARGS -E copy ${PROJECT_SOURCE_DIR}/src/${file_i} ${CMAKE_INSTALL_PREFIX}/grayCameraRos2_ert_rtw/${file_i}
				   )
add_custom_command(
                   TARGET grayCameraRos2
                   POST_BUILD
                   COMMAND ${CMAKE_COMMAND}
                   ARGS -E copy ${PROJECT_SOURCE_DIR}/src/${file_i} ${CMAKE_INSTALL_PREFIX}/codegen/exe/grayCameraRos2/${file_i}
				   )				   
endforeach(file_i)
ament_package()
# Generated on Wed Jan 14 09:58:34 2026
