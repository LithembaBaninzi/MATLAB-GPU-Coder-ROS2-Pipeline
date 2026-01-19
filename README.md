# MATLAB-GPU-Coder-ROS2-Pipeline
End-to-end deployment pipeline for MATLAB-generated CUDA code on NVIDIA Jetson Nano with ROS2 integration. This workflow enables the seamless deployment of MATLAB algorithms (via GPU Coder) to embedded ROS 2 systems, specifically designed for machine vision applications.

# Step-by-Step Tutorial: Deploying MATLAB-Generated ROS 2 Node with GPU Grayscale Processing on Jetson Nano
This guide documents the process of getting a MATLAB-generated ROS 2 node (grayCameraRos2) running on a Jetson Nano, including handling GPU libraries, camera input, and publishing to a ROS 2 topic. It also records common errors and fixes for easier duplication.

### 1. System Setup
Jetson Nano prerequisites
- Ubuntu 20.04 (or JetPack version compatible with CUDA 10.2)
- ROS 2 Humble installed
- CUDA 10.2 toolkit installed
- MATLAB R2024b with GPU Coder installed

Verify installed tools
- nvcc --version        # CUDA version
- ros2 --version        # ROS 2 version
- v4l2-ctl --list-devices  # Verify camera is detected

### 2. Shared library(.so) generation
- Save the files in **LibGen** in a project folder, e.g., MATLAB/Projects/gpuGrayscale/
- Run the compilation code, *buildGpuGrayLib.m*
- It should produce in both devices(Host PC + Jetson):
    * codegen/dll/gpuGrayscale/libgpuGrayscale.so
    * codegen/dll/gpuGrayscale/gpuGrayscale.so
    * codegen/dll/gpuGrayscale/gpuGrayscale.h
    * codegen/dll/gpuGrayscale/gpuGrayscale.cu
- **Note:** *you won't see libgpuGrayscale.so in your PC, but it should be available in the Jetson*
    * MATLAB Output:
      - Output file: C:\projectPath\codegen\dll\gpuGrayscale\gpuGrayscale.so

### 3. Test the Library in Jetson 
- To test if your shared library works without ROS2, you will need test scripts like the ones found in the LibTest folder
- You need to write MATLAB code that uses your shared library, like *grayCameraEntry.m* 
- And compile using a script similar to *buildingGrayCam.m*
- **NB:** On the *buildingGrayCam.m* compile script, you put the path to gpuGrayscale.so in your Host PC, **NOT** your Jetson path, this is because MATLAB will try to compile it locally before deploying it, so you get an error if you put the Linux path

### 4. Integrating CUDA and ROS2 in MATLAB
After you have successfully tested your library with CUDA alone, you can move to integrating it with ROS2. The integration involves several key modifications to your project structure, CMake configuration, and code organization.
1. Write your MATLAB scripts that combine ROS2 with CUDA and compile them as shown in ***buildJetsonGray.m*** in the grayCam folder
   - Build locally by setting the BuildAction to **None**:
     ``` matlab
     cfg.Hardware.BuildAction = 'None';
     ```
2. Copy the generated package to Jetson 
   - On your PC terminal (not MATLAB), run:
     ``` bash
     scp "C:\projectPath\grayCameraRos2.tgz" jetson@196.xx.xxx.xxx:~/
     ```
3. Unpack and build manually
   - On your Jetson terminal (or ssh to your Jetson), run the following:
   ``` bash
   mkdir -p ~/ros2_ws/src  # You can skip this if you already have src in your ros2 workspace folder
   cd ~/ros2_ws/src
   tar -xzf ~/grayCameraRos2.tgz
   ```
   - Your folder structure should now look like: <br>
     ros2_ws/src/graycameraros2/  <br>
        ├── src/<br>
        ├── include/<br>
        ├── package.xml<br>
        └── CMakeLists.txt<br>
4. Copy CUDA Library
   - Place the gpuGrayscale.so shared library in your ROS2 package folder:
     ``` bash
     ros2_ws/src/graycameraros2/lib/libgpuGrayscale.so # Might have to create lib if it doesn't exist 
     ```
