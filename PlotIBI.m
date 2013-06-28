% Plot IBI PDF for use with PlotBurstInfo.m
function PlotIBI(IBIpre,IBIpost,text);
IBIpre=IBIpre./1000; %conversion to sec
IBIpost=IBIpost./1000; %conversion to sec
if isinf(floor(log10(min(IBIpre))))
    lowlimit=0;
else
    lowlimit=floor(log10(min(IBIpre)));
end

if isinf(floor(log10(min(IBIpost))))
    lowlimit1=0;
else
    lowlimit1=floor(log10(min(IBIpost)));
end

highlimit=floor(log10(max(IBIpre)));
highlimit1=floor(log10(max(IBIpost)));


ll=min(IBIpre);
ll1=min(IBIpost);
hl=max(IBIpre);
hl1=max(IBIpost);
%% Find Best Plot
j=[10:1:100];
for c=1:length(j)
%     bins=logspace(min(lowlimit,lowlimit1)-1,max(highlimit,highlimit1)+2,j(c));
    bins=logspace(-2,5,j(c));
        for i=1:length(bins)-1
            preTest(i)=size(IBIpre(IBIpre>=bins(i)&IBIpre<bins(i+1)),2);
            postTest(i)=size(IBIpost(IBIpost>=bins(i)&IBIpost<bins(i+1)),2);
        end
NumPointsPre(c)=length(preTest(preTest~=0));
NumPointsPost(c)=length(postTest(postTest~=0));
end

CheckNumPoints=j(min((length(preTest)+length(postTest))-(length(NumPointsPre)+length(NumPointsPost))));
% temp=(NumPointsPre+NumPointsPost)./j;
% [ss CheckNumPoints]=min(temp);

%% Plot
% bins=logspace(min(lowlimit,lowlimit1)-1,max(highlimit,highlimit1)+2,CheckNumPoints);
bins=logspace(-2,5,j(c));
for i=1:length(bins)-1
    PreIBIhist(i)=size(IBIpre(IBIpre>=bins(i)&IBIpre<bins(i+1)),2);
    PostIBIhist(i)=size(IBIpost(IBIpost>=bins(i)&IBIpost<bins(i+1)),2);
end 
% bins=linspace(0,max(hl,hl1)+10,15);
a=diff(bins);
PreIBIhist=PreIBIhist./a;
PostIBIhist=PostIBIhist./a;
% PreIBIhist(PreIBIhist==0)=0.001;
% PostIBIhist(PostIBIhist==0)=0.001;
PreIBIhist=PreIBIhist./max(PreIBIhist);
PostIBIhist=PostIBIhist./max(PostIBIhist);

%% Log Plot
loglog(bins(1:end-1),PreIBIhist,':b.','MarkerSize',12);
hold on
loglog(bins(1:end-1),PostIBIhist,':r.','MarkerSize',12);
hold off
title(text);

%% Linear Plot
% 
% semilogx(bins(PreIBIhist~=0),PreIBIhist(PreIBIhist~=0),':bs','MarkerSize',12);
% hold on
% semilogx(bins((PostIBIhist~=0)),PostIBIhist(PostIBIhist~=0),':rs','MarkerSize',12);
% hold off
% title(text);
end