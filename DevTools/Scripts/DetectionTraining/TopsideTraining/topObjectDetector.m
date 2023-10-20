% ========== Training the R-CNN Object Detectors ==========

% Specify the pretrained CNN model
pretrainedCNN = 'resnet50';

% Define training options with GPU usage
options = trainingOptions('sgdm', ...
    'ExecutionEnvironment', 'gpu', ...
    'MiniBatchSize', 64, ...
    'InitialLearnRate', 1e-3, ...
    'MaxEpochs', 2, ...
    'Verbose', true);

% Train R-CNN object detector for Hand
handDetector = trainRCNNObjectDetector(topsideTrainingData, pretrainedCNN, options, ...
    'NegativeOverlapRange', [0 0.3], 'PositiveOverlapRange', [0.5 1]);

% ========== Save the Trained Detectors ==========

saveDir = 'D:\myCode\CAPSTONE\TrainingData\Topside\MAT';
if ~exist(saveDir, 'dir')
    mkdir(saveDir);
end

savePath = fullfile(saveDir, 'trainedTopSideHandDetectorT105.mat');
save(savePath, 'handDetector');


disp('Training complete!');