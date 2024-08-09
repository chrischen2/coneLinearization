%% Light Level Calibration Workflow Example (https://elifesciences.org/reviewed-preprints/93795v2)
% IMPORTANT NOTE: This script is an example of the workflow for 
% and isomerization rate calculation. You will need to modify certain values
% (especially calibration values and file paths) based on your own devices,
% experimental setup, and data. Please review and adjust all parameters
% marked with "ADJUST" comments before running this script with your own data.

% Clear all variables from the workspace and close all figures to ensure a clean start
clearvars; close all;

%% User Input Section
% Define the species to load corresponding photoreceptor spectra
species = 'mouse'; % Can be 'mouse' or 'primate'

% ADJUST: Define the photoreceptor to analyze
photoreceptorName = 'rod'; % e.g., 'rod', 's_cone', 'm_cone', 'l_cone' etc.

% ADJUST: Define the device to analyze
deviceName = 'uv_led'; % e.g., 'uv_led', 'red_led', etc.

% Define parameters related to the collecting area and calibration for light intensity calculation
if strcmp(species, 'mouse')
    if strcmp(photoreceptorName, 'rod')
        collectingArea = 0.5; % Collecting area in um^2 for mouse rods
    else
        collectingArea = 0.2; % Collecting area in um^2 for mouse cones
    end
elseif strcmp(species, 'primate')
    if strcmp(photoreceptorName, 'rod')
        collectingArea = 1.0; % Collecting area in um^2 for primate rods
    else
        collectingArea = 0.37; % Collecting area in um^2 for primate cones
    end
else
    error('Invalid species selected. Choose either "mouse" or "primate".');
end

% NOTE: The following two values are dependent upon the calibration of each individual lab's device.
% ADJUST: They should be modified according to your specific experimental setup.
calibrationValue = 17.77 * 1e-9; % Calibration value in Watts, corresponding to input of 1 volt from an LED.
                                 % This value is specific to the LED and power meter used in your setup.
calibrationDiameter = 500; % Diameter of the calibrated area in micrometers.
                           % This value depends on the size of the light spot used during calibration.

% Display the calibration values for user verification
fprintf('Current calibration settings:\n');
fprintf('Calibration Value: %.2e Watts per volt\n', calibrationValue);
fprintf('Calibration Diameter: %d micrometers\n', calibrationDiameter);
fprintf('Please ensure these values match your lab\'s specific calibration.\n\n');

% Construct the path to the folder containing spectral data files for the specified species
spectrum_path = fullfile(pwd, 'spectrums/sources', species);

% List all text files in the spectrum path
spectrum_files = dir(fullfile(spectrum_path, '*.txt'));

% Loop over each spectrum file found in the directory
for i = 1:length(spectrum_files)
    % Extract the name of the photoreceptor from the file name
    photoreceptorNames{i} = regexprep(spectrum_files(i).name, '_spectrum.txt', '');
    
    % Full path to the current spectrum file
    IndSpectrumPath = fullfile(spectrum_path, spectrum_files(i).name);
    
    % Read the spectrum data from the file
    spectrum = readmatrix(IndSpectrumPath);
    
    % Store the spectral values and wavelengths (converted to meters) in a structured array
    receptor.(photoreceptorNames{i}).values = spectrum(:, 2);
    receptor.(photoreceptorNames{i}).wavelengths = spectrum(:, 1) * (10^-9);
end

% Validate user input for photoreceptor
if ~ismember(photoreceptorName, photoreceptorNames)
    error('Invalid photoreceptor name. Available options are: %s', strjoin(photoreceptorNames, ', '));
end

% Load the Device Spectrum
% Define the path to the folder containing device spectral data
device_path = fullfile(pwd, 'spectrums/devices/');

% List all text files in the device path
device_files = dir(fullfile(device_path, '*.txt'));

% Loop over each device spectrum file found
for i = 1:length(device_files)
    % Extract the base name of the device from the file name
    deviceNames{i} = regexprep(device_files(i).name, '_spectrum.txt', '');
    
    % Full path to the current device spectrum file
    IndDevicePath = fullfile(device_path, device_files(i).name);
    
    % Read the device spectrum data from the file
    deviceSpectrum = readmatrix(IndDevicePath);
    
    % Store the spectral values and wavelengths (converted to meters) in a structured array
    device.(deviceNames{i}).values = deviceSpectrum(:, 2);
    device.(deviceNames{i}).wavelengths = deviceSpectrum(:, 1) * (10^-9);
end


% Validate user input for device
if ~ismember(deviceName, deviceNames)
    error('Invalid device name. Available options are: %s', strjoin(deviceNames, ', '));
end

%% Visualize the Spectrum
% Create a new figure and hold it for multiple plots
figure; hold on;

% Generate distinct colors for plotting photoreceptor and device spectra
photoreceptorColors = lines(length(photoreceptorNames));
deviceColors = lines(length(deviceNames));

% Plot each photoreceptor spectrum with dashed lines on the left y-axis
yyaxis left;
for i = 1:length(photoreceptorNames)
    % Format photoreceptor names for display in legends
    cleanName = strrep(photoreceptorNames{i}, '_', ' ');
    plot(receptor.(photoreceptorNames{i}).wavelengths * 1e9, receptor.(photoreceptorNames{i}).values, 'LineStyle', '--', 'LineWidth', 2, 'Color', photoreceptorColors(i,:));
    photoreceptorLegends{i} = cleanName; % Collect formatted names for legend
end
ylabel('Normalized Photoreceptor Sensitivity');
xlabel('Wavelength (nm)');

% Plot each device spectrum with solid lines on the right y-axis
yyaxis right;
for i = 1:length(deviceNames)
    % Format device names for display in legends
    cleanDeviceName = strrep(deviceNames{i}, '_', ' ');
    plot(device.(deviceNames{i}).wavelengths * 1e9, device.(deviceNames{i}).values, 'LineStyle', '-', 'LineWidth', 2, 'Color', deviceColors(i,:));
    deviceLegends{i} = cleanDeviceName; % Collect formatted names for legend
end
ylabel('Device Spectral Value');

% Combine photoreceptor and device names for the legend and display it
legendNames = [photoreceptorLegends, deviceLegends];
legend(legendNames, 'Location', 'Best');
title('Spectra of Photoreceptors and Devices');

% Stop holding the figure for further plots
hold off;

%% Compute the Isomerization per Watt for the Spectrum Loaded Above
% Calculate light intensity that arrives at the photoreceptor in nW/um^2
lightInt = calibrationValue / (pi * (calibrationDiameter / 2)^2);

% Calculate light power at individual photoreceptor
prLight = lightInt * collectingArea;

% Display the selected device and photoreceptor for isomerization calculation
fprintf('Selected species: %s\n', species);
fprintf('Selected photoreceptor: %s\n', photoreceptorName);
fprintf('Selected device: %s\n', deviceName);
fprintf('Collecting area: %.2f μm^2\n', collectingArea);

% Calculate isomerizations per watt using the calcIsomPerWatt function  
isom = calcIsomPerWatt(device.(deviceName), receptor.(photoreceptorName));

% Adjust isomerization rate by the light power at the photoreceptor
isom = isom * prLight;
fprintf(['The isomerization rate per unit input is %.2f per %s photoreceptor per second from device %s.' ...
    '\n'], isom, photoreceptorLegends{photoreceptorIndex}, deviceLegends{deviceIndex});

