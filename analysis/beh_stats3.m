% Detect all subjects in ./data/
files = dir('./beh_data/*_linearmodel_all.csv');
n_subjects = numel(files);
subject = cell(n_subjects,1);
V  = cell(n_subjects,1);
np = cell(n_subjects,1);

% Load all data
for i = 1:n_subjects

    % Extract subject id from filename
    fn = files(i).name;
    subject{i} = extractBefore(fn, '_');

    % Read file
    data = readtable(fullfile('./data/', fn));

    % Convert cell array to string in case of NA
    np_str = string(data.np);

    % Eliminate NA
    real_np = np_str ~= "NA";
    data = data(real_np, :);

    % Make sure np are doubles
    np_clean = str2double(np_str(real_np));  

    % Build np cell array
    np{i} = np_clean;  
  
    % valence coding: +1 for positive attribute ("p"), -1 otherwise
    valenceStr = string(data.valence);
    Vtmp = ones(size(valenceStr));
    Vtmp(valenceStr ~= "p") = -1;
    V{i} = Vtmp;  

end

% Valence rating
np_positive = nan(n_subjects,1);
np_negative = nan(n_subjects,1);

for i = 1:n_subjects
    npi = np{i};
     Vi  = V{i};
  
    % Defining attribute valence
    positive = Vi == 1;
    negative = Vi == -1;
    
    % Average attribute valence rating 
    np_positive(i)=mean(npi(positive));
    np_negative(i)=mean(npi(negative));
end

% show average valence rating (M ¡À SD) and paired t-test
fprintf('The average valence rating for positive attribute: %.2f ¡À %.2f\n', ...
    mean(np_positive), std(np_positive));
fprintf('The average valence rating for positive attributes: %.2f ¡À %.2f\n', ...
    mean(np_negative), std(np_negative));
[~, p, ~, stats] = ttest(np_positive, np_negative);
fprintf('Total trials: t(%d) = %.2f, p = %.4f\n', ...
    stats.df, stats.tstat, p);