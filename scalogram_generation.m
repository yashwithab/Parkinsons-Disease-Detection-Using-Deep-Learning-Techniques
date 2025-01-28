% MATLAB Script to Generate Scalograms for Multiple CSV Files

% Input folder containing the CSV files
inputFolder = '/MATLAB Drive/Project/Parkinsons_Disease'; % Replace with your input folder path

% Output folder to save the scalogram images
outputFolder = '/MATLAB Drive/Project/PD_Left Scalograms'; % Replace with your output folder path

% Ensure the output folder exists
if ~exist(outputFolder, 'dir')
    mkdir(outputFolder);
end

% Get a list of all CSV files in the input folder
csvFiles = dir(fullfile(inputFolder, '*.csv'));

% Define the sampling frequency
fs = 100; % Sampling frequency in Hz

% Process each CSV file
for k = 1:length(csvFiles)
    % Get the full path of the current CSV file
    inputFilePath = fullfile(inputFolder, csvFiles(k).name);

    % Read data from the CSV file
    data = readmatrix(inputFilePath);

    % Extract time and signal data
    time = data(:, 1);         % First column (time in seconds)
    signal = data(:, 18);      % 19th column (signal)

    % Remove outliers using median filter
    windowSize = 5;  % Size of the window for median filtering
    filteredSignal = medfilt1(signal, windowSize);

    % Generate the continuous wavelet transform (CWT)
    [cwtCoeffs, frequencies] = cwt(filteredSignal, 'amor', fs);

    % Filter frequencies within the range of 0.032 Hz to 32 Hz
    validFreqs = (frequencies >= 0.032) & (frequencies <= 32); 
    filteredCoeffs = cwtCoeffs(validFreqs, :);
    filteredFrequencies = frequencies(validFreqs);

    % Time vector for the scalogram (convert to minutes)
    timeVector = (0:length(signal)-1) / fs / 60;

    % Plot the scalogram
    figure('Position', [100, 100, 1600, 800]); % Adjust the width and height of the figure
    imagesc(timeVector, filteredFrequencies, abs(filteredCoeffs));
    axis xy;
    colormap(jet);

    % Customize the plot
    colorbar;
    title('Magnitude Scalogram', 'FontSize', 14);
    xlabel('Time (minutes)', 'FontSize', 12);
    ylabel('Frequency (Hz)', 'FontSize', 12);
    set(gca, 'YScale', 'log'); % Logarithmic scale for frequency
    set(gca, 'FontSize', 12); % Improve axis label readability

    % Save the figure as an image in the output folder
    [~, fileName, ~] = fileparts(csvFiles(k).name); % Extract file name without extension
    outputFilePath = fullfile(outputFolder, [fileName, '_scalogram.png']);
    saveas(gcf, outputFilePath);

    % Close the figure
    close(gcf);
end

disp('Scalograms have been saved to the output folder.');
