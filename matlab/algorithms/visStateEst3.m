function visStateEst3()
%VISSTATEEST2 Visual state estimator with ROS2 control
%   Listens for start/stop commands via ROS2 and publishes pose estimates
%   Exits cleanly when the stop command is received

%% Initializations
    % Include library header
    coder.cinclude('nanoP3p.h');
    
    % Control flags (make them persistent for callbacks)
    isRunning = false;
    shouldExit = false;

    hwobj = jetson;
    % Jetson camera configuration
    camName = 'vi-output, imx219 6-0010';
    camRes  = [640 360];
    cam = camera(hwobj, camName, camRes);
    
    % Optional display (on Jetson monitor)
    dispObj = imageDisplay(hwobj);

    % Prepare frame buffers
    width  = int32(camRes(1));
    height = int32(camRes(2));
    frameRGB  = zeros(height, width, 3, 'uint8');
    frameOverlay = frameRGB;
    p3pSoln = zeros(7,4);

    %% Init ROS2 nodes (Domain 0 for communication with MATLAB app)
    rosID = 0;  % Domain 0 to match MATLAB app
    p3pNode = ros2node("p3p_node", rosID);
    
    % Publisher for pose data
    p3pPub = ros2publisher(p3pNode, "/pose_p3p", "geometry_msgs/Pose");
    p3pMsg = ros2message("geometry_msgs/Pose");
    
    % Publisher for status messages
    pub_status = ros2publisher(p3pNode, "/jetson/camera/status", "std_msgs/String");
    
    % Subscriber for control commands from MATLAB app
    % Note: We can't use nested callbacks with codegen, so we'll poll
    commandSub = ros2subscriber(p3pNode, "/jetson/camera/command", "std_msgs/String");
    
    fprintf('ROS2 initialized. Waiting for START command...\n');
    sendStatus(pub_status, 'Ready. Waiting for START command.');

    %% Main loop - wait for commands and process
    frameCounter = 0;
    lastStatusTime = tic;
    
    while ~shouldExit
        % Poll for new commands (instead of callback)
        [cmd_msg, cmd_ok] = receive(commandSub, 0.05);  % Non-blocking
        
        if cmd_ok
            command = char(cmd_msg.data);
            fprintf('Received command: %s\n', command);
            
            switch lower(command)
                case 'start'
                    if ~isRunning
                        isRunning = true;
                        frameCounter = 0;
                        fprintf('Starting pose estimation...\n');
                        sendStatus(pub_status, 'Pose estimation started.');
                    end
                    
                case 'stop'
                    if isRunning
                        isRunning = false;
                        fprintf('Stopping pose estimation...\n');
                        sendStatus(pub_status, 'Pose estimation stopped.');
                        % Display blank frame when stopped
                        image(dispObj, zeros(360, 640, 3, 'uint8'));
                    end
                    
                case 'shutdown'
                    fprintf('Shutdown command received.\n');
                    sendStatus(pub_status, 'Shutting down...');
                    shouldExit = true;
                    isRunning = false;
                    
                otherwise
                    fprintf('Unknown command: %s\n', command);
                    sendStatus(pub_status, sprintf('Unknown command: %s', command));
            end
        end
        
        % Check if we should be processing frames
        if isRunning
            % Capture frame
            frameRGB = rot90(snapshot(cam), 2);
            
            frameCounter = frameCounter + 1;
            
            % Display progress every 10 frames
            if mod(frameCounter, 10) == 0
                fprintf('Processing frame %d...\n', int32(frameCounter));
            end
            
            % Call external CUDA P3P function
            coder.ceval('nanoP3p', coder.rref(frameRGB), coder.wref(p3pSoln));

            % Populate ROS2 message
            p3pMsg.position.x = p3pSoln(1,1);
            p3pMsg.position.y = p3pSoln(2,1);
            p3pMsg.position.z = p3pSoln(3,1);
            p3pMsg.orientation.w = p3pSoln(4,1);
            p3pMsg.orientation.x = p3pSoln(5,1);
            p3pMsg.orientation.y = p3pSoln(6,1);
            p3pMsg.orientation.z = p3pSoln(7,1);
            send(p3pPub, p3pMsg);
            
            % Debug: Check if we got a valid pose
            if ~isnan(p3pSoln(1,1))
                if mod(frameCounter, 100) == 0  % Print less frequently
                    fprintf('Frame %d: Detected Pose: [%.3f, %.3f, %.3f, %.3f, %.3f, %.3f, %.3f]\n', ...
                            int32(frameCounter), p3pSoln(1,1), p3pSoln(2,1), p3pSoln(3,1), ...
                            p3pSoln(4,1), p3pSoln(5,1), p3pSoln(6,1), p3pSoln(7,1));
                end
            elseif mod(frameCounter, 100) == 0
                fprintf('Frame %d: No features detected (NaN)\n', int32(frameCounter));
            end
            
            % Display overlay
            frameOverlay = overlayPoseOnImage(frameRGB, p3pSoln);
            image(dispObj, frameOverlay);
            
            % Send heartbeat status every 5 seconds
            if toc(lastStatusTime) > 5
                sendStatus(pub_status, sprintf('Streaming - Frames processed: %d', int32(frameCounter)));
                lastStatusTime = tic;
            end
            
            % Control frame rate (adjust as needed)
            pause(0.033);  % ~30 FPS
        else
            % Not running - send idle heartbeat every 5 seconds
            if toc(lastStatusTime) > 5
                sendStatus(pub_status, 'Idle - Waiting for START command');
                lastStatusTime = tic;
            end
            
            % Not running - sleep to reduce CPU usage
            pause(1);
        end
    end


    %% Clean shutdown
    fprintf('\nShutting down cleanly...\n');
    sendStatus(pub_status, 'Shutdown complete');
  
    fprintf('Shutdown complete. Total frames processed: %d\n', int32(frameCounter));
    
    % Exit gracefully - let MATLAB handle cleanup
    return;
end

%% --- Helper: Send Status ---
function sendStatus(pub, txt)
%#codegen
msg = ros2message(pub);
msg.data = char(txt);
send(pub, msg);
fprintf("[STATUS] %s\n", txt);

end
