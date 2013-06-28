function a = single_dot(xust,pos,sgdf,ogdf,TimeDisplayMode)
% a=single_dot(xust,pos,sgdf,ogdf,TimeDisplayMode),
% create a single dot-display at pos, optionally mark special spikes
% **********************************************************************
% *                                                                    *
% * Usage:   xust, information from Xust_dot.m                         *
% *          pos,  Position of axis object                             *
% *          sgdf, (trial, time) spike data                            *
% *          a,    handle of axis object                               * 
% *                                                                    *
% *                                                                    *
% * Options:                                                           *
% *                                                                    *
% *   TrialDisplayMode,      'from_top' (default), 'from_bottom'       *
% *   MarkerType,            'none' (default), 'raw', 'unitary'        *
% *   MarkerHeightPercentage, 0.1 (default) of height                  *
% *   MarkerPosition,         'binsize' (default), 'center'  (square)  *
% *                                                                    *
% * Input:  xust:   xust-structure from Xust_dot.m                     *
% *         pos:    Position of axis object                            *
% *         sgdf:  (trial, time) spike data                            *
% *         otype: (optional) marker type: 'raw', 'unitary', 'behav'   *
% *         ogdf:  (optional)(trial,time) spike data of special spikes *
% *         TimeDisplayMode                                            *
% *                                                                    *
% * Output: a:  handle of axis object                                  *
% *                                                                    *
% * Uses:   uses only builtin functions                                *
% *                                                                    *
% * Future:                                                            *
% *                                                                    *
% *         - Make MarkerSize dependent on Figure size, number         *
% *           of neurons etc (SG, 16.4.98)                             *
% *                                                                    *
% *         - make options accessible from outside                     *
% *                                                                    *
% *                                                                    *
% * History:                                                           *
% *         (5) GeneralOptions replaced by TimeDisplayMode in          *
% *             function call                                          *
% *            PM, 11.3.02, FfM                                        *
% *         (4) globalBin replaced by new global Bin (structure)       *
% *             plot spikes and events separately, plot behavioral     *
% *             events                                                 *
% *            SG, 6.10.98, FfM                                        *
% *         (3) marker code rewritten and new comment                  *
% *            MD, 25.7.1997, Jerusalem                                *
% *         (2) internal 'from_bottom' option and                      * 
% *             REWRITE comment added                                  *
% *            MD, 22.7.1997, Jerusalem                                *
% *         (1) rewritten for cellular array format                    *
% *            MD, 8.5.1997, Freiburg                                  *
% *         (0) ???? SG adopted from OD source                         *
% **********************************************************************

% GeneralOptions no longer used PM 11.3.02
%global GeneralOptions; 
%checkstruct(GeneralOptions,{'TimeDisplayMode'}); ...
%namespace(GeneralOptions);


% **********************************
% * set/evaluate options           *
% *                                *
% **********************************
%DotHeightPercentage     = 0.05;
%MarkerType              = 'none';
%MarkerHeightPercentage  = 0.1;
%MarkerPosition          = 'center';
%TrialDisplayMode        = 'from_top';
%Interactive             = 'off'; % 'on', 'off'

AspectRatio=get(gcf,'PaperPosition');
AspectRatio=AspectRatio(4)/AspectRatio(3);

BinDisplayMode = 'real'; % 'discrete'. Use discrete for debugging purposes
                         %  only


% *********************************
% * prepare axis object           *
% *                               *
% *********************************
a=axes;
set(a,'Position', pos);
set(a,'Color','none');  
set(gca, 'TickLength', [0 0]);
set(a,'YTickLabel', []);
set(a,'XTickLabel', []);
set(a,'XLim', xust.TimeAxisInTimeUnits);
set(a,'YLim',[1 xust.NumberOfLines] + [-1  1]);
set(a,'Box','on');


u=get(a,'Units');
set(a,'Units','points');
AxesPositionInPoints=get(a,'Position');
set(a,'Units',u);

%if strcmp(xust.Interactive,'on')
% set(a,'UserData',struct(...
%  'MarkerType',MarkerType,...
%  'MarkerPosition',MarkerPosition,...
%  'TrialDisplayMode',TrialDisplayMode ...
% ))
%end




% *********************************
% * plot spike events if available*
% *                               *
% *********************************
if isfield(xust,'Dot')
 
 %disp('plotting spikes ....')
 % **********************************
 % * convert spike indices to times *
 % * in time units relative to      *
 % * cut event                      *
 % **********************************
 spike_time  = xust.MarkTimesInTimeUnits(1) + sgdf(:,2) -1; 


 % **********************************
 % * prepare trial for display      *
 % * direction                      *
 % **********************************
 switch xust.TrialDisplayMode
  case 'from_top'                        
   spike_trial = xust.NumberOfLines - sgdf(:,1) + 1; 
  case 'from_bottom' 
   spike_trial = sgdf(:,1);
  otherwise
   error('SingleDot::UnknownTrialDisplayMode'); 
 end 

 
 % *********************************
 % * display mode for spike times  *
 % *                               *
 % *********************************

 switch TimeDisplayMode
  case 'discrete'
   % nothing to do
  case 'real'
   spike_time=spike_time+0.5;
  otherwise
   error('SingleDotot::UnknownTimeDisplayMode');
 end


 % *********************************
 % * plot dots                     *
 % *                               *
 % *********************************
