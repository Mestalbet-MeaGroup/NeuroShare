function SignPlot(psth,uw,raw,b,c,sel_pat,d)
% function SignPlot(psth,uw,raw,b,c,sel_pat,pf,pn):
% plot various statistics of selected pattern
% ***************************************************************
% *                                                             *
% * Usage:                                                      *
% *        sel_pat, selected pattern as vector of 0,1s          *
% *                 e.g. [0 1 0 1]                              *
% *        pf,      print flag : (optional),                    *
% *                   not given: plot only on screen            *
% *                   1 : print to ps-file                      *
% *                   2 : print to eps-file                     *
% *                 (if 1 or 2, only a small dislay             *
% *                 on lower left corner on screen)             *
% *        pn,      print file name: (optional),                *
% *                 if pf givenprint file name                  *	
% *                                                             *
% * Input:  d:       Datafile-structure                         *
% *         psth:    Psth-structure                             *
% *         b:       Bin-structure                              *
% *         uw:      UEmwa-structure                            *
% *         c:       Cut-structure                              *
% *         raw:     Raw-structure                              *
% *         sel_pat: Selected Pattern                           *
% *                                                             *
% * Output:                                                     *
% *                                                             *
% * 5 Plots:                                                    *
% *                                                             *
% * 1. PSTHs (smoothed, width of time window == width of        *
% *    the sliding window) of all neurons;                      *
% *    solid line: if they contribute with a spike to the       *
% *    selected pattern; dashed if not                          *
% *                                                             *
% * for the selected pattern:                                   *
% *                                                             *
% * 2. graph of the expected coincidence rate per secs (green)  *
% *    and the actual (raw) coincidence rate per secs (red)     *
% *    as a function of time; evaluated per sliding window      *
% * 3. Significance Level as a function of time:                *
% *    (1-joint-p-value) per sliding window, put at the         *
% *    middle point of the sliding window                       *
% *    - the blue dotted line shows the threshold for           *
% *      sigificantly missing pattern                           *
% *    - the red dotted line shows the threshold for            *
% *      sigificantly more pattern than expected by chance      *
% *    The threshold for significance is the same as            *
% *    chosen for the UEMWA-Analysis.                           *
% * 4. Significant Epochs as a function of time:                *
% *    Illustrates how often each point in time was             *
% *    a member of a significant analysis window;               *
% *    positive values show > upper threshold (in red)          *
% *    negative values show < lower threshold (in blue)         *
% * 5. Dot Display incl. Unitary Events ONLY of the             * 
% *    selected pattern                                         *
% *                                                             *
% *  Problems:                                                  *
% *    (1) better to use a property string for WMT instead of   *
% *        integer values.                                      *
% *    (2) we should aim to seperate the time in the array and  *
% *        the index into the array - single_dot.m              *
% *        works on times!!!                                    *
% *                                                             *
% * Future:                                                     *
% *         - better separation of time axis information        *
% *                                                             *
% *                                                             *
% * See Also:                                                   *
% *          UEMWA(), UE_core()                                 *
% *                                                             *
% * Uses:                                                       *
% *       hash(), subrect(), Xust_dot(), Xust_Filter(), logP()  *
% *                                                             *
% * History:                                                    *
% *       (7) Cut,Bin,Raw,UEmwa,Psth no longer global variables *
% *            PM, 5.8.02, FfM                                  *
% *       (6) no GeneralOptions anymore                         *
% *           TimeDisplayMode now in DataFile.GeneralOptions... *
% *            PM, 11.3.02, FfM                                 *
% *       (5) string concatenation for print name               *
% *           extended to muliple cut events                    *
% *           and, if print-filename given, cut events not      *
% *           appended                                          *
% *            SG, 16.4.98, FfM                                 *
% *       (4) VerticalLineStyle and VerticalLinePos introduced  *
% *           with Fig2-Fig4 for Science paper                  * 
% *            MD, 10/97                                        * 
% *       (3) design improvement (like Science Fig)             * 
% *           and commented                                     * 
% *            SG, 16.3.97                                      * 
% *       (2) extended for use of RawDot and UEDot,             *
% *           which include overplotted matrices                * 
% *            SG 11.12.96,Jerusalem                            * 
% *       (1) import/export                                     * 
% *            MD 13.10.96,Freiburg                             * 
% *       (0) firstversion                                      * 
% *            SG 12.10.96, Jerusalem                           *  
% *                                                             * 
% *                                                             * 
% *                          diesmann@biologie.uni-freiburg.de  *
% *                          gruen@hbf.huji.ac.il               *
% *                                                             *
% ***************************************************************

