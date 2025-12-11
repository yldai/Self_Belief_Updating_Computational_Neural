% Detect all subjects in ./data/
files = dir('./beh_data/*_linearmodel_all.csv');
n_subjects = numel(files);

subject = cell(n_subjects,1);
BR = cell(n_subjects,1);
E1 = cell(n_subjects,1);
V  = cell(n_subjects,1);
E2 = cell(n_subjects,1);

% Load all data
for i = 1:n_subjects

    % Extract subject id from filename
    fn = files(i).name;
    subject{i} = extractBefore(fn, '_');

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
end

% Total number of trials
total_fav = nan(n_subjects,1);
total_unfav = nan(n_subjects,1);

% Number of updated trials
updated_fav = nan(n_subjects,1);
updated_unfav = nan(n_subjects,1);

% Average trial-wise estimation error magnitude
EEt_fav= nan(n_subjects,1);
EEt_unfav= nan(n_subjects,1);

% Total estimation error magnitude
EET_fav = nan(n_subjects,1);
EET_unfav = nan(n_subjects,1);

for i = 1:n_subjects
    BRi = BR{i};
    E1i = E1{i};
    E2i = E2{i};
    Vi  = V{i};
  
    % Definition of favorability
    fav_trials = (Vi .* sign(E1i - BRi)) == -1;
    unfav_trials = (Vi .* sign(E1i - BRi)) == 1;
    
    % Total number of trials (per subject)
    total_fav(i) = sum(fav_trials);
    total_unfav(i) = sum(unfav_trials);
    
    % Updated trials
    update = E1i ~= E2i;

    % Number of updated trials (per subject)
    updated_fav(i) = sum(update & fav_trials);
    updated_unfav(i) = sum(update & unfav_trials);
    
    % Calculate trial-wise estimation error magnitude
    EE = abs(BRi - E1i);

    % Average trial-wise estimation error magnitude 
    EEt_fav(i) = mean(EE(fav_trials));
    EEt_unfav(i) = mean(EE(unfav_trials));
    
    % Total estimation error magnitude
    EET_fav(i) = sum(EE(fav_trials));
    EET_unfav(i) = sum(EE(unfav_trials));

end

% Total number of trials (M ¡À SD) and paired t-test
fprintf('Total favorable trials: %.2f ¡À %.2f\n', ...
    mean(total_fav), std(total_fav));
fprintf('Total unfavorable trials: %.2f ¡À %.2f\n', ...
    mean(total_unfav), std(total_unfav));
[~, p, ~, stats] = ttest(total_fav, total_unfav);
fprintf('Total trials: t(%d) = %.2f, p = %.4f\n', ...
    stats.df, stats.tstat, p);

% Number of updated trials (M ¡À SD) and paired t-test
fprintf('Updated favorable trials: %.2f ¡À %.2f\n', ...
    mean(updated_fav), std(updated_fav));
fprintf('Updated unfavorable trials: %.2f ¡À %.2f\n', ...
    mean(updated_unfav), std(updated_unfav));
[~, p, ~, stats] = ttest(updated_fav, updated_unfav);
fprintf('Updated trials: t(%d) = %.2f, p = %.4f\n', ...
    stats.df, stats.tstat, p);

% Average trial-wise estimation error magnitudes (M ¡À SD) and paired t-test
fprintf('Average trial-wise EE favorable: %.2f ¡À %.2f\n', ...
    mean(EEt_fav), std(EEt_fav));
fprintf('Average trial-wise EE unfavorable: %.2f ¡À %.2f\n', ...
    mean(EEt_unfav), std(EEt_unfav));
[~, p, ~, stats] = ttest(EEt_fav, EEt_unfav);
fprintf('Mean EE magnitude:   t(%d) = %.2f, p = %.4f\n', ...
    stats.df, stats.tstat, p);

% Total estimation error magnitudes (M ¡À SD) and paired t-test
fprintf('Total EE favorable: %.2f ¡À %.2f\n', ...
    mean(EET_fav), std(EET_fav));
fprintf('Total EE unfavorable: %.2f ¡À %.2f\n', ...
    mean(EET_unfav), std(EET_unfav));
[~, p, ~, stats] = ttest(EET_fav, EET_unfav);
fprintf('Total EE magnitude:  t(%d) = %.2f, p = %.4f\n', ...
    stats.df, stats.tstat, p);

