function gdf=pp_PoissonData(NumberOfProcesses,Rate,Ts,varargin)
% gdf=pp_PoissonData(NumberOfProcesses,Rate,Ts,varargin) constructs 
% NumberOfProcesses parallel, Poisson point processes of length Ts (in sec)
% and rate Rate (in Hz). The size of Rate determines the process type:
%       If Rate is a number, the processes are all
%               stationary with the same rate. 
%       If size(Rate)=[1,NumberOfChannels], the processes
%               are stationary, with the k-th process havig rate Rate(k). 
%       If size(Rate)=[Ts*1000,1], the processes are non-stationary with a
%               rate-profile given by Rate in ms-Resolution in Units of Hz.
%       If size(Rate)=[Ts*1000,NumberOfChannels], the processes are
%               non-stationary with the k-th process having the rate profile
%               Rate(:,k) (ms-Resolution in Units of Hz).
% 
%   INPUT : NumberOfProcesses - number of parallel processes (integer)
%           Rate  - rate of individual processes (number or array, in Hz) 
%           Ts      - Total time of experiment (in sec)
%
%   OUTPUT : gdf    - data in .gdf format in units of ms
%
%   REMARKS for nonstationary processes: 
%       - METHOD: Randomly places points in R^2 and uses only those under the prescribed
%               rate profile
%       - Interpolates the given rate-profile linearly 
%
% History: 15.12.05: removed temporal setting options
%          20.12.05: fixed orientation of Rate
%          19.1.06 : Corrected the help and the input-test
%          14.02.06: Taken From PoissData_stat and included
%                   nonstationarities
%          01.03.06: Made the simulations faster
% Version 1.1
% Benjamin Staude, Berlin, 14/02/06 (staude@neurobiologie.fu-berlin.de)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

if nargin < 3
    error('pp_PoissonData:TooFewInputs','Requires at least three input argument.');
end
gdf=[];
[RateTMs,RateProcesses]=size(Rate);
if (RateTMs>1) & (RateTMs~=Ts*1000)
    error('pp_PoissonData: size(Rate,1)~=Ts*1000 !');
end
if (RateProcesses>1)
    if (RateProcesses~=NumberOfProcesses)
        error('pp_PoissonData: size(Rate,2)~=NumberOfProcesses !');
    else
        RateMs=Rate; %Adjust Resolution
    end
else
    RateMs=repmat(Rate,1,NumberOfProcesses);
end
        

%tic
%%%%%%%%%%%%%% Simulation %%%%%%%%%%%%%%%
gdfcell=cell(NumberOfProcesses,1);
if RateTMs==1
    %
    % The Stationary Case 
    %
    s=poissrnd(RateMs*Ts);   %number of Spikes per channel
    for k=1:NumberOfProcesses
        times=rand(s(k),1)*Ts*1000;  %fit to units of ms 
        NeurNum=ones(s(k),1)*k;
        gdfcell{k}=cat(2,NeurNum,times);
    end
    gdf=cat(1,gdfcell{1:NumberOfProcesses});
else
    %
    % The Nonstationary Case 
    %
    for k=1:NumberOfProcesses
        R=max(RateMs(:,k));
        s=poissrnd(R*Ts); %number of points
        %{
        randomPoints=rand(1,s);
        extra_x=Ts*randomPoints*1000;
        extra_y=R*randomPoints;
        %}
        extra_x=Ts*rand(1,s)*1000;  %in ms Unit
        extra_y=R*rand(1,s);
        extra_rate = interp1([0:size(RateMs,1)-1],RateMs(:,k),extra_x); %ratevalues at the position of xvec        times=extra_x(find(extra_y<=extra_rate))'; %only take the points under the rate profile!!
        times=extra_x(find(extra_y<=extra_rate))'; %only take the points under the rate profile!!
        NeurNum=k*ones(size(times));
        gdfcell{k}=cat(2,NeurNum,times);
    end
    gdf=cat(1,gdfcell{1:NumberOfProcesses});
end

if ~isempty(gdf)
    gdf=sortrows(gdf,2);
end
%toc