function  retval = UEmwaPlot(uemwa,raw,bin,d,cut)
% retval = UEmwaPlot(uemwa,raw,bin,d,cut): 
% Dot Display, Raw Coincidences and Unitary Events
% ***************************************************************
% *                                                             *
% * Usage:   d.UEMWAFigure.Display = 'screen'                   *
% *          d.UEMWAFigure.Display = 'off'                      *
% *          d.UEMWAFigure.Device  = 'ps'                       *
% *          d.UEMWAFigure.Device  = 'eps'                      *
% *          d.UEMWAFigure.Device  = 'off'                      *
% *          d.UEMWAFigure.Text    = 'none'                     *
% *          d.UEMWAFigure.Text    = 'default'                  *
% *          d.UEMWAFigure.Text    = 'owntext'                  *
% *          d.UEMWAFigure.FileName= 'default'                  *
% *          d.UEMWAFigure.FileName= 'owntext'                  *
% *                                                             *
% * Input:   d: Datafile                                        *
% *          cut.Parameters.CutEvent                            *
% *          cut.Results.FileName                               *
% *                                                             *
% * Passes:  uemwa,raw,bin,cut (to Xust_dot.m)                  *
% *                                                             *
% * Output:  plot on screeen (small icon, or big)               *
% *          ps- or eps-file or print directly                  *	
% *                                                             *
% * See Also:                                                   *
% *          single_dot(), SignPlot()                           *
% *                                                             *
% * Uses:                                                       *
% *          Xust_dot()                                         *
% *                                                             *
% *                                                             *
% * History:                                                    *
% *       (6) passes variables to subfunction Xust_dot          *
% *          PM, 8.5.02, FfM                                    *
% *       (5) Uses now property strings for type of plot        *
% *          SG, 5.10.98, FfM                                   *
% *       (4) Uses NO globals anymore; more flexible            *
% *          SG, 28.9.98, FfM                                   *
% *       (3) string concatenation for print name               *
% *           extended to muliple cut events                    *
% *           and, if print-filename given, cut events not      *
% *           appended                                          *
% *          SG, 16.4.98, FfM                                   *
% *       (2) version 5 matrix operations                       *
% *          MD, 4.5.97, Freiburg                               *
% *       (1) white background; commented; print option         *
% *          SG, 26.3.97, Jerusalem                             *
% *       (0) first version                                     *
% *          SG 23.3.97, Jerusalem                              * 
% *                                                             *
% *                                                             *
% *                          diesmann@biologie.uni-freiburg.de  *
% *                          gruen@mpih-frankfurt.mpg.de        *
% *                                                             *
% ***************************************************************



% ***************************************
% *                                     *
% *           Set up Figure             *
% *                                     *
% ***************************************

f=figure;
set(f,'Units','centimeters');
set(f,'PaperType','a4letter');
set(f,'PaperUnits','centimeters');
set(f,'Color', 'white');
set(f,'InvertHardCopy','off');

if strcmp(d.UEMWAFigure.Display, 'off')        % no big display on screen
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
% *    put filename on top of plot      *
% *                                     *
% ***************************************
r = [0.15,0.9, 0.8,0.1];
th = axes;
set(th,'Position',r);
set(th,'visible','off');



% string generation of cut event list
sp = 'c';
for i=1:length(cut.Parameters.CutEvent)
 sp = strcat(sp, '\_',int2str(cut.Parameters.CutEvent(i)));
end

text2write = d.UEMWAFigure.Text; 
text2write(findstr(text2write, '_'))='-';
text(-0.1,0.75, text2write,...
      'FontSize',d.UEMWAFigure.TextFontSize, 'Color','black');

  
% ***************************************
% *                                     *
% *            Dot Display              *
% *                                     *
% ***************************************
r = [0.15,0.7, 0.8,0.2];

pp.plotformat = 'dot';
pp.pos        = r;
pp.figure     = f;
DotFigure=Xust_dot(uemwa,raw,bin,cut,pp,d);

% plot on top of the other the events
for i=1:length(d.UEMWAFigure.EventsToPlot)
  if ~isempty(cut.Results.IdExistList == d.UEMWAFigure.EventsToPlot(i))
    ii = find(cut.Parameters.EventList == ...
	d.UEMWAFigure.EventsToPlot(i));
     pp.plotformat = 'behav';
     pp.pos        = r;
     pp.figure     = f;
     pp.SelectedEvent = cut.Parameters.EventList(ii);
     DotFigure=Xust_dot(uemwa,raw,bin,cut,pp,d);
  else
    display(['SelectedDisplayEventNotExistent'...
	      num2str(d.UEMWAFigure.EventsToPlot(i))]);
 end
end

  
  
% ***************************************
% *                                     *
% *          Raw Coincidences           *
% *                                     *
% ***************************************
r = [0.15,0.4,0.8,0.2];
pp.plotformat = 'raw';
pp.pos        = r;
pp.figure     = f;
RawDotFigure  = Xust_dot(uemwa,raw,bin,cut,pp,d);


% ***************************************
% *                                     *
% *          Unitary Events             *
% *                                     *
% ***************************************
r = [0.15,0.1,0.8,0.2];
pp.plotformat = 'ue';
pp.pos        = r;
pp.figure     = f;
UEPlot        = Xust_dot(uemwa,raw,bin,cut,pp,d);


% ***************************************
% *                                     *
% *           Print to file             *
% *                                     *
% ***************************************




switch d.UEMWAFigure.FileName
  case 'default'
    name = [strrep(d.FileName,'-','_') 'UE'];
  case 'addtext'
    name = [strrep(d.FileName,'-','_') 'UE' d.UEMWAFigure.FileName];
  otherwise
    name = [d.UEMWAFigure.FileName];
end

switch d.UEMWAFigure.FileDevice 
  case {'eps','ps'}
   Printcommand=['print ',...
         '-f',num2str(f),...
         ' -d' , ...
		  d.UEMWAFigure.FileDevice, ...
	         'c2 ', ...       
	          name  , ...
		  '.'   , ...
		  d.UEMWAFigure.FileDevice ...
		];
         disp(Printcommand)
         drawnow
   eval(Printcommand);
   disp('UEmwaPlot: print to file'); drawnow
  case 'off'
end

switch d.UEMWAFigure.PrintDevice 
  case 'on'
    Printcommand=['print '];
    eval(Printcommand);
    disp('UEmwaPlot: send to printer');
  case 'off'
end

    
switch d.UEMWAFigure.Display
 case 'off'
    close(f)
end

    

if nargout > 0
  retval = [gcf];
end; 

% *******************************************************
% *                  end of UEmwaPlot                   *
% *******************************************************
