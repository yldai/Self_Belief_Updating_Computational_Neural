%==========================================================================
% EMPIRICAL ANALYSIS: STATIC LEARNING MODEL + MODEL COMPARISON
% AUTHOR / DATE
%   Matthew D. Greaves, University of Melbourne; adapted by Yingliang Dai, 
% University of Melbourne.
%   Last updated: 25/06/2026.
%==========================================================================

% --------------------------- USER INPUTS ---------------------------------
% Provide these cell arrays in your workspace (e.g., loaded from .mat):
%   E1, E2, BR, V  (each S?1 cell; contents are column vectors)

assert(iscell(E1) && iscell(E2) && iscell(BR) && iscell(V), ...
    'E1, E2, BR, V must be S?1 cell arrays.');

S = numel(E1);

% ---------------------- PRIORS FOR THREE MODELS --------------------------
pE_full = log([1/128; 1/128]);   % prior mean
pC_full = diag([1/4,1/4]);      % prior covariance

M = 3;                           % number of models

muPhi    = cell(M,1);
SigmaPhi = cell(M,1);

% M1: full
muPhi{1}    = pE_full;
SigmaPhi{1} = pC_full;

% M2: alpha-only - no bias
muPhi{2}    = pE_full;
SigmaPhi{2} = pC_full;
muPhi{2}(2)      = log(1e-6);
SigmaPhi{2}(2,2) = 1e-6;

% M3: beta-only
muPhi{3}    = pE_full;
SigmaPhi{3} = pC_full;
muPhi{3}(1)      = log(1e-6);
SigmaPhi{3}(1,1) = 1e-6;

% ------------------ INVERSION PER SUBJECT x MODEL ------------------------
posts = cell(S, M);          % posterior structs per subject x model
F     = nan(S, M);           % free energy per subject x model

for s = 1:S
    % Basic shape checks / coercions
    y = E2{s}(:)';
    U = [BR{s}(:)'; E1{s}(:)'; V{s}(:)']; 

    for m = 1:M
        [post, out, ~] = upd_invert(y, U, ...
            'muPhi',    muPhi{m}, ...
            'SigmaPhi', SigmaPhi{m});

        posts{s,m} = post;
        F(s,m)     = out.F;
    end
end

% ------------------ FIXED-EFFECTS BPA (full model only) ------------------
% Use the subject posteriors from the full model (M1) for BPA
posts_full = posts(:,1);              % Sx1 cell, each entry = post for M1
p = upd_ffx_bpa(posts_full, 'Phi');   % BPA in log space

% ------------- Use group moments on the natural scale --------------------
mu_nat = p.muNatPhi;          % [alpha; beta] means in natural space
sd_nat = p.sdNatPhi;          % [alpha; beta] SDs in natural space

% Posterior probability param > 0 (Gaussian approx on natural scale)
pp_alpha_gt0 = 1 - normcdf(0, mu_nat(1), sd_nat(1));
pp_beta_gt0  = 1 - normcdf(0, mu_nat(2), sd_nat(2));

% (Optional) also report 95% Gaussian CIs on natural scale
z = 1.96;
ci_alpha_nat = mu_nat(1) + z*[-1 1]*sd_nat(1);
ci_beta_nat  = mu_nat(2) + z*[-1 1]*sd_nat(2);

% ---------------------- FFX SUMMARY: PRINT TO TERMINAL -------------------
fprintf('=============================================================\n');
fprintf('Static learning model: group-level parameters (full model)\n');
fprintf('-------------------------------------------------------------\n');
fprintf(['Natural scale (group): mean = [a=%.3f, b=%.3f], ',...
         'SD = [%.3f, %.3f]\n'], ...
        mu_nat(1), mu_nat(2), sd_nat(1), sd_nat(2));
fprintf('P(a > 0) = %.3f,  P(b > 0) = %.3f\n', ...
        pp_alpha_gt0, pp_beta_gt0);
fprintf('95%% CI a = [%.3f, %.3f], b = [%.3f, %.3f]\n', ...
        ci_alpha_nat(1), ci_alpha_nat(2), ci_beta_nat(1), ci_beta_nat(2));
fprintf('=============================================================\n');

% -------------------- FIXED-EFFECTS MODEL COMPARISON ---------------------
[~, winModel] = max(F, [], 2);          % Sx1: winning model per subject
win_counts    = accumarray(winModel, 1, [M 1]);
F_group       = sum(F, 1);              % 1xM: sum log-evidence per model

F_shift       = F_group - max(F_group); % numerical stability
model_post_FFX = exp(F_shift) ./ sum(exp(F_shift));

fprintf('Fixed-effects model comparison (by summed free energy)\n');
fprintf('-------------------------------------------------------------\n');
fprintf('Number of subjects: %d\n', S);
fprintf('Models:\n');
fprintf('  1: Full (a, b free)\n');
fprintf('  2: a-only (b shrunk to ~0)\n');
fprintf('  3: b-only (a shrunk to ~0)\n\n');


for m = 1:M
    fprintf(['Model %d (FFX): n_wins = %d, sum F = %.2f,',...
        ' p(model|Y)_FFX ?? %.3f\n'], ...
        m, win_counts(m), F_group(m), model_post_FFX(m));
end
fprintf('-------------------------------------------------------------\n');

% ---------------- RFX BAYESIAN MODEL COMPARISON (VBA_groupBMC) ----------
optionsBMC = struct;
optionsBMC.DisplayWin = 0;       % no GUI by default
optionsBMC.verbose    = 1;
optionsBMC.families   = [];      % no model families here
optionsBMC.figName    = 'Static learning: group BMC';
optionsBMC.modelNames = { ...
    '(\alpha,\beta)', ...   % Model 1: full
    '(\alpha)',       ...   % Model 2: α-only
    '(\beta)'         ...   % Model 3: β-only
    };

[postRFX, outRFX] = VBA_groupBMC(F', optionsBMC);   % F': models x subjects

Ef = outRFX.Ef;        % expected model frequencies (Kx1)
ep = outRFX.ep;        % exceedance probabilities (Kx1)

fprintf('Random-effects model comparison (RFX, VBA_groupBMC)\n');
fprintf('-------------------------------------------------------------\n');
for m = 1:M
    fprintf(['Model %d (RFX): Ef = %.3f, ep = %.3f ', ...
             '(n_wins = %d, sum F = %.2f)\n'], ...
        m, Ef(m), ep(m), win_counts(m), F_group(m));
end
fprintf('-------------------------------------------------------------\n');
fprintf(['Note: Ef = expected model frequency;',...
    ' ep = exceedance probability.\n']);
fprintf('=============================================================\n');
