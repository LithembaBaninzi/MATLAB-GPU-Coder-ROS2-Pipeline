# MATLAB-GPU-Coder-ROS2-Pipeline
End-to-end deployment pipeline for MATLAB-generated CUDA code on NVIDIA Jetson Nano with ROS2 integration. This workflow enables seamless deployment of MATLAB algorithms (via GPU Coder) to embedded ROS2 systems, specifically designed for machine vision applications.

# Step-by-Step Tutorial: Deploying MATLAB-Generated ROS 2 Node with GPU Grayscale Processing on Jetson Nano
This guide documents the process of getting a MATLAB-generated ROS 2 node (grayCameraRos2) running on a Jetson Nano, including handling GPU libraries, camera input, and publishing to a ROS 2 topic. It also records common errors and fixes for easier duplication.\

## 1. System Setup
Jetson Nano prerequisites
- Ubuntu 20.04 (or JetPack version compatible with CUDA 10.2)
- ROS 2 Humble installed
- CUDA 10.2 toolkit installed
- MATLAB R2024b with GPU Coder installed

Verify installed tools
- nvcc --version        # CUDA version
- ros2 --version        # ROS 2 version
- v4l2-ctl --list-devices  # Verify camera is detected
