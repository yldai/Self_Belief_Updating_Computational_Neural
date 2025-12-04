%% Parametric Empirical Bayes (PEB), Model 2

% This script reproduces the model 2 effective connectivity results
% reported in the Dai et al. manuscript (Figure 4, Supplementary table 3).

% -----------------------------------------------------------------------
% Please ensure that your SPM12 folder (r7771) is listed in your MATLAB set
% path. These results were obtained using Matlab R2023a. Values may
% slightly differ from the manuscript depending on OS and Matlab version.
% -----------------------------------------------------------------------

% This section runs a PEB model quantifying the between-subject commonality
% in connectivity parameters across the sample. The design matrix included
% an intercept term (single column of ones) denoting the overall mean
% connectivity.
clear

% Load GCM
load('/data/projects/punim1864/yingliang/spartan_scripts/DCM_scripts/specify/est_infer/GCM_controls_bg.mat');

% PEB specification (load prepared design matrix)
load('M_Control_mean.mat');
X = dm.X;
K = width(X);
X(:,2:K)=X(:,2:K)-mean(X(:,2:K));
X_labels = dm.labels;

M = struct();
M.Q = 'fields';
M.X = X;
M.Xnames = X_labels;

% PEB model estimation (select DCM parameters to take to 2nd level)
[PEB, RCM] = spm_dcm_peb(DCM, M, {'A','B'});
save('/data/projects/punim1864/yingliang/spartan_scripts/DCM_scripts/specify/est_infer/PEB_AB_bg.mat', 'PEB', 'RCM');

% PEB model comparison (automatic search over reduced PEB models)
BMA = spm_dcm_peb_bmc(PEB);
save('/data/projects/punim1864/yingliang/spartan_scripts/DCM_scripts/specify/est_infer/BMA_search_AB_bg.mat', 'BMA');

% Review BMA
spm_dcm_peb_review(BMA, DCM);
