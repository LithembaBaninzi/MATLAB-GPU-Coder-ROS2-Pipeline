function grayCameraEntry()
%#codegen
% Capture frames from Jetson camera and process using gpuGrayscale.so

    % Include library header
    coder.cinclude('gpuGrayscale.h');

    hwobj = jetson;

    % Jetson camera configuration
    camName = 'vi-output, imx219 6-0010';
    camRes  = [1280 720];

    cam = camera(hwobj, camName, camRes);

    % Prepare frame buffers
    width  = int32(camRes(1));
    height = int32(camRes(2));
    % frameRGB  = zeros(height, width, 3, 'uint8');
    frameGray = zeros(height, width, 'uint8');

    % Run capture loop
    for i = 1:20
        % Capture frame
        %frameRGB = rot90(snapshot(cam));
        frameRGB = snapshot(cam);

        % Call external CUDA grayscale function (from library)
        coder.ceval('gpuGrayscale', coder.rref(frameRGB), coder.wref(frameGray));

        % Optional display (on Jetson monitor)
        dispObj = imageDisplay(hwobj);
        image(dispObj, frameGray);

        pause(5);
    end

    fprintf('All frames captured and processed.\n');
end
