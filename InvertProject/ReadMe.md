# InvertProject 

**InvertProject** contains all MATLAB source files, build scripts, and generated CUDA/ROS 2 artifacts used to create and deploy the standalone **`invertCameraRos2`** node on an NVIDIA Jetson device.

This project extends the workflow from the earlier **GrayCameraRos2** example, replacing the grayscale CUDA processing library (`gpuGrayscale`) with a custom image inversion library (`gpuInvert`).

---
##  Folder Files
- **gpuInvert.m**
  - **Purpose:** Core image processing algorithm.
  - **Function:** GPU-accelerated function that inverts pixel values (255 - pixel) for RGB images. Converts input to single precision for CUDA arithmetic, performs inversion, converts back to uint8, and computes a checksum for verification.
    
- **buildGpuInvertLib.m**
  - **Purpose:** Generates the CUDA shared library (*`gpuInvert.so`*) from MATLAB GPU Coder.
  - **Function:** Configures GPU environment for Jetson, sets up code generation parameters for a DLL/shared library, and calls codegen to compile the *`gpuInvert.m`* function into an optimized CUDA library.

- **invertCameraEntry.m**
  - **Purpose:** Standalone camera processing entry point.
  - **Function:** Captures frames from Jetson camera using MATLAB Hardware Support, calls the external *`gpuInvert`* CUDA function for processing, and displays inverted images on Jetson display. Serves as a non-ROS2 test application.

- **buildingInvertCam.m**
  - **Purpose:** Builds and deploys a standalone executable (*`invertCameraEntry`*) to Jetson.
  - **Function:** Connects to Jetson hardware, configures GPU environment, links the pre-built *`gpuInvert.so`* library, and generates a standalone executable that captures camera frames and processes them using the CUDA library.
    
- **invertCameraRos2.m**
  - **Purpose:** Main ROS2 node function.
  - **Function:** Creates a ROS2 node and publisher, captures camera frames from Jetson, processes them using the *`gpuInvert`* CUDA library, packages inverted images into ROS2 Image messages, and publishes to *`/camera/image_inverted`* topic.

- **buildInvertCamRos2.m**
  - **Purpose:** Generates a ROS2 package (*`invertCameraRos2`*) for Jetson.
  - **Function:** Configures ROS2 hardware settings, specifies workspace paths, and links the *`gpuInvert.so`* CUDA library, and generates a ROS2 node that publishes inverted camera images to a ROS2 topic.

- **ros2InvSub.m**
  - **Purpose:** MATLAB-based ROS2 subscriber for visualization.
  - **Function:** Creates a ROS2 subscriber node on the host PC, receives inverted image messages from Jetson, converts ROS2 Image messages to MATLAB format, and displays them in a MATLAB figure window.

- **invertCameraRos2.tgz**
  - Generated zip file which is to be copied to your Jetson and unpacked there

