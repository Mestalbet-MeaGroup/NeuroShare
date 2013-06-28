function gdf=pp_ConvertTimeSetings(gdf,varargin);
% Convert the temporal settings of the gdf accoring to the specifications
% in varargin. gdf is assumed to be in ms Resolution!!!
%
%   INPUT:  gdf    -   in gdf Format
%           
%         
%   OPTIONS:    'Unit'    -   desired temporal unit in ms
%               'Precision'-    desired temporal precision in ms
%               'Clipping'  -   
%
%   OUTPUT:   gdf with corrected temporal settings
%
%   REMARKS: gdf is required to be in ms-resolution!!!!!
%   USES: 
%   Benjamin Staude, Berlin  15/12/05 (staude@neurobiologie.fu-berlin.de)
% Part of the ParaProc Toolbox, Copyright 2005, Free University, Berlin
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

UnitsMs=1;
PrecisionMs=realmin;
for i=1:2:length(varargin)
    switch varargin{i}
        case 'Unit'
            UnitsMs=varargin{i+1};
        case 'Precision'
            PrecisionMs=varargin{i+1};
        otherwise
            error(['pp_ConvertTimeSettings: unknown option ' num2str(varargin{i})])
    end
end

%%%   Correct Times %%%
gdf(:,2)=gdf(:,2)/UnitsMs;
if PrecisionMs~=realmin
    gdf(:,2)=floor(gdf(:,2)/PrecisionMs)*PrecisionMs;
end