function data=pp_Trials(NumberOfTrials,Type,NumberOfChannels,ProcessParameters,TrialDurationS,varargin)
%
% Concatinate several trials with the same parameter settings
%   INPUT:
%         
%         
%         
%         
%
%   OPTIONS:   'Resolution'  - Resolution of the data (in ms). Default is the
%                                MatLab resolution.
%               'DiplayTime' - Default is 1 ms.
%               'Clipping' - 'on' or 'off'. IF 'Resolution' is set
%                            manually, clipping's default is 'on', else it is 'off' 
%               'Marker' - style of the marker between trials. Default
%                           is "-1"
%               'Offset' - Time Difference between trials. Default is 0
%               'StartTimeS' - Start time of Experiment in sec
%
%   OUTPUT : gdf    - data in .gdf format
%
%
%   USES: 
%
% Version 1.0
%   Benjamin Staude, Berlin  06/12/05 (staude@neurobiologie.fu-berlin.de)
% Part of the ParaProc Toolbox, Copyright 2005, Free University, Berlin
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

if round(NumberOfTrials)~=NumberOfTrials
    error('pp_Trials: Number of Trials must be inter!!!')
end
Marker=100000;
OffsetMs=0;
Clip=0;
Acc=realmin;
Res=1;
StartTimeMs=0;
for i=1:2:length(varargin)
    switch lower(varargin{i})
        case {'accuracy'}
            Acc=varargin{i+1};
            if ~isnumeric(Acc)
                error('Accuracy needs to be a number!')
            end
            Clip=1;
        case {'resolution'}
            Res=varargin{i+1};
            if ~isnumeric(Res)
                error('Resolution needs to be a number!')
            end
        case {'clipping'}
            switch lower(varargin{i+1})
                case {'on'}
                        Clip=1;
                case {'off'}
                    Clip=0;
                otherwise
                        error('Clipping has be to set to on or off')
            end
        case {'marker'}
            Marker=varargin{i+1};
            if Marker>0
                warning(['pp_Trials: Marker style"' Marker '" conflicts with other entries in gdf!!!'])
            end
        case {'offset'}
            OffsetMs=varargin{i+1};
            if OffsetMs<0
                error('pp_Trials: Offet between Trials must be positive')
            end
        case {'starttimes'}
            StartTimeMs=varargin{i+1}*1000;
        otherwise
            error(['pp_Trials: unknown option ' varargin{i}]);
            
    end
end
%keyboard


%%%%%%%%%%%%  SIMULATION  %%%%%%%%%%%%%%%%%%%%%%
TrialDurationMs=TrialDurationS*1000;;

gdf=cat(2,Marker,StartTimeMs);
switch lower(Type)
    case 'poisson_stat'
        for TrialNumber=1:NumberOfTrials
            TrialGdf=pp_PoissData_stat(NumberOfChannels,ProcessParameters,TrialDurationS);
            TrialGdf(:,2)=TrialGdf(:,2)+(TrialNumber-1)*TrialDurationMs+OffsetMs;
            MarkerLine=cat(2,Marker,StartTimeMs+(TrialNumber-1)*(TrialDurationMs)+OffsetMs);
            %keyboard
            TrialGdf=cat(1,TrialGdf,MarkerLine);
            gdf=cat(1,gdf,TrialGdf);
        end
    case 'poisson_nonstat'
    case 'gamma'
end


%%%%%%%%%%%%%%% Resolution, Accuracy & Clipping &&&&&&&&&&&
gdf(:,2)=gdf(:,2)*Res;
if Acc~=realmin
    gdf(:,2)=round(gdf(:,2)/Acc)*Acc;
end
if Clip
    gdf=pp_clipping(gdf);
end



%%%%%%%%%%%%%  Construct output structure %%%%%%%%%%%%%%%%
data.gdf=gdf;
data.Marker=Marker;
data.ResolutionMs=Res;
data.Accuracy=Acc;
data.Clipping=Clip;
data.TrialDurationS=TrialDurationS;
data.NumberOfTrials=NumberOfTrials;
data.Type=Type;
        
        
            
        