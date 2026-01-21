function out = gpuInvert(in)
%#codegen
% GPU-Coder-compatible image inversion
% Works for uint8 grayscale or RGB images

% Convert input to single for CUDA arithmetic
inSingle = single(in);

% Invert pixel values: 255 - pixel
invFrame = 255 - inSingle;

% Convert back to uint8
out = uint8(invFrame);

% Compute a simple numeric summary
checksum = sum(out(:), 'native');
fprintf('Checksum: %u\n', checksum);

end
