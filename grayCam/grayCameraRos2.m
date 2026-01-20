function grayCameraRos2()
%#codegen
% Jetson standalone ROS2 publisher: camera + CUDA grayscale
    deviceAddress = '196.24.150.228';
userName = 'jetson';
password = 'jetson';
hwobj = jetson(deviceAddress, userName, password);

    % --- External includes ---
    coder.cinclude('gpuGrayscale.h');

    % shuts down any old ROS1 global node
    % rosshutdown;
    % --- ROS2 setup ---
    node = ros2node("/jetson_cuda_camera_node");
    pub  = ros2publisher(node, "/camera/image_gray", "sensor_msgs/Image");

    % --- Camera config ---
    %hwobj = jetson;

    % Jetson camera configuration
    camName = 'vi-output, imx219 6-0010';
    camRes  = [1280 720];
    cam = camera(hwobj, camName, camRes);

    % --- Camera config ---
    width  = int32(camRes(1));
    height = int32(camRes(2));
    
    % --- Buffers ---
    frameRGB  = zeros(height, width, 3, 'uint8');
    frameGray = zeros(height, width, 'uint8');

    % --- Capture–process–publish loop ---
    for i = 1:50

        % Capture frame via Jetson camera 
        frameRGB = snapshot(cam);       % frameRGB = rot90(snapshot(cam));

        % Call external CUDA grayscale function (from library)
        coder.ceval('gpuGrayscale', coder.rref(frameRGB), coder.wref(frameGray));

        % Build and populate ROS2 message
        msg  = ros2message(pub);
        msg.encoding = 'mono8';  % grayscale
        msg.height = uint32(size(frameGray,1));
        msg.width  = uint32(size(frameGray,2));
        msg.step   = uint32(size(frameGray,2));
        msg.data   = reshape(frameGray', [], 1);

        % Timestamp + frame id
        msg.header.frame_id = 'camera_frame';
        %msg.header.stamp = rostime('now');

        % Display (on Jetson monitor)
        dispObj = imageDisplay(hwobj);
        image(dispObj, frameGray);

        % Publish
        send(pub, msg);

        pause(2);
        fprintf('Finished publishing Frame: %d on /camera/image_gray\n', i );
    end

    fprintf('All frames captured, processed and published.\n');
    
end
