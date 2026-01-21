deviceAddress = '196.24.150.228';
userName = 'jetson';
password = 'jetson';
hwobj = jetson(deviceAddress, userName, password);

% Configure GPU environment
envCfg = coder.gpuEnvConfig('jetson');
envCfg.HardwareObject = hwobj;
envCfg.BasicCodegen = 1;
envCfg.Quiet = 1; 
coder.checkGpuInstall(envCfg);

% Configure GPU-Coder to build shared library (.so)
% cfg = coder.gpuConfig('lib');
cfg = coder.gpuConfig('dll');
cfg.Hardware = coder.hardware('NVIDIA Jetson');
cfg.Hardware.BuildDir = '~/build_matlab';
cfg.GenerateReport = true;


% Define input size explicitly
inputSize = zeros(720, 1280, 3, 'uint8');

% Generate code
codegen -config cfg gpuInvert  -args {inputSize} -report

fprintf("\n Library built successfully.\n");