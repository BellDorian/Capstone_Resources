%Segment A: Frames 1 - 400
%Segment B: Frames 401 - 800
%Segment C: Frames 801 - last image

aStart = 1;
aEnd = 400;
bStart = 401;
bEnd = 800;

%Make sure your last frame of data is 1043 like mine is
%Otherwise, alter the cEnd value accordingly
cStart = 801;
cEnd = 1050;

%Update these values to decide which segment is being generated
startFrame = aStart;
endFrame = aEnd;

%Make sure the time between your frames is 0.03336 like mine is
%Otherwise, alter accordingly. (Round to 5th decimal place)
timeBetweenFrames = 0.03336;
i = startFrame - 1;

%This is just an intermediate variable to shorten the name
time = timeBetweenFrames;

%*** SET THIS variable equal to whatever your hand data array is called
handDataCellArray = Hand2;

for frame = startFrame:1:endFrame
    
    time = i * 0.03336;
    disp("Frame #" + frame);
    fprintf("%.4E", time)
    i = i + 1;

    celldisp(handDataCellArray(frame))

end
