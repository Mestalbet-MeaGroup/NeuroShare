function  xust = XustFilter(uw,r,b,c,p)
% ***************************************
% *    import global variables 		*
% ***************************************

% Cut no longer global variable
%global Cut;
%c = Cut;

%global Bin;
%b = Bin;

%global Raw;
%r = Raw;

%global UEmwa;
%uw = UEmwa;

 % ********************************
 %   get general parameters       *
 % ********************************
 
 xust.plotformat = p;

 % it might be different for SignPlot????
 %xust.VerticalLinePos      = d.UEMWAFigure.VerticalLinePos;
 %xust.VerticalLineStyle    = d.UEMWAFigure.VerticalLineStyle;

 % add (1) or not (0) time axis labels
 xust.MakeTimeLabel=1;

 xust.TimeUnits               = c.Parameters.TimeUnits;
 xust.MarkTimesInTimeUnits(1) = c.Results.PreCutInTimeUnits;
 xust.MarkTimesInTimeUnits(2) = c.Results.PostCutInTimeUnits; 
 xust.TimeAxisInTimeUnits     = xust.MarkTimesInTimeUnits + [-1,1];

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
   xust.Data1                  = c.Results.Data;
   if ~isempty(find(c.Results.IdExistList == p.SelectedEvent))
    ii = find(c.Parameters.EventList == p.SelectedEvent);
    xust.Data2{1}             = c.Results.EventData{ii};
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
  
  cell_involved	= find(inv_hash(p.pattern,c.Results.NumberOfNeurons,...
                                b.Results.Basis));
  pat_idx	= find(r.Results.ExistingPatterns==p.pattern);

  % put only UEs of selected pattern
  for ni=1:length(cell_involved)
   cc=cell_involved(ni);
   xust.Data2{cc}=uw.Results.Data{pat_idx};
  end 

 
 case 'ue_bin'
 
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
  
  xust.TimeUnits              = c.Parameters.TimeUnits;
  xust.MarkTimesInBins(1)     = c.Results.PreCutInTimeUnits/...
                                 b.Results.BinsizeInTimeUnits;
  xust.MarkTimesInBins(2)     = c.Results.PostCutInTimeUnits/...
                                 b.Results.BinsizeInTimeUnits;; 
  xust.TrialLengthInBins      = b.Results.TrialLengthInBins;
  

  if (xust.MarkTimesInBins(1) < 0 & ...
      xust.MarkTimesInBins(2) > 0   )
      xust.XTicksInBins = [1  ...
	                   0-xust.MarkTimesInBins(1)...
			   xust.TrialLengthInBins];
  else
      xust.XTicksInBins = [1 xust.TrialLengthInBins];	      
  end
		    
  xust.XTickLabelsInBins = ...
      map('num2str', xust.XTicksInBins*xust.TimeUnits);


end % switch xust.plotformat  
  
  




