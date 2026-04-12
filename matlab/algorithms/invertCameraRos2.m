function invertCameraRos2()
%#codegen
% Jetson standalone ROS2 publisher: camera + CUDA inversion

    % % --- Jetson credentials ---
    % deviceAddress = '196.24.150.228';
    % userName = 'jetson';
    % password = 'jetson';
    % hwobj = jetson(deviceAddress, userName, password);

    % --- External includes ---
    coder.cinclude('gpuInvert.h');

    % --- ROS2 setup ---
    node = ros2node("/jetson_cuda_invert_node");
    pub  = ros2publisher(node, "/camera/image_inverted", "sensor_msgs/Image");
    
    % --- Camera config ---
    hwobj = jetson;

    % --- Jetson camera configuration ---
    camName = 'vi-output, imx219 6-0010';
    camRes  = [1280 720];
    cam = camera(hwobj, camName, camRes);

    % --- Frame buffers ---
    width  = int32(camRes(1));
    height = int32(camRes(2));
    frameRGB = zeros(height, width, 3, 'uint8');
    frameInv = zeros(height, width, 3, 'uint8');

    
    % --- Capture–process–publish loop ---
    for i = 1:50

        % Capture frame
        frameRGB = snapshot(cam);

        % Call external CUDA inversion function (from gpuInvert library)
        coder.ceval('gpuInvert', coder.rref(frameRGB), coder.wref(frameInv));

        % --- Build ROS2 Image message ---
        msg = ros2message(pub);
        msg.encoding = 'rgb8';                    % inverted RGB image
        msg.height   = uint32(size(frameInv,1));
        msg.width    = uint32(size(frameInv,2));
        msg.step     = uint32(size(frameInv,2) * 3);
        msg.data     = reshape(permute(frameInv, [3 2 1]), [], 1); % ROS expects column-major order

        % --- Header info ---
        msg.header.frame_id = 'camera_frame';
        % msg.header.stamp = rostime('now');  % optional, depends on deployment setup
        
        send(pub, msg);

        pause(2);
        fprintf('Published inverted Frame %d on /camera/image_inverted\n', int32(i));
    end

    fprintf('All frames captured, processed, and published.\n');
end
