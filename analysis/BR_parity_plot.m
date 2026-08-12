word_order = {'SENSITIVE','UNIMPORTANT','UNDESIRABLE','HELPLESS', ...
    'ORDINARY','INTELLIGENT','INFERIOR','ANNOYING','LIKABLE', ...
    'CHEERFUL','WEAK','ASHAMED','NEEDY','HUMBLE','CARELESS', ...
    'SUCCESSFUL','BORING','VALUABLE','SELFISH','CONFIDENT', ...
    'ENTHUSIASTIC','AGREEABLE','LAZY','INSECURE','TALENTED', ...
    'MOODY','PATIENT','WITTY','EFFICIENT','COMPETENT','RESERVED', ...
    'GLOOMY','ADMIRABLE','CREATIVE','ANXIOUS','INDECISIVE', ...
    'VULNERABLE','HAPPY','SUPPORTED','INTERESTING','HUMOROUS', ...
    'LUCKY','SOCIABLE','AMBITIOUS','UNHEALTHY','INATTENTIVE', ...
    'PASSIVE','PRODUCTIVE','ORIGINAL','BRILLIANT'};

mu_empirical = [66.25,29.17,28.33,17.64,45.14,72.78,25.28, ...
    44.44,69.86,66.81,29.86,19.02,40.69,56.53,34.72,63.57, ...
    35.56,71.25,38.06,57.00,67.68,65.42,41.39,45.42,53.33, ...
    43.19,61.39,59.58,64.86,69.58,50.97,25.83,49.44,57.08, ...
    55.97,54.58,46.25,70.42,73.75,61.67,64.58,61.80,60.55, ...
    67.22,33.19,37.65,35.71,62.29,48.00,49.26];

sigma_empirical = [20.44,26.31,23.81,17.50,26.02,10.17,22.99, ...
    21.37,12.22,15.82,20.62,18.08,25.94,16.81,23.84,14.78, ...
    21.93,17.58,20.64,19.82,17.59,21.86,21.70,24.51,20.35, ...
    20.95,22.12,15.56,18.73,12.27,24.84,16.63,16.64,21.72, ...
    25.66,25.64,20.85,16.36,20.37,18.01,18.22,19.13,20.13, ...
    17.99,20.53,21.04,23.24,15.26,19.90,19.03];

K = numel(word_order);
S = n_subjects;
sd_scale = 0.75;

lo_k = max(mu_empirical - sd_scale .* sigma_empirical, 5);
hi_k = min(mu_empirical + sd_scale .* sigma_empirical, 95);

x_mu = []; y_br = [];
for s = 1:S
    br_s = double(BR{s}); wrd_s = W{s};
    for i = 1:numel(br_s)
        k = find(strcmp(word_order, wrd_s{i}), 1);
        if isempty(k), continue; end
        x_mu(end+1) = mu_empirical(k);
        y_br(end+1) = br_s(i);
    end
end
x_mu = x_mu(:); y_br = y_br(:);

band_w = 1.5;
fig = figure('Color','w','Position',[80 80 720 680]);
ax  = axes('Parent',fig);
hold(ax,'on');

for ki = 1:K
    px = mu_empirical(ki) + [-band_w, band_w, band_w, -band_w];
    py = [lo_k(ki), lo_k(ki), hi_k(ki), hi_k(ki)];
    if ki==1
        fill(ax,px,py,[0.114 0.620 0.459],'FaceAlpha',0.18,'EdgeColor','none',...
            'DisplayName','\mu_k^* \pm 3/4\sigma_k^*');
    else
        fill(ax,px,py,[0.114 0.620 0.459],'FaceAlpha',0.18,'EdgeColor','none',...
            'HandleVisibility','off');
    end
end
 

scatter(ax, x_mu, y_br, 15, [0.4 0.4 0.4], 'filled', ...
    'MarkerEdgeColor','none', 'MarkerFaceAlpha', 0.4, ...
    'HandleVisibility','off');

scatter(ax,mu_empirical,mu_empirical,55,'k','filled','DisplayName','Means (\mu_k^*)');

plot(ax,[0 100],[0 100],'--','Color',[0.6 0.6 0.6],'LineWidth',1.4,...
    'HandleVisibility', 'off');

xlabel(ax,'Means from independent sample (\mu_k^*)','FontSize',18,'Interpreter','tex');
ylabel(ax,'Actual adjusted base rates','FontSize',18);
lgd = legend(ax,'Location','northwest'); 
lgd.FontSize=18; 
lgd.Box='off';
xlim(ax,[0 100]); 
ylim(ax,[0 100]);
ax.FontSize = 15;
axis(ax,'square'); 
box(ax,'off');
hold(ax,'off');