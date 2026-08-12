% Run BR_sim_full.m first.
R2_actual = 0.4811;
ci_cal    = prctile(R2_runs, [2.5 97.5]);

figure('Color','w','Position',[100 100 600 420]);
ax = axes;
hold(ax,'on');

histogram(ax, R2_runs, 40, 'FaceColor',[0.1 0.4 0.5], ...
    'FaceAlpha', 0.6, 'EdgeColor', 'none');

yl = ylim(ax);

patch(ax, [ci_cal(1) ci_cal(2) ci_cal(2) ci_cal(1)], ...
          [0 0 yl(2) yl(2)], [0.7 0.7 0.7], ...
          'FaceAlpha', 0.25, 'EdgeColor', 'none');

plot(ax, [R2_actual R2_actual],       yl, 'r-',  'LineWidth', 2);
plot(ax, [median(R2_runs) median(R2_runs)], yl, 'k--', 'LineWidth', 1.5);

hold(ax,'off');
xlabel(ax, 'Proportion of variance explained (R^2)', 'FontSize', 18);
ylabel(ax, 'Frequency', 'FontSize', 18);
ax.FontSize = 15;
ylim(ax, yl);
box(ax, 'off');
