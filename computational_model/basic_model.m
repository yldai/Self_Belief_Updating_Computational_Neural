%% Model building and testing
% This script specifies the self belief updating generative model and tests whether 
% the model reliably captures different updating behaviors, including positively biased updating,
% non-biased symmetric updating, positive-only paradoxical updating, and null learning.

% To replicate the visualization presented in Supplementary Figure 2, modify line 16 & 17 as follows:
% For Figure 2a (a = 0.5, b = 0.2):   a = 0.5; b = 0.2;
% For Figure 2b (a = 0.5, b = 0):     a = 0.5; b = 0;
% For Figure 2c (a = 0, b = 0.2):     a = 0; b = 0.2;
% For Figure 2d (a = 0, b = 0):       a = 0; b = 0;

% simulate input variables and parameters 
BR = [35;20;30;40;25];
E1 = [50;45;50;60;40];
V = [-1;1;-1;1;-1];
a = 0.5; 
b = 0.2;  

%% Self belief updating generative model: 
% E2 = E1 + (a+(sign(BR-E1) * V) * b) * (BR-E1)
EE = BR-E1;
% derive sign of EE
N = (EE ./abs(EE)) .* V;  
% specify LR 
LR = a + N .* b;
% specify how E1 is updated to E2
E2 = E1 + LR .* EE;

%% Model visualization
N_y = zeros(length(N), 1);  
N_color = zeros(length(N), 3); 
N_y2 = zeros(length(N), 1); 
N_color2 = zeros(length(N), 3);

% visualize favorable & unfavorable condition
for t = 1:length(N)
    if N(t) == 1  
        N_y(t) = 100;
        N_color(t, :) = [0, 0.5, 0];  
    elseif N(t) == -1  
        N_y(t) = 100;
        N_color(t, :) = [0.8, 0, 0]; 
    elseif N(t) == 0  
        N_y(t) = 100;
        N_color(t, :) = [1, 0, 0]; 
    end
end
% visualize word valence
    for t = 1:length(N)
      if V(t) == 1  
         N_y2(t) = 0;
         N_color2(t, :) = [0.8, 0.5, 0];  
      else 
         N_y2(t) = 0;
         N_color2(t, :) = [0, 0, 1];  
      end
    end
figure;
hold on;
plot(1:length(E1), E1, '-o', 'LineWidth', 1.5, 'DisplayName', 'E1'); 
plot(1:length(BR), BR, '-x', 'LineWidth', 1.5, 'DisplayName', 'BR');  
plot(1:length(E2), E2, '-s', 'LineWidth', 1.5, 'DisplayName', 'E2');
scatter(1:length(N), N_y, 50, N_color, 'filled', 'DisplayName', 'Favorable');
scatter(1:length(N), N_y2, 50, N_color2, 'filled', 'DisplayName', 'Positive word');
hold on;
legend('show');
title('Estimated model - a=0.5 & b=0.2');
xlabel('Trials');
ylabel('E2 Values');
hold off;

