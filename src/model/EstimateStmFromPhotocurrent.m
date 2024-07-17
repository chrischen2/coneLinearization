function results = EstimateStmFromPhotocurrent(params)
% The EstimateStmFromPhotocurrent function inverts the photoreceptor model to
% estimate the stimulus that would cause a given photoreceptor output. This is
% achieved by using the impulse responses and model parameters to
% reverse-engineer the stimulus from the photoreceptor current response.

% Output Structure Description:
%  - estimate: The final estimated stimulus after corrections and smoothing
%  - resid: Residual error between the original and estimated stimulus
%  - corr: Correlation coefficient between the estimated and original stimulus
%  - rSquared: R-squared value indicating the variance in the original stimulus explained by the estimated stimulus
%  - rawEstimate: Initial raw estimated stimulus before any adjustments
%  - rawRSquared: R-squared value calculated using the raw estimated stimulus


numPts = length(params.CombinedStim);
params.tme = [1:numPts]*params.timeStep;

% stm-opsin filter (impulse response from Eq. 1, Fig 1)
opsinFilter = params.gamma * exp(-params.tme * params.sigma);

% opsin-PDE filter (impulse response from Eq. 2, Fig. 1)
pdeFilter =  exp(-params.tme * params.phi);

% model parameters constrained by steady state conditions for Eqs. 5
% and 6
cur2Ca = params.beta * params.cdark / params.darkCurrent;                % get q using steady state
cyclaseMax = (params.eta/params.phi) * params.gdark * (1 + (params.cdark / params.kGC)^params.m);		% get smax using steady state

currentResponse = params.CombinedResponse;
origStim = params.CombinedStim;

% generate cGMP and Ca from current
params.TargetcGMP = (-currentResponse / params.k).^(1/params.n);
calciumFilter = params.timeStep * exp(-params.tme * params.beta);

params.TargetCalcium = -cur2Ca * real(ifft(fft(currentResponse) .* (fft(calciumFilter))));

% calculate PDE from cGMP and Ca
cyclaseRate = cyclaseMax ./ (1 + (params.TargetCalcium / params.kGC).^params.m);

% calculate PDE from Eq. 3
gDeriv = diff(params.TargetcGMP) / params.timeStep;
gDeriv = [gDeriv gDeriv(length(gDeriv))];  % make correct length (diff removes one point)

params.PDE = (cyclaseRate - gDeriv) ./ params.TargetcGMP;
params.PDE = params.PDE - params.eta / params.phi;

% calculate stimulus by inverting Eqs 1 and 2
estimatedStimulus = real(ifft(fft(params.PDE) ./ (fft(opsinFilter) .* fft(pdeFilter))));
estimatedStimulus = estimatedStimulus / params.timeStep;

results.rawRSquared = 1 - mean((estimatedStimulus(length(origStim)/10:length(origStim)) - origStim(length(origStim)/10:length(origStim))).^2) / mean((origStim(length(origStim)/10:length(origStim)) - mean(origStim(length(origStim)/10:length(origStim)))).^2);

if (params.matchMean)
    results.rawEstimate = estimatedStimulus - mean(estimatedStimulus) + mean(origStim);
else
    results.rawEstimate = estimatedStimulus;
end

if (params.matchPower)
    stmps = real(fft(origStim) .* conj(fft(origStim)));
    estps = real(fft(estimatedStimulus) .* conj(fft(estimatedStimulus)));
    weights = sqrt(stmps ./ estps) * params.timeStep;
    correctedEstimate = real(ifft(fft(estimatedStimulus) .* weights));
else
    correctedEstimate = estimatedStimulus;
end

% smooth if specified
correctedEstimate = filter(gausswin(params.smoothPts), 1, correctedEstimate/params.timeStep)/sum(gausswin(params.smoothPts));
origStim = filter(gausswin(params.smoothPts), 1, origStim)/sum(gausswin(params.smoothPts));

xc = corrcoef(correctedEstimate, origStim);

% returned parameters
results.estimate = correctedEstimate;
results.resid = origStim - correctedEstimate;
results.corr = xc(1, 2);
results.rSquared = 1 - mean((correctedEstimate - origStim).^2) / mean((origStim - mean(origStim)).^2);

end
