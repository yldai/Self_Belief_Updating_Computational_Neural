%% ========================================================================
% This script models trial-wise estimation error magnitudes, updated trial
% proportions, and update magnitudes by word across participants, with
% favorability being the fixed effect.
%% ========================================================================
word_order = {'SENSITIVE','UNIMPORTANT','UNDESIRABLE','HELPLESS',...
    'ORDINARY', 'INTELLIGENT','INFERIOR','ANNOYING','LIKABLE', ...
    'CHEERFUL', 'WEAK','ASHAMED','NEEDY','HUMBLE','CARELESS', ...
    'SUCCESSFUL','BORING','VALUABLE','SELFISH','CONFIDENT', ...
    'ENTHUSIASTIC','AGREEABLE','LAZY','INSECURE','TALENTED', ...
    'MOODY','PATIENT','WITTY','EFFICIENT','COMPETENT','RESERVED', ...
    'GLOOMY','ADMIRABLE','CREATIVE','ANXIOUS','INDECISIVE', ...
    'VULNERABLE','HAPPY','SUPPORTED','INTERESTING','HUMOROUS', ...
    'LUCKY','SOCIABLE','AMBITIOUS','UNHEALTHY','INATTENTIVE',...
    'PASSIVE','PRODUCTIVE','ORIGINAL','BRILLIANT'};
n_words = numel(word_order);

% load data
files      = dir('./beh_data/*_linearmodel_all.csv');
n_subjects = numel(files);

subject = cell(n_subjects, 1);
BR      = cell(n_subjects, 1);
E1      = cell(n_subjects, 1);
E2      = cell(n_subjects, 1);
V       = cell(n_subjects, 1);
W       = cell(n_subjects, 1);

for i = 1:n_subjects

    fn         = files(i).name;
    subject{i} = extractBefore(fn, '_');

    data = readtable(fullfile('./beh_data/', fn));

    BR{i} = data.base_rate;
    E1{i} = data.parpre_rate;
    E2{i} = data.slider_score;
    W{i}  = string(data.word);

    valenceStr = string(data.valence);
    Vtmp = ones(size(valenceStr));
    Vtmp(valenceStr ~= "p") = -1;
    V{i} = Vtmp;
end



n_trials_total = n_subjects * 40;
col_subj   = zeros(n_trials_total, 1);
col_word   = strings(n_trials_total, 1);
col_cond   = strings(n_trials_total, 1);
col_valence= strings(n_trials_total, 1);
col_update = nan(n_trials_total, 1);
col_EE     = nan(n_trials_total, 1);
col_UP     = nan(n_trials_total, 1);
col_UPEE   = nan(n_trials_total, 1);

row = 0;
for i = 1:n_subjects
    BRi = BR{i};
    E1i = E1{i};
    E2i = E2{i};
    Vi  = V{i};
    Wi  = W{i};

    fav_trials = (Vi .* sign(BRi - E1i)) == 1;
    unfav_trials = (Vi .* sign(BRi - E1i)) == -1;
    update     = (E1i ~= E2i) & (sign(BRi - E1i) == sign(E2i - E1i));
    EE_vec     = abs(BRi - E1i);
    UP_vec     = abs(E2i - E1i);

    for t = 1:numel(BRi)
        row = row + 1;
        col_subj(row) = str2double(subject{i});
        col_word(row) = Wi(t);

        if fav_trials(t)
            col_cond(row) = 1;
        elseif unfav_trials(t)
            col_cond(row) = 0;
        else
            col_cond(row) = missing;
        end

        if Vi(t) == 1
            col_valence(row) = "Positive";
        else
            col_valence(row) = "Negative";
        end

        col_update(row) = double(update(t));
        col_EE(row)     = EE_vec(t);
        col_UP(row)     = UP_vec(t);

        if EE_vec(t) > 0
            col_UPEE(row) = UP_vec(t) / EE_vec(t);
        end
    end
end


T = table( ...
    categorical(col_subj), ...
    categorical(col_word,   word_order), ...
    categorical(col_cond), ...
    categorical(col_valence,{'Positive','Negative'}), ...
    col_update, col_EE, col_UP, col_UPEE, ...
    'VariableNames', {'participant','word','favorability','word_valence', ...
                      'update_choice','EE','UP','UP_EE'});


% --- EEtrial ---------------------------------------------
fprintf('--- EE ~ favorability + (1+favorability|participant) + (1+favorability|word) ---\n');
lme_EE = fitlme(T, ...
    'EE ~ favorability + (1+favorability|participant) + (1+favorability|word)');%, ...
   % 'FitMethod', 'REML');
tbl_EE = anova(lme_EE);%, 'DFMethod', 'Satterthwaite');
disp(tbl_EE);

% --- update choice --------------------------
fprintf('--- update_choice ~ favorability + (1+favorability|participant) + (1+favorability|word) ---\n');
glme_upd = fitglme(T, ...
    'update_choice ~ favorability + (1+favorability|participant) + (1+favorability|word)');
tbl_upd = anova(glme_upd);
disp(tbl_upd);


% --- UP/EE -----------------------------------------------
fprintf('--- UP_EE ~ favorability + (1+favorability|participant) + (1+favorability|word) ---\n');
T_valid = T(T.EE > 0, :);
lme_UPEE = fitlme(T_valid, ...
    'UP_EE ~ favorability + (1+favorability|participant) + (1+favorability|word)');
tbl_UPEE = anova(lme_UPEE);
disp(tbl_UPEE);


