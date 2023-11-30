%load('D:\myCode\CAPSTONE\A3_GroundTruth\Matlab\Side1\Side1_gTruth_objects\Side1_03.mat');

labelData = gTruth.ROILabelData.side2_5;

imageFileNames = cell(height(labelData), 1);

for i = 1:height(labelData)
    imageFileNames{i} = sprintf('%sS205frame_%04d.jpg', outputDir, i);
end

% Initialize empty cell arrays for storing bounding boxes
HandsBB = cell(height(labelData), 1);
EyesBB = cell(height(labelData), 1);
FaceBB = cell(height(labelData), 1);
MouthBB = cell(height(labelData), 1);

% Extract the bounding boxes from labelData
for i = 1:height(labelData)
    HandsBB{i} = labelData.Hand{i};
    EyesBB{i} = labelData.Eyes{i};
    FaceBB{i} = labelData.Face{i};
    MouthBB{i} = labelData.Mouth{i};
end

trainingData = table(imageFileNames, HandsBB, EyesBB, FaceBB, MouthBB, ...
    'VariableNames', {'imageFilename', 'Hand', 'Eyes', 'Face', 'Mouth'});

disp('Training Data Table created!');