%    'Marker','.'...
 dotsize = xust.Dot.MarkerHeightPercentage * AxesPositionInPoints(4);
 switch xust.Interactive
  case 'off'
  line(...
    'XData',spike_time,'YData',spike_trial,...
    'LineStyle','none',...
    'MarkerSize',dotsize,...
 'Marker', xust.Dot.Marker, ...
 'MarkerEdgeColor', xust.Dot.Color, ...
 'MarkerFaceColor', xust.Dot.Color ...
 );                     % MarkerSize was 5
  case 'on'
  l=line(repmat(spike_time',2,1),repmat(spike_trial',2,1));
  set(l,...
    'LineStyle','none',...
    'Color',xust.Dot.Color,...
    'MarkerSize',dotsize,...
    'Marker',xust.Dot.Marker,...
    'Tag','Dot',...
    'ButtonDownFcn','dotdisplaycallback'...
  )                        % MarkerSize was 5
  otherwise
  error('SingleDot::UnknownInteractionMode');
 end


end % of plot spike events


% check if there are events to plot
if ~isempty(ogdf)

% **********************************
% *      plot events               *
% *                                *
% **********************************
if isfield(xust,'Marker')
  
% disp('plotting events ....')
% **********************************
% * convert spike indices to times *
% * in time units relative to      *
% * cut event                      *
% **********************************                                         

event_time   =  xust.MarkTimesInTimeUnits(1) + ogdf(:,2) -1;

% **********************************
% * prepare trial for display      *
% * direction                      *
% **********************************
switch xust.TrialDisplayMode
 case 'from_top'                         
   event_trial  =  xust.NumberOfLines - ogdf(:,1) + 1;
 case 'from_bottom' 
   event_trial  = ogdf(:,1);
 otherwise
  error('SingleDot::UnknownTrialDisplayMode'); 
end 


switch xust.Marker.Marker
  
  case {'binsize', 'center'}
    switch xust.Marker.Marker
      case 'binsize'   
	markerheight= xust.Marker.MarkerHeightPercentage*(xust.NumberOfLines+2);
	dy = markerheight/2;
	dx = xust.BinsizeInTimeUnits-1;       
	xo = 0;               % left corner at t (first time unit in bin)
	switch BinDisplayMode
	  case 'discrete'
	    % nothing to do
	  case 'real'
	    dx=dx+1;  % dot in TimeUnits center, box around.
	end

      case 'center'
	yd  = get(a,'YLim'); yd=yd(2)-yd(1); % get height in y units
	xd  = get(a,'XLim'); xd=xd(2)-xd(1); % get width in x units
	
	dy  = 0.5 * xust.Marker.MarkerHeightPercentage * yd;  
	                     % distance in abs. y units 
	
	mh  = xust.Marker.MarkerHeightPercentage * pos(4); 
	                    % markerheight normalized y u.
	
	dx  = mh * AspectRatio;         % markerwidth normalized x u
	dx  = dx/pos(3) * xd;           % markerwidth in x units (time units)

	switch TimeDisplayMode
	  case 'real'
	    xo  = xust.BinsizeInTimeUnits/2 - dx/2;     
	  case 'discrete'
	    xo  = - dx/2;  				       
	end
		
    end
    x=reshape(event_time,1,length(event_time));
    x=repmat(x,5,1);
    x(1,:) = x(1,:) + xo;
    x(2,:) = x(2,:) + xo + dx;
    x(3,:) = x(3,:) + xo + dx;
    x(4,:) = x(4,:) + xo;
    x(5,:) = x(5,:) + xo; 

    y=reshape(event_trial,1,length(event_trial));
    y=repmat(y,5,1);
    y(1,:) = y(1,:) - dy;
    y(2,:) = y(2,:) - dy;
    y(3,:) = y(3,:) + dy;
    y(4,:) = y(4,:) + dy;
    y(5,:) = y(5,:) - dy; 

    l=line(x,y);
    set(l,...
	'Color',xust.Marker.Color,...
	'Tag','Marker',...
	'Clipping','off'...
	);

    if strcmp(xust.Interactive,'on')
      set(l,'ButtonDownFcn','dotdisplaycallback');
    end

  otherwise
    
    switch TimeDisplayMode
      case 'discrete'
	% nothing to do
      case 'real'
	event_time=event_time+xust.BinsizeInTimeUnits/2;
      otherwise
	error('SingleDotot::UnknownTimeDisplayMode');
    end
    
    markersize = xust.Marker.MarkerHeightPercentage*AxesPositionInPoints(4);
    l=line(...
	'XData',event_time,...
	'YData',event_trial,...
	'LineStyle','none',...
	'MarkerSize',markersize,...
	'Marker', xust.Marker.Marker,...
	'Color',xust.Marker.Color...
	);

end % of switch xust.Marker.Marker


end % of if isfield(xust,'Marker')

end % of if ~isempty(ogdf)
