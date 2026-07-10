%% ========================================================================
% Correlation between age and update magnitude (estimation error corrected)
%% ========================================================================
n_subjects_con = numel(files);
subject_con = cell(n_subjects_con,1);
E1 = cell(n_subjects_con,1);
BR = cell(n_subjects_con,1);
V  = cell(n_subjects_con,1);
E2 = cell(n_subjects_con,1);
UP = nan(n_subjects_con,1);

% Load all data
for i = 1:n_subjects_con
    
    % Extract subject id from filename
    fn = files(i).name;
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
    % update magnitude (EE corrected)
    EE = abs(BR{i} - E1{i});
    UPmag = abs(E2{i} - E1{i});
    valid = EE > 0;
    UP(i) = mean(UPmag(valid) ./ EE(valid));
end

load('data_demo_all_con.mat');
age_all = data_demo_all_con.demo_age;

[R,P] = corrcoef(age_all,UP);
r = R(1,2);
p = P(1,2);
fprintf('The correlation between age and update magnitude was r = %.3f, p = %.3f.\n', ...
        r, p);