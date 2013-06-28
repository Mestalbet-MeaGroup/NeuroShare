function gdf=pp_GammaData(NumberOfProcesses,Rate,Order,Ts,varargin)
% gdf=pp_GammaData(NumberOfProcesses,Rate,Order,Ts,varargin) Constructs NumberOfProcesses parallel gamma processes of length Ts (in sec)
% rate Rate (in Hz) and order Order. If Rate or Order is a number, all processes 
% share this value.
% If either Rate or Order are column vectors, the k-th process 
% will be of rate Rate(k) or order Order(k), respecively. 
%
% 
%   INPUT : NumberOfProcesses       - number of parallel processes (intger)
%           Rate  - rate of individual processes (number of column vector, in Hz)
%           Order   - order of individual processes (number of column
%                       vector of integers)
%           Ts      - Total time of experiment (number, in sec)
%
%   OPTIONS:    'Type'      - 'equilibrium' or 'ordinary'. Default is
%                               equilibrium
%
%   OUTPUT : gdf    - data in .gdf format in units of ms
%
%
%   METHOD: Thinning of Poisson processes, hence Order needs to be
%   integer!!!
%
%
% History: 15.12.05: removed temporal setting options
%          20.12.05: fixed orientation of Rate
%
% Version 1.0
% 15.12.05 staude@neurobiologie.fu-berlin.de
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


%test input dimensions and contents
if nargin < 4
    error('pp_PoissData_stat:TooFewInputs','Requires at least four input argument.');
end
if ~any(Order==round(Order))
    error('pp_GammaData: entries in Order must be integers')
end

% Check Rate and Order dimensions
[Rate_n,Rate_m]=size(Rate);
[Order_n,Order_m]=size(Order);
if Rate_m==1
    Rate=repmat(Rate,1,NumberOfProcesses);
end
if Order_m==1
    Order=repmat(Order,1,NumberOfProcesses);
end
[Rate_n,Rate_m]=size(Rate);
[Order_n,Order_m]=size(Rate);
if ~(Rate_n==Order_n & Rate_m==Order_m & Rate_m==NumberOfProcesses & Rate_n==1)
    error('pp_GammaData: input dimensions of Rate, Order and/or NumberOfProcesses are inconsistent')
end


% Switch varargin
ExtraTs=30;     %To produce equilibrium processes
for i=1:2:length(varargin)
    switch lower(varargin{i})
       case {'type'}
            switch varargin{i+1}
                case {'equilibrium'}
                    type = 'equil';
                case {'ordinary'}
                    type = 'ord';
                    ExtraTs=0;
                otherwise
                    error(['pp_GammaData: Unknown process type ' varargin{i+1}])
            end
    end
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%  Simulate  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
SimulTs=Ts+ExtraTs;
SimuLambda=Rate.*Order;
s=poissrnd(SimuLambda*SimulTs);   %number of Spikes per channel
gdf=[];
%keyboard
for k=1:NumberOfProcesses
    times=sort(rand(s(k),1)*SimulTs*1000);  %spiketimes of Poisson train
    times=times([1:Order(k):s(k)]); %take every Orderth spike
    NeurNum=ones(size(times))*k;
    gdf=cat(1,gdf,cat(2,NeurNum,times));
end
gdf=sortrows(gdf,2);


%cut the time at the beginning
gdf=gdf(find(gdf(:,2)>=ExtraTs*1000),:);
gdf(:,2)=gdf(:,2)-ExtraTs*1000;





