clear;
% Set the ROS_DOMAIN_ID to the appropriate value (e.g., 0)
setenv('ROS_DOMAIN_ID', '0');

% Create a ROS 2 node with the correct domain ID
ros2node = ros2node("/matlab_subscriber", 0); % Use a numeric domain ID

% Create a subscriber for the specified topic
sub = ros2subscriber(ros2node, "/camera/image_gray", "sensor_msgs/Image");

% Continuously receive and display images
figure;
while true
    try
        msg = receive(sub, 15); % Wait up to 5 seconds for a message

        % Convert ROS Image to MATLAB image
        img = rosReadImage(msg);
        frame = rot90(img, -1); % Rotate the image
        imshow(frame);
        title("Grayscale Image from Jetson");
        drawnow;

    catch ME
        % Handle specific exceptions for graceful termination
        if strcmp(ME.identifier, 'MATLAB:class:InvalidHandle') || ...
           strcmp(ME.identifier, 'ros:transport:ConnectionClosed') || ...
           strcmp(ME.identifier, 'ROS:transport:ConnectionClosed') || ...
           contains(ME.message, 'interrupted by user')
            disp("Terminating subscriber...");
            break; % Exit the loop on connection issues or user interruption
        else
            disp("Error occurred: " + ME.message);
            % Optionally, you can decide to break or continue based on the error
             break; % Uncomment to terminate on other errors
        end
    end
end

% Clean up
clear sub;
clear ros2node;


