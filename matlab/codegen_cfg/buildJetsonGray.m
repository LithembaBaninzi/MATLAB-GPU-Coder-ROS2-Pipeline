clear; 
deviceAddress = '196.xx.xxx.xxx';
userName = 'jetsonName';
password = 'jetsonPassword';

disp("Building grayCameraRos2 for Jetson (ROS 2 + CUDA library)...");

% ROS 2 build configuration
cfg = coder.config('exe');
cfg.Hardware = coder.hardware("Robot Operating System 2 (ROS 2)");
cfg.Hardware.ROS2Workspace = '/home/jetson/ros2_ws';
cfg.Hardware.ROS2Folder = '/home/jetson/ros2_humble/install' ; 
cfg.Hardware.RemoteDeviceAddress = deviceAddress;
cfg.Hardware.RemoteDeviceUsername = userName;
cfg.Hardware.RemoteDevicePassword = password;
cfg.Hardware.DeployTo = 'Remote Device';
cfg.Hardware.BuildAction = 'None';
cfg.GenerateReport = true;


% Add your GPU grayscale library 
% libPath = '/home/jetson/build_matlab/gpu_lib';   % copy .so & .h here on Jetson
% cfg.CustomInclude = {libPath};
% cfg.CustomLibrary = {fullfile(libPath, 'gpuGrayscale.so')};
% cfg.CustomSourceCode = '#include "gpuGrayscale.h"';

libPath = 'C:\projectPath\codegen\dll\gpuGrayscale';
cfg.CustomInclude = {libPath};
cfg.CustomLibrary = {fullfile(libPath, 'gpuGrayscale.so')};
cfg.CustomSourceCode = '#include "gpuGrayscale.h"';


% Code generation
codegen -config cfg grayCameraRos2 -report

disp("grayCameraRos2 build complete. You can now run:");
disp("  ros2 run gray_camera_ros2 grayCameraRos2");


