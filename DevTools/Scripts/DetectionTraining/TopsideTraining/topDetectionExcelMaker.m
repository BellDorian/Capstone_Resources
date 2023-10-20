% Split data into training and validation sets
disp('Gathering Hand detection data for topside views');
splitRatio = 0.8;  % Assuming 80% of data is for training and 20% for validation
topsideNumImages = height(topsideTrainingData);
topsideSplitIdx = randperm(topsideNumImages, round(splitRatio * topsideNumImages));
topsideTrainingDataSplit = topsideTrainingData(topsideSplitIdx, :);
topsideValidationDataSplit = topsideTrainingData(setdiff(1:end, topsideSplitIdx), :);

topsideDetectionResults = table();
imageFilesTopside = topsideValidationDataSplit.imageFilename;
numImagesTopside = numel(imageFilesTopside);
bboxesTopside = cell(numImagesTopside, 1);
scoresTopside = cell(numImagesTopside, 1);
for i = 1:numImagesTopside
    [bboxesTopside{i}, scoresTopside{i}] = detect(handDetector, imread(imageFilesTopside{i}));
end
topsideDetectionResults.imageFilename = imageFilesTopside;
topsideDetectionResults.Hand = bboxesTopside;
topsideDetectionResults.HandScore = scoresTopside;

numImages = numel(topsideDetectionResults.imageFilename);

disp('data gathering complete for topside views!');

% Convert bounding boxes and scores to strings for Excel export
bboxStr = cell(numImages, 1);
scoreStr = cell(numImages, 1);

for i = 1:numImages
    bboxStr{i} = mat2str(topsideDetectionResults.Hand{i});
    scoreStr{i} = mat2str(topsideDetectionResults.HandScore{i});
end

% Convert to table
T = table(topsideDetectionResults.imageFilename, bboxStr, scoreStr, ...
    'VariableNames', {'Filename', 'BoundingBox', 'ConfidenceScore'});

% Save to Excel
excelPath = 'topsideHandDetectionResults.xlsx';
writetable(T, excelPath);

disp(['Excel file created and stored at ' excelPath '.']);
