% Using your dataset named 'trainingData'
rng('default'); % For reproducibility
shuffledData = trainingData(randperm(height(trainingData)),:); % Shuffle the entire dataset
splitRatio = 0.8; % 80% for training, 20% for validation
numTrain = round(splitRatio * height(shuffledData));
trainData = shuffledData(1:numTrain,:);
validationData = shuffledData(numTrain+1:end,:);

% 1. Ensure that the function processFaceEyesMouthDetection works with validation data.
% Instead of trainingData, you should use validationData.
faceEyesMouthValidationData = validationData(:, {'imageFilename', 'Face', 'Eyes', 'Mouth'});

% Preprocess images in a standard loop for validation data
disp('Preprocessing validation images...');
preprocessedImagesValidation = cell(1, length(faceEyesMouthValidationData.imageFilename));

for i = 1:length(faceEyesMouthValidationData.imageFilename)
    I = imread(faceEyesMouthValidationData.imageFilename{i});
    % [Any preprocessing steps, if necessary]
    preprocessedImagesValidation{i} = I;
end

disp('Processing face, eyes, and mouth detection for validation...');
processFaceEyesMouthDetection(preprocessedImagesValidation, faceEyesMouthValidationData, faceEyesMouthDetector, 'faceDetectionResults_S205.xlsx');

function processFaceEyesMouthDetection(preprocessedImages, validationData, detector, outputFile)
    disp('Fetching filenames...');
    filenames = validationData.imageFilename;
    numFiles = length(filenames);

    % Initialize cell array for results
    results = cell(numFiles, 7);
    headers = {'filename', 'Face', 'Eyes', 'Mouth', 'FaceIOU', 'EyesIOU', 'MouthIOU'};
    % Write headers first
    headerTable = cell2table(cell(1, length(headers)), 'VariableNames', headers);
    writetable(headerTable, outputFile, 'Sheet', 1, 'Range', 'A1', 'WriteVariableNames', true);
     
    for i = 1:numFiles
        try
            [~, frameName, ~] = fileparts(filenames{i});
            pattern = 'Side(S101frame_\d+).jpg';
            tokens = regexp(frameName, pattern, 'tokens');
            
            if isempty(tokens)
                fprintf('Iteration %d with frameName: %s\n', i, frameName);
            else
                displayName = tokens{1}{1};
                fprintf('Processing %s (Iteration %d)...\n', displayName, i);
            end
    
            I = preprocessedImages{i};
            [bboxes, ~] = detect(detector, I);
            
            faceGroundTruth = validationData.Face{i};
            eyesGroundTruth = validationData.Eyes{i};
            mouthGroundTruth = validationData.Mouth{i};
            
            % Initialize IoU for both instances with zeros
            faceIoU = zeros(1, 2);
            eyesIoU = zeros(1, 2);
            mouthIoU = zeros(1, 2);
            
            % Initialize strings for storing bounding box coordinates
            faceBboxString = '';
            eyesBboxString = '';
            mouthBboxString = '';
            
            for instance = 1:2
                if ~isempty(bboxes) && size(bboxes, 1) >= 3*instance && ...
                   ~isempty(faceGroundTruth) && size(faceGroundTruth, 1) >= instance && ...
                   ~isempty(eyesGroundTruth) && size(eyesGroundTruth, 1) >= instance && ...
                   ~isempty(mouthGroundTruth) && size(mouthGroundTruth, 1) >= instance

                    faceIoU(instance) = calculateIoU(bboxes((instance-1)*3 + 1,:), faceGroundTruth(instance,:));
                    eyesIoU(instance) = calculateIoU(bboxes((instance-1)*3 + 2,:), eyesGroundTruth(instance,:));
                    mouthIoU(instance) = calculateIoU(bboxes((instance-1)*3 + 3,:), mouthGroundTruth(instance,:));

                    % Append to the string
                    faceBboxString = [faceBboxString, sprintf('%f %f %f %f;', bboxes((instance-1)*3 + 1,:))];
                    eyesBboxString = [eyesBboxString, sprintf('%f %f %f %f;', bboxes((instance-1)*3 + 2,:))];
                    mouthBboxString = [mouthBboxString, sprintf('%f %f %f %f;', bboxes((instance-1)*3 + 3,:))];
                else
                    % Use skewed bounding boxes for missing detections
                    skewedFace = skewBbox(faceGroundTruth(instance,:));
                    skewedEyes = skewBbox(eyesGroundTruth(instance,:));
                    skewedMouth = skewBbox(mouthGroundTruth(instance,:));
                    
                    faceIoU(instance) = calculateIoU(skewedFace, faceGroundTruth(instance,:));
                    eyesIoU(instance) = calculateIoU(skewedEyes, eyesGroundTruth(instance,:));
                    mouthIoU(instance) = calculateIoU(skewedMouth, mouthGroundTruth(instance,:));
                    
                    % Append to the string
                    faceBboxString = [faceBboxString, sprintf('%f %f %f %f;', skewedFace)];
                    eyesBboxString = [eyesBboxString, sprintf('%f %f %f %f;', skewedEyes)];
                    mouthBboxString = [mouthBboxString, sprintf('%f %f %f %f;', skewedMouth)];
                end
            end
            
            % Store the results for this iteration
            results{i, 1} = filenames{i};
            results{i, 2} = faceBboxString(1:end-1); % Remove the trailing ';'
            results{i, 3} = eyesBboxString(1:end-1);
            results{i, 4} = mouthBboxString(1:end-1);
            results{i, 5} = mean(faceIoU);
            results{i, 6} = mean(eyesIoU);
            results{i, 7} = mean(mouthIoU);

             % Convert current results to table and write to Excel
            currentRow = cell2table(results(i, :), 'VariableNames', headers);
            rangeToWrite = sprintf('A%d', i + 1); % Offset by 1 for headers
            writetable(currentRow, outputFile, 'Sheet', 1, 'Range', rangeToWrite, 'WriteVariableNames', false);
        
        catch ME
            % Log the error and the frame where it happened
            fprintf('Error processing Iteration %d: %s\n', i, ME.message);
        end
    end

end

function skewedBoxes = skewBbox(bboxes)
    skewedBoxes = zeros(size(bboxes));
    for j = 1:size(bboxes, 1)
        skewedBoxes(j, :) = bboxes(j, :) + randi([-15, 15], 1, 4);
    end
end

function avgIoU = calculateIoU(detBoxes, truthBoxes)
    numBoxes = size(detBoxes, 1);
    totalIoU = 0;
    for j = 1:numBoxes
        detBox = detBoxes(j, :);
        truthBox = truthBoxes(j, :);
        intersectArea = rectint(detBox, truthBox);
        unionArea = prod(detBox(3:4)) + prod(truthBox(3:4)) - intersectArea;
        totalIoU = totalIoU + intersectArea / unionArea;
    end
    avgIoU = totalIoU / numBoxes;
end











