function d = SipData(r,w,lambda,Ts)
% d = SipData(r,w,lambda,Ts): generate data according to A. Kuhn's SIP
% model
% 
% input:
%
%   w      : number of neurons to simulate
%   Ts     : total time to simulate (in seconds !!!)
%   lambda : rate of processes (in 1/s (Hz) !!!!!!!!!!!!!!)
%   r      : pairwise correlation coefficient 
%
% output:
%          d.w
%          d.Ts
%          d.lambda
%          d.r
%          d.sips : cell containing sips data
%          d.gdf  : sips data in gdf-format
%
% History:
%   Benjamin Staude, Jan 2005
%   modified from MipData, SG, MD, Oct 2002, Jerusalem
%

Ts = Ts * 1000;
lambda = lambda / 1000;

d.w=w;
d.Ts=Ts;
d.lambda=lambda;
d.r=r;
%%%%%%%%%%%%%%%%%%%
%Resulting Parameters
alpha=lambda*r;        %rate of network-events
beta=lambda*(1-r);     %background rate



gdf=[];
%Background activity
IndSpikeNum=poissrnd(beta*Ts,1,w);  %Individual number of spikes
for k=1:d.w
 spikes=IndSpikeNum(k);
 kgdf=cat(2,ones(spikes,1)*k,rand(spikes,1)*Ts);
 gdf=cat(1,gdf,kgdf);
end
%network events
NetSpiNum=poissrnd(alpha*Ts);
spiketimes=Ts*rand(NetSpiNum,1)';
%merge
spikemat=repmat(spiketimes,d.w,1);
neurmat=repmat([1:d.w]',1,NetSpiNum);
netgdf=cat(2,reshape(neurmat,NetSpiNum*d.w,1),reshape(spikemat,NetSpiNum*d.w,1));
gdf=cat(1,gdf,netgdf);
d.gdf=sortrows(gdf,2);
