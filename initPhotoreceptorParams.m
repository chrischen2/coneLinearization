function params = initPhotoreceptorParams(modelType)
% Initialize parameters for different photoreceptor models.

% Default values (could be adjusted based on needs)
params.sigma = 22;  % receptor activity decay rate (1/sec)
params.phi = 22;     % phosphodiesterase activity decay rate (1/sec)
params.eta = 2000;	  % phosphodiesterase activation rate constant (1/sec)
params.gdark = 35; % concentration of cGMP in darkness
params.k = 0.01;     % constant relating cGMP to current
params.h = 3;       % cooperativity for cGMP->current
params.cdark = 1;  % dark calcium concentration
params.beta = 9;	  % rate constant for calcium removal in 1/sec
params.hillcoef = 4;  	  % cooperativity for cyclase, hill coef
params.hillaffinity = 0.5;   % hill affinity for cyclase
params.gamma = 10; % so stimulus can be in R*/sec (this is rate of increase in opsin activity per R*/sec)
params.timeStep = 1e-4;

switch modelType
    case 'peripheralPrimateCone'
        params.sigma = 22;  % receptor activity decay rate (1/sec)
        params.phi = 22;     % phosphodiesterase activity decay rate (1/sec)
        params.eta = 2000;	  % phosphodiesterase activation rate constant (1/sec)
        params.gdark = 35; % concentration of cGMP in darkness
        params.k = 0.01;     % constant relating cGMP to current
        params.h = 3;       % cooperativity for cGMP->current
        params.cdark = 1;  % dark calcium concentration
        params.beta = 9;	  % rate constant for calcium removal in 1/sec
        params.hillcoef = 4;  	  % cooperativity for cyclase, hill coef
        params.hillaffinity = 0.5;   % hill affinity for cyclase
        params.gamma = 10; % so stimulus can be in R*/sec (this is rate of increase in opsin activity per R*/sec)
    case 'primateRod'
        params.sigma = 7.07;    % rhodopsin activity decay rate (1/sec)
        params.phi = 7.07;      % phosphodiesterase activity decay rate (1/sec)
        params.eta = 2.53;      % phosphodiesterase activation rate constant (1/sec)
        params.gdark = 15.5;    % concentration of cGMP in darkness
        params.k = 0.01;        % constant relating cGMP to current
        params.h = 3;           % cooperativity for cGMP->current
        params.cdark = 1;       % dark calcium concentration
        params.beta = 25 ;      % rate constant for calcium removal in 1/sec
        params.hillcoef = 4;        % cooperativity for cyclase, hill coef
        params.hillaffinity = 0.5;  % affinity for Ca2+
        params.gamma = 4.2;     % so stimulus can be in R*/sec (this is rate of increase in opsin activity per R*/sec)
    case 'mouseCone'
        params.sigma = 9.74; % receptor activity decay rate (1/sec)
        params.phi = 9.74;  % phosphodiesterase activity decay rate (1/sec)
        params.eta = 761;  % phosphodiesterase activation rate constant (1/sec)
        params.gdark = 20; % concentration of cGMP in darkness
        params.k = 0.01;     % constant relating cGMP to current
        params.h = 3;       % cooperativity for cGMP->current
        params.cdark = 1;  % dark calcium concentration
        params.beta = 2.64;  % rate constant for calcium removal in 1/sec
        params.hillcoef = 4;  	  % cooperativity for cyclase, hill coef
        params.hillaffinity = 0.4;  % hill affinity for cyclase
        params.gamma = 10; % so stimulus can be in R*/sec (this is rate of increase in opsin activity per R*/sec)
    case 'mouseRod'
        params.sigma = 7.66;  % rhodopsin activity decay rate (1/sec)
        params.phi = 7.66;     % phosphodiesterase activity decay rate (1/sec)
        params.eta = 1.62;	  % phosphodiesterase activation rate constant (1/sec)
        params.gdark = 13.4; % concentration of cGMP in darkness
        params.k = 0.01;     % constant relating cGMP to current
        params.h = 3;       % cooperativity for cGMP->current
        params.cdark = 1;  % dark calcium concentration
        params.beta = 25 ;	  % rate constant for calcium removal in 1/sec
        params.hillcoef = 4;  	  % cooperativity for cyclase, hill coef
        params.hillaffinity = 0.40;		% affinity for Ca2+
        params.gamma = 8; % so stimulus can be in R*/sec (this is rate of increase in opsin activity per R*/sec)
end

params.darkCurrent = params.gdark^params.h * params.k;
end
