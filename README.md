# MATLAB-to-CUDA ROS2 Vision Pipeline on NVIDIA Jetson Nano
 
> Bridging high-level algorithm development in MATLAB with real-time GPU-accelerated deployment on embedded robotics platforms using ROS2.
 
## 🔹 Overview
A key challenge in embedded AI is the gap between algorithm prototyping and production deployment. MATLAB GPU-generated CUDA code does not seamlessly integrate with ROS2 nodes on platforms such as the Jetson Nano due to runtime and execution conflicts between CUDA and ROS2 middleware.
 
This project builds an end-to-end pipeline that resolves these conflicts and enables stable, real-time deployment of GPU-accelerated vision algorithms within a ROS2 ecosystem — from a MATLAB function all the way to a running node on edge hardware.

---

## 🔹 Demo
🎥 *Demo video:* *(add your video link here)*  

The system demonstrates:
- CUDA-accelerated processing on Jetson Nano  
- ROS2-based communication  
- Real-time pose and trajectory visualization in MATLAB  

---

## 🔹 Key Features
- **MATLAB → CUDA C++** code generation using GPU Coder — no manual CUDA authoring
- **CUDA + ROS2 co-existence** — resolves the runtime conflicts that arise when linking GPU-generated code into ROS2 nodes
- **Edge deployment** on NVIDIA Jetson Nano with real GPU acceleration
- **End-to-end pipeline**: camera acquisition → CUDA processing → ROS2 publish → desktop visualisation
- **Three complete vision projects** building in complexity: grayscale conversion, image inversion, and P3P pose estimation
 
---

## 🔹 System Architecture
<img width="761" height="61" alt="System_archive drawio" src="https://github.com/user-attachments/assets/cdb18923-dac2-49bd-9ec3-e1e2ce9a02c6" />


The pipeline has two sides connected over ROS2:
 
**Jetson (edge)** — captures camera frames, runs CUDA-accelerated processing compiled from MATLAB, and publishes results to ROS2 topics.
 
**Desktop** — the MATLAB App subscribes to those topics, displays live results, and sends control commands back to the Jetson.

---
 
## 🔹 Projects in This Repo
 
Three progressively more advanced projects share the same folder layout:
 
| Project | Algorithm | ROS2 Topic | Key files |
|---|---|---|---|
| GrayCameraRos2 | GPU grayscale conversion | `/camera/image_gray` | `gpuGrayscale.m`, `grayCameraRos2.m` |
| InvertCameraRos2 | GPU image inversion | `/camera/image_inverted` | `gpuInvert.m`, `invertCameraRos2.m` |
| VisStateEst / nanoP3p | P3P pose estimation ~30 Hz | `/pose_p3p` | `nanoP3p.m`, `visStateEst3.m` |
 
---
 
## 🔹 Repository Structure
 
```
.
├── matlab/                   # All MATLAB source — author and edit here
│   ├── algorithms/           # Core .m functions (GPU kernels, ROS2 nodes, subscribers)
│   └── codegen_cfg/          # Build and compile scripts (GPU Coder, ROS2 package gen)
│
├── generated/                # Auto-generated artefacts — do not edit by hand
│   ├── cuda_lib/             # Compiled CUDA shared libraries (.so)
│   ├── tgz_files/            # ROS2 package archives ready to deploy to Jetson
│   └── CMakeLists/           # CMake files emitted by MATLAB Coder
│
├── Jetson_App/               # MATLAB App Designer UI (desktop side)
│
└── docs/                     # Setup guides and tutorials
```
 
### Where do I look for each part of the system?
 
| I want to… | Go to |
|---|---|
| Edit a MATLAB algorithm (grayscale, invert, pose) | `matlab/algorithms/` |
| Change GPU Coder or build settings | `matlab/codegen_cfg/` |
| Find generated CUDA kernels or `.so` libraries | `generated/cuda_lib/` |
| Find the deployable ROS2 package archives | `generated/tgz_files/` |
| Fix a CMakeLists build issue | `generated/CMakeLists/` |
| Run the desktop visualisation app | `Jetson_App/` |
| Read setup guides or tutorials | `docs/` |
 
---
 
## 🔹 Quick Start
 
### Prerequisites
 
- MATLAB with GPU Coder and ROS Toolbox
- NVIDIA Jetson Nano with CUDA Toolkit and cuDNN
- ROS2 (Humble or later) on both Jetson and desktop
- Matching `ROS_DOMAIN_ID` on both machines (default: `0`)
 
See `docs/` for full environment setup.
 
### 1. Generate the CUDA library or ROS2 package (host PC)
 
Open MATLAB and run the appropriate build script from `matlab/codegen_cfg/`:
 
```matlab
% Grayscale shared library
buildGpuGrayLib
 
% Image inversion shared library
buildGpuInvertLib
 
% Pose estimation MEX (nanoP3p CUDA kernel)
compile_nanoP3p
 
% Generate ROS2 package archive for Jetson
buildInvertCamRos2     % or buildJetsonGray / compile_visStateEst
```
 
### 2. Transfer and build on Jetson
 
```bash
scp generated/tgz_files/<package>.tgz user@jetson:~/
 
# On Jetson:
tar -xzf <package>.tgz -C ~/ros2_ws/src/
cd ~/ros2_ws
colcon build
source install/setup.bash
```
 
### 3. Run a node on Jetson
 
```bash
ros2 run visstateest3 visStateEst3
```
 
Expected output:
```
ROS2 initialized. Waiting for START command...
[STATUS] Ready. Waiting for START command.
```
 
### 4. Launch the desktop app
 
```matlab
>> Jetson_Live_Updated
```
 
Click **START** in the app. The pose fields and 3D trajectory plot will begin updating in real time.
 
---
 
## 🔹 ROS2 Topics
 
| Topic | Direction | Type | Purpose |
|---|---|---|---|
| `/jetson/camera/command` | Desktop → Jetson | `std_msgs/String` | Start / Stop / Shutdown |
| `/jetson/camera/status` | Jetson → Desktop | `std_msgs/String` | Status messages |
| `/jetson/camera/image` | Jetson → Desktop | `sensor_msgs/Image` | Live camera feed |
| `/camera/image_gray` | Jetson → Desktop | `sensor_msgs/Image` | Grayscale output |
| `/camera/image_inverted` | Jetson → Desktop | `sensor_msgs/Image` | Inverted image output |
| `/pose_p3p` | Jetson → Desktop | `geometry_msgs/Pose` | 7-DOF pose estimate |
 
---
## 🔹 Results 
- Successful deployment on Jetson Nano with stable CUDA + ROS2 co-execution
- Real-time P3P pose estimation at ~30 Hz with 3D trajectory visualisation
- Fully functional end-to-end pipeline across all three vision projects


---

## 🔹 What I Learned
 
- Diagnosing and resolving runtime conflicts between GPU-generated CUDA code and ROS2 middleware
- Structuring a multi-stage build pipeline (MATLAB → GPU Coder → CMake → colcon)
- GPU vs CPU execution trade-offs in embedded vision systems
- ROS2 publish/subscribe architecture and distributed system design across heterogeneous hardware
- Debugging multi-component embedded systems across two machines and two operating environments
 
---
 
## 🔹 Future Improvements
 
- Add performance benchmarking (latency, throughput, FPS) across all three projects
- Optimise GPU kernel execution and memory transfer overhead
- Extend to more capable embedded platforms (Jetson Orin, Xavier)
- Add a CI pipeline for automated codegen and build validation
 
---

## 🔹 Author
**Lithemba Baninzi**  
Electrical & Computer Engineering – University of Cape Town 
