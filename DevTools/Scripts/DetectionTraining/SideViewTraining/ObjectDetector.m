% ========== Splitting the Data into Training and Validation Sets ==========

% Using your dataset named 'trainingData'
rng('default'); % For reproducibility
shuffledData = trainingData(randperm(height(trainingData)),:); % Shuffle the entire dataset
splitRatio = 0.8; % 80% for training, 20% for validation
numTrain = round(splitRatio * height(shuffledData));
trainData = shuffledData(1:numTrain,:);
validationData = shuffledData(numTrain+1:end,:);

% ========== Training the R-CNN Object Detectors ==========

% Specify the pretrained CNN model
pretrainedCNN = 'resnet50';

% Training options
options = trainingOptions('sgdm', ...
    'ExecutionEnvironment', 'gpu', ...
    'MiniBatchSize', 32, ...
    'InitialLearnRate', 1e-3, ...
    'MaxEpochs', 20, ...
    'LearnRateSchedule', 'piecewise', ...
    'LearnRateDropPeriod', 5, ...
    'LearnRateDropFactor', 0.1, ...
    'Shuffle', 'every-epoch', ...
    'Momentum', 0.9, ...
    'GradientThresholdMethod', 'l2norm', ...
    'GradientThreshold', 1, ...
    'L2Regularization', 0.0001, ...
    'CheckpointPath', 'D:\myCode\CAPSTONE\DevTools\Scripts\DetectionTraining\SideViewTraining\checkpoint\S101', ...
    'Verbose', true);

% Train R-CNN object detector for Face, Eyes, and Mouth
faceEyesMouthTrainingData = trainData(:, {'imageFilename', 'Face', 'Eyes', 'Mouth'});
faceEyesMouthDetector = trainRCNNObjectDetector(faceEyesMouthTrainingData, pretrainedCNN, options, ...
    'NegativeOverlapRange', [0 0.3], 'PositiveOverlapRange', [0.5 1]);

% Train R-CNN object detector for Hand
handTrainingData = trainData(:, {'imageFilename', 'Hand'});
handDetector = trainRCNNObjectDetector(handTrainingData, pretrainedCNN, options, ...
    'NegativeOverlapRange', [0 0.3], 'PositiveOverlapRange', [0.5 1]);

% ========== Save the Trained Detectors ==========

save('trainedFaceDetector_S101.mat', 'faceEyesMouthDetector');
save('trainedHandDetector_S101.mat', 'handDetector');

% ========== IoU Evaluation ==========

% Detect objects in the validation set for Face, Eyes, and Mouth
detectionResultsFaceEyesMouth = detect(faceEyesMouthDetector, validationData.imageFilename);
iouFace = bboxOverlapRatio(detectionResultsFaceEyesMouth, validationData.Face);
meanIoUFace = mean(diag(iouFace));

% Detect objects in the validation set for Hand
detectionResultsHand = detect(handDetector, validationData.imageFilename);
iouHand = bboxOverlapRatio(detectionResultsHand, validationData.Hand);
meanIoUHand = mean(diag(iouHand));

disp(['Average IoU for Face, Eyes, and Mouth: ', num2str(meanIoUFace)]);
disp(['Average IoU for Hand: ', num2str(meanIoUHand)]);

% ========== End ==========

disp('Training, validation, and evaluation complete!');


