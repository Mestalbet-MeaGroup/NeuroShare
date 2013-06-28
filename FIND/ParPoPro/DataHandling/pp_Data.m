function gdf=pp_Data(Type,n,ProcessParameters,TrialDurationS,varargin)
%
%       Constructs n parallel, independent gamma-processes by drawing the
%       ISI's from a gamma-Distribution
%
%   INPUT:
%         
%         
%         
%         
%
%   OUTPUT:   
%
%
%   Version 1.0
%   Benjamin Staude, Berlin  10.12.05 (staude@neurobiologie.fu-berlin.de)
% Part of the ParaProc Toolbox, Copyright 2005, Free University, Berlin
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%









switch lower(Type)
    case 'poisson_stat'
        for k=
        gdf=pp_PoissData_stat(n,ProcessParameters,TrialDusrationS,'Resolution',Res,'Accuracy',Acc,'Clipping',Clip);
    case 'poisson_nonstat'
        gdf=pp_PoissData_stat(n,ProcessParameters,TrialDusrationS,'Resolution',Res,'Accuracy',Acc,'Clipping',Clip);
    case 'gamma'
        gdf=pp_PoissData_stat(n,ProcessParameters,TrialDusrationS,'Resolution',Res,'Accuracy',Acc,'Clipping',Clip);
end
        