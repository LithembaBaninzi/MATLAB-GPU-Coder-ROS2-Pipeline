function buildingGrayCam()
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

    % Configure build
    cfg = coder.gpuConfig('exe');
    cfg.Hardware = coder.hardware('NVIDIA Jetson');
    cfg.Hardware.BuildDir = '~/build_matlab';
    cfg.GenerateExampleMain = 'GenerateCodeAndCompile';
    cfg.GenerateReport = true;

    % Link external CUDA library
    libPath = 'C:\Users\lithe\OneDrive\BNNLIT002\Documents\MATLAB\2025_Dec_Vac_Work\project3\codegen\dll\gpuGrayscale';
    cfg.CustomInclude = {libPath};
    cfg.CustomLibrary = {fullfile(libPath, 'gpuGrayscale.so')};
    cfg.CustomSourceCode = '#include "gpuGrayscale.h"';


    % Compile
    disp("Building and deploying grayCameraEntry to Jetson...");

    codegen -config cfg grayCameraEntry -report
      
    fprintf('\nExecutable generated successfully!\n');

    % Run on Jetson
    pid = runApplication(hwobj, 'grayCameraEntry');
    fprintf('Application running on Jetson with PID: %d\n', pid);
  
end
