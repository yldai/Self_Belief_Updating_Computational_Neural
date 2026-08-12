% Detect all subjects in ./data/
files = dir('./beh_data/*_linearmodel_all.csv');
n_subjects = numel(files);

subject = cell(n_subjects,1);
BR = cell(n_subjects,1);
E1 = cell(n_subjects,1);
V  = cell(n_subjects,1);
E2 = cell(n_subjects,1);
V_par = cell(n_subjects,1);
V_sub = cell(n_subjects,1);
W = cell(n_subjects,1);
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
    W{i} = string(data.word);
    % valence coding: +1 for positive attribute ("p"), -1 otherwise
    valenceStr = string(data.valence);
    Vtmp = ones(size(valenceStr));
    Vtmp(valenceStr ~= "p") = -1;
    V{i} = Vtmp;
    % valence coding based on participant own valence rating: +1 for positive attribute
    %(rated 4 or 5), -1 for negative attribute (rated 1 or 2), 0 for neutral attribute (rated 3).
    np_str = string(data.np);
    V_sub{i} = str2double(np_str);
    V_par{i} = nan(size(V_sub{i}));
    V_par{i}(V_sub{i} <= 2) = -1;
    V_par{i}(V_sub{i} == 3) = 0;
    V_par{i}(V_sub{i} >= 4) = 1;
    idx_nan = isnan(V_sub{i});
    V_par{i}(idx_nan) = Vtmp(idx_nan);
end

% Summary stats for entire experiment (i.e., Totals)
T_updated           = [];       % How many trials were actually updated
T_favourable_h1     = [];       % When other's better ("favourable")
T_unfavourable_h1   = [];       % When other's worse  ("unfavourable")
T_upd_paradoxated           = []; % Paradoxical trials

% Summary stats for subjects
updated_subs            = nan(n_subjects, 1);  % How many trials updated
favourable_h1_subs      = nan(n_subjects, 1);  % When other's better
unfavourable_h1_subs    = nan(n_subjects, 1);  % When other's worse


% Update magnitudes
unfav_upd_mag   = nan(n_subjects, 1);
fav_upd_mag     = nan(n_subjects, 1);
upd_paradoxated_subs_paradox  = nan(n_subjects, 1); % Paradoxical trials

for i = 1:n_subjects

    % Grand (and subject-level) updates
    upd             = E1{i}~=E2{i};
    updated_subs(i) = sum(upd);
    T_updated       = [T_updated; upd]; %#ok

    % Obtain absolute updates and estimation error
    y = [abs(E2{i}-E1{i}), abs(BR{i}-E1{i})];
    
    % When other's better: are subjects' minimizing error (i.e., providing 
    % self-enhancing updates)?
    x                       =   [V{i}.*sign(E1{i}-BR{i}) == -1,...
                             (E2{i} ~= E1{i}) & (sign(BR{i}-E1{i}) == sign(E2{i}-E1{i}))];

    % Obtain favourable update magnitude
    unfav_upd_mag(i)         =   sum(y(x(:,1) & x(:,2),1))/sum(y(x(:,1),2));
    favourable_h1_subs(i)    =   sum(x(x(:, 1),2))/numel(x(x(:, 1),2));
    T_favourable_h1          =   [T_favourable_h1; x(x(:, 1),2)]; %#ok


    % When other's worse: are subjects' minimizing error (i.e., providing 
    % self-diminshing updates)?
    x                       =   [V{i}.*sign(E1{i}-BR{i}) == 1,...
                            (E2{i} ~= E1{i}) & (sign(BR{i}-E1{i}) == sign(E2{i}-E1{i}))];

    % Obtain unfavourable update magnitude
    fav_upd_mag(i)         =   sum(y(x(:,1) & x(:,2),1))/sum(y(x(:,1),2));
    unfavourable_h1_subs(i)  =   sum(x(x(:, 1),2))/numel(x(x(:, 1),2));
    T_unfavourable_h1        =   [T_unfavourable_h1; x(x(:, 1),2)]; %#ok
    
    upd_paradox             = E1{i}~=E2{i} & sign(BR{i}-E1{i}) ~= sign(E2{i}-E1{i});
    upd_paradoxated_subs_paradox(i) = sum(upd_paradox);
    T_upd_paradoxated       = [T_upd_paradoxated; upd_paradox]; %#ok

end

% Compute simple ratios (reduce to nearest integer ratio)
r           = numel(T_favourable_h1) / numel(T_unfavourable_h1);
pc_diff     = (1-r)*100;
fprintf(...
'%.2f%% fewer favourable (compared to unfavourable) trails.\n\n',...
    pc_diff);

% Updates
fprintf(['On averge, %.2f%% ¡À %.2f%% of initial estimates were',...
    ' updated:\n'], mean(updated_subs./40)*100, std(updated_subs./40)*100)
fprintf('%.2f%% ¡À %.2f%% of responses on favourable trials;\n',...
    mean(favourable_h1_subs)*100,...
    std(favourable_h1_subs)*100);
fprintf('%.2f%% ¡À %.2f%% of responses on unfavourable trials.\n',...
    mean(unfavourable_h1_subs)*100,...
    std(unfavourable_h1_subs)*100);

% Paired t-test
[~, p, ~, stats] = ttest(favourable_h1_subs, unfavourable_h1_subs);

% Print statistical test
fprintf(['A paired t-test comparing this update behaviour ',...
    'shows t(%d) = %.2f, p = %.3f.\n\n'], ...
         stats.df, stats.tstat, p);
     
% Paired t-test
[~, p, ~, stats] = ttest(unfav_upd_mag, fav_upd_mag);

% Print statistical test
fprintf(['A paired t-test comparing favourable and unfavourable update',...
    ' magnitudes shows t(%d) = %.2f, p = %.3f.\n'], ...
         stats.df, stats.tstat, p);
     

% Compare update magnitudes
unfav_upd_mag = unfav_upd_mag(~isnan(unfav_upd_mag));
fav_upd_mag = fav_upd_mag(~isnan(fav_upd_mag));

m_unfav = mean(unfav_upd_mag);
sd_unfav = std(unfav_upd_mag);

m_fav = mean(fav_upd_mag);
sd_fav = std(fav_upd_mag);

% Print descriptive results (rounded to 2 decimals)
fprintf(['For favourable trials, the mean update',...
    ' magnitude was %.2f ¡À %.2f,\n'], m_unfav, sd_unfav);
fprintf(['For unfavourable trials, the mean update ',...
    'magnitude was %.2f ¡À %.2f.\n'], m_fav, sd_fav);

 % Paradoxical trials    
fprintf(['On averge, %.2f%% ¡À %.2f%% of initial estimates were',...
    ' paradoxically updated.\n'], mean(upd_paradoxated_subs_paradox./40)*100, std(upd_paradoxated_subs_paradox./40)*100);


