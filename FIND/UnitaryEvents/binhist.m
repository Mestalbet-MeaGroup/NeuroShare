function [y,t]=binhist(x,tl,tr,d)
% [y,t]=binhist(x,tl,tr,d): binned histogram  
%
% input:
%     x : vector of time stamps of spikes;
%         unsorted time stamps allowed
%     tl: start time for histogram
%     tr: end time of histogram
%     d : binwidth (in units of time stamps in x)
%
% output: 
%     y: histogram vector
%     t: binned time vector
%
% history:
%    (0) original version
%          MD, 1997
%    (1) commented
%          SG, 24.2.01
%    (2) exclude indices < 1
%          SG, 18.3.02
% 
% Example:
%[y,t]=binhist([3 4 5 1],0,6,2)  
%
% y=     1     1     2
% t =    0     2     4     
%


n= ceil((tr-tl)/d);       % total number of bins

y=zeros(1,n);             % initialize histogram vector

i=floor((x-tl)/d)+1;      % indices of times within bin steps d
i=i(i<=n & i>0 );         % take only indices <= max bin 
                          % and which are larger than 0


for k=1:length(i)         % go along index vector
 y(i(k))=y(i(k))+1;       % and add up by one per
end                       % relevant bin i

t=tl:d:tl+(n-1)*d;        % make time vector in bins




