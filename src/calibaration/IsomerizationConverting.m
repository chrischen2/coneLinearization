% Clear all variables from the workspace and close all figures to ensure a clean start
clearvars; close all;

%% Load the Source Spectrum
% Define the species to load corresponding photoreceptor spectra, can be 'mouse' or 'primate'
species = 'mouse';

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
% Define parameters related to the collecting area and calibration for light intensity calculation
collectingArea = 0.37; % Collecting area in um^2, example value for l/m/s cones in primates
calibrationValue = 17.77 * 1e-9; % Calibration value in Watts, corresponding to input of 1 volt from an LED
calibrationDiameter = 500; % Diameter of the calibrated area in micrometers
deviceIndex=1;
photoreceptorIndex=3;
% Calculate light intensity that arrives at the photoreceptor in nW/um^2
lightInt = calibrationValue / (pi * (calibrationDiameter / 2)^2);

% Calculate light power at individual photoreceptor
prLight = lightInt * collectingArea;

% Display the selected device and photoreceptor for isomerization calculation
fprintf('%s\n', ['device ' deviceLegends{deviceIndex} ' ' 'photoreceptor ', ' ' photoreceptorLegends{photoreceptorIndex}]);

% Calculate isomerizations per watt using the calcIsomPerWatt function  
isom = calcIsomPerWatt(device.(deviceNames{deviceIndex}), receptor.(photoreceptorNames{photoreceptorIndex}));

% Adjust isomerization rate by the light power at the photoreceptor
isom = isom * prLight;
fprintf(['The isomerization rate per unit input is %.2f per %s photoreceptor per second from device %s.' ...
    '\n'], isom, photoreceptorLegends{photoreceptorIndex}, deviceLegends{deviceIndex});

