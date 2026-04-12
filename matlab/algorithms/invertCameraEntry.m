function invertCameraEntry()
%#codegen
% Capture frames from Jetson camera and process using gpuInvert.so

    % Include the generated CUDA library header
    coder.cinclude('gpuInvert.h');

    % Connect to Jetson hardware
    hwobj = jetson;

    % Jetson camera configuration
    camName = 'vi-output, imx219 6-0010';
    camRes  = [1280 720];

    cam = camera(hwobj, camName, camRes);

    % Prepare frame buffers
    width  = int32(camRes(1));
    height = int32(camRes(2));
    frameRGB  = zeros(height, width, 3, 'uint8');
    frameInv  = zeros(height, width, 3, 'uint8'); % output will also be RGB

    % Run capture loop
    for i = 1:20
        % Capture frame
        frameRGB = snapshot(cam);

        % Call external CUDA inversion function
        coder.ceval('gpuInvert', coder.rref(frameRGB), coder.wref(frameInv));

        % Display processed image (on Jetson monitor)
        dispObj = imageDisplay(hwobj);
        image(dispObj, frameInv);


        pause(1);
    end

    fprintf('All frames captured and inverted.\n');
end
