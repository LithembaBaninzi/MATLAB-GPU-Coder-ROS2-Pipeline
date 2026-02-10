# Jetson Camera Live Stream App

## Real-Time Visual Pose Estimation System

A comprehensive MATLAB-based system for real-time camera pose estimation on NVIDIA Jetson platforms using ROS2 communication. This application provides live 3D visualization of camera pose estimates computed using the P3P (Perspective-3-Point) algorithm with CUDA acceleration.


---
<img width="1302" height="627" alt="UI screenshort " src="https://github.com/user-attachments/assets/58d55eb5-6a1c-4bd8-88c0-0b85d559142b" />

---

## 🎯 Overview

This system enables real-time camera pose estimation by combining:
- **NVIDIA Jetson** hardware for edge computing with CUDA acceleration
- **MATLAB** for algorithm development and visualization
- **ROS2** for robust inter-process communication
- **P3P Algorithm** for efficient pose estimation from visual markers

The system consists of two main components:
1. **Jetson Side**: Captures camera frames and computes pose estimates
2. **Desktop Side**: Displays live pose data and provides a control interface

---

## ✨ Features

### Visual Pose Estimation
- Real-time P3P pose estimation at ~30 Hz
- CUDA-accelerated processing on Jetson GPU
- 7-DOF output: Position (X, Y, Z) + Orientation (Quaternion)
- Automatic conversion to Euler angles (Yaw, Pitch, Roll)

### User Interface
- **Live Camera Feed**: Real-time video stream from Jetson camera
- **Pose Display Panel**: 
  - Position in meters (X, Y, Z coordinates)
  - Orientation as quaternion (w, x, y, z)
  - Euler angles in degrees (Yaw, Pitch, Roll)
- **3D Visualization**: 
  - Interactive 3D plot showing camera trajectory
  - Coordinate frame visualization
  - Multiple pose history display
- **Control Buttons**:
  - 🟢 **START**: Begin pose estimation
  - 🔵 **STOP**: Pause pose estimation (keeps system running)
  - 🔴 **SHUTDOWN**: Clean system shutdown
- **Status Indicators**:
  - Live Preview Lamp (Red/Amber/Green)
  - FPS counter
  - Connection status messages

### Communication
- ROS2-based publish/subscribe architecture
- Bi-directional communication (commands and data)
- Real-time status updates
- Graceful shutdown handling

---

## 🎮 Quick Start

### Starting the System

#### 1. On Jetson (SSH or local terminal):

```bash
cd ~/ros2_ws
source install/setup.bash
ros2 run visstateest3 visStateEst3
```

**Expected Output:**
```
ROS2 initialized. Waiting for START command...
Subscriber created for topic: /jetson/camera/command
[STATUS] Ready. Waiting for START command.
[IDLE] Waiting for START command... 
```

#### 2. On Desktop (MATLAB):

```matlab
% Open and run the app
>> Jetson_Live_Updated
```

Or double-click `Jetson_Live_Updated.mlapp` to launch.

#### 3. Start Pose Estimation:

In the MATLAB App:
1. Click **START** button (turns green)
2. Watch the pose fields populate with real-time data
3. Observe 3D visualization update

**Jetson Output After START:**
```
>>> NEW COMMAND RECEIVED: "start" <<<
==> STARTING pose estimation...
Processing frame 30...
Processing frame 60...
Frame 50: Valid pose [0.242, -0.157, 0.957]
```

#### 4. Control the System:

- **STOP**: Pause pose estimation (camera stops, program keeps running)
- **START** (again): Resume pose estimation
- **SHUTDOWN**: Clean exit of the Jetson program

---

# 🖥️ User Interface Guide

### Main Window Components

#### Left Panel: Pose Information Display

**Position (meters)**
- **X**: Forward/backward position relative to markers
- **Y**: Left/right position
- **Z**: Up/down position (height)

**Orientation (quaternion wxyz)**
- **w, x, y, z**: Quaternion components representing 3D rotation
  - Normalized: w² + x² + y² + z² = 1

**Euler Angles (ZYX, degrees)**
- **Yaw** (-180° to 180°): Rotation around vertical axis (heading)
- **Pitch** (-90° to 90°): Rotation around lateral axis (nose up/down)
- **Roll** (-180° to 180°): Rotation around longitudinal axis (tilt)

#### Center Panel: 3D Pose Visualization

The main 3D plot shows:
- **Blue Wireframe**: Camera trajectory (historical poses)
- **Coordinate Frame**: RGB axes (X=Red, Y=Green, Z=Blue)
- **Interactive**: Rotate view with mouse, zoom with scroll wheel

#### Bottom Panel: Control Buttons

- **🟢 START**: Begin/resume pose estimation
  - Sends `start` command to Jetson
  - Enables data streaming
  - Button becomes disabled when active

- **🔵 STOP**: Pause pose estimation
  - Sends `stop` command to Jetson
  - Preserves current state
  - Can be resumed with START

- **🔴 SHUTDOWN X**: Exit the system
  - Sends `shutdown` command to Jetson
  - Cleanly exits visStateEst3 program
  - Closes ROS2 connections
  - No daemon restart needed!

---

## 📁 File Descriptions

