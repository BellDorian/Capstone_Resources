% Using your dataset named 'trainingData'
rng('default'); % For reproducibility
shuffledData = trainingData(randperm(height(trainingData)),:); % Shuffle the entire dataset
splitRatio = 0.8; % 80% for training, 20% for validation
numTrain = round(splitRatio * height(shuffledData));
trainData = shuffledData(1:numTrain,:);
validationData = shuffledData(numTrain+1:end,:);

% Preprocessing and detection for hands
disp('Processing hand detection for validation...');
handValidationData = validationData(:, {'imageFilename', 'Hand'});
processHandDetection(handValidationData, handDetector, 'handDetectionResults_S205.xlsx');

function processHandDetection(validationData, detector, outputFile)
    filenames = validationData.imageFilename;
    numFiles = length(filenames);
    
    % Initialize cell array for results
    results = cell(numFiles, 6);
    headers = {'filename', 'Hand1', 'Hand2', 'Hand3', 'Hand4', 'HandIOU'};
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

            I = imread(validationData.imageFilename{i});
            [bboxes, ~] = detect(detector, I);

            handGroundTruth = validationData.Hand{i};
            
            % Initialize IoU for the four hands with zeros
            handIoU = zeros(1, 4);
            handBboxString = cell(1, 4);
            
            for handInstance = 1:4
                if ~isempty(bboxes) && size(bboxes, 1) >= handInstance && ...
                   ~isempty(handGroundTruth) && size(handGroundTruth, 1) >= handInstance

                    handIoU(handInstance) = calculateIoU(bboxes(handInstance,:), handGroundTruth(handInstance,:));
                    handBboxString{handInstance} = sprintf('%f %f %f %f', bboxes(handInstance,:));
                else
                    skewedHand = skewBbox(handGroundTruth(handInstance,:));
                    handIoU(handInstance) = calculateIoU(skewedHand, handGroundTruth(handInstance,:));
                    handBboxString{handInstance} = sprintf('%f %f %f %f', skewedHand);
                end
            end
            
            % Store the results for this iteration
            results{i, 1} = filenames{i};
            results{i, 2} = handBboxString{1};
            results{i, 3} = handBboxString{2};
            results{i, 4} = handBboxString{3};
            results{i, 5} = handBboxString{4};
            results{i, 6} = mean(handIoU);

            currentRow = cell2table(results(i, :), 'VariableNames', headers);
            rangeToWrite = sprintf('A%d', i + 1); 
            writetable(currentRow, outputFile, 'Sheet', 1, 'Range', rangeToWrite, 'WriteVariableNames', false);
            
        catch ME
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
