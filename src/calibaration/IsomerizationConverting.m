% main
clearvars; close all;

%load the source spectrum
species='mouse';   % or primate
spectrum_path=fullfile(pwd, 'spectrums/sources', species);
spectrum_files=dir(fullfile(spectrum_path,'*.txt'));

for i=1:length(spectrum_files)
    % Full path to the spectrum .txt file
    photoreceptorNames{i}=regexprep(spectrum_files(i).name,'_spectrum.txt','');
    IndSpectrumPath = fullfile(spectrum_path, spectrum_files(i).name);
    spectrum = readmatrix(IndSpectrumPath);
    receptor.(photoreceptorNames{i}).values= spectrum(:,2);
    receptor.(photoreceptorNames{i}).wavelengths= spectrum(:,1)*(10^-9);
end

% load the device spectrum
device_path=fullfile(pwd, 'spectrums/devices/');
device_files=dir(fullfile(device_path,'*.txt'));
for i=1:length(device_files)
    deviceNames{i}=regexprep(device_files(i).name,'_spectrum.txt','');
    IndDevicePath = fullfile(device_path, device_files(i).name);
    deviceSpectrum = readmatrix(IndDevicePath);
    device.(deviceNames{i}).values= deviceSpectrum(:,2);
    device.(deviceNames{i}).wavelengths= deviceSpectrum(:,1)*(10^-9);
end

%% visualize the spectrum
% Assuming the 'receptor' and 'device' structures are populated with spectra data
% as described in the provided code  
figure;  hold on;
% Generate a colormap for distinct line colors
photoreceptorColors = lines(length(photoreceptorNames));
deviceColors = lines(length(deviceNames));

% Plot photoreceptor spectra on the left y-axis with dashed lines
yyaxis left;
for i = 1:length(photoreceptorNames)
    % Replace "_" with " " for proper naming in legends
    cleanName = strrep(photoreceptorNames{i}, '_', ' ');
    plot(receptor.(photoreceptorNames{i}).wavelengths * 1e9, receptor.(photoreceptorNames{i}).values, 'LineStyle', '--', 'LineWidth', 2, 'Color', photoreceptorColors(i,:));
    photoreceptorLegends{i} = cleanName; % Collect names for legend
end
ylabel('Normalized Photoreceptor Sensitivity');
xlabel('Wavelength (nm)');

% Plot device spectra on the right y-axis with solid lines
yyaxis right;
for i = 1:length(deviceNames)
    % Replace "_" with " " for proper naming in legends
    cleanDeviceName = strrep(deviceNames{i}, '_', ' ');
    plot(device.(deviceNames{i}).wavelengths * 1e9, device.(deviceNames{i}).values, 'LineStyle', '-', 'LineWidth', 2, 'Color', deviceColors(i,:));
    deviceLegends{i} = cleanDeviceName; % Collect names for legend
end
ylabel('Device Spectral Value');

% Combine photoreceptor and device names for the legend
legendNames = [photoreceptorLegends, deviceLegends];
legend(legendNames, 'Location', 'Best');
title('Spectra of Photoreceptors and Devices');
hold off;


%% compute the isomerization per watts for the spectrum loaded above
% collecting area: l/m/s cones in primate  0.37, stimuli from below or 0.6
% stimulate from above, that is 1 and 1 for rods
% in mouse, collecting area is 0.2 for M/S cones from below, and 1 from
% above.  for rod, that value is 0.5 and 0.87 respectively.
deviceIndex=3; 
photoreceptorIndex=2;
collectingArea= 0.37;  % um^2 
calibrationValue=17.77; % in nW
calibrationDiameter=500;  % in uM
% compute the light intensity (arrives at the photoreceptor)
lightInt=calibrationValue/(pi*(calibrationDiameter/2)^2);  % nW/um^2
% light power at individual photoreceptor 
prLight=lightInt*collectingArea; 
fprintf('%s\n', ['device ' deviceLegends{deviceIndex}  ' ' 'photoreceptor ', ' ' photoreceptorLegends{photoreceptorIndex}]);
isom = calcIsomPerWatt(device.(deviceNames{deviceIndex}), receptor.(photoreceptorNames{photoreceptorIndex})); 


