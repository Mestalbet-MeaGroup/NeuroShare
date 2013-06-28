function  xust = Xust_dot(uw,r,b,c,p,d)
% xust = Xust_dot(uw,r,b,c,p,d): plot dot display and/or events
% ***********************************************************************
% *                                                                     *
% *  Usage:                                                             *
% *                                                                     *
% * 	p.plotformat, type of plot:                                     *
% *            'dot': Dot Display                                       *
% *           'must': MUST DISPLAY                                      *
% *           'gust': GUST DISPLAY                                      *
% *            'raw': Raw Coincidences                                  *
% *             'ue': Unitary Events                                    *
% *         'ue_pat': UE of selected pattern                            *
% *                                                                     *
% *     p.pattern,    hash value of selected pattern                    *
% *     p.pos,      (optional) position rectangle to put plot           * 
% *     p.figure,   (optional) figure handler, in which to put the plot * 
% *                                                                     *
% *                                                                     *
% *  Input:  p:   structure containing plot information                 *
% *          c:   Cut-structure                                         *
% *          d:   DataFile-structure                                    *
% *          b:   Bin-structure                                         *
% *          r:   Raw-structure                                         *
% *          uw:  UEmwa-structure                                       *
% *                                                                     *
% *  Output: xust-structure                                             *
% *                                                                     *
% *          xust.Title                                                 *
% *          xust.NumberOfPlots                                         *
% *          xust.YLabel                                                * 
% *          xust.YTickLabels                                           *
% *          xust.XTickLabels                                           *
% *          xust.XLabel                                                *
% *          xust.XTicksInTimeUnits                                     *
% *          xust.TimeUnits                                             *
% *          xust.TrialLengthInTimeUnits                                *
% *          xust.NumberOfLines                                         *
% *          xust.Data1                                                 *
% *          xust.Data2                                                 *
% *          xust.MarkTimesInTimeUnits                                  *
% *          xust.TimeAxisInTimeUnits                                   *
% *          xust.BinsizeInTimeUnits                                    *
% *          xust.MarkTimesInBins                                       *
% *          xust.XTicksInBins                                          *
% *          xust.plotformat                                            *
% *          xust.MakeTimeLabel                                         *
% *          xust.VerticalLinePos                                       *
% *          xust.VerticalLineStyle                                     *
% *          xust.axes                                                  *
% *          xust.figure                                                *
% *                                                                     *
% *                                                                     *
% * See Also: single_dot                                                *
% *                                                                     *
% * Uses:     subrect(), single_dot()                                   *
% *                                                                     *
% * Problems:                                                           *
% *                                                                     *
% *         (2) must and gust options not implemented !!!!!!            *
% *         (1) Problem with screen appearance of YLabel. Seems to be   *
% *             a Problem with text handle object                       *
% *                                                                     *
% *         (2) Maybe we should get rid of Xust_Filter.m                *
% *                                                                     *
% * History:                                                            *
% *                                                                     *
% *         (12) Cut,Bin,Raw,UEmwa no longer global variables           *
% *             PM, 5.8.02 FfM                                          *
% *         (11) NO USE of Xust_Filter.m anymore, using structure xust  *
% *              global XUST not in use anymore                         *
% *             SG, 6.10.98,FfM                                         *
% *         (10) property strings introduced for plotformat             *
% *             SG, 5.10.98,FfM                                         *
% *         (9) VerticalLineStyle introduced with Fig2-Fig4 for Science *
% *             paper                                                   *
% *            MD, 10/97                                                *
% *         (8) VerticalLinePos introduced for vertical                 *
% *             lines in dot displays                                   *
% *            SG, 1.10.97 Marseille                                    *
% *         (7) reason for wrong screen appearance of YLabel found.     *
% *            MD, 26.7.97, Jerusalem                                   *
% *         (6) updated for new single_dot version                      *
% *            MD, 24.7.97, Jerusalem                                   *
% *         (5) version 5 matrix operations                             *
% *            MD, 4.5.97, Freiburg                                     *
% *         (4) UE plot of selected pattern implemented                 *
% *             WMT==20; variabilit of number of input arguments        *
% *             dependent on WMT implemented                            *
% *            SG,25.3.97                                               *
% *         (3) commented                                               *
% *            SG, 23.3.97                                              *
% *         (2) extended for use of RawDot and UEDot,                   *
% *             which include overplotted matrices                      *
% *            SG 11.12.96, Jerusalem                                   *
% *         (1) import/export                                           *
% *            MD 13.10.96, Freiburg                                    *
% *         (0) first version                                           *
% *            SG 12.10.96, Jerusalem                                   *
% *                                                                     *
% ***********************************************************************

