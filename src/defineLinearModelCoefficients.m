function linearModelCoef = defineLinearModelCoefficients()
    % Define linear model coefficients for different light levels and photoreceptor types.
    % This function provides coefficients of a linear model fit to the responses
    % of the full model of each photoreceptor type to low contrast stimuli at discrete light levels.
    % Light levels are specified in R*/photoreceptor/s (R* denotes isomerizations of photopigments)
    % For cones, light levels are set at 1250, 2500, 5000, 10000, and 20000 R*/cone/s.
    % For rods, light levels are set at 1, 3, 10, and 30 R*/rod/s.
    % Users can add more light levels for specific types if needed.
    % The detailed fitting procedure is described in a separate script named 'fitLinearPRModel.m'.


    % The output structure linearModelCoef for each photoreceptor type contains arrays with four columns:
    %  - The first column represents the light level.
    %  - The second column is the Scaling factor.
    %  - The third column is the Rising time constant.
    %  - The fourth column is the Decaying time constant.

    % Peripheral primate cone
    linearModelCoef.peripheralPrimateCone = [
        1250, [12.6177, 0.0273, 0.0123]; 
        2500, [4.0624, 0.0196, 0.0153];
        5000, [1.6550, 0.0152, 0.0181];
        10000, [0.6963, 0.0121, 0.0210];
        20000, [0.3065, 0.0106, 0.0236]
    ];

    % Primate rod
    linearModelCoef.primateRod = [
        1, [14.7078, 0.2170, 0.2702];
        3, [11.5524, 0.1945, 0.2374];
        10, [5.2782, 0.1412, 0.2085];
        30, [1.6408, 0.0904, 0.2102]
    ];

    % Mouse cone
    linearModelCoef.mouseCone = [
        1250, [0.5836, 0.0304, 0.0452];
        2500, [0.2795, 0.0276, 0.0481];
        5000, [0.1312, 0.0267, 0.0503];
        10000, [0.0621, 0.0277, 0.0525];
        20000, [0.0308, 0.0316, 0.0567]
    ];

    % Mouse rod
    linearModelCoef.mouseRod = [
        1, [15.6556, 0.2164, 0.2918];
        3, [11.3591, 0.1842, 0.2185];
        10, [3.6669, 0.1152, 0.1848];
        30, [0.9139, 0.0671, 0.1944]
    ];
end
