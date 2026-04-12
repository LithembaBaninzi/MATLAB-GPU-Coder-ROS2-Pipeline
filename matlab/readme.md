# matlab/

This folder contains all MATLAB source code for the pipeline. Everything here is human-authored — nothing in this folder is auto-generated.

After editing files here, run the corresponding build script in `codegen_cfg/` to regenerate the CUDA library or ROS2 package in `generated/`.

---

## Sub-folders

### `algorithms/`

Core `.m` functions — the actual algorithms and ROS2 node logic. Edit these when you want to change processing behaviour.

| File | What it does |
|---|---|
| `gpuGrayscale.m` | Converts an RGB image to grayscale using CUDA. Input: `uint8` RGB frame. Output: `uint8` grayscale frame. |
| `gpuInvert.m` | Inverts pixel values (`255 − pixel`) for an RGB image using CUDA. Converts to `single` for arithmetic, back to `uint8` on output. Includes a checksum for verification. |
| `grayCameraEntry.m` | Standalone (non-ROS2) test entry point for the grayscale library. Captures frames from Jetson camera and processes them without ROS2. |
| `grayCameraRos2.m` | Main ROS2 node function for grayscale. Publishes processed frames to `/camera/image_gray`. |
| `invertCameraEntry.m` | Standalone test entry point for the inversion library. Captures and inverts frames on the Jetson display without ROS2. |
| `invertCameraRos2.m` | Main ROS2 node function for image inversion. Publishes inverted frames to `/camera/image_inverted`. |
| `nanoP3p.m` | CUDA MEX source for the P3P pose estimation algorithm. Input: `640×360×3 uint8` RGB frame. Output: `7×4` solution matrix (rows 1–3 = XYZ position in metres, rows 4–7 = quaternion wxyz; up to 4 pose solutions per frame). |
| `ros2GraySub.m` | Desktop-side MATLAB subscriber. Connects to the Jetson ROS2 network, subscribes to `/camera/image_gray`, and displays the live feed in MATLAB. Used for debugging. |
| `ros2InvSub.m` | Desktop-side MATLAB subscriber for `/camera/image_inverted`. Same purpose as `ros2GraySub.m` but for the inversion pipeline. |
| `updatedVisStateEst.m` | Revised pose estimation node. Use this version for new deployments. |
| `visStateEst.m` | Original pose estimation node — kept for reference. |
| `visStateEst3.m` | Latest production pose estimation node. Manages idle / running / shutdown states, publishes to `/pose_p3p`, and responds to control commands on `/jetson/camera/command`. |

---

### `codegen_cfg/`

Build and compile scripts. Run these in MATLAB on the host PC to produce the artefacts in `generated/`.

| File | What it produces | Where the output goes |
|---|---|---|
| `buildGpuGrayLib.m` | `gpuGrayscale.so` shared library | `generated/cuda_lib/` |
| `buildGpuInvertLib.m` | `gpuInvert.so` shared library | `generated/cuda_lib/` |
| `buildJetsonGray.m` | `grayCameraRos2` ROS2 package | `generated/tgz_files/` |
| `buildingGrayCam.m` | Standalone `grayCameraEntry` executable for Jetson | Jetson via SSH |
| `buildingInvertCam.m` | Standalone `invertCameraEntry` executable for Jetson | Jetson via SSH |
| `buildInvertCamRos2.m` | `invertCameraRos2.tgz` ROS2 package | `generated/tgz_files/` |
| `compile_nanoP3p.m` | `nanoP3p` CUDA MEX file | `generated/cuda_lib/` |
| `compile_visStateEst.m` | Compiled `visStateEst3` for Jetson deployment | `generated/tgz_files/` |

---

## Typical Workflow

1. **Edit** an algorithm in `algorithms/`.
2. **Run** the matching build script in `codegen_cfg/`.
3. **Copy** the output from `generated/` to the Jetson (see root README).
4. **Rebuild** on the Jetson with `colcon build`.
5. **Test** using the subscriber script (e.g. `ros2GraySub.m`) or the desktop app in `Jetson_App/`.