% ***************************************
% *     import global variables         *
% ***************************************

% Cut,Bin,Raw,UEmwa no longer global variables, PM,5.8.02

%global Cut;
%c = Cut;
%global Bin;
%b = Bin;
%global Raw;
%r = Raw;
%global UEmwa;
%uw = UEmwa;


 % ***************************************
 % *                                     *
 % *           Select figure             *
 % *                                     *
 % ***************************************
 if isempty(p.figure)
  f=figure;
 else
  figure(p.figure);
 end;

 % ***************************************
 % *       Specify rectangle for         *
 % *       plot                          *
 % ***************************************
 if isempty(p.pos)
  p.pos=[0.1 0.1 0.8 0.8];
 end


 % ********************************
 %   get general parameters       *
 % ********************************
 
 xust.plotformat = p.plotformat;

 % add (1) or not (0) time axis labels
 xust.MakeTimeLabel=1;

 xust.TimeUnits               = c.Parameters.TimeUnits;
 xust.MarkTimesInTimeUnits(1) = c.Results.PreCutInTimeUnits;
 xust.MarkTimesInTimeUnits(2) = c.Results.PostCutInTimeUnits;
 xust.TimeAxisInTimeUnits     = xust.MarkTimesInTimeUnits;
 %xust.MarkTimesInTimeUnits     = xust.MarkTimesInTimeUnits + [-1,1];

 
 % it might be different for SignPlot????
 xust.VerticalLinePosInTimeUnits ...
     = d.UEMWAFigure.VerticalLinePosInMS/xust.TimeUnits;
 xust.VerticalLineStyle    = d.UEMWAFigure.VerticalLineStyle;
 xust.VerticalLineText     = d.UEMWAFigure.VerticalLineText;
 
 
 if (xust.MarkTimesInTimeUnits(1) < 0 & ...
     xust.MarkTimesInTimeUnits(2) > 0   )
  xust.XTicksInTimeUnits = [xust.MarkTimesInTimeUnits(1) ...
	                    0 ...
			    xust.MarkTimesInTimeUnits(2)];
 else
  xust.XTicksInTimeUnits = [xust.MarkTimesInTimeUnits(1) ...
			    xust.MarkTimesInTimeUnits(2)];	      
  end
		    
 xust.XTickLabels = map('num2str', xust.XTicksInTimeUnits*xust.TimeUnits);
 xust.BinsizeInTimeUnits   = b.Results.BinsizeInTimeUnits;  % new

 if ~isempty(xust.VerticalLineText)
  xust.XTicksInTimeUnits = xust.VerticalLinePosInTimeUnits;
  xust.XTickLabels       = xust.VerticalLineText;
 end    

xust.FontSize           = d.FontSize; 
xust.TrialDisplayMode   = d.DotDisplay.TrialDisplayMode;   
xust.Interactive        = d.DotDisplay.Interactive;       
 
