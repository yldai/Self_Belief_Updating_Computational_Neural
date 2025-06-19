%% Random effect Bayesian model comparison across full and reduced models
% Please make sure that VBA-toolbox-master has been added to the MATLAB path.

% VBA toolbox downloaded from https://mbb-team.github.io/VBA-toolbox/download/.

% Having inverted full and reduced models to each participant and collated
% log model evidences in the 'F_values_matrix.mat', run this procedure to
% derive model attribution for each participant, expected model
% frequencies and protected exceedance probabilities. 

% load log evidences
load('F_values_matrix.mat');

% perform random effect Bayesian model comparison 
L=F_values_matrix;
[posterior,out]=VBA_groupBMC(L, struct());

% save outputs
save('BMC_posteriors.mat','posterior','out');