%------------------ OBSOLETE -------------------
% written for SIP simulations

subplot(221);
trainFiltered=conv(myMatrix(1,:),normpdf(-5:0.01:5,0,1));
trainFiltered=trainFiltered(500:end-500);
plot(trainFiltered);
xlim([0 size(myMatrix,2)]);
hold on;
trainFiltered=conv(myMatrix(1,:),exppdf(0:0.01:5,1));
trainFiltered=trainFiltered(1:end-500);
plot(trainFiltered,'r');
xlim([0 size(myMatrix,2)]);
xlabel('ms');
title('kernel width = 1');

% suptitle
myXLim=get(gca,'XLim');
myYLim=get(gca,'YLim');
text(myXLim(2)*.75,myYLim(2)*1.05,['Comparison between {\color{red}exp.}'...
    ' and {\color{blue}Gaussian} kernels'],'fontsize',14);

subplot(222);
trainFiltered=conv(myMatrix(1,:),normpdf(-5*2:0.01:5*2,0,1*2));
trainFiltered=trainFiltered(500*2:end-500*2);
plot(trainFiltered);
xlim([0 size(myMatrix,2)]);
hold on;
trainFiltered=conv(myMatrix(1,:),exppdf(0:0.01:5*2,1*2));
trainFiltered=trainFiltered(1:end-500*2);
plot(trainFiltered,'r');
xlim([0 size(myMatrix,2)]);
xlabel('ms');
title('kernel width = 2');

subplot(223);
trainFiltered=conv(myMatrix(1,:),normpdf(-5*5:0.01:5*5,0,1*5));
trainFiltered=trainFiltered(500*5:end-500*5);
plot(trainFiltered);
xlim([0 size(myMatrix,2)]);
hold on;
trainFiltered=conv(myMatrix(1,:),exppdf(0:0.01:5*5,1*5));
trainFiltered=trainFiltered(1:end-500*5);
plot(trainFiltered,'r');
xlim([0 size(myMatrix,2)]);
xlabel('ms');
title('kernel width = 5');

subplot(224);
trainFiltered=conv(myMatrix(1,:),normpdf(-5*10:0.01:5*10,0,1*10));
trainFiltered=trainFiltered(500*10:end-500*10);
plot(trainFiltered);
xlim([0 size(myMatrix,2)]);
hold on;
trainFiltered=conv(myMatrix(1,:),exppdf(0:0.01:5*10,1*10));
trainFiltered=trainFiltered(1:end-500*10);
plot(trainFiltered,'r');
xlim([0 size(myMatrix,2)]);
xlabel('ms');
title('kernel width = 10');
