function h=pp_DotDisplay(gdf,varargin)
%h=pp_DotDisplay(gdf,varargin) plots a Dot-Display of the data in gdf and returns the figure-handle in h
%
%   OPTIONS - 'DotMarkerStyle':   'Line'   plot a line for a spike
%                           'Dot'    plot a dot. Default is 'dot'.
%             'LineLength'  a value between .01 and 1 that specifies the
%             length of the lines. Default is .4
%             'UnitMs':   Temporal resolution of the Data (in ms)
%             'ylabel'  :   Label of the y-Axis (Channel Id or Trial Id)
%   
%   HISTORY:    Taken from pp_Gdf2DotDisplay
%
% Version 1.1
% 13/12/05 (staude@neurobiologie.fu-berlin.de)
% Part of the PointProc Toolbox, Copyright 2005, Free University, Berlin
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%Set Defaults
poption='dot';
LineLength=0.4;
UnitMs=1;
YLabel='';

% Switch varargin
for i=1:2:length(varargin)
    switch varargin{i}
        case 'DotMarkerStyle'
            poption=varargin{i+1};
        case 'LineLength'
            LineLength=varargin{i+1};
            if LineLength<0.01 | LineLength>1
                error('pp_Gdf2DotDisplay: LineLength must be between 0.01 and 1!!!')
            end
        case 'UnitMs'
            UnitMs=varargin{i+1};
            if UnitMs==1
                UnitMs=[];
            end
        case 'ylabel'
            if isstr(varargin{i+1});
                YLabel=varargin{i+1};
            else
                error(['pp_DotDisplay: ylabel needs to be a string'])
            end
        otherwise
            error(['pp_DotDisplay: unknow option: ' varargin{i}])
    end
end



%%%%%%%%%%%%% Compute and Plot %%%%%%%%%%%%%%%%
IdGdf=sortrows(gdf);
Channels=IdGdf(:,1);
Times=IdGdf(:,2);
switch lower(poption)
    case {'line'}
        X=repmat(Times',2,1);
        Y=cat(1,(Channels-LineLength/2)',(Channels+LineLength/2)');
        %keyboard
        h=figure;
        line(X,Y,'Color','b')
        xlim([0 max(Times)])
        ylim([min(Channels)-LineLength/2-.2 max(Channels)+LineLength/2+.2]) 
        xlabel(['Time in ' num2str(UnitMs) 'ms'])
        ylabel(YLabel)
        title('Dot Display')
    case {'dot'}
       h=figure;
        plot(Times,Channels,'d','MarkerFaceColor', 'b', 'MarkerSize' , 2);
        title('Dot-Display')
        ylabel(YLabel)
        xlabel(['Time in' num2str(UnitMs) ' ms'])
        title('Dot Display')
        xlim([0 max(Times)])
        ylim([min(Channels)-.2 max(Channels)+.2]) 
    otherwise
        error(['pp_Gdf2DotDisplay: Unknown plot type: ' poption])
end
    
