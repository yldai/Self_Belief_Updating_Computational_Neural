% Run dai_beh_stats.m first.

n_runs = 1000;

gamma = 0.5625;

word_order = {'SENSITIVE','UNIMPORTANT','UNDESIRABLE','HELPLESS',...
    'ORDINARY','INTELLIGENT','INFERIOR','ANNOYING','LIKABLE',...
    'CHEERFUL','WEAK','ASHAMED','NEEDY','HUMBLE','CARELESS',...
    'SUCCESSFUL','BORING','VALUABLE','SELFISH','CONFIDENT',...
    'ENTHUSIASTIC','AGREEABLE','LAZY','INSECURE','TALENTED',...
    'MOODY','PATIENT','WITTY','EFFICIENT','COMPETENT','RESERVED',...
    'GLOOMY','ADMIRABLE','CREATIVE','ANXIOUS','INDECISIVE',...
    'VULNERABLE','HAPPY','SUPPORTED','INTERESTING','HUMOROUS',...
    'LUCKY','SOCIABLE','AMBITIOUS','UNHEALTHY','INATTENTIVE',...
    'PASSIVE','PRODUCTIVE','ORIGINAL','BRILLIANT'};

mu_empirical = [66.25,29.17,28.33,17.64,45.14,72.78,25.28,44.44,69.86,66.81,...
    29.86,19.02,40.69,56.53,34.72,63.57,35.56,71.25,38.06,57.00,67.68,65.42,...
    41.39,45.42,53.33,43.19,61.39,59.58,64.86,69.58,50.97,25.83,49.44,57.08,...
    55.97,54.58,46.25,70.42,73.75,61.67,64.58,61.80,60.55,67.22,33.19,37.65,...
    35.71,62.29,48.00,49.26];

sigma_empirical = [20.44,26.31,23.81,17.50,26.02,10.17,22.99,21.37,12.22,15.82,...
    20.62,18.08,25.94,16.81,23.84,14.78,21.93,17.58,20.64,19.82,17.59,21.86,...
    21.70,24.51,20.35,20.95,22.12,15.56,18.73,12.27,24.84,16.63,16.64,21.72,...
    25.66,25.64,20.85,16.36,20.37,18.01,18.22,19.13,20.13,17.99,20.53,21.04,...
    23.24,15.26,19.90,19.03];

V_empirical = [-1, -1, -1, -1,...
    -1, 1, -1, -1, 1,...
    1, -1, -1, -1, 1, -1,...
    1, -1, 1, -1, 1,...
    1, 1, -1, -1, 1,...
    -1, 1, 1, 1, 1, -1,...
    -1, 1, 1, -1, -1,...
    -1, 1, 1, 1, 1,...
    1, 1, 1, -1, -1,...
    -1, 1, 1, 1];

K = 50;  
S = n_subjects;
BR_sim = nan(S,K);
B_mat  = nan(S, K);
E1_mat = nan(S,K); 
for s = 1:S
    for k = 1:K
        idx = strcmp(W{s}, word_order{k});
        if any(idx)
            B_mat(s,k)  = BR{s}(find(idx,1));
            E1_mat(s,k) = E1{s}(find(idx,1));
        end
    end
end
V_sim  = repmat(V_empirical, S, 1);
valid_mask = ~isnan(E1_mat);
V_sim(~valid_mask) = NaN;

fprintf('  gamma=%.4f: Actual hand-coded R^2=%.4f\n', gamma, fit_R2(B_mat, mu_empirical, sigma_empirical, gamma, S));


fprintf('\nSimulation (%d runs) by gamma:\n', n_runs);
fprintf('%-8s  %-10s  %-20s  %-10s\n', 'gamma', 'R2_actual', '95% sim interval', 'median_sim');
fprintf('%s\n', repmat('-',1,55));


sd = sqrt(gamma);
draw_g  = @(k) min(max(5*round((mu_empirical(k)+sd*sigma_empirical(k)*randn)/5),5),95);
R2_runs = nan(1, n_runs);

for r = 1:n_runs
    BR_sim = nan(S, K);

    for s = 1:S
        E1_s = E1_mat(s,:);
        V_s  = V_sim(s,:);
        BR_s = arrayfun(draw_g, 1:K);

        EE=abs(BR_s-E1_s);
        fav=V_s.*sign(BR_s-E1_s)==1; unf=V_s.*sign(BR_s-E1_s)==-1;
        EEf=sum(EE(fav)); EEu=sum(EE(unf));
        improved=true;

        while abs(EEf-EEu)>=10 && improved
            improved=false;
            if EEu>EEf, pool=find(unf); 
                tgt=1;
            else
                pool=find(fav); 
                tgt=-1; 
            end
             if isempty(pool)
                 break; 
             end
             
             [~,si]=sort(EE(pool),'descend'); pool=pool(si);
             
             for k=pool
                 old=BR_s(k);
                 for d=1:50, c=draw_g(k);
                     if V_s(k)*sign(c-E1_s(k))==tgt
                         BR_s(k)=c; 
                         break; 
                     end
                 end
                    if BR_s(k)==old
                        for d=1:100
                            c=draw_g(k);
                            if abs(c-E1_s(k))<EE(k)
                                BR_s(k)=c; 
                                break; 
                            end
                        end
                    end
             
                EE=abs(BR_s-E1_s);
                fav=V_s.*sign(BR_s-E1_s)==1; 
                unf=V_s.*sign(BR_s-E1_s)==-1;
                EEf=sum(EE(fav)); 
                EEu=sum(EE(unf));
                
                    if abs(EEf-EEu)<10 
                        improved=true; 
                        break; 
                    end
                    if BR_s(k)~=old
                        improved=true; 
                    end
             end
        end
        BR_sim(s,:)=BR_s;
    end

        R2_runs(r) = fit_R2(BR_sim, mu_empirical, sigma_empirical, gamma, S);
end

    R2_actual = fit_R2(B_mat, mu_empirical, sigma_empirical, gamma, S);
    med       = median(R2_runs);
    ci        = prctile(R2_runs, [2.5 97.5]);
    pct_rank  = mean(R2_runs <= R2_actual) * 100;

    fprintf('%-8.4f  %-10.4f  [%.4f, %.4f]        %-10.4f  (actual at %.0f%%ile)\n', ...
        gamma, R2_actual, ci(1), ci(2), med, pct_rank);


function R2w = fit_R2(B, mu, sig, gamma, S)
    Y  = B';  
    Y  = Y(:);
    m  = repmat(mu',  S, 1); 
    m  = m(:);
    s  = repmat(sig', S, 1); 
    s  = s(:);
    ok = ~isnan(Y);
    Y=Y(ok); 
    m=m(ok); 
    s=s(ok);
    w  = 1./(gamma .* s.^2);
    X  = [ones(numel(Y),1), m];
    th = (X'.*w'*X) \ (X'.*w'*Y);
    Yh = X*th;  
    Yw = sum(w.*Y)/sum(w);
    R2w = 1 - sum(w.*(Y-Yh).^2) / sum(w.*(Y-Yw).^2);
end