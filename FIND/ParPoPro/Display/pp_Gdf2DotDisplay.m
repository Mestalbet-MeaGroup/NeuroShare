function pp_Gdf2DotDisplay(gdf,varargin)
%Plots a Dot-Display of the .gdf-file
%
%   OPTIONS - 'MarkerStyle':   'line'   plot a line for a spike
%                           'dot'    plot a dot. Default is 'dot'.
%             'LineLength'  a value between .01 and 1 that specifies the
%             length of the lines. Default is .4
%
% Version 1.0
% 12/05 (staude@neurobiologie.fu-berlin.de)
% Part of the PointProc Toolbox, Copyright 2005, Free University, Berlin
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


poption='dot';
LineLength=0.4;
for i=1:2:length(varargin)
    switch lower(varargin{i})
        case 'markerstyle'
            poption=varargin{i+1};
        case 'linelength'
            LineLength=varargin{i+1};
            if LineLength<0.01 | LineLength>1
                error('pp_Gdf2DotDisplay: LineLength must be between 0.01 and 1!!!')
            end
        otherwise
            error(['pp_Gdf2DotDisplay: unknow option: ' varargin{i}])
    end
end


IdGdf=sortrows(gdf);
neur=IdGdf(:,1);
times=IdGdf(:,2);
switch lower(poption)
    case {'line'}
        X=repmat(times',2,1);
        Y=cat(1,(neur-LineLength/2)',(neur+LineLength/2)');
        %keyboard
        figure
        line(X,Y,'Color','b')
        xlim([0 max(times)])
        ylim([min(neur)-LineLength/2-.2 max(neur)+LineLength/2+.2]) 
        xlabel('Time')
        ylabel('Neuron Id')
    case {'dot'}
        if length(unique(neur))<100
            warning('pp_gdf2DotDisplay: Events may not be visible in Dot Dislpay. Use option plot with value line')
        end
       figure
       %keyboard
        plot(times,neur,'d','MarkerFaceColor', 'b', 'MarkerSize' , 2);
        title('Dot-Display')
        ylabel('Neuron Id')
        xlabel('Time (in orig. resolution)')
        %xlim([1 1000])
    otherwise
        error(['pp_Gdf2DotDisplay: Unknown plot type: ' poption])
end
    