5. Update CMakeLists.txt<br>
   Modify your CMakeLists.txt file to include the CUDA library and ROS 2 dependencies. Key changes:
   - Add gstreamer-app with the GST package
   ``` c
   find_package(PkgConfig REQUIRED)
   pkg_check_modules(GSTREAMER_APP_1_0GSTREAMER_VIDEO_1_0 REQUIRED gstreamer-app-1.0 gstreamer-video-1.0) # Find this line 
   pkg_check_modules(GST REQUIRED gstreamer-app-1.0 gstreamer-video-1.0)   # Add this new line below this line above ^^^
   ```
   - Remove MATLAB's custom library path (Comment out these lines)
   ``` c
   # add_library(coder_custom_lib_1 UNKNOWN IMPORTED)
   # set_property(TARGET coder_custom_lib_1 PROPERTY IMPORTED_LOCATION "${PROJECT_SOURCE_DIR}/src/gpuGrayscale.so")
   ```
   - Replace the bad compile options block ***target_compile_options(grayCameraRos2 PRIVATE ...)*** with this clean version:
   ``` c
   target_compile_options(grayCameraRos2 PRIVATE
   $<$<OR:$<COMPILE_LANGUAGE:CXX>,$<COMPILE_LANGUAGE:C>>:
   ${GST_CFLAGS_OTHER}
   -D_MW_MATLABTGT_
   -D_CAMERA_DEP_
   -D__MW_TARGET_USE_HARDWARE_RESOURCES_H__
   -DROS2_PROJECT
   -DSTACK_SIZE=200000
   -DMODEL=grayCameraRos2
   >
   )
   ```
   - Add this after **ament_target_dependencies(...)** before **target_link_directories(...)**:
   ``` c
   include_directories(${GST_INCLUDE_DIRS})
   include_directories(${SDL_INCLUDE_DIR})
   # CUDA + CUSTOM LIBRARIES
   link_directories(/usr/local/cuda-10.2/targets/aarch64-linux/lib ${CMAKE_CURRENT_SOURCE_DIR}/lib) #path to CUDA libs + path to custom lib
   link_directories(${GST_LIBRARY_DIRS})
   ```
 6. Build and run
    ``` bash
    cd ~/ros2_ws
    colcon build --packages-select graycameraros2 --event-handlers console_direct+
    source install/setup.bash
    ros2 run graycameraros2 grayCameraRos2
    ```
    After a successful build and install an executable ***grayCameraRos2*** will be installed under:<br>
    /home/jetson/ros2_ws/install/graycameraros2/lib/graycameraros2
 7. To verify 
## Common Errors and Fixes 
1. If you are trying to run an executable on the Jetson and you get this error:
   ```c
   Camera = 0 in 657
   Error generated. /dvs/git/dirty/git-master_linux/multimedia/nvgstreamer/gst-nvarguscamera/gstnvarguscamerasrc.cpp, execute:736 Failed to create CaptureSession
   Error: Getting samples from the pipeline
   ```
   This is a Jetson/NVARGUS camera error, meaning the nvarguscamerasrc GStreamer plugin cannot initialize the camera capture session.<br>
**FIX**<br>
  Restart the Argus daemon:
    ```markdown
    sudo systemctl restart nvargus-daemon
    ```
    If it still gives you an error, kill any leftover GStreamer or ROS2 processes:
     ```linux
    sudo pkill -9 gst-launch-1.0
    sudo pkill -9 grayCameraRos2
    sudo pkill -9 graycameraros2
    ```
2. If you are running a ROS 2 node and you see the following output at the end, it means your node is destroying publishers while FastDDS(ROS 2's default RMW) is still trying to handle messages:
   ```c
   cannot publish data, at .../src/rmw_publish.cpp:62 during '__function__'
   [ERROR] [jetson_cuda_camera_node.rclcpp]: Error in destruction of rcl subscription handle:
   Failed to delete datareader, at ... subscription.c:184
   [ros2run]: segmentation fault
   ```
   **FIX**<br>
     Edit the main.cpp file add "*gNodePtr.reset()*" before "*rcl::shutdown()*"
     ```c
       threadTerminating = true; 
       gNodePtr.reset();    //Put this line before ...
       rcl::shutdown();     //ths line
     ```