% ***************************************************************
% * examples:                                                   *
% *                                                             *
% * SignPlot([1 1 0],1) : prints displays of pattern [1 1 0]	*
% *                       to ps-file of name FILENAME110.ps     *
% *                                                             *
% * SignPlot([1 1 0],2,'test') : prints displays of pattern     *
% *                              [1 1 0] to eps-file of name    *
% *                              test110.eps                    *
% *                                                             *
% ***************************************************************

% GeneralOptions no longer used PM 11.3.02
%global GeneralOptions; namespace(GeneralOptions);

% Cut,Bin no longer global variables, PM 5.8.02

%global Cut;
%c = Cut;
%global Bin;
%b = Bin;
%global Raw;
%r=Raw;
%global UEmwa;
%uw = UEmwa;
%global Psth;
%psth = Psth;

%profile on 

TimeDisplayMode = d.GeneralOptions.TimeDisplayMode;

% ***************************************
% *                                     *
% *        evaluate options             *
% *                                     *
% *                                     *
% ***************************************

% add (1) or not (0) time axis labels
MakeTimeLabel=1;


% ***************************************
% * prepare dot displays                *
% *                                     *
% ***************************************
sp = XustFilter(uw,raw,b,c,'ue_bin');	 


% ****************************************************
% *                                                  *
% * Prepare time axis for data on TimeUnits and Bin  *
% * resolution  according to [,) convention          *
% * This code should be formulated in terms of the   *
% * UEMWA struct independent of the actual window    *
% * moving method.                                   *
% *                                                  *
% ****************************************************

% use bintriallength !!

TimeIndexRangeInTimeUnits  =  (psth.Results.LossLeftInTimeUnits+1)...
                             :(b.Results.TrialLengthInTimeUnits-...
			       psth.Results.LossRightInTimeUnits);

TimeCenterRangeInTimeUnits = TimeIndexRangeInTimeUnits;

if isodd(psth.Results.WindowWidthInTimeUnits)
switch TimeDisplayMode
 case 'discrete'
  % nothing to do
 case 'real'
  TimeCenterRangeInTimeUnits=TimeCenterRangeInTimeUnits + 0.5;
 otherwise
  error('SignPlot::UnknownTimeDisplayMode');
 end
end

BinRange =  (uw.Results.BinLossLeftInBins+1)...
           :(b.Results.TrialLengthInBins-...
	          uw.Results.BinLossRightInBins);


BinCenterRangeInTimeUnits = ...
                (uw.Results.BinLossLeftInTimeUnits+1)...
                :b.Results.BinsizeInTimeUnits...
                :(b.Results.TrialLengthInTimeUnits-...
		             uw.Results.BinLossRightInTimeUnits);
                 
if isodd(uw.Results.WindowWidthInBins)
 switch TimeDisplayMode
  case 'discrete'
   BinCenterRangeInTimeUnits = BinCenterRangeInTimeUnits + ...
                               floor(b.Results.BinsizeInTimeUnits/2);
  case 'real'
   BinCenterRangeInTimeUnits = BinCenterRangeInTimeUnits + ...
                               b.Results.BinsizeInTimeUnits/2;
  otherwise
   error('SignPlot::UnknownTimeDisplayMode');
 end
end


TimeIntervalInTimeUnits    = sp.MarkTimesInTimeUnits;

TimeCenterRangeInTimeUnits = TimeIntervalInTimeUnits(1)+ ...
                                   TimeCenterRangeInTimeUnits -1;
BinCenterRangeInTimeUnits  = TimeIntervalInTimeUnits(1)+ ...
                                   BinCenterRangeInTimeUnits  -1;  

VerticalLinePosInTimeUnits = ...
    d.SignFigure.VerticalLinePosInMS / c.Parameters.TimeUnits;

% ***************************************
% *                                     *
% *      Check Pattern Selection        *
% *                                     *
% ***************************************

% Pattern selection mixed up !!!!!!!!


 if isempty(raw.Results.ExistingPatterns)
  error('SignPlot::NoPatterns');
 end

 % check number of digits:
 if ~rowvec(sel_pat)
  error('SignPlot:PatternVector::CheckOrientation');
  return;
 elseif cols(sel_pat) ~= c.Results.NumberOfNeurons
  error('SignPlot:PatternVector::CheckLengths');
  return;
 else
  pat_idx = find(raw.Results.ExistingPatterns==hash(sel_pat,...
                                 c.Results.NumberOfNeurons,...
				 b.Results.Basis));
  if isempty(pat_idx)
   error('SignPlot:PatternNotExistent');
   return;
  end
 end


