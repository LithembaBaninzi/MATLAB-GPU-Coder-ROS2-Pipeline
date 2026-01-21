clear;
% Build and deploy invertCameraEntry to Jetson using gpuInvert.so
% Jetson device credentials
deviceAddress = '196.24.150.228';
userName = 'jetson';
password = 'jetson';

% Connect to Jetson
hwobj = jetson(deviceAddress, userName, password);

% Configure GPU environment
envCfg = coder.gpuEnvConfig('jetson');
envCfg.HardwareObject = hwobj;
envCfg.BasicCodegen = 1;
envCfg.Quiet = 1;
coder.checkGpuInstall(envCfg);

% Configure build
cfg = coder.gpuConfig('exe');
cfg.Hardware = coder.hardware('NVIDIA Jetson');
cfg.Hardware.BuildDir = '~/build_matlab';
cfg.GenerateExampleMain = 'GenerateCodeAndCompile';
cfg.GenerateReport = true;

% Path to the generated CUDA library (adjust this path!)
libPath = 'C:\Users\lithe\OneDrive\BNNLIT002\Documents\MATLAB\2025_Dec_Vac_Work\project5\codegen\dll\gpuInvert';

% Link the custom CUDA library
cfg.CustomInclude  = {libPath};
cfg.CustomLibrary  = {fullfile(libPath, 'gpuInvert.so')};
cfg.CustomSourceCode = '#include "gpuInvert.h"';

% Compile and deploy
disp("Building and deploying invertCameraEntry to Jetson...");

codegen -config cfg invertCameraEntry -report

fprintf('\nExecutable generated successfully!\n');

% Run on Jetson
pid = runApplication(hwobj, 'invertCameraEntry');
fprintf('Application running on Jetson with PID: %d\n', pid);