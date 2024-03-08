% Description:
% This script initiates a full biophysical model for a specified type of photoreceptor.
% It generates the photoreceptor's response to a small, or dim, stimulus.
% This response is then used to fit a linear model of the photoreceptor,
% and to extract the coefficients for the linear model of the photoreceptor.
% The linear models used to generate the target response were obtained by 
% fitting a parameterized linear filter to response of full model to low contrast Gaussian noise
% Script Annotations:

% Choose the model type for the photoreceptor.
modelType = 'peripheralPrimateCone'; % Example model type

% Initialize parameters for the chosen photoreceptor model.
params = initPhotoreceptorParams(modelType);

% Calculate the dark current based on initialized parameters.
params.darkCurrent = params.gdark^params.h * params.k;

% Initialize linear model coefficients for all photoreceptor types.
linearModelCoef = defineLinearModelCoefficients();

% Select coefficients from a nearby light level as a starting point for the fitting process.
% This selection depends on the chosen model type and the specific light level you are working with.
% For example, if working with a 'peripheralPrimateCone' at 5000 R*/photoreceptor/s:
coefLin = linearModelCoef.peripheralPrimateCone(linearModelCoef.peripheralPrimateCone(:,1) == 5000, 2:end);

% Start of the linear model fitting process.
% Clearing global variables to ensure a clean workspace.
clear global TargetStm
clear global TargetResp
clear global DarkCurrent
clear global timeStep

% Declaring necessary global variables for model fitting.
global TargetStm;
global TargetResp;
global DarkCurrent
global timeStep

% Set the dark current and timestep in global variables for use in model fitting.
DarkCurrent = params.darkCurrent;
timeStep = params.timeStep;

% Define mean intensity for the stimulus and smoothing points for the stimulus generation.
meanIntensity = 4000; % Small signal mean intensity
smoothpts = 30; % Points for smoothing the stimulus

% Set the number of points for the stimulus.
numPts = 500000;

% Set random number generator for consistent results.
rng(1);

% Calculate mean photon flux.
MeanPhoFlux = meanIntensity * params.timeStep;

% Generate a smoothed stimulus signal.
TargetStm = filter(gausswin(smoothpts), 1, normrnd(MeanPhoFlux, MeanPhoFlux, 1, numPts)) / sum(gausswin(smoothpts));

% Flag to indicate use of the full biophysical model.
params.biophysFlag = 1;

% Create a time vector for the stimulus.
tme = [1:2*length(TargetStm)] * params.timeStep;

% Set the stimulus in the parameters structure.
params.stm = [TargetStm TargetStm];
params.tme = tme;

% Run the biophysical model with the given parameters.
params = BiophysModel(params);

% Extract the target response from the model's response.
TargetResp = params.response(length(params.stm)/2+1:length(params.stm));
TargetResp = TargetResp - mean(TargetResp);

% Plot the target response.
figure(5); clf
plot(TargetResp);

% Start of the linear model fitting process.
% The following lines search for the best fit linear model coefficients.

% Initialize an error variable for the current coefficients.
err = PhotoreceptorModelLinWrapper(coefLin);


% Initialize global variable to store error values
global errorHistory;
errorHistory = [];

% Set up optimization options with custom output function
options = optimset('MaxFunEvals', 100, 'OutputFcn', @outfun);

for iter = 1:2
    fitcoef = fminsearch(@PhotoreceptorModelLinWrapper, coefLin, options);
    coefLin = fitcoef;
end

% Plot the error history after the optimization
figure;
plot(errorHistory, '-o');
xlabel('Iteration');
ylabel('Error');
title('Error over Iterations in Linear Model Fitting');