% ***************************************
% *                                     *
% *          Set up Figure              *
% *                                     *
% ***************************************

f=figure;
set(f,'Units','centimeters');
set(f,'PaperType','a4letter');
set(f,'PaperUnits','centimeters');
set(f,'Color', 'white');
set(f,'InvertHardCopy','off');

if strcmp(d.SignFigure.Display, 'off')        % no big display on screen
 p(1)=0.5;		% in cm 
 p(2)=0.5;		% in cm
 p(3)=3.0; 		% in cm
 p(4)=3.0; 		% in cm

 set(f,'Position',p);
 set(f,'PaperPosition',[1.5 2 18 26]);
else                                           % on screen
 p(1)=1;		% in cm
 p(2)=1;		% in cm
 p(3)=18; 		% in cm
 p(4)=22; 		% in cm

 set(f,'Position',p);
 set(f,'PaperPosition',p);
end



% ***************************************
% *                                     *
% *   put filename and selected pattern *
% *   on top of plot                    *
% *                                     *
% ***************************************
r = [0.15,0.9, 0.8,0.1];
th = axes;
set(th,'Position',r);
set(th,'visible','off');


% string generation of cut event list
cutString = '_c';
for i=1:length(c.Parameters.CutEvent)
 cutString = strcat(cutString, int2str(c.Parameters.CutEvent(i)));
end

% string generation of pattern
patString ='_sp';
for i=1:length(sel_pat)
 patString = strcat(patString, int2str(sel_pat(i)));
end

PatternString  = int2str(sel_pat);
CutEventString = int2str(c.Parameters.CutEvent);

newstring  = [' , pattern: ' PatternString ...
              ' , cut event: ' CutEventString];
text2write = strrep(d.SignFigure.Text,'(pattern: ... , cut event: ...)',newstring);
text2write(findstr(text2write,'_'))='-';

text(-0.1,0.75, text2write,...
        'FontSize', d.SignFigure.TextFontSize, 'Color','black');


%
% specify rectangle for the first 4 plots
%
r=[0.1 0.35 0.8 0.55];


% *******************************************************
% *                                                     *
% *      PSTHS of original, non-binned data,            *
% *      smoothed                                       *
% *                                                     *
% *******************************************************
 
 
 pos = subrect(r,4,1,4,0,0.05);
 a = axes;
 set(gca, 'FontSize',d.FontSize);
 set(gca, 'Position', pos);
 set(gca, 'Color','none');
 set(gca, 'XLim', TimeIntervalInTimeUnits);
 set(gca, 'YLim', [0 (max(max(psth.Results.Mat))+1)]);    
 set(gca, 'TickLength', [0 0]);
 set(gca, 'XTick',sp.XTicksInTimeUnits);
 set(gca, 'XTickLabel', [ ]);
 set(gca, 'XColor','black');
 set(gca, 'YColor','black');
 set(gca,'YLabel', text(0,0,'sp/sec',...
     'FontSize',d.FontSize, 'Color','black'));
 set(gca, 'Box', 'on');   
 set(gca, 'title', text(0,0,'Spike Rates',...
     'FontSize',d.FontSize, 'Color','black'));

 colors  = ['g','b','m','c','y'];

 for i=1:c.Results.NumberOfNeurons

  l=line(TimeCenterRangeInTimeUnits, ...
         psth.Results.Mat(TimeIndexRangeInTimeUnits,i));
  if sel_pat(i)==1
   col = colors(rem(i,length(colors))+1);
   set(l, 'Color', col,'LineStyle','-' );
  elseif sel_pat(i)==0
   set(l, 'Color', 'k','LineStyle',':' );
  end
 end

 if ~isempty(VerticalLinePosInTimeUnits)
   hold on;
   line_height = get(gca,'Ylim');
   for ll=1:length(VerticalLinePosInTimeUnits)
    plot([VerticalLinePosInTimeUnits(ll),...
	  VerticalLinePosInTimeUnits(ll)],...
	  line_height(:), ...
	cat(2, d.SignFigure.VerticalLineStyle{ll}, 'k'));

   end
   hold off;
  end 
 
 hold on;
 line_width = get(gca,'Xlim');
 plot(line_width(:),[5 5],'k:');
 hold off;


