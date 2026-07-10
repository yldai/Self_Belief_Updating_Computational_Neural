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
T_favourable_h1_reverse     = [];       % When other's better ("favourable")
T_unfavourable_h1_reverse   = [];       % When other's worse  ("unfavourable")
% Summary stats for subjects
updated_subs            = nan(n_subjects, 1);  % How many trials updated
favourable_h1_subs      = nan(n_subjects, 1);  % When other's better
unfavourable_h1_subs    = nan(n_subjects, 1);  % When other's worse
favourable_h1_subs_reverse      = nan(n_subjects, 1);  % When other's better
unfavourable_h1_subs_reverse    = nan(n_subjects, 1);  % When other's worse


% Update magnitudes
unfav_upd_mag   = nan(n_subjects, 1);
fav_upd_mag     = nan(n_subjects, 1);
unfav_upd_mag_reverse   = nan(n_subjects, 1);
fav_upd_mag_reverse     = nan(n_subjects, 1);
for i = 1:n_subjects

    % Grand (and subject-level) updates
    upd             = E1{i}~=E2{i};
    updated_subs(i) = sum(upd);
    T_updated       = [T_updated; upd]; %#ok

    % Obtain absolute updates and estimation error
    y = [abs(E2{i}-E1{i}), abs(BR{i}-E1{i})];
    
    % When other's better: are subjects' minimizing error (i.e., providing 
    % self-enhancing updates)?
    x1                       =   [V{i}.*sign(E1{i}-BR{i}) == -1,...
                             (E2{i} ~= E1{i}) & (sign(BR{i}-E1{i}) == sign(E2{i}-E1{i}))];
    x2                       =   [V{i}.*sign(E1{i}-BR{i}) == -1,...
                             (E2{i} ~= E1{i}) & (sign(BR{i}-E1{i}) == sign(E1{i}-E2{i}))];

    % Obtain favourable update magnitude
    unfav_upd_mag(i)         =   sum(y(x1(:,1) & x1(:,2),1))/sum(y(x1(:,1),2));
    favourable_h1_subs(i)    =   sum(x1(x1(:, 1),2))/numel(x1(x1(:, 1),2));
    T_favourable_h1          =   [T_favourable_h1; x1(x1(:, 1),2)]; %#ok
    unfav_upd_mag_reverse(i) =   sum(y(x2(:,1) & x2(:,2),1))/sum(y(x2(:,1),2));
    favourable_h1_subs_reverse(i) =   sum(x2(x2(:, 1),2))/numel(x2(x2(:, 1),2));
    T_favourable_h1_reverse          =   [T_favourable_h1_reverse; x2(x2(:, 1),2)]; %#ok


    % When other's worse: are subjects' minimizing error (i.e., providing 
    % self-diminshing updates)?
    x1                       =   [V{i}.*sign(E1{i}-BR{i}) == 1,...
                            (E2{i} ~= E1{i}) & (sign(BR{i}-E1{i}) == sign(E2{i}-E1{i}))];
    x2                       =   [V{i}.*sign(E1{i}-BR{i}) == 1,...
                            (E2{i} ~= E1{i}) & (sign(BR{i}-E1{i}) == sign(E1{i}-E2{i}))];

    % Obtain unfavourable update magnitude
    fav_upd_mag(i)         =   sum(y(x1(:,1) & x1(:,2),1))/sum(y(x1(:,1),2));
    unfavourable_h1_subs(i)  =   sum(x1(x1(:, 1),2))/numel(x1(x1(:, 1),2));
    T_unfavourable_h1        =   [T_unfavourable_h1; x1(x1(:, 1),2)]; %#ok
    fav_upd_mag_reverse(i)    =   sum(y(x2(:,1) & x2(:,2),1))/sum(y(x2(:,1),2));
    unfavourable_h1_subs_reverse(i)  =   sum(x2(x2(:, 1),2))/numel(x2(x2(:, 1),2));
    T_unfavourable_h1_reverse     =   [T_unfavourable_h1_reverse; x2(x2(:, 1),2)]; %#ok

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
fprintf('%.2f%% ¡À %.2f%% of reverse responses on favourable trials;\n',...
    mean(favourable_h1_subs_reverse)*100,...
    std(favourable_h1_subs_reverse)*100);
fprintf('%.2f%% ¡À %.2f%% of reverse responses on unfavourable trials.\n',...
    mean(unfavourable_h1_subs_reverse)*100,...
    std(unfavourable_h1_subs_reverse)*100);


% Paired t-test
[~, p, ~, stats] = ttest(favourable_h1_subs, unfavourable_h1_subs);

% Print statistical test
fprintf(['A paired t-test comparing this update behaviour ',...
    'shows t(%d) = %.2f, p = %.3f.\n\n'], ...
         stats.df, stats.tstat, p);
     
% Paired t-test
[~, p, ~, stats] = ttest(favourable_h1_subs_reverse, unfavourable_h1_subs_reverse);

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
     
% Paired t-test
[~, p, ~, stats] = ttest(unfav_upd_mag_reverse, fav_upd_mag_reverse);

% Print statistical test
fprintf(['A paired t-test comparing reverse favourable and unfavourable update',...
    ' magnitudes shows t(%d) = %.2f, p = %.3f.\n'], ...
         stats.df, stats.tstat, p);


     
% Compare update magnitudes
unfav_upd_mag = unfav_upd_mag(~isnan(unfav_upd_mag));
fav_upd_mag = fav_upd_mag(~isnan(fav_upd_mag));
unfav_upd_mag_reverse = unfav_upd_mag_reverse(~isnan(unfav_upd_mag_reverse));
fav_upd_mag_reverse = fav_upd_mag_reverse(~isnan(fav_upd_mag_reverse));
m_unfav = mean(unfav_upd_mag);
sd_unfav = std(unfav_upd_mag);

m_fav = mean(fav_upd_mag);
sd_fav = std(fav_upd_mag);

% Print descriptive results (rounded to 2 decimals)
fprintf(['For favourable trials, the mean update',...
    ' magnitude was %.2f ¡À %.2f,\n'], m_unfav, sd_unfav);
fprintf(['For unfavourable trials, the mean update ',...
    'magnitude was %.2f ¡À %.2f.\n'], m_fav, sd_fav);

     
% Compare update magnitudes
m_unfav_reverse = mean(unfav_upd_mag_reverse);
sd_unfav_reverse = std(unfav_upd_mag_reverse);

m_fav_reverse = mean(fav_upd_mag_reverse);
sd_fav_reverse = std(fav_upd_mag_reverse);

% Print descriptive results (rounded to 2 decimals)
fprintf(['For reversely udpated favourable trials, the mean update',...
    ' magnitude was %.2f ¡À %.2f,\n'], m_unfav_reverse, sd_unfav_reverse);
fprintf(['For reversely udpated unfavourable trials, the mean update ',...
    'magnitude was %.2f ¡À %.2f.\n'], m_fav_reverse, sd_fav_reverse);

