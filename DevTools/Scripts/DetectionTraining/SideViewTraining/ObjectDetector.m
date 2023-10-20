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

% Train R-CNN object detector for Face, Eyes, and Mouth
faceEyesMouthTrainingData = trainingData(:, {'imageFilename', 'Face', 'Eyes', 'Mouth'});
faceEyesMouthDetector = trainRCNNObjectDetector(faceEyesMouthTrainingData, pretrainedCNN, options, ...
    'NegativeOverlapRange', [0 0.3], 'PositiveOverlapRange', [0.5 1]);

% Train R-CNN object detector for Hand
handTrainingData = trainingData(:, {'imageFilename', 'Hand'});
handDetector = trainRCNNObjectDetector(handTrainingData, pretrainedCNN, options, ...
    'NegativeOverlapRange', [0 0.3], 'PositiveOverlapRange', [0.5 1]);

% ========== Save the Trained Detectors ==========

save('trainedFaceDetector_S103.mat', 'faceEyesMouthDetector');
save('trainedHandDetector_S103.mat', 'handDetector');

disp('Training and evaluation complete!');
