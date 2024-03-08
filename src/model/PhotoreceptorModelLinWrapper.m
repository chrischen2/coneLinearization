% PhotoreceptorModelLinWrapper
%
% Purpose:
%   Evaluates the fit of a linear model to the response of a photoreceptor.
%   Used in optimization routines to find the best-fitting linear model parameters.
%
% Input:
%   coef - A vector containing the coefficients of the linear model.
%          coef(1) - Scaling factor
%          coef(2) - Rising time constant
%          coef(3) - Decaying time constant
%
% Global Variables:
%   TargetResp - The target response of the photoreceptor to a stimulus.
%   TargetStm - The stimulus applied to the photoreceptor.
%   DarkCurrent - The dark current value of the photoreceptor.
%   timeStep - The time interval at which measurements are taken.
%
% Output:
%   err - The error of the linear model fit, calculated as the normalized mean squared error.
%
% Visual Output:
%   If the Verbose flag is set to 1, the function plots both the predicted response
%   and the target response for visual comparison.

function err = PhotoreceptorModelLinWrapper(coef)
    % Access global variables with the target response, stimulus, dark current, and timestep.
    global TargetResp
    global TargetStm
    global DarkCurrent
    global timeStep
    
    Verbose = 1; % Flag for verbose output

    % Assign linear model coefficients from the input 'coef'.
    params.ScFact = coef(1); % Scaling factor
    params.TauR = coef(2); % Rising time constant
    params.TauD = coef(3); % Decaying time constant
    
    params.biophysFlag = 0; % Flag for using a linear model
    params.darkCurrent = DarkCurrent; % Set dark current
    
    % Create a time vector for model simulation.
    tme = [1:length(TargetResp)] * timeStep;
    
    % Set the stimulus and time vector in parameters.
    params.stm = TargetStm;
    params.tme = tme;

    params.Dt = timeStep; % Set timestep in parameters
    Resp = TargetResp; % Local copy of target response
    
    % Run the simplified biophysical model.
    params = BiophysModel(params);
    
    % Normalize the model response.
    params.response = params.response - mean(params.response);
    
    % Plot responses if verbose mode is active.
    if (Verbose)
        figure(5); clf; 
        plot(params.response); hold on
        plot(Resp);
    end
    
    % Calculate and return the normalized mean squared error.
    err = mean((params.response - Resp).^2) / mean(Resp.^2);
    
    % Print the error value and pause for a second.
    fprintf(1, '%d\n', err);
    pause(1);
end
