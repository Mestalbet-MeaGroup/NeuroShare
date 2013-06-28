function Data=pp_GenerateData(SingleProcessStats,CorrelatedProcessStats,...
    TrialParameters);
% Data=pp_GenerateData(SingleProcessStats,TrialParameters) genrates 
%       Data according to the settings in the paramter-sructures
%
%   INPUT: SingleProcessStats: struct containing the fields:
%               - ProcessType: either 'Gamma', or 'Poisson'
%               - Rate: array containing the rate-information. See help
%                 pp_PoissonData or help pp_GammaData for information
%               -  if ProcessType='Gamma': you need the fields 'order'
%                 and optionally 'GammaType', see help pp_GammaData 
%           optional fields:
%               - UnitMs (in ms)
%               - PrecisionMs (in ms)
%               - Clipping (0 or 1)
%
%           CorrelatedProcessStats:
%               - Rate: firing rate of the Single Interaction Process
%               - CorrCoefficient: pairwise correlation coefficient of SIP,
%                 theoretically takes values between -1 and 1, but right
%                 now only accepts 0~1, not sure -- JB
%
%           TrialParameters: struct containing the fields:
%               - NumberOfProcesses
%               - TrialDurationS (in sec)
%               - NumberOfTrials
%               - Marker (integer, needed if NumberOfTrials>1)
%           optional fields:
%               - StartOfExperimentMs (in ms)
%               - TrialOffsetMs (in ms)
%
%   OUTPUT:   Data. struct containing the cells:
%           - SingleProcessStats and
%           - TrialParameters as in the input
%           - gdfcell: cell, containing the unconcatinated trials
%               (Data.gdfcell{k}=k-th trial)
%           - gdf concatinated trials...
%
%   EXAMPLE: SingleProcessStats.ProcessType = 'Poisson';
%            SingleProcessStats.Rate = sin([1:1000]'/(2*pi*10))+10;
%            TrialParameters.NumberOfProcesses = 10;
%            TrialParameters.TrialDurationS = 1;
%            TrialParameters.NumberOfTrials = 40;
%            TrialParameters.Marker = 100;
%           Data = pp_GenerateData(SingleProcessStats,TrialParameters);
%           Generates 40 trials of 10 nonstationary Poisson processes with
%           a sine-like rate profile
%
%   USES: The ParPoPro Toolbox 
%   Version 1.1
%   Benjamin Staude, Berlin  22/02/06 (staude@neurobiologie.fu-berlin.de)
% Part of the ParPoPro Toolbox, Copyright 2005, Free University, Berlin
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Check input

%%%  TEST THIS HERE!
%if strncmp(SingleProcessStats.ProcessType,'Gam',3) & ~isfield(SingleProcessStats.GammaType)
%    SingleProcessStats.GammaType='equilibrium';
%%% 
%end
if ~isfield(SingleProcessStats,'UnitMs')
    SingleProcessStats.UnitMs=1;
end
if ~isfield(SingleProcessStats,'PrecisionMs')
    SingleProcessStats.PrecisionMs=realmin;
end
if ~isfield(SingleProcessStats,'Clipping')
    SingleProcessStats.Clipping=0;
end

if ~isfield(TrialParameters,'StartOfExperimentMs')
    TrialParameters.StartOfExperimentMs=0;
end
if ~isfield(TrialParameters,'TrialOffsetMs')
    TrialParameters.TrialOffsetMs=0;
end




Data.SingleProcessStats=SingleProcessStats;
Data.CorrelatedProcessStats = CorrelatedProcessStats;
Data.TrialParameters=TrialParameters;


%%%%%%%%%%%%%%%%%%%%%
%                   %
%   Generate Data   %
%                   %
%%%%%%%%%%%%%%%%%%%%%

Data.gdfcell=cell(TrialParameters.NumberOfTrials,1);

if TrialParameters.isSingleProcess == true

    switch SingleProcessStats.ProcessType
        case 'Gamma'
            for k=1:TrialParameters.NumberOfTrials
                Data.gdfcell{k}=pp_GammaData(TrialParameters.NumberOfProcesses,...
                    SingleProcessStats.Rate,...
                    SingleProcessStats.Order,...
                    TrialParameters.TrialDurationS,...
                    'Type',lower(SingleProcessStats.GammaType));
            end
        otherwise %it will be assumed Poisson...
            for k=1:TrialParameters.NumberOfTrials
                Data.gdfcell{k}=pp_PoissonData(TrialParameters.NumberOfProcesses,...
                    SingleProcessStats.Rate,...
                    TrialParameters.TrialDurationS);
            end

    end

else
    
    for k=1:TrialParameters.NumberOfTrials
        myStruct = pp_SipData(CorrelatedProcessStats.CorrCoefficient,...
            TrialParameters.NumberOfProcesses,...
            CorrelatedProcessStats.Rate,TrialParameters.TrialDurationS);
        Data.gdfcell{k} = myStruct.gdf;
    end
    
end


%%%%%%%%%%%%%%%%%%%%%%%%%
%                       %
%   Concatinate Trials  %
%                       %
%%%%%%%%%%%%%%%%%%%%%%%%%

TrialWithOffsetMs=TrialParameters.TrialDurationS*1000+TrialParameters.TrialOffsetMs;
Data.gdf=[]; 
%gdf=[];%cat(2,TrialParameters.Marker,TrialParameters.StartOfExperimentMs);
if TrialParameters.NumberOfTrials>1
    Data.gdf(1,:)=[TrialParameters.Marker TrialParameters.StartOfExperimentMs];
    TrialGdf=Data.gdfcell{1};
    TrialGdf(:,2)=TrialGdf(:,2)+TrialParameters.StartOfExperimentMs;
    Data.gdf=cat(1,Data.gdf,TrialGdf);
    for TrialNumber=2:TrialParameters.NumberOfTrials
        MarkerLine=cat(2,TrialParameters.Marker,...
            TrialParameters.StartOfExperimentMs+(TrialNumber-1)*TrialWithOffsetMs);
        TrialGdf=Data.gdfcell{TrialNumber};
        TrialGdf(:,2)=TrialGdf(:,2)+...
            TrialParameters.StartOfExperimentMs+(TrialNumber-1)*TrialWithOffsetMs;;
        TrialGdf=cat(1,MarkerLine,TrialGdf);
        Data.gdf=cat(1,Data.gdf,TrialGdf);
    end

else
    Data.gdf=Data.gdfcell{1};
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                           %
%  Adjust Temporal Settings %
%                           %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% Of gdfcell
if (SingleProcessStats.UnitMs~=1) | (SingleProcessStats.PrecisionMs~=realmin)
    for TrialNumber=1:TrialParameters.NumberOfTrials
        Data.gdfcell{TrialNumber}=pp_ConvertTimeSettings(Data.gdfcell{TrialNumber},...
            'Unit',SingleProcessStats.UnitMs,...
            'Precision',SingleProcessStats.PrecisionMs);
        if SingleProcessStats.Clipping
            Data.gdfcell{TrialNumber}=pp_Clipping(Data.gdfcell{TrialNumber});
        end
    end

    %% Of gdf
    Data.gdf=pp_ConvertTimeSettings(Data.gdf,...
        'Unit',SingleProcessStats.UnitMs,...
        'Precision',SingleProcessStats.PrecisionMs);
    if SingleProcessStats.Clipping
        Data.gdf=pp_Clipping(Data.gdf);
    end
end

