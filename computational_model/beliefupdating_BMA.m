%% Model inversion using real experimental data
% Please make sure that VBA-toolbox-master has been added to the MATLAB path.

% VBA toolbox downloaded from https://mbb-team.github.io/VBA-toolbox/download/.

% Biased self belief updating model specified towards the end of script.

% After iteratively inverting the model to each participant, posterior distributions and log evidences (i.e. free energy approximation) 
% for all participants were combined into two data structures for the BMA procedures.

%Specify participant files 
subject_ids = {'303','304','305','312','313','314','316','317','319','321','322','323','328','330','331','332','334','339','341','342','343','345','346','347','348','349','351','352','355','358','359','360','363','364','366','368','372','374','375','377','379','381','382','385','388','403','409','416'};
n = numel(subject_ids);
posteriors = cell(n, 1);
Fs = zeros(n, 1);

for s = 1:n
    subj = subject_ids{s};
    filename = ['/Users/yingliangdai/Desktop/behavioral_results/controls/' subj '_linearmodel_all.csv'];

  %Define input variables 
    data = readtable(filename);
    N = 40;
    BR = data.base_rate; 
    E1 = data.parpre_rate; 
    valenceStr = string(data.valence); 
    V = ones(size(valenceStr)); 
    V(valenceStr ~= "p") = -1; 
    inputs = [E1, BR, V]';
    y = data.slider_score';

    % Define priors
    options.priors.muPhi = [1; 0];
    options.priors.SigmaPhi = diag([0.1, 0.1]); 
    dim.n_phi = 2;
    dim.u = 3;
    dim.p = 1;

    % Call function
    [posterior, out] = VBA_NLStateSpaceModel(y, inputs, [], @generative_model, dim, options);

% Combine posteriors  
    posteriors{s} = posterior;
    Fs(s) = out.F;
end

% Perform Bayesian model averaging
p_BMA = VBA_BMA(posteriors, Fs);
posterior0.muPhi=p_BMA.muPhi;
posterior0.SigmaPhi=p_BMA.SigmaPhi;
posterior0.muTheta=p_BMA.muTheta;
posterior0.SigmaTheta=p_BMA.SigmaTheta;
posterior0.muX0=p_BMA.muX0;
posterior0.SigmaX0=p_BMA.SigmaX0;

% Define group priors
out0.prior.muPhi=[1; 0];
out0.prior.SigmaPhi=diag([0.1, 0.1]); 

% Infer posterior probability of group parameter estimates
[PP]=VBA_PP0(posterior,out);

% Save outputs if needed
save('/Users/yingliangdai/Desktop/behavioral_results/R_behav_codes/VBA_scripts/VBA_posterior_BMA.mat', 'p_BMA','PP');

%% Self belief updating generative model
function [gx] = generative_model(~, theta, inputs, ~)
    BR=inputs(1,:);
    E1=inputs(2,:);
    V=inputs(3,:);
    % Define sign_EE here
    % ---------------------------------------------------------------
    sign_EE=(BR - E1) ./ abs(BR - E1);
    % ---------------------------------------------------------------
    % Define conditions here
    % Favorable or unfavorable casted by sign of EE and word valence V
    % ----------------------------------------------------------------
    News = sign_EE .* V;
    % ----------------------------------------------------------------
    % define learning rate here
    % ----------------------------------------------------------------
    % LRfavorable = a + b,
    % LRunfavorable = a - b
    LR = theta(1) + News .* theta(2);
    % ----------------------------------------------------------------
    % Define E2 here
    % ----------------------------------------------------------------
    E2 = E1 + LR .* (BR - E1); 
    E2(isnan(E2)) = E1(isnan(E2)); % Address the nan by the end
    % Define output here
    % ----------------------------------------------------------------
    gx = E2;
end