% ********************************************************
% *                                                      *
% *       plot expected and actual coincidence rates     *
% *       of selected pattern                            *
% *                                                      *
% ********************************************************


 pos = subrect(r,4,1,3,0,0.05);
 a = axes; 
 set(gca, 'FontSize',d.FontSize);
 set(gca, 'Position', pos);
 set(gca, 'Color','none');
 set(gca, 'XLim', TimeIntervalInTimeUnits);
 
 % actual occurrences in rates per second per trial
% uw.Results.UEmwaResults(tm,11,ip')=ues(11,:)...
%     /uw.Results.WindowWidthInSec/c.Results.NumberOfTrials; 
 
% expected occurrences in rates per second per trial
% uw.Results.UEmwaResults(tm,12,ip')=ues(12,:)...
%     /uw.Results.WindowWidthInSec/c.Results.NumberOfTrials;
 

% exp_coinc =  uw.Results.UEmwaResults(:,4,pat_idx);
% exp_coinc =  exp_coinc.*(1000/(b.Results.BinsizeInTimeUnits...
%                                 *c.Parameters.TimeUnits));
			     
 expCoincRate =  uw.Results.UEmwaResults(:,12,pat_idx);		     

 actCoincRate =  uw.Results.UEmwaResults(:,11,pat_idx);
 
 
 % this should be done in UE_core !
% act_coinc =  act_coinc.*(1000/(b.Results.BinsizeInTimeUnits...
%                                 *c.Parameters.TimeUnits));

			   %  uw.Results.UEmwaResults(:,11,pat_idx)
			     
 ymax = max([actCoincRate' expCoincRate']);
 ymin = min([actCoincRate' expCoincRate']);
 if ymax<=ymin
     ymax =1;
     ymin =0;
 end
     hangover = 0.1 * (ymax - ymin);
 
 set(gca, 'ylim', [(ymin - hangover) (ymax + hangover)]);
 set(gca, 'YLabel', text(0,0,'coinc/sec',...
     'FontSize', d.FontSize, 'Color','black'));  
 set(gca, 'TickLength', [0 0]);
 %set(gca, 'XTick',sp.XTicksInTimeUnits);
 set(gca, 'XTickLabel', [ ]);
 set(gca, 'XColor','black');
 set(gca, 'YColor','black');
 set(gca, 'Box', 'on');   
 set(gca, 'title', ...
  text(0,0,'Coincidence Rates (actual:solid, expect:dashed)',...
   'FontSize',d.FontSize, 'Color','black'));
 
 l=line(BinCenterRangeInTimeUnits, actCoincRate(BinRange)');
 set(l, 'Color', 'red');
 
 l=line(BinCenterRangeInTimeUnits, expCoincRate(BinRange)');
 set(l, 'Color', 'black');
 set(l, 'LineStyle', '--');

 if ~isempty(VerticalLinePosInTimeUnits)
   hold on;
   line_height = get(gca,'Ylim');
   for ll=1:length(VerticalLinePosInTimeUnits)
    plot([VerticalLinePosInTimeUnits(ll),...
	  VerticalLinePosInTimeUnits(ll)],...
	  line_height(:), ...
	cat(2, d.SignFigure.VerticalLineStyle{ll}, 'k'));

   end
   hold off;
  end


% ********************************************************
% *                                                      *
% *         Surprise  as a function of time              *
% *                                                      *
% ********************************************************

 pos = subrect(r,4,1,2,0,0.05);
 a = axes;
 set(gca, 'FontSize',d.FontSize);
 set(gca, 'Position', pos);
 set(gca, 'Color','none');
 set(gca, 'XLim', TimeIntervalInTimeUnits);
 set(gca, 'XTickLabel', [ ]);
 set(gca, 'TickLength', [0 0]);
 set(gca, 'XColor','black');
 set(gca, 'YColor','black');
 %set(gca, 'Ylabel', 'JS');
 set(gca, 'Box', 'on');   
 set(gca, 'title', text(0,0,'Significance Level',...
      'FontSize',d.FontSize, 'Color','black'));
 
 set(gca, 'ylim', [-4,4]);
 % check again 
 js_vec = uw.Results.UEmwaResults(:,9,pat_idx);
 l=line(BinCenterRangeInTimeUnits,js_vec(BinRange));
 set(l, 'Linestyle','-','Color', 'black');
 
 l=line(BinCenterRangeInTimeUnits,...
     zeros(size(BinCenterRangeInTimeUnits))-logP(uw.Results.Alpha));
 set(l, 'Linestyle',':','Color', 'blue');
 
 l=line(BinCenterRangeInTimeUnits,...
     logP(uw.Results.Alpha)+zeros(size(BinCenterRangeInTimeUnits)));
 set(l, 'Linestyle',':','Color', 'red');

 if ~isempty(VerticalLinePosInTimeUnits)
   hold on;
   line_height = get(gca,'Ylim');
   for ll=1:length(VerticalLinePosInTimeUnits)
    plot([VerticalLinePosInTimeUnits(ll),...
	  VerticalLinePosInTimeUnits(ll)],...
	  line_height(:), ...
	cat(2, d.SignFigure.VerticalLineStyle{ll}, 'k'));

   end
   hold off;
  end



% ********************************************************
% *                                                      *
% *              Significant Epochs                      *
% *                                                      *
% ********************************************************

 pos = subrect(r,4,1,1,0,0.05);
 a = axes;  
 set(gca, 'FontSize',d.FontSize);
 set(gca, 'Position', pos);
 set(gca, 'Color','none');
 set(gca, 'XLim', TimeIntervalInTimeUnits);
 lim_max = max(max([uw.Results.UEmwaResults(:,7,pat_idx), ...
                         abs(uw.Results.UEmwaResults(:,8,pat_idx))]) );
 if lim_max ==0
  lim_max = 1;
 end

 set(gca, 'ylim', [-lim_max-(0.05*lim_max) (0.05*lim_max)+lim_max]);     
 set(gca, 'TickLength', [0 0]);
% set(gca, 'XTick',BinWorkXTicks);
 set(gca, 'XTickLabel',[ ]);
 set(gca, 'XColor','black');
 set(gca, 'YColor','black'); 
 set(gca, 'Box', 'on');
 set(gca, 'title', text(0,0,'Significant Epochs',...
      'FontSize',d.FontSize, 'Color','black'));

 seb=uw.Results.UEmwaResults(:,8,pat_idx);
 l = line(BinCenterRangeInTimeUnits,seb(BinRange));
 set(l, 'Color', 'blue');
 ser=uw.Results.UEmwaResults(:,7,pat_idx);
 l = line(BinCenterRangeInTimeUnits,ser(BinRange));
 set(l, 'Color', 'red');

 
 
  if ~isempty(VerticalLinePosInTimeUnits)
   hold on;
   line_height = get(gca,'Ylim');
   for ll=1:length(VerticalLinePosInTimeUnits)
    plot([VerticalLinePosInTimeUnits(ll),...
	  VerticalLinePosInTimeUnits(ll)],...
	  line_height(:), ...
	cat(2, d.SignFigure.VerticalLineStyle{ll}, 'k'));

   end
   hold off;
  end
 


% ********************************************************
% *                                                      *
% *  Dot Display + Unitary Events of selected pattern    *
% *                                                      *
% ********************************************************


r=[0.1 0.1 0.8 0.2];
pp.plotformat = 'ue_pat';
pp.pattern    = hash(sel_pat,c.Results.NumberOfNeurons,b.Results.Basis);
pp.pos        = r;
pp.figure     = gcf;
UEPFigure      = Xust_dot(uw,raw,b,c,pp,d);

% plot on top of the other the behavioral events
for i=1:length(d.UEMWAFigure.EventsToPlot)
  if ~isempty(c.Results.IdExistList == d.UEMWAFigure.EventsToPlot(i))
    ii = find(c.Parameters.EventList == ...
	d.UEMWAFigure.EventsToPlot(i));
     pp.plotformat = 'behav';
     pp.pos        = r;
     pp.figure     = f;
     pp.SelectedEvent = c.Parameters.EventList(ii);
     DotFigure=Xust_dot(uw,raw,b,c,pp,d);
  else
    display(['SelectedDisplayEventNotExistent'...
	      num2str(d.UEMWAFigure.EventsToPlot(i))]);
 end
end


% ***************************************
% *                                     *
% *          Print to file              *
% *                                     *
% ***************************************


name = [d.SignFigure.FileName cutString patString];

switch d.SignFigure.FileDevice 
  case {'eps','ps'}
   PrintCommand=['print ',...
       '-f', num2str(f),...
         ' -d' , ...
		  d.SignFigure.FileDevice, ...
	         'c2 ', ...     
	          name  , ...
		  '.'   , ...
		  d.SignFigure.FileDevice ...
		  ];
      disp(PrintCommand)
      drawnow
   eval(PrintCommand);
   disp('SignPlot: print to file');
 case 'off'
end

switch d.SignFigure.PrintDevice 
  case 'on'
    PrintCommand=['print '];
    eval(PrintCommand);
    disp('SignPlot: send to printer');
  case 'off'
end

    
switch d.SignFigure.Display
  case 'off'
    close(f)
end

%profile viewer
