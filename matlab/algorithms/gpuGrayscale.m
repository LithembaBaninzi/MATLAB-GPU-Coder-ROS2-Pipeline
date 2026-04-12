function out = gpuGrayscale(in)
%#codegen
% GPU-Coder-compatible grayscale conversion
% Converts RGB uint8 image to grayscale using CUDA arithmetic

% Convert to single for accurate weighted sum
grayFrame = 0.2989 * single(in(:,:,1)) + ...    % R
            0.5870 * single(in(:,:,2)) + ...    % G
            0.1140 * single(in(:,:,3));         % B

out = uint8(grayFrame);

% Compute a simple numeric summary
checksum = sum(out(:), 'native');
fprintf('Checksum: %u\n', checksum);
end
