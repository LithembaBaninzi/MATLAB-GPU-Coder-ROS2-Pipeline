# MATLAB-GPU-Coder-ROS2-Pipeline
End-to-end deployment pipeline for MATLAB-generated CUDA code on NVIDIA Jetson Nano with ROS2 integration. This workflow enables the seamless deployment of MATLAB algorithms (via GPU Coder) to embedded ROS 2 systems, specifically designed for machine vision applications.

# Step-by-Step Tutorial: Deploying MATLAB-Generated ROS 2 Node with GPU Grayscale Processing on Jetson Nano
This guide documents the process of getting a MATLAB-generated ROS 2 node (grayCameraRos2) running on a Jetson Nano, including handling GPU libraries, camera input, and publishing to a ROS 2 topic. It also records common errors and fixes for easier duplication.\

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
       
       
### **Examples**
- **JavaScript**:
   ``` js
  function hello() {
    console.log("Hello, world!");
  }

  
- **Python**:
``` py
def greet():
    print("Hello!")   

