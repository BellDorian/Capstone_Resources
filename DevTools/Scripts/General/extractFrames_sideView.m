% ========== Frame Extraction ==========

videoFile = 'D:\myCode\CAPSTONE\A1_Videos\Side2\Side2_04.mp4';
outputDir = 'D:\myCode\CAPSTONE\A1_Videos\Side2\frames\S205\';

if ~exist(outputDir, 'dir')
    mkdir(outputDir);
end

vidObj = VideoReader(videoFile);

frameNum = 0;
while hasFrame(vidObj)
    frameNum = frameNum + 1;
    frame = readFrame(vidObj);
    
    outputFileName = sprintf('%sS202frame_%04d.jpg', outputDir, frameNum);
    imwrite(frame, outputFileName);
end

disp('Frame extraction complete!');