% ********************************
%    get  specific parameters    *
%     (former Xust_Filter.m)     *
% ********************************

 switch xust.plotformat
  
  case {'dot'}
   xust.Title	                = 'Dot Display';
   xust.NumberOfPlots  	= c.Results.NumberOfNeurons;
   xust.YLabel                 = 'NEURONS';
   xust.YTickLabels            = c.Parameters.NeuronList;
   xust.XLabel                 = 'time (ms)';
   xust.TimeUnit               = c.Parameters.TimeUnits;
   xust.TrialLengthInTimeUnits = b.Results.TrialLengthInTimeUnits;
   xust.NumberOfLines          = c.Results.NumberOfTrials;
   xust.Data1                  = c.Results.Data;
   xust.Data2                  = cell(c.Results.NumberOfNeurons,1);

   xust.Dot.MarkerHeightPercentage = d.DotDisplay.DotHeightPercentage;
   xust.Dot.Marker                 = d.DotDisplay.DotMarker;
   xust.Dot.Color                  = d.DotDisplay.DotColor;

   % xust.Marker does not exist.

   
  % !!!!!!!!!!! NOT FULLY UPDATED YET !!!!!!!!!!!!!!!!!!
 %case 'must'
  %xust.Title                  = 'MUST DOT DISPLAY';
  %xust.NumberOfPlots          = N_TRIAL_SEL;
  %xust.YLabelWork             = 'TRIALS';
  %xust.YTickLabels            = TRIAL_SEL_LIST;
  %xust.XLabel	              = 'time (ms)';
  %xust.TimeUnit               = c.Parameters.TimeUnits;
  %xust.TrialLengthInTimeUnits = b.Results.TrialLengthInTimeUnits;
  %xust.NumberOfLines          = c.Results.NumberOfNeurons;
  %xust.Data1                  = TrialMat;
  
 % !!!!!!!!!!! NOT FULLY UPDATED YET !!!!!!!!!!!!!!!!!!
 %case 'gust'
  %xust.Title                  = 'Dot Display';
  %xust.NumberOfPlots          = N_N_GRPS;;
  %xust.YLabelWork             = 'groups';
  %xust.YTickLabels            = GRP_SEL_LIST;
  %xust.XLabel	              = 'time (ms)';
  %xust.TimeUnit               = c.Parameters.TimeUnits;
  %xust.TrialLengthInTimeUnits = b.Results.TrialLengthInTimeUnits;
  %xust.NumberOfLines          = N_IDs_GRP;
  %xust.Data1                  = GrpMat;
  
  case 'behav'
   xust.Title	               = '';
   xust.NumberOfPlots  	       = c.Results.NumberOfNeurons;
   xust.YLabel                 = '';
   xust.YTickLabels            = c.Parameters.NeuronList;
   xust.XLabel                 = 'time (ms)';
   xust.TimeUnit               = c.Parameters.TimeUnits;
   xust.TrialLengthInTimeUnits = b.Results.TrialLengthInTimeUnits;
   xust.NumberOfLines          = c.Results.NumberOfTrials;
   xust.Data1                  = cell(c.Results.NumberOfNeurons,1);
   xust.Marker.MarkerHeightPercentage = ...
       d.DotDisplay.Behavior.MarkerHeightPercentage;
   xust.Marker.Marker                 = ...
       d.DotDisplay.Behavior.Marker;
   xust.Marker.Color                  = ...
       d.DotDisplay.Behavior.Color;
   
 
  if ~isempty(find(c.Results.IdExistList == p.SelectedEvent))
    ii = find(c.Parameters.EventList == p.SelectedEvent);
    for i=1:c.Results.NumberOfNeurons
     xust.Data2{i}             = c.Results.EventData{ii};
    end 
    xust.SelectedEvent        = p.SelectedEvent;
   else
    error('SelectedEventNotExistent')
  end
  
 case 'raw'
  xust.Title	              = 'Raw Coincidences';
  xust.NumberOfPlots  	      = c.Results.NumberOfNeurons;
  xust.YLabel                 = 'NEURONS';
  xust.YTickLabels            = c.Parameters.NeuronList;
  xust.XLabel                 = 'time (ms)';
  xust.TimeUnit               = c.Parameters.TimeUnits;
  xust.TrialLengthInTimeUnits = b.Results.TrialLengthInTimeUnits;
  xust.NumberOfLines          = c.Results.NumberOfTrials;
  xust.Data1                  = c.Results.Data;
  xust.Data2                  = r.Results.Data;

  xust.Dot.MarkerHeightPercentage = d.DotDisplay.DotHeightPercentage;
  xust.Dot.Marker                 = d.DotDisplay.DotMarker;
  xust.Dot.Color                  = d.DotDisplay.DotColor;

  xust.Marker.MarkerHeightPercentage = d.DotDisplay.Raw.MarkerHeightPercentage;
  xust.Marker.Marker                 = d.DotDisplay.Raw.Marker;
  xust.Marker.Color                  = d.DotDisplay.Raw.Color;

   
 case {'ue'}
  xust.Title	              = 'Unitary Events';
  xust.NumberOfPlots  	      = c.Results.NumberOfNeurons;
  xust.YLabel                 = 'NEURONS';
  xust.YTickLabels            = c.Parameters.NeuronList;
  xust.XLabel                 = 'time (ms)';
  xust.TimeUnit               = c.Parameters.TimeUnits;
  xust.TrialLengthInTimeUnits = b.Results.TrialLengthInTimeUnits;
  xust.NumberOfLines          = c.Results.NumberOfTrials;
  xust.Data1                  = c.Results.Data;
  xust.Data2                  = uw.Results.Data;
 
  xust.Dot.MarkerHeightPercentage = d.DotDisplay.DotHeightPercentage;
  xust.Dot.Marker                 = d.DotDisplay.DotMarker;
  xust.Dot.Color                  = d.DotDisplay.DotColor;

  xust.Marker.MarkerHeightPercentage = d.DotDisplay.UE.MarkerHeightPercentage;
  xust.Marker.Marker                 = d.DotDisplay.UE.Marker;
  xust.Marker.Color                  = d.DotDisplay.UE.Color;

     
 case {'ue_pat'} 
   
  xust.Title	              = 'Unitary Events of selected pattern';
  xust.NumberOfPlots  	      = c.Results.NumberOfNeurons;
  xust.YLabel                 = 'NEURONS';
  xust.YTickLabels            = c.Parameters.NeuronList;
  xust.XLabel                 = 'time (ms)';
  xust.TimeUnit               = c.Parameters.TimeUnits;
  xust.TrialLengthInTimeUnits = b.Results.TrialLengthInTimeUnits;
  xust.NumberOfLines          = c.Results.NumberOfTrials;
  xust.Data1                  = c.Results.Data;
  xust.Data2                  = cell(c.Results.NumberOfNeurons,1);
 
  xust.Dot.MarkerHeightPercentage = d.DotDisplay.DotHeightPercentage;
  xust.Dot.Marker                 = d.DotDisplay.DotMarker;
  xust.Dot.Color                  = d.DotDisplay.DotColor;

  xust.Marker.MarkerHeightPercentage = d.DotDisplay.UE.MarkerHeightPercentage;
  xust.Marker.Marker                 = d.DotDisplay.UE.Marker;
  xust.Marker.Color                  = d.DotDisplay.UE.Color;

  cellInvolved	  = find(inv_hash(p.pattern,c.Results.NumberOfNeurons,...
                                b.Results.Basis));		    
  pat_idx	  = find(uw.Results.SignificantPatterns==p.pattern);
  if ~isempty(pat_idx)
   % put only UEs of selected pattern
   for ni=1:length(cellInvolved)
    xust.Data2{cellInvolved(ni)}=uw.Results.DataPerPattern{pat_idx};
  end 
 end


