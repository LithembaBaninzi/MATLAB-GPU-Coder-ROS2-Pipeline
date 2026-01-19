# LibTest Folder
## Overview
The **LibTest** folder contains test scripts and utilities to verify that your MATLAB-generated shared libraries function correctly before integrating them with ROS2. This validation step ensures your CUDA/GPU code works independently, helping you isolate and debug library issues separately from ROS2 complexities.

## Purpose
Test your compiled shared libraries (.so files) to confirm they:<br>
1. Load correctly without ROS2 dependencies
2. Execute GPU/CUDA functions as expected
3. Return valid results from MATLAB algorithms
4. Are properly compiled with all necessary dependencies

## Key Files
- grayCameraEntry.m
- buildingGrayCam.m
