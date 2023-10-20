% ========== Frame Extraction ==========
%must be ran first for crating training data table

%specify where the video is located and where to store the frames
videoFile = 'D:\myCode\CAPSTONE\Videos\topside\topside_5.mp4';
outputDir = 'D:\myCode\CAPSTONE\Videos\topside\frames\T105\';

if ~exist(outputDir, 'dir')
    mkdir(outputDir);
end

vidObj = VideoReader(videoFile);

frameNum = 0;
while hasFrame(vidObj)
    frameNum = frameNum + 1;
    frame = readFrame(vidObj);
    
    outputFileName = sprintf('%sT105frame_%04d.jpg', outputDir, frameNum);
    imwrite(frame, outputFileName);
end

disp('Frame extraction complete!');