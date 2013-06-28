%showSim illustrates how the inhomogeneous Poisson process is generated

RateMs=5*sin((1:1000)/100)+10;
R=max(RateMs);
Ts=1;
s=poissrnd(R*Ts); %number of points

extra_x=Ts*rand(1,s)*1000;  %in ms Unit
extra_y=R*rand(1,s);
extra_rate = interp1([0:length(RateMs)-1],RateMs,extra_x); 
times=extra_x(find(extra_y<=extra_rate))'; %only take the points under the r

% convert spike times to a binary matrix
myTrain=zeros(1,length(RateMs));
for i=1:length(times)
    myTrain(ceil(times(i)))=1;
end

hold on;

% plot rate profile and the final spike train
[ax h1 h2]=plotyy(1:1000,RateMs,1:1000,myTrain,'plot','stem');

set(ax(2),'YLim',[-1 2],'YTick',[0 1],'YColor','k','fontsize',16);
set(h2,'marker','none','Color','b');
set(ax(1),'YLim',[0 20],'YTick',0:5:20,'YColor','k','fontsize',16);
set(get(ax(1),'Ylabel'),'String','Hz', 'fontsize',16); 
set(h1,'Color','r');

% plot the spike train with the maximum firing rate from rate vector
stem(extra_x,extra_y,'r','marker','none');

xlabel('ms','fontsize',16);
title('Simulation algorithm','fontsize',16);

hold off;