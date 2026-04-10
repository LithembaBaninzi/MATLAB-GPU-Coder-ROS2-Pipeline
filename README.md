# MATLAB-to-CUDA ROS2 Vision Pipeline on Jetson Nano

## 🔹 Overview
This project addresses a key challenge in robotics and embedded AI: bridging the gap between high-level algorithm development in MATLAB and deployment on embedded GPU systems using ROS2.

MATLAB GPU-generated CUDA code does not seamlessly integrate with ROS2 nodes on embedded platforms such as the Jetson Nano due to runtime and execution conflicts. This project develops an end-to-end pipeline to resolve these issues and enable stable deployment of GPU-accelerated vision algorithms within a ROS2 ecosystem.

---

## 🔹 Demo
🎥 *Demo video:* *(add your video link here)*  

The system demonstrates:
- CUDA-accelerated processing on Jetson Nano  
- ROS2-based communication  
- Real-time pose and trajectory visualization in MATLAB  

---

## 🔹 Key Features
- MATLAB → CUDA C++ deployment using GPU Coder  
- Integration of GPU-accelerated code with ROS2 middleware  
- Embedded execution on Jetson Nano  
- End-to-end pipeline: data acquisition → processing → visualization  
- MATLAB app for live pose and trajectory tracking  

---

## 🔹 System Architecture
<img width="761" height="61" alt="System_archive drawio" src="https://github.com/user-attachments/assets/cdb18923-dac2-49bd-9ec3-e1e2ce9a02c6" />


## 🔹 Solution
This project implements a structured pipeline that:

- Generates CUDA-enabled C++ from MATLAB using GPU Coder  
- Integrates the generated code into ROS2 nodes  
- Resolves runtime conflicts between CUDA and ROS2  
- Enables stable real-time communication and visualization  

---

## 🔹 Results
- Successful deployment on Jetson Nano  
- Stable CUDA + ROS2 integration  
- Real-time pose and trajectory visualization  
- Fully functional end-to-end pipeline  

---

## 🔹 Repository Structure

- /matlab → MATLAB scripts and GPU Coder configs <br>
- /src → Generated CUDA/C++ code
- /ros2_ws → ROS2 nodes and packages
- /app → MATLAB visualization app
- /docs → Tutorial + architecture diagrams
- README.md
---

## 🔹 What I Learned
- Bridging prototyping and deployment pipelines  
- GPU vs CPU execution trade-offs  
- ROS2 communication and distributed system design  
- Debugging multi-component embedded systems  

---

## 🔹 Future Improvements
- Add performance benchmarking (latency, FPS)  
- Optimize GPU execution  
- Extend to more advanced embedded platforms  

---

## 🔹 Author
**Lithemba Baninzi**  
Electrical & Computer Engineering – University of Cape Town 
