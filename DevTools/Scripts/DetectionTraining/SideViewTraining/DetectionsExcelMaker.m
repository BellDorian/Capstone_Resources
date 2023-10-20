% Split the data for Face, Eyes, and Mouth
disp('Gathering Face, Eyes, Mouth detection data');
splitRatio = 0.8;
faceNumImages = height(faceEyesMouthTrainingData);
faceSplitIdx = randperm(faceNumImages, round(splitRatio * faceNumImages));

faceTrainingDataSplit = faceEyesMouthTrainingData(faceSplitIdx, :);
faceValidationDataSplit = faceEyesMouthTrainingData(setdiff(1:end, faceSplitIdx), :); % Corrected indexing

% Detect faces using the trained detector
faceDetectionResults = table();
imageFiles = faceValidationDataSplit.imageFilename;
numImages = numel(imageFiles);
bboxes = cell(numImages, 1);
scores = cell(numImages, 1);
for i = 1:numImages
    [bboxes{i}, scores{i}] = detect(faceEyesMouthDetector, imread(imageFiles{i}));
end
faceDetectionResults.imageFilename = imageFiles;
faceDetectionResults.Face = bboxes;
faceDetectionResults.FaceScore = scores;

numImages = numel(faceDetectionResults.imageFilename);

disp('data gathering complete!');

% Convert bounding boxes and scores to strings for Excel export
bboxStr = cell(numImages, 1);
scoreStr = cell(numImages, 1);

for i = 1:numImages
    bboxStr{i} = mat2str(faceDetectionResults.Face{i});
    scoreStr{i} = mat2str(faceDetectionResults.FaceScore{i});
end

% Convert to table
T = table(faceDetectionResults.imageFilename, bboxStr, scoreStr, ...
    'VariableNames', {'Filename', 'BoundingBox', 'ConfidenceScore'});

writetable(T, 'faceDetectionResults_S103.xlsx');

disp('Excel file created and stored with faceDetector results.');



% Similarly, detect hands and evaluate the handDetector using the same method
% --- Hand Detection & Evaluation ---
disp('Gathering Hand detection data');
handNumImages = height(handTrainingData);
handSplitIdx = randperm(handNumImages, round(splitRatio * handNumImages));
handTrainingDataSplit = handTrainingData(handSplitIdx, :);
handValidationDataSplit = handTrainingData(setdiff(1:end, handSplitIdx), :);

handDetectionResults = table();
imageFilesHand = handValidationDataSplit.imageFilename;
numImagesHand = numel(imageFilesHand);
bboxesHand = cell(numImagesHand, 1);
scoresHand = cell(numImagesHand, 1);
for i = 1:numImagesHand
    [bboxesHand{i}, scoresHand{i}] = detect(handDetector, imread(imageFilesHand{i}));
end
handDetectionResults.imageFilename = imageFilesHand;
handDetectionResults.Hand = bboxesHand;
handDetectionResults.HandScore = scoresHand;

numImages = numel(handDetectionResults.imageFilename);

disp('data gathering complete!');

% Convert bounding boxes and scores to strings for Excel export
bboxStr = cell(numImages, 1);
scoreStr = cell(numImages, 1);

for i = 1:numImages
    bboxStr{i} = mat2str(handDetectionResults.Hand{i});
    scoreStr{i} = mat2str(handDetectionResults.HandScore{i});
end

% Convert to table
T = table(handDetectionResults.imageFilename, bboxStr, scoreStr, ...
    'VariableNames', {'Filename', 'BoundingBox', 'ConfidenceScore'});

writetable(T, 'handDetectionResults_S103.xlsx');

disp('Excel file created and stored with faceDetector results.');


