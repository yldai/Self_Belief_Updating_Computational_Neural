%% ========================================================================
% This script models update choice, to test whether update choice could be
% explained by the estimation error and the favorability of the trial.
%% ========================================================================

files = dir('./beh_data/*_linearmodel_all.csv');
n_subjects_con = numel(files);

subject_con = cell(n_subjects_con,1);
BR = cell(n_subjects_con,1);
E1 = cell(n_subjects_con,1);
V  = cell(n_subjects_con,1);
E2 = cell(n_subjects_con,1);
N = cell(n_subjects_con,1);
N_bi = cell(n_subjects_con, 1);
EE = cell(n_subjects_con,1);
up_choice = cell(n_subjects_con,1);


% Load all data
for i = 1:n_subjects_con
    
    % Extract subject id from filename
    fn = files(i).name;
    subject_con{i} = n_subjects_con;
    % Read file
    data = readtable(fullfile('./beh_data/', fn));
   
    BR{i} = data.base_rate;
    E1{i} = data.parpre_rate;
    E2{i} = data.slider_score;
    % valence coding: +1 for positive attribute ("p"), -1 otherwise
    valenceStr = string(data.valence);
    Vtmp = ones(size(valenceStr));
    Vtmp(valenceStr ~= "p") = -1;
    V{i} = Vtmp;
    % favorability coding
    N{i} = V{i} .* sign(BR{i}-E1{i});
    N_bi{i} = double(N{i} == 1); 
    % update frequency - update choice
    up_choice{i} = double(E2{i} ~= E1{i});
    % trial-wise absolute EE magnitude
    EE{i} = abs(BR{i} - E1{i});
end

subj_con = [];
E2_con = [];
E1_con = [];
BR_con = [];
V_con = [];
N_con = [];
EE_con = [];
up_choice_con = [];

for s = 1: n_subjects_con
    subj_con = [subj_con; repmat(subject_con(s), 40, 1)];
end

for d = 1:n_subjects_con

    E2_con = [E2_con; E2{d}(:)];
    E1_con = [E1_con; E1{d}(:)];
    BR_con = [BR_con; BR{d}(:)];
    V_con = [V_con; V{d}(:)];
    N_con = [N_con; N_bi{d}(:)];
    EE_con = [EE_con; EE{d}(:)];
    up_choice_con = [up_choice_con; up_choice{d}(:)];
end
subj_con = cell2mat(subj_con);

T = table(EE_con, up_choice_con, N_con, subj_con, BR_con, E1_con, E2_con, ...
    'VariableNames', {'EE', 'Update_choice', 'Favorability','Subject', 'BR', 'E1', 'E2'});
T.Subject = categorical(T.Subject);
T.Favorability = categorical(T.Favorability, ...
    [0 1], {'Unfavorable','Favorable'});
glme = fitglme(T, ...
    'Update_choice ~ 1 + EE + Favorability + EE * Favorability + (1 + Favorability|Subject) + (1 + EE|Subject)');



% =========================================================================
% Visualization
% =========================================================================

refSubj = T.Subject(1);
EE_grid = linspace(min(T.EE), max(T.EE), 100)';

pred_unfav = table(EE_grid, ...
    categorical(repmat("Unfavorable",100,1), {'Unfavorable','Favorable'}), ...
    repmat(refSubj,100,1), ...
    'VariableNames', {'EE','Favorability','Subject'});

pred_fav = table(EE_grid, ...
    categorical(repmat("Favorable",100,1), {'Unfavorable','Favorable'}), ...
    repmat(refSubj,100,1), ...
    'VariableNames', {'EE','Favorability','Subject'});

% Match category levels
pred_unfav.Favorability = categorical(pred_unfav.Favorability, ...
    {'Unfavorable','Favorable'});
pred_fav.Favorability = categorical(pred_fav.Favorability, ...
    {'Unfavorable','Favorable'});

[p_unfav, ci_unfav] = predict(glme, pred_unfav, ...
    'Conditional', false);
[p_fav, ci_fav] = predict(glme, pred_fav, ...
    'Conditional', false);

% Plot
figure; hold on;

plot(EE_grid, p_unfav, 'LineWidth', 2);
plot(EE_grid, p_fav, 'LineWidth', 2);

xlabel('Estimation error magnitude', 'FontSize', 16);
ylabel('Predicted update choice', 'FontSize', 16);
legend({'Unfavorable','Favorable'}, ...
        'Location','northwest', 'FontSize',15);

title('Update choice by estimation error and favorability', 'FontSize', 20, ...
      'FontWeight', 'bold');
ylim([-0.05 1.05]);
box off;