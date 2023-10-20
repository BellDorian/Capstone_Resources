% Load the gTruth object
load('side1_03_new.mat', 'gTruth');

% Define the old (current) and new (alternative) paths
currentPath = 'C:\Users\MsDor\OneDrive\Documents\MATLAB\side1_3.mp4';
alternativePath = 'D:\myCode\CAPSTONE\Videos\side1\side1_3.mp4';

% Create a cell array with the current and alternative paths
pathPairs = {currentPath, alternativePath};

% Use changeFilePaths to update the paths in gTruth
unresolvedPaths = changeFilePaths(gTruth, pathPairs);

% If unresolvedPaths is empty, then the paths were successfully updated
if isempty(unresolvedPaths)
    % Save the updated gTruth object back to the MAT file
    save('side1_03_new.mat', 'gTruth', '-append');
    disp('File path updated successfully.');
else
    disp('Some paths could not be updated. Check unresolvedPaths for details.');
end


