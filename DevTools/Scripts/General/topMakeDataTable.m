% ========== Creating Training Data Table ==========

load('Topside_05.mat', 'gTruth');

labelData = gTruth.ROILabelData.topside_5;

imageFileNames = cell(height(labelData), 1);

for i = 1:height(labelData)
    imageFileNames{i} = sprintf('%sT105frame_%04d.jpg', outputDir, i);
end

% Since the Hand bounding boxes are stored as cell arrays of 8x4 matrices, 
% we need to retrieve them for each image and store them in the training data.
handBboxes = cell(height(labelData), 1);
for i = 1:height(labelData)
    handBboxes{i} = double(labelData.Hand{i});
end

topsideTrainingData = table(imageFileNames, handBboxes, ...
    'VariableNames', {'imageFilename', 'Hand'});

disp('Training Data Table Created');