### 1. Jetson_Live_Updated.mlapp
**Location**: Desktop computer  
**Type**: MATLAB App Designer application  
**Purpose**: Main user interface and control application

**Key Functions**:
- Provides graphical control interface (START/STOP/SHUTDOWN)
- Subscribes to ROS2 topics to receive:
  - Camera pose estimates (`/pose_p3p`)
  - Camera images (`/jetson/camera/image`)
  - Status messages (`/jetson/camera/status`)
- Publishes control commands (`/jetson/camera/command`)
- Displays real-time pose data in multiple formats
- Renders 3D visualization of camera trajectory
- Calculates and displays Euler angles from quaternions

**Key Classes/Methods**:
- `connectToROS2()`: Establishes ROS2 connection
- `poseCallback()`: Updates UI when new pose data arrives
- `imageCallback()`: Updates camera preview
- `statusCallback()`: Updates connection status
- Button callbacks for START/STOP/SHUTDOWN

### 2. visStateEst3.m
**Location**: Jetson  
**Type**: MATLAB function (compiled for Jetson)  
**Purpose**: Main pose estimation loop and ROS2 interface

**Key Functions**:
- Captures frames from Jetson camera (IMX219)
- Calls the CUDA P3P algorithm for pose estimation
- Publishes pose estimates to ROS2 (`/pose_p3p`)
- Listens for control commands from the desktop app
- Manages start/stop/shutdown states
- Provides status updates
- Handles clean shutdown (no daemon restart needed!)

**Operation Modes**:
- **Idle**: Waiting for START command (low CPU usage)
- **Running**: Processing frames and publishing poses (~30 Hz)
- **Shutdown**: Clean exit with resource cleanup

**ROS2 Topics**:
- Publishes to:
  - `/pose_p3p` (geometry_msgs/Pose)
  - `/jetson/camera/status` (std_msgs/String)
- Subscribes to:
  - `/jetson/camera/command` (std_msgs/String)

### 3. nanoP3p.m
**Location**: Jetson  
**Type**: CUDA MEX function source  
**Purpose**: GPU-accelerated P3P pose estimation

**Key Functions**:
- Implements Perspective-3-Point algorithm
- Runs on Jetson GPU using CUDA
- Detects visual markers in camera frames
- Computes up to 4 possible pose solutions
- Returns 7-DOF pose (position + quaternion)
- Optimized for real-time performance

**Inputs**:
- RGB image frame (640×360×3 uint8)

**Outputs**:
- `p3pSoln` matrix (7×4):
  - Row 1-3: Position X, Y, Z (meters)
  - Row 4-7: Quaternion w, x, y, z
  - Columns 1-4: Up to 4 different pose solutions

### 4. compile_nanoP3p.m
**Type**: MATLAB build script  
**Purpose**: Compiles nanoP3p.m into CUDA MEX file

**Usage**:
```matlab
>> compile_nanoP3p
```

**What it does**:
- Configures GPU Coder for Jetson target
- Compiles MATLAB code to CUDA kernels
- Links with CUDA libraries
- Generates optimized MEX file for Jetson GPU
- Enables real-time performance

**Requirements**:
- MATLAB Coder
- GPU Coder
- CUDA Toolkit installed on Jetson

### 5. compile_visStateEst.m 
**Type**: MATLAB build script  
**Purpose**: Compiles visStateEst3.m for deployment

**Usage**:
```matlab
>> compile_visStateEst
```

**What it does**:
- Prepares visStateEst3 for standalone execution
- Links with Jetson hardware support libraries
- Includes ROS2 dependencies
- Optimizes for embedded deployment
- Generates executable or enhanced performance code

**Note**: Depending on your deployment strategy, this may generate:
- MEX file for MATLAB execution
- Standalone executable
- Or optimized code generation

---

## 🔧 Troubleshooting

### Problem: "No commands received on Jetson."

**Symptoms**: visStateEst3 stays in IDLE mode, doesn't respond tothe  START button

**Solution**:
```bash
# 1. Check ROS_DOMAIN_ID matches on both systems
echo $ROS_DOMAIN_ID  # Should be 0 on both

# 2. Verify topic connection
ros2 topic list  # Should show /jetson/camera/command

# 3. Test command publishing manually
ros2 topic pub --once /jetson/camera/command std_msgs/String "{data: 'start'}"

# 4. Check subscriber count
ros2 topic info /jetson/camera/command
# Should show: Subscription count: 1
```

### Problem: "Daemon restart required."

**Cause**: Force-terminated previous session  
**Solution**: This shouldn't happen with the updated code! Always use the SHUTDOWN button.

If it does happen:
```bash
sudo systemctl restart nvargus-daemon
```

### Problem: "No pose data in app."

**Checklist**:
1. ✓ visStateEst3 running on Jetson?
2. ✓ Pressed START in the app?
3. ✓ Camera has a clear view of markers?
4. ✓ Lighting conditions adequate?

**Debug**:
```bash
# On Jetson or Desktop, check the pose topic
ros2 topic echo /pose_p3p

# Should show pose messages streaming
```

### Problem: "App shows NaN values."

**Explanation**: This is normal! It means no visual markers were detected.

**Solutions**:
- Improve lighting
- Position the camera to see markers clearly
- Check marker size and contrast
- Verify the camera is in focus

---
