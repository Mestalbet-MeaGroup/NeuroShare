function [y,t] = HistSlidOnGDF(st,tl,tr,b)
% [y,t] = HistSlidOnGDF(st,tl,tr,b): sliding window histogram
%
% input:
%    st : vector of time stamps of spikes;
%         unsorted time stamps allowed
%     tl: start time for histogram
%     tr: end time of histogram
%     d : binwidth (in units of time stamps in st)
%
% output: 
%     y: histogram vector
%     t: binned time vector
%
%
% Uses: binhist.m
% 
% Example:
%
% idx = 1:5:100
% [y,t] = HistSlidOnGDF(idx,0,100,5)
% plot(t,y)
%
% history:
%    (0) first version
%         SG, 18.3.02
%


% prepare xl,xr for sliding
tll  = tl + [0:1:b-1];
ntll = length(tll);

y = [];
t = [];

% histograms per offset
for i=1:ntll
 ttmp = [];
 ytmp = [];
 [ytmp,ttmp]=binhist(st,tll(i),tr,b);
 y = [y ytmp];
 t = [t ttmp];
end

% sort such that time is increasing
[t, is] =  sort(t);
y = y(is);