end % switch xust.plotformat  
  
  
  
%**************************************
% ************************************
% *   generate all plots             *
% ************************************
%**************************************
    
for i=1:xust.NumberOfPlots

  % ************************************
  % *       position of plot           *
  % ************************************
  pos=subrect(p.pos,xust.NumberOfPlots,1,xust.NumberOfPlots-i+1,0,0);

  % *************************************
  % *       create one panel            *
  % *************************************
  dot_axes(i) = single_dot(xust,pos,xust.Data1{i},...
                           xust.Data2{i},...
                           d.GeneralOptions.TimeDisplayMode);
  


% ************************************
% *         Font selection           *
% ************************************
  set(gca,'FontName','Helvetica');
  set(gca,'FontSize',xust.FontSize);
  set(gca,'FontWeight', 'normal');
    

% ************************************
% *         Titel of Plot            *
% ************************************
  if i==1
   set(gca,'Title',...
       text('String',xust.Title,'FontSize',xust.FontSize,'Color','black'));
  end
  
  
% ************************************
% *         YLabel                   *
% ************************************
  set(gca,'YColor', 'black');
  set(gca, 'YTick', xust.NumberOfLines/2, ...
           'YTickLabel', int2str(xust.YTickLabels(i)) );
  if i==ceil(xust.NumberOfPlots/2.)
   ylabel(xust.YLabel);
  end

% ************************************
% *         XLabel                   *
% ************************************
  set(gca,'XColor', 'black');
  if i==xust.NumberOfPlots & xust.MakeTimeLabel==1
   set(gca,'XLabel',...
       text('String',xust.XLabel,'FontSize',xust.FontSize,'Color','black'));   

   i=find(  xust.XTicksInTimeUnits >= c.Results.PreCutInTimeUnits ...
          & xust.XTicksInTimeUnits <= c.Results.PostCutInTimeUnits);
   if ~isempty(i)   
    set(gca, 'TickLength', [0 0]);
    set(gca,'XTick',xust.XTicksInTimeUnits(i));
    set(gca,'XTickLabel',xust.XTickLabels(i));
  end   
 end

% ************************************
% *         VertcalLines             *
% ************************************
  
  if ~isempty(xust.VerticalLinePosInTimeUnits)
   hold on;

   % draw lines at time indicated by VerticalLinePos
   line_height = get(gca,'Ylim');
   for ll=1:length(xust.VerticalLinePosInTimeUnits)
    plot([xust.VerticalLinePosInTimeUnits(ll), ...
	  xust.VerticalLinePosInTimeUnits(ll)],...
	  line_height(:), ...
 	cat(2, xust.VerticalLineStyle{ll}, 'k'));

   end
   hold off;
  end

end

set(gcf, 'Color', 'white');
set(gcf, 'InvertHardCopy', 'off'); 



xust.axes   = dot_axes;
xust.figure = gcf;
