% Load the trained detectors
% Uncomment the following lines after ensuring the detector variables are correctly named
% load('trainedFaceDetector_S101.mat', 'faceEyesMouthDetector');
% load('trainedHandDetector_S101.mat', 'handDetector');

% Set up and ensure the output directory exists
outputDir = 'D:\myCode\CAPSTONE\A1_Videos\Topside\frames\T05\';
if ~exist(outputDir, 'dir')
    mkdir(outputDir);
end

% Initialize Excel files for each detection
handDetectionFile = 'HandDetections_V305.xlsx';

% Prepare headers for Excel files
headers = {'Frame#', 'PosX', 'PosY', 'TopLeftX', 'TopLeftY', 'Width', 'Height'};

% Create Excel files and write headers
writecell(headers, handDetectionFile, 'Sheet', 1, 'Range', 'A1');

% Define the number of expected detections for each object
numExpectedHandDetections = 8; % Updated to 8 for topside hands


% Process each frame in the trainingData
for frameNum = 1:height(topsideTrainingData)
    frameData = topsideTrainingData(frameNum, :);
    frame = imread(frameData.imageFilename{1});
    outputFileName = sprintf('%sframe_%04d.jpg', outputDir, frameNum);
    imwrite(frame, outputFileName);

    disp(frameNum);

    % Detect objects using the trained detectors
    [bboxesHand, ~, ~] = detect(handDetector, frame);

    % Write detections to Excel files
    writeDetections(handDetectionFile, frameNum, bboxesHand, numExpectedHandDetections, headers);
end

disp('Frame extraction and detection export complete.');

% ========== Helper Function ==========

function writeDetections(file, frameNum, bboxes, numExpectedDetections, headers)
    % Read the existing data to find the next empty row
    existingData = readcell(file, 'Sheet', 1);
    nextRow = size(existingData, 1) + 1; % Next row is one more than the current size

    % Prepare detection data for writing
    detectionData = cell(numExpectedDetections, length(headers));
    for i = 1:size(bboxes, 1)
        bbox = bboxes(i, :);
        detectionData{i, 1} = frameNum;
        detectionData{i, 2} = bbox(1) + bbox(3)/2; % PosX
        detectionData{i, 3} = bbox(2) + bbox(4)/2; % PosY
        detectionData{i, 4} = bbox(1); % TopLeftX
        detectionData{i, 5} = bbox(2); % TopLeftY
        detectionData{i, 6} = bbox(3); % Width
        detectionData{i, 7} = bbox(4); % Height
    end

    % Fill in the rest of the rows if there were less detections than expected
    for i = size(bboxes, 1) + 1:numExpectedDetections
        detectionData{i, 1} = frameNum;
        for j = 2:length(headers)
            detectionData{i, j} = '[]'; % Writing empty detection for unfound hands
        end
    end

    % Write detection data to Excel file
    writeRange = sprintf('A%d', nextRow);
    writecell(detectionData, file, 'Sheet', 1, 'Range', writeRange);
end