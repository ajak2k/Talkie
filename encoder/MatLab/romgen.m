% Talkie library
% Copyright 2011 Peter Knight
% This code is released under GPLv2 license.
%
% Convert model parameter mapping into bitstream for ROM

binData = fopen ('binData.txt', 'w');

frames = csvread('TomsDinerStream.csv');
lastFrame = [-1,0,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1]; % Jumk frame

repeatThreshold = 4;

silentFrames = 0;
repeatFrames = 0;
unvoicedFrames = 0;
voicedFrames = 0;

numFrames = size(frames);

 

for f = 1:numFrames

    frame = frames(f,:);
    % Is this a silent frame?
    if frame(1) < 1
        % Emit a silent frame
        bitEmit(0,4,binData);
        silentFrames = silentFrames + 1;
        lastFrame = [0,0,0,0,0,0,0,0,0,0,0,0,0];
    else
        bitEmit(frame(1),4,binData);
        coefficientDelta = sum(abs(frame(4:13)-lastFrame(4:13)));
        if coefficientDelta <= repeatThreshold
            % Emit a repeat frame
            bitEmit(1,1,binData);
            bitEmit(frame(3),6,binData);
            repeatFrames = repeatFrames + 1;
            lastFrame(1) = frame(1);
            lastFrame(3) = frame(3);
        else
            bitEmit(0,1,binData);
            bitEmit(frame(3),6,binData);
            bitEmit(frame(4),5,binData);
            bitEmit(frame(5),5,binData);
            bitEmit(frame(6),4,binData);
            bitEmit(frame(7),4,binData);
            if frame(3) < 1
                % Emit an unvoiced frame
                unvoicedFrames = unvoicedFrames + 1;
                lastFrame = frame;
            else
                % Emit a voiced frame
                bitEmit(frame(8),4,binData);
                bitEmit(frame(9),4,binData);
                bitEmit(frame(10),4,binData);
                bitEmit(frame(11),3,binData);
                bitEmit(frame(12),3,binData);
                bitEmit(frame(13),3,binData);

                voicedFrames = voicedFrames + 1;
                lastFrame = frame;
            end
        end
    end
end

% Emit a stop frame
bitEmit(15,4,binData);
fclose(binData);
fprintf('\nFrames:\n%d V, %d U, %d R, %d S\n',voicedFrames,unvoicedFrames,repeatFrames,silentFrames);
romSize = 50*voicedFrames + 29*unvoicedFrames + 11*repeatFrames + 4*silentFrames;
fprintf('Rom size %d bits\n',romSize);

% Output from this needs to be grouped into groups of 8 bits.
% LSB of byte is the first bit to be decoded.
% Then needs to be packaged up as a C snippet for inclusion in the libary.