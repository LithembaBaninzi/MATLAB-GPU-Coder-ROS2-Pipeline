# Jetson Camera Live Stream App

## Real-Time Visual Pose Estimation System

Desktop-side MATLAB App Designer application for controlling and visualising the Jetson pipeline in real time.

---
<img width="660" height="391" alt="image" src="https://github.com/user-attachments/assets/477b9ed5-605d-46b9-a3f1-756db8bf037d" />

---


## Files

| File | Notes |
|---|---|
| `Jetson_Live_Updated.mlapp` | Backup copy. |
| `Jetson_Live_Updated (1).mlapp` |Current version — use this one.  |
| `ReadMe.md` | Original quick-start notes (superseded by this file and the root README). |

---

## What the App Does

The app is the desktop half of the system. It connects to the Jetson over ROS2 and provides:

- **Live camera feed** — receives `/jetson/camera/image` and displays it in real time.
- **Pose display panel** — shows position (X, Y, Z in metres), orientation as quaternion (w, x, y, z), and Euler angles (Yaw, Pitch, Roll in degrees) from `/pose_p3p`.
- **3D trajectory plot** — interactive 3D visualisation of the camera's pose history. Rotate with mouse, zoom with scroll wheel.
- **Control buttons** — START, STOP, and SHUTDOWN commands sent to Jetson over `/jetson/camera/command`.
- **Status indicators** — live preview lamp (Red / Amber / Green), FPS counter, and connection status.

---

## ROS2 Topics

| Topic | Direction | Type |
|---|---|---|
| `/jetson/camera/command` | App → Jetson | `std_msgs/String` |
| `/jetson/camera/status` | Jetson → App | `std_msgs/String` |
| `/jetson/camera/image` | Jetson → App | `sensor_msgs/Image` |
| `/pose_p3p` | Jetson → App | `geometry_msgs/Pose` |


---

## Control Buttons

| Button | What it does |
|---|---|
| START | Sends `"start"` to Jetson. Begins pose estimation and image streaming. |
| STOP | Sends `"stop"` to Jetson. Pauses processing but keeps the node alive so you can resume. |
| SHUTDOWN | Sends `"shutdown"` to Jetson. Cleanly exits `visStateEst3` and releases the camera — no daemon restart needed. |

> Always use the SHUTDOWN button to exit. Force-killing the Jetson process can leave the camera daemon in a bad state and require `sudo systemctl restart nvargus-daemon`.

---

## Pose Data Explained

**Position (metres)**

| Field | Meaning |
|---|---|
| X | Forward / backward relative to the marker plane |
| Y | Left / right |
| Z | Up / down (height) |

**Orientation**

- Quaternion (w, x, y, z) — normalised: w² + x² + y² + z² = 1
- Euler angles (ZYX convention): Yaw (−180° to 180°), Pitch (−90° to 90°), Roll (−180° to 180°)

`NaN` values in the pose fields are normal — they mean no visual markers were detected in that frame.

---

## Quick Start

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

Make sure the Jetson node is already running before you click START (see root README for Jetson setup).

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

# User Interface Guide

### Main Window Components

#### Center Panel: 3D Pose Visualization

The main 3D plot shows:
- **Blue Wireframe**: Camera trajectory (historical poses)
- **Coordinate Frame**: RGB axes (X=Red, Y=Green, Z=Blue)
- **Interactive**: Rotate view with mouse, zoom with scroll wheel

---

## 🔧 Troubleshooting

### Problem: "No commands received on Jetson."

**Symptoms**: visStateEst3 stays in IDLE mode, doesn't respond to the  START button

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
