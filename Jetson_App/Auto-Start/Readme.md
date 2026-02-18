# Jetson Auto-Start Setup Guide

## Automatically Launch updatedVisStateEst on Boot

This guide explains how to configure your NVIDIA Jetson to automatically launch the `updatedVisStateEst` ROS2 node (or MATLAB-based visual state estimator) when the system boots up, without requiring a monitor or manual intervention.

---

## 📋 Table of Contents

1. [Overview](#overview)
2. [Prerequisites](#prerequisites)
3. [Method 1: Basic Auto-Start (Recommended)](#method-1-basic-auto-start-recommended)
4. [Method 2: With ROS2 Cleanup (Untested - Suggested)](#method-2-with-ros2-cleanup-untested---suggested)
5. [Method 3: Wait for MATLAB App (Untested - Suggested)](#method-3-wait-for-matlab-app-untested---suggested)
6. [Verification](#verification)
7. [Managing the Service](#managing-the-service)
8. [Troubleshooting](#troubleshooting)
9. [Common Issues](#common-issues)

---

## 🎯 Overview

This setup uses **systemd**, Ubuntu's standard service manager, to:
- Automatically start your visual state estimator on boot
- Restart it if it crashes
- Provide logging for debugging
- Allow easy start/stop/status checking

Three methods are provided:
1. **Basic** - Simple startup (recommended for testing)
2. **With Cleanup** - Kills old ROS2 processes first (prevents conflicts)
3. **With App Wait** - Waits for MATLAB app before starting (ensures connection)

---

## 📦 Prerequisites

- ✅ NVIDIA Jetson with JetPack installed
- ✅ ROS2 Humble (or Foxy) installed
- ✅ Your ROS2 workspace built at `/home/jetson/ros2_ws`
- ✅ `updatedVisStateEst` node compiled and working
- ✅ sudo/root access to create systemd services

**Test your node works manually first:**
```bash
source /opt/ros/humble/setup.bash # Or wherever it is located in your Jetson
source /home/jetson/ros2_ws/install/setup.bash
export ROS_DOMAIN_ID=0
ros2 run updatedvissteest updatedVisStateEst
```

If this works, you're ready to set up auto-start!

---

## Method 1: Basic Auto-Start (Recommended)

This is the simplest method - it launches your node 10 seconds after boot.

### Step 1: Create Startup Script

```bash
sudo nano /usr/local/bin/start_visstate.sh
```

**Paste this content:**

```bash
#!/bin/bash
# --- ROS2 Jetson Auto-start Script ---

# Wait a bit to ensure the system and network are ready
sleep 10

# Source your ROS2 and workspace setup files
source /opt/ros/humble/setup.bash
source /home/jetson/ros2_ws/install/setup.bash

# Optional: set domain ID if needed
export ROS_DOMAIN_ID=0

# Run your executable (modify package and node names)
ros2 run updatedvisstateest updatedVisStateEst >> /home/jetson/startup_log.txt 2>&1
```

**Save and exit** (Ctrl+O, Enter, Ctrl+X)

**Make it executable:**
```bash
sudo chmod +x /usr/local/bin/start_visstate.sh
```

### Step 2: Create Systemd Service

```bash
sudo nano /etc/systemd/system/visstate.service
```

**Paste this content:**

```ini
[Unit]
Description=Auto-start Visual State Estimator
After=network.target

[Service]
Type=simple
User=jetson
ExecStart=/usr/local/bin/start_visstate.sh
Restart=always
RestartSec=5

[Install]
WantedBy=multi-user.target
```

**Save and exit**

### Step 3: Enable and Start

```bash
# Reload systemd to recognize new service
sudo systemctl daemon-reload

# Enable service to start on boot
sudo systemctl enable visstate.service

# Start the service now
sudo systemctl start visstate.service
```

### Step 4: Verify It's Running

```bash
# Check status
systemctl status visstate.service

# View logs
cat /home/jetson/startup_log.txt
```

**✅ Done!** Your node will now start automatically on every boot.

---

## Method 2: With ROS2 Cleanup (Untested - Suggested)

**⚠️ Note:** This method is suggested but not fully tested. Use with caution.

This method kills any leftover ROS2 processes before starting, preventing conflicts from previous runs.

### Step 1: Create Enhanced Startup Script

```bash
sudo nano /usr/local/bin/start_visstate_cleanup.sh
```

**Paste this content:**

```bash
#!/bin/bash
# --- Jetson ROS2 Visual State Estimator startup script with cleanup ---

LOGFILE=/home/jetson/startup_log.txt
echo "[Startup] ===== Boot sequence started $(date) =====" >> $LOGFILE

# Wait for system services to be ready
sleep 8

echo "[Startup] Cleaning up old ROS2 processes..." >> $LOGFILE

# Kill any leftover ROS2 processes from previous runs
sudo pkill -f ros2 2>/dev/null
ros2 daemon stop 2>/dev/null
ros2 daemon start

# Source ROS2 environment
source /opt/ros/humble/setup.bash
source /home/jetson/ros2_ws/install/setup.bash

# Set domain ID
export ROS_DOMAIN_ID=0

# Launch your node
echo "[Startup] Launching updatedVisStateEst..." >> $LOGFILE
ros2 run updatedvisstateest updatedVisStateEst >> $LOGFILE 2>&1
```

**Make it executable:**
```bash
sudo chmod +x /usr/local/bin/start_visstate_cleanup.sh
```

### Step 2: Create Service

```bash
sudo nano /etc/systemd/system/visstate.service
```

**Content:**

```ini
[Unit]
Description=Auto-start Visual State Estimator with Cleanup
After=network.target

[Service]
Type=simple
User=jetson
ExecStart=/usr/local/bin/start_visstate_cleanup.sh
Restart=always
RestartSec=5

[Install]
WantedBy=multi-user.target
```

### Step 3: Enable

```bash
sudo systemctl daemon-reload
sudo systemctl enable visstate.service
sudo systemctl start visstate.service
```

**What this does:**
- Kills any old ROS2 nodes on startup
- Restarts ROS2 daemon fresh
- Prevents topic/node conflicts

---

## Method 3: Wait for MATLAB App (Untested - Suggested)

**⚠️ Note:** This method is suggested but not fully tested. Use with caution.

This method waits for your MATLAB app to be ready before starting the estimator, ensuring proper connection order.

### Step 1: Create Smart Startup Script

```bash
sudo nano /usr/local/bin/start_visstate_wait.sh
```

**Paste this content:**

```bash
#!/bin/bash
# --- Jetson ROS2 Visual State Estimator with MATLAB app wait ---

LOGFILE=/home/jetson/startup_log.txt
echo "[Startup] ===== Boot sequence started $(date) =====" >> $LOGFILE

# Wait for system to settle
sleep 8

echo "[Startup] Cleaning up old ROS2 processes..." >> $LOGFILE
sudo pkill -f ros2 2>/dev/null
ros2 daemon stop 2>/dev/null
ros2 daemon start

# Source ROS2 environment
source /opt/ros/humble/setup.bash
source /home/jetson/ros2_ws/install/setup.bash
export ROS_DOMAIN_ID=0

# ✅ Wait until MATLAB app is publishing /jetson/camera/command
echo "[Startup] Waiting for MATLAB app to be ready..." >> $LOGFILE
MAX_WAIT=60    # seconds
COUNTER=0
while true; do
    PUB_COUNT=$(ros2 topic info /jetson/camera/command 2>/dev/null | grep "Publisher count" | awk '{print $3}')
    if [[ "$PUB_COUNT" =~ ^[0-9]+$ ]] && [ "$PUB_COUNT" -ge 1 ]; then
        echo "[Startup] MATLAB app detected! ($PUB_COUNT publisher(s))" >> $LOGFILE
        break
    fi
    sleep 2
    COUNTER=$((COUNTER+2))
    if [ $COUNTER -ge $MAX_WAIT ]; then
        echo "[Startup] MATLAB app not detected after $MAX_WAIT s — starting anyway." >> $LOGFILE
        break
    fi
done

# 🚀 Launch updatedVisStateEst node
echo "[Startup] Launching updatedVisStateEst..." >> $LOGFILE
ros2 run updatedvisstateest updatedVisStateEst >> $LOGFILE 2>&1
```

**Make it executable:**
```bash
sudo chmod +x /usr/local/bin/start_visstate_wait.sh
```

### Step 2: Create Service

```bash
sudo nano /etc/systemd/system/visstate.service
```

**Content:**

```ini
[Unit]
Description=Auto-start Visual State Estimator (waits for MATLAB app)
After=network.target

[Service]
Type=simple
User=jetson
ExecStart=/usr/local/bin/start_visstate_wait.sh
Restart=always
RestartSec=5

[Install]
WantedBy=multi-user.target
```

### Step 3: Enable

```bash
sudo systemctl daemon-reload
sudo systemctl enable visstate.service
sudo systemctl start visstate.service
```

**What this does:**
- Waits up to 60 seconds for MATLAB app
- Checks if `/jetson/camera/command` topic has publishers
- Only starts when MATLAB is ready (or after timeout)

---

## 🔍 Verification

### Check Service Status

```bash
# Check if service is running
systemctl status visstate.service
```

**Good output:**
```
● visstate.service - Auto-start Visual State Estimator
   Loaded: loaded (/etc/systemd/system/visstate.service; enabled)
   Active: active (running) since Fri 2026-02-06 10:00:00 SAST
```

### View Live Logs

```bash
# Follow logs in real-time
sudo journalctl -u visstate.service -f
```

### Check Startup Log

```bash
# View the log file
cat /home/jetson/startup_log.txt

# Or follow it live
tail -f /home/jetson/startup_log.txt
```

### Verify ROS2 Node is Running

```bash
# List active ROS2 nodes
ros2 node list

# Should show your node, e.g.:
# /p3p_node
# /updated_visstate_node
```

### Check ROS2 Topics

```bash
# List topics
ros2 topic list

# Should show:
# /pose_p3p
# /jetson/camera/command
# /jetson/camera/status
```

---

## 🎮 Managing the Service

### Start/Stop/Restart

```bash
# Start the service
sudo systemctl start visstate.service

# Stop the service
sudo systemctl stop visstate.service

# Restart the service
sudo systemctl restart visstate.service
```

### Enable/Disable Auto-Start

```bash
# Enable auto-start on boot
sudo systemctl enable visstate.service

# Disable auto-start (but don't stop current instance)
sudo systemctl disable visstate.service

# Disable and stop immediately
sudo systemctl disable --now visstate.service
```

---
## 🔧 Troubleshooting

### Problem: Service fails to start

**Check detailed logs:**
```bash
sudo journalctl -u visstate.service -n 200 --no-pager
```

**Common causes:**

1. **ROS2 not sourced correctly**
   ```bash
   # Verify paths in your script
   ls /opt/ros/humble/setup.bash
   ls /home/jetson/ros2_ws/install/setup.bash
   ```

2. **Package name wrong**
   ```bash
   # List your packages
   source /opt/ros/humble/setup.bash
   source /home/jetson/ros2_ws/install/setup.bash
   ros2 pkg list | grep visstate
   
   # Update script with correct package name
   sudo nano /usr/local/bin/start_visstate.sh
   ```

3. **Script not executable**
   ```bash
   sudo chmod +x /usr/local/bin/start_visstate.sh
   ```

### Problem: Topic conflict errors

**Error message:**
```
Topic /pose_p3p with message type geometry_msgs/Pose is already on the ROS 2 network
```

**Solution - Kill old processes:**

```bash
# Stop the service
sudo systemctl stop visstate.service

# Kill all ROS2 processes
sudo pkill -f ros2

# Clean ROS2 daemon
ros2 daemon stop
ros2 daemon start

# Verify no nodes remain
ros2 node list

# Restart service
sudo systemctl start visstate.service
```

**Or use Method 2 (With Cleanup)** which does this automatically.

### Problem: Multiple nodes with same name

**Check for duplicate nodes:**
```bash
ros2 node list
```

**If you see duplicate `/p3p_node`:**

```bash
# Find which processes are running
ps aux | grep ros2

# Kill specific PID
sudo kill -9 

# Or kill all ROS2
sudo pkill -f ros2
```

**Long-term fix:** Use unique node names in your code:
```matlab
% In your MATLAB code:
p3pNode = ros2node("p3p_node_updated", rosID);  % Unique name
```

### Problem: Service starts but node doesn't work

**Check if node is actually running:**
```bash
ros2 node list
```

**Check if topics are published:**
```bash
ros2 topic list
ros2 topic info /pose_p3p
```

**Test publishing manually:**
```bash
ros2 topic pub --once /jetson/camera/command std_msgs/String "{data: 'start'}"
```

### Problem: Service keeps restarting

**View restart logs:**
```bash
sudo journalctl -u visstate.service -f
```

**Common causes:**
- Node crashes immediately (check `/home/jetson/startup_log.txt`)
- ROS2 daemon not ready (increase `sleep` time in script)
- Camera not available (check `systemctl status nvargus-daemon`)

**Disable auto-restart to debug:**
```bash
sudo nano /etc/systemd/system/visstate.service

# Change:
Restart=always
# To:
Restart=no

sudo systemctl daemon-reload
sudo systemctl restart visstate.service
```
---

## 🆘 Common Issues

### Issue 1: Camera daemon not ready

**Symptom:** Service starts but camera fails

**Solution:** Add camera daemon dependency:

```bash
sudo nano /etc/systemd/system/visstate.service

# Add to [Unit] section:
After=network.target nvargus-daemon.service
Wants=nvargus-daemon.service

sudo systemctl daemon-reload
sudo systemctl restart visstate.service
```

### Issue 2: Network not ready

**Symptom:** ROS2 communication fails

**Solution:** Increase startup delay:

```bash
sudo nano /usr/local/bin/start_visstate.sh

# Change:
sleep 10

# To:
sleep 30  # or higher

sudo systemctl restart visstate.service
```

### Issue 3: Wrong ROS_DOMAIN_ID

**Check domain ID:**
```bash
# In your script, verify:
export ROS_DOMAIN_ID=0

# On MATLAB side, also use:
setenv('ROS_DOMAIN_ID', '0')
```

### Issue 4: Permissions error

**Fix file permissions:**
```bash
sudo chown jetson:jetson /home/jetson/startup_log.txt
sudo chmod +x /usr/local/bin/start_visstate.sh
```

### Issue 5: Can't connect from MATLAB app

**Checklist:**
```bash
# 1. Jetson node running?
ros2 node list

# 2. Topics published?
ros2 topic list

# 3. Same domain ID?
echo $ROS_DOMAIN_ID  # On Jetson

# 4. Network connectivity?
ping      # From desktop

# 5. Firewall blocking?
sudo ufw status
```

---
## 🧪 Testing Procedure

### Test 1: Manual Run (Before Setting Up Service)

```bash
# Source environment
source /opt/ros/humble/setup.bash
source /home/jetson/ros2_ws/install/setup.bash
export ROS_DOMAIN_ID=0

# Run node manually
ros2 run your_package_name updatedVisStateEst
```

**If this fails, fix it before setting up auto-start!**

### Test 2: Script Run

```bash
# Run the startup script manually
sudo /usr/local/bin/start_visstate.sh &

# Check if node started
ros2 node list

# Stop it
sudo pkill -f updatedVisStateEst
```

### Test 3: Service Run

```bash
# Start via systemd
sudo systemctl start visstate.service

# Check status
systemctl status visstate.service

# Check nodes
ros2 node list

# Stop
sudo systemctl stop visstate.service
```

### Test 4: Reboot Test

```bash
# Enable service
sudo systemctl enable visstate.service

# Reboot
sudo reboot

# After reboot, SSH back in and check
systemctl status visstate.service
ros2 node list
cat /home/jetson/startup_log.txt
```

---


## 🗑️ Uninstalling Auto-Start

To remove the auto-start setup:

```bash
# Stop and disable service
sudo systemctl stop visstate.service
sudo systemctl disable visstate.service

# Remove service file
sudo rm /etc/systemd/system/visstate.service

# Remove script
sudo rm /usr/local/bin/start_visstate.sh

# Reload systemd
sudo systemctl daemon-reload

# Verify removal
systemctl list-units --type=service | grep visstate
# Should return nothing
```

---
