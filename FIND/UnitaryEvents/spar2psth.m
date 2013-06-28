function psth=spar2psth(c,uw,ftype,sw)
% psth=spar2psth(c,uw,ftype,sw): calculate PSTHs of each neuron in c
% ***************************************************************
% *                                                             *
% * Input:   c:    Cut structure with data and information      *
% *                c.Results.TrialLengthInTimeUnits             *
% *                c.Results.NumberOfNeurons                    *
% *                c.Results.NumberOfNeurons                    *
% *                c.Results.Data                               *
% *                c.Parameters.TimeUnits                       *
% *                c.Results.TrialLengthInTimeUnits             *
% *                                                             *
% *          uw:   window width of smoothing window             *
% *                uw.Results.WindowWidthInTimeUnits            *
% *                uw.Results.WrapAround                        *
% *                                                             *
% *          ftype:type of smoothing filter to use:             *
% *                'boxwindow', 'gaussian'                      *
% *                                                             *
% *          sw:   (optional) smooth data with filter width     *
% *                of sw (half sided)                           *
% *                                                             *
% *                                                             *
% * Output:  psth: per column (!!!) the                         *
% *                PSTH of one neuron, in same order as in      *
% *                c.Parameters.NeuronList                      *
% *                if smoothed: data have the same length       *  
% *                (nr of rows) as input data                   *
% *          psth.Results.SmoothingFilter                       *
% *          psth.Results.WindowWidthInTimeUnits                *
% *          psth.Results.LossLeftInTimeUnits                   *
% *          psth.Results.LossRightInTimeUnits                  *
% *          psth.Results.Mat                                   *
% *                                                             *
% * Uses:    make_psth(), normpdf(), wrs()                      *
% *                                                             *
% * See also: SignPlot() as an example                          *
% *                                                             *
% * History:                                                    *
% *                                                             *
% *     (3) NO globals anymore, all in psth-Structure           *
% *        SG, 5.10.98                                          *
% *     (2) orientation of output matrix corrected              *
% *        SG, 24.3.97                                          *
% *     (1) smoothing implemented                               *
% *        SG, 23.3.97, Jerusalem                               *
% *     (0) first version                                       *
% *        SG, 19.12.96 Freiburg                                *
% *                                                             *
% ***************************************************************

% ***************************************
% *                                     *
% *        evaluate options             *
% *                                     *
% ***************************************

psth.Results.SmoothingFilter=ftype;% 'boxwindow', 'gaussian'


% ***************************************
% *                                     *
% *  construct the smoothing filter     *
% *                                     *
% ***************************************

switch psth.Results.SmoothingFilter
  case 'boxwindow'      
   filter=ones(uw.Results.WindowWidthInTimeUnits,1)/...
      uw.Results.WindowWidthInTimeUnits; 
   psth.Results.WindowWidthInTimeUnits=uw.Results.WindowWidthInTimeUnits;
   psth.Results.LossLeftInTimeUnits =floor(uw.Results.WindowWidthInTimeUnits/2);
   psth.Results.LossRightInTimeUnits=...
                     psth.Results.WindowWidthInTimeUnits -...
		     psth.Results.LossLeftInTimeUnits - 1; 

  case 'gaussian'
   sigma=sw/c.Parameters.TimeUnits;         % smoothing width given in ms
   delta=floor(3*sigma);                    % signal will be shortend by delta bins
   filter = normpdf(-delta:delta,0,sigma)'; % on both sides
   psth.Results.WindowWidthInTimeUnits = 2*delta+1;
   psth.Results.LossLeftInTimeUnits = delta;
   psth.Results.LossRightInTimeUnits= delta;

  otherwise
   error('Spar2Psth::UnknownSmoothingFilter');
end


% ***************************************
% *                                     *
% *           create PSTH               *
% *                                     *
% ***************************************
psth.Results.Mat = zeros(c.Results.TrialLengthInTimeUnits,...
                         c.Results.NumberOfNeurons);
		     
 for i=1:c.Results.NumberOfNeurons

  signal=make_psth(c.Results.Data{i},...
                   c.Results.TrialLengthInTimeUnits,...
		   c.Parameters.TimeUnits);

  switch uw.Results.WrapAround
   case 'off'
    cc=cat(1,cat(1,...
       zeros(psth.Results.LossLeftInTimeUnits,1),...
       wrs(signal',filter')'),...
       zeros(psth.Results.LossRightInTimeUnits,1)...
      );

   case 'onIDLVersion'
     l=length(signal);
     cc=wrs(cat(1,cat(1,...
            signal(l-(psth.Results.LossLeftInTimeUnits:-1:1)+1),...
            signal),...
            signal(1:psth.Results.LossRightInTimeUnits)...
           )',filter')';

   otherwise
    error('UEMWA::UnknownWrapAroundOption');
  end

  psth.Results.Mat(1:c.Results.TrialLengthInTimeUnits,i)=cc;
 end 

if strcmp(uw.Results.WrapAround,'onIDLVersion')
 psth.Results.LossLeftInTimeUnits = 0;
 psth.Results.LossRightInTimeUnits= 0;
end


% ***************************************************************
% *                  end of spar2psth                           *
% ***************************************************************
