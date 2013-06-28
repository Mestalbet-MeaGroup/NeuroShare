%scaling4in1 plots 4 scaling plots in one figure, including rate profile,
%            scaling of all trials and scaling of 2 individual trials
%            separately

figure;

%----------- PARAMETERIZATION ----------------

kernel = 'Gauss';
sigma = '100';

%---------------------------------------------

subplot(221);
scalingForProfile;
title('Rate profiles','fontsize',16);
xlim([0.7 1]);
ylim([-0.8 0.6]);
text(1.02, 0.8, 'Normalized Gaussian \sigma=100ms', 'fontsize', 18); % suptitle
%set(gca, 'fontsize', 16);

subplot(222);
load(['tmp/ramp/B' kernel 'Sigma' sigma '.mat']);
scaling(normB, 2);
title('All trials','fontsize',16);
%xlim([0.8 1]);
%ylim([-0.8 0.6]);
%set(gca, 'fontsize', 16);

subplot(223);
index = [1:5 51:55 101:105 151:155 201:205];
myB = normB(index, index);
scaling(myB, 2);
title('Trial 1','fontsize',16);
xlim([0.7 1]);
ylim([-0.8 0.6]);
%set(gca, 'fontsize', 16);

subplot(224);
index = index + 5;
myB = normB(index, index);
scaling(myB, 2);
title('Trial 2','fontsize',16);
xlim([0.7 1]);
ylim([-0.8 0.6]);
%set(gca, 'fontsize', 16);