function c=cut_gdf(gdf,p)
% c=cut_gdf(gdf,p): cutting data (gdf-format) relative to selected event(s)
% ********************************************************************
% *                                                                  *
% *                                                                  *
% * copyright (c) see licensetext.txt                                *
% *                                                                  *
% * Usage:                                                           *
% * -------                                                          *
% *                                                                  *
% * Input:                                                           *
% *       gdf: structure that contains information about gdf-data    *
% *                                                                  *
% *         gdf.Data        : contains gdf-data (read by read_gdf.m) *
% *         gdf.FileName    : file name gdf-data are from            *
% *         gdf.TimeUnits   : not used for calculation yet,          *
% *                           but for information                    *
% *                                                                  *
% *       p: structure that has to contain all cutting information:  *
% *                                                                  *
% *                p.NeuronList;                                     *
% *                p.EventList;                                      *
% *                p.CutEvent;                                       *
% *                p.TPre;                                           *
% *                p.TPost;                                          *
% *                p.TimeUnits;                                      *
% *                p.TrialOverlapMode                                *
% *                p.GeneralOptions.Compatibility                    *
% *                p.GeneralOptions.SpikeDataFormat                  *
% *                                                                  *
% *                                                                  *
% * Output: c: structure containing                                  *
% *           c.Parameters: input Parameters                         *
% *           c.Results   : cut results                              *
% *                                                                  *
% *          c.Parameters.NeuronList                                 *
% *          c.Parameters.EventList                                  *
% *          c.Parameters.CutEvent                                   *
% *          c.Parameters.TPre                                       *
% *          c.Parameters.TPost                                      *
% *          c.Parameters.TimeUnits                                  *
% *          c.Parameters.TrialOverlapMode                           *
% *          c.Results.FileName                                      *
% *          c.Results.Data                                          *
% *          c.Results.EventData                                     *
% *          c.Results.SpikeDataFormat                               *
% *          c.Results.IdExistList                                   *
% *          c.Results.PostCutInTimeUnits                            *
% *          c.Results.PreCutInTimeUnits                             *
% *          c.Results.TrialLengthInTimeUnits                        *
% *          c.Results.TrialLengthInMS                               *
% *          c.Results.TrialReductionMode                            *
% *          c.Results.NumberOfNeurons                               *
% *          c.Results.NumberOfEvents                                *
% *          c.Results.NumberOfTrials                                *
% *          c.Results.TrialList                                     *
% *                                                                  *
% *                                                                  *
% *                                                                  *
% *                                                                  *
% * ---------------------------------------------------------------- *
% *  soon obsolete, after version 1.3.7 full implemented:            *
% *                                                                  *
% *                                                                  *
% *  neuron_list  : list of selected neurons			             *
% *  event_list   : list of selected events                          *
% *  cut_event_list : list of events, relative to which the          *   
% *		      data will be cut                                       *
% *  t_pre_cut    : from time before cut event (in ms)               *
% *  t_post_cut   : to time after cut event  (in ms)		         *
% *  time_units   : time units of the data			                 *
% *  Input data: globalGDF : data in gdf-format (2 cols)	         *
% *						id  time	                                 *
% *								                                     *
% *  Output data: globalWorkCell :				                     *
% *								                                     *
% *	WorkCell						                                 *
% *	EventMat						                                 *
% * N_NEURON 						                                 *
% *	NEURON_LIST						                                 *
% *	N_EVENT EVENT_LIST					                             *
% *	CUT_EVENT_LIST						                             *
% *	ID_EXIST_LIST						                             *
% *	N_TRIAL							                                 *
% *	TRIAL_LIST						                                 *
% *	T_PRE_CUT						                                 *
% *	T_POST_CUT						                                 *
% *	TIME_UNITS						                                 *
% *	TRIAL_LENGTH						                             *
% * ---------------------------------------------------------------- *
% *								                                     *
% * Problems:                                                        *
% *          - time and temporary memory consumption critically      *
% *	       depends on the implementation of                          *
% *            where() and inrange().                                *
% * Future:                                                          *
% *        CLEAN Up old variables, when Cut-structure full           *
% *          in use                                                  *
% * Uses:							                                 *
% *       where(), inrange()					                     *
% *                                                                  *
% * See Also:                                                        *
% *           read_gdf(),                                            *
% *                                                                  *
% * TO DO:  OVERLAP "CAUSAL" and "EXCLUSIVE" do not work !!!!!!!!    *
% *                                                                  *
% * History:                                                         *
% *         (9) implemented new overlap method: "off"                *
% *            PM, 23.9.02, Goettingen                               *
% *         (8) general options no longer in workspace               *
% *            PM, 9.3.02, FfM                                       *
% *         (7) new input structures and output structures           *
% *             - all input and output in output structure           *
% *             - NO global variables, but OLD (global)              *
% *               variables still in use                             *
% *            SG, MD, 20.9.98, FfM                                  *   
% *         (6) overlap option added                                 *
% *            SG MD, 16.7.97, Jerusalem                             *
% *         (5) version 5  matrix operations                         *
% *            MD, 4.5.97, Freiburg                                  *
% *	        (4) transfer gdf-filename (without extension) 	         *
% *		        to global variable				                     *
% *	           SG, 25.3.97					                         *
% *         (3) vectorized, now intensively uses where and           *
% *             inrange                                              *
% *            MD, 23.3.97, Freiburg                                 *       
% *	        (2) commented					                         *
% *	           SG, 13.3.97					                         *
% *         (1) error check for (partly) empty event lists           *
% *	            val_exist() substituted with unique()		         *
% *            SG 13.3.97 Jerusalem  	                             *
% *         (0) first Version                                        *
% *            SG 2/96, Jerusalem                                    * 
% *                                                                  *
% *                                                                  *
% *                          diesmann@biologie.uni-freiburg.de       *
% *                          gruen@mpih.frankfurt.mpg.de             *
% *                                                                  *
% ********************************************************************

% next lines no longer in use PM 9.3.2002

%global GeneralOptions; namespace(GeneralOptions);
%checkstruct(GeneralOptions,{'Compatibility','SpikeDataFormat'});

% end of PM

checkstruct(p,{ ...
               'NeuronList', ...
               'EventList',  ...
               'CutEvent',   ...
               'TPre',       ...
               'TPost',      ...     
               'TimeUnits',   ...
	           'DataFormat', ...
	           'TrialOverlapMode' ...
               'GeneralOptions.Compatibility'...
               'GeneralOptions.SpikeDataFormat'...
	      });

c.Parameters.NeuronList       = p.NeuronList;
c.Parameters.EventList        = p.EventList;
c.Parameters.CutEvent         = p.CutEvent;
c.Parameters.TPre             = p.TPre;
c.Parameters.TPost            = p.TPost;
c.Parameters.TimeUnits        = p.TimeUnits;
c.Parameters.TrialOverlapMode = p.TrialOverlapMode;

%
%disp(c.Parameters.NeuronList)
%

% replace this in the file !
format  = p.GeneralOptions.SpikeDataFormat;
overlap = c.Parameters.TrialOverlapMode;


disp('cutting data ...');

% **************************************
% * create global WorkCell struct:     *
% *                                    *
% *                                    *
% **************************************

c.Results.FileName               = gdf.FileName(1:length(gdf.FileName)-4);
c.Results.SpikeDataFormat        = format;
c.Results.IdExistList            = unique(sort(row(gdf.Data(:,1))));
c.Results.PostCutInTimeUnits     = c.Parameters.TPost/c.Parameters.TimeUnits;
c.Results.PreCutInTimeUnits      = c.Parameters.TPre/c.Parameters.TimeUnits;
c.Results.TrialLengthInTimeUnits = ...
                                  - c.Results.PreCutInTimeUnits ...
		                  + 1 ...
			          + c.Results.PostCutInTimeUnits;
c.Results.TrialLengthInMS        = c.Results.TrialLengthInTimeUnits ...
                                  * c.Parameters.TimeUnits;
c.Results.TrialReductionMode     = 'none';
c.Results.NumberOfNeurons        = cols(c.Parameters.NeuronList);
c.Results.NumberOfEvents         = cols(c.Parameters.EventList);


%
%disp(gdf.Data)
%


% **************************************
% * check consistency of time units    *
% * information in GDF struct and cut  *
% * parameters                         *
% **************************************
if ~isempty(gdf.TimeUnits)
 if gdf.TimeUnits~=p.TimeUnits
  error('CutGDF::InconsistentTimeUnits');
 end
else
 gdf.TimeUnits=p.TimeUnits;
end


% **************************************************************
% * compatibility with older version                           *
% * requested?                                                 *
% *                                                            *
% * IDLVersion: Same definition of trial length.               *
% *             However, cut window was shifted by one         *
% *             unit of time resolution. In matlab versions    *
% *             the time resolution by definition equals the   *
% *             time unit of the input data. Shift by one      *
% *             TimeUnit is correct here.                      *
% *             See IDL cut_fct.pro (last updated 14.3.1995).  *
% *                                                            *
% *                                                            *
% **************************************************************
switch p.GeneralOptions.Compatibility
 case 'IDLVersion'
  c.Results.PreCutInTimeUnits  = c.Results.PreCutInTimeUnits  + 1;
  c.Results.PostCutInTimeUnits = c.Results.PostCutInTimeUnits + 1;
 otherwise
end


if c.Results.TrialLengthInTimeUnits <= 0
 error('cut_gdf::TrialLengthNegative');
end
			
% *****************************************************************
% * check and prepare spikes:                                     *
% *                                                               * 
% *    1. existence in GDF_MAT                                    *
% *    2. position in GDF_MAT (multiple occurrence allowed)       *
% *                                                               *
% *****************************************************************

if ~isempty(c.Parameters.NeuronList)
 sel_neuron_id_exist	= where(c.Results.IdExistList,c.Parameters.NeuronList);
 if isempty(sel_neuron_id_exist)
  error('cut_gdf::SelectedNeuronIDsNotExistent');
 else
  if elements(sel_neuron_id_exist) ~= elements(c.Parameters.NeuronList)
   disp(' WARNING::cut_gdf::NotAllSelectedNeuronIDsExistent');
  end
  spike_pos=where(gdf.Data(:,1),c.Parameters.NeuronList);
 end
else
 error('cut_gdf::NoNeuronIDSelected');
end

% *****************************************************************
% * check and prepare events:                                     *
% *                                                               * 
% *    1. existence in GDF_MAT                                    *
% *    2. position in GDF_MAT (multiple occurrence allowed)       *
% *                                                               *
% *****************************************************************

event_pos=[];

if ~isempty(c.Parameters.EventList)
 sel_event_id_exist	= where(c.Results.IdExistList,c.Parameters.EventList);
 if isempty(sel_event_id_exist)
  error('cut_gdf::SelectedEventIDsNotExistent');
  return;
 else
  if elements(sel_event_id_exist) ~= elements(c.Parameters.EventList)
   disp('WARNING::cut_gdf::NotAllSelectedEventIDsExistent');
  end
  event_pos=where(gdf.Data(:,1),c.Parameters.EventList);
 end
else
 disp('WARNING::cut_gdf::NoEventIDsSelected');
end

% *****************************************************************
% * check and prepare cut events:                                 *
% *                                                               * 
% *    1. existence in GDF_MAT                                    *
% *    2. position in GDF_MAT (multiple occurrence allowed)       *
% *                                                               *
% *****************************************************************

if ~isempty(c.Parameters.CutEvent) 
 cut_id_exist	= where(c.Results.IdExistList,c.Parameters.CutEvent);
 if isempty(cut_id_exist)
  error('cut_gdf::CutEventsNotExistent')
 else
  if elements(cut_id_exist) ~= elements(c.Parameters.CutEvent)
   disp('WARNING::cut_gdf::NotAllSelectedCutEventsExistent');
  end
  cut_event_pos=where(gdf.Data(:,1),c.Parameters.CutEvent);
 end 
else
  error('cut_gdf::NoCutEventsSelected')
end


disp('... cutting gdf data and putting it in gdfCell format ');

 id_list = [c.Parameters.NeuronList c.Parameters.EventList];

% *****************************************************************
% * determination of cut intervals                                *
% *                                                               * 
% *    1. compute cut event times                                 *
% *    2. take only non overlapping intervals                     *
% *                                                               *
% *****************************************************************


% ****************************************************************
% * compute cut event times:                                     *
% *    - compute list of positions (indices) of cut events in    *
% *      GDF data sorted by their occurrence in time             *
% *    - get times of these events                               *
% *                                                              *
% * Example:                                                     *
% *                                                              *
% *  g =            e =      j=where(g(:,1),e) =   g(j,2) =      *
% *                                                              *
% *     7   20         8                         1          20   *
% *     5   23         5                         2          23   *
% *     2   29         7                         6          36   *
% *     3   29         4                         7          41   *
% *     2   35                                   9          47   *
% *     8   36                                  10          52   *
% *     5   41                                                   *
% *     1   47                                                   *
% *     5   47                                                   *
% *     4   52                                                   *
% *                                                              *
% *                                                              *
% * g=[7 5 2 3 2 8 5 1 5 4; 20 23 29 29 35 36 41 47 47 52]';     *
% * e=[8 5 7  4]';                                               *
% *                                                              *
% ****************************************************************

cut_times = gdf.Data(cut_event_pos,2);


% ****************************************************************
% * take only non overlapping intervals                          *
% *                                                              *
% *                                                              *
% * A window of T_PRE_CUT bins to the left and  T_POST_CUT bins  *
% * to the right is assigned to each cut event.                  *
% *                                                              *
% * Two modes: overlap == 'exclusive','causal'                   *
% *                                                              *
% * 1. EXCLUSIVE                                                 *
% * Only those events where the window completely lies in the    *
% * range from tmin to tmax and does not overlap with any other  *
% * window are taken for further analysis                        *
% *                                                              *
% * Example:                                                     *
% *                T_PRE_CUT   T_POST_CUT                        *
% *                      <--- -->                                *
% *                          |                                   *
% *                        event                                 *
% *                                                              *
% *             taken           <--- -->                         *
% *      -->  <--- -->    <--- -->  |                  <---      *
% *     |..|------|-----------|-----|------------------|...|     *
% *     | tmin            not taken                   tmax |     *
% *     |                        not taken                 |     *
% *  virtual event                                 virtual event *
% *                                                              *
% *                                                              *
% * 2. CAUSAL                                                    *
% * Only those events, where the window completely lies in the   *
% * range from tmin to tmax and does not overlap                 *
% * with its left neighbour window, are taken for further        *
% * analysis                                                     *
% *                                                              *
% * Example:                                                     *
% *                T_PRE_CUT   T_POST_CUT                        *
% *                      <--- -->                                *
% *                          |                                   *
% *                        event                                 *
% *                                                  not taken   *
% *             taken           <--- -->          <--- -->       *
% *      -->  <--- -->    <--- -->  |                 |          *
% *     |..|------|-----------|-----|-----------------||         *
% *     | tmin              taken                   tmax         *
% *     |                        not taken                       *
% *  virtual event                                               *
% *                                                              *
% *                                                              *
% ****************************************************************


switch overlap
    
 case 'off'
     
   % nothing to do
   
 case 'exclusive'
        
   tmin=min(gdf.Data(:,2)) - c.Results.PostCutInTimeUnits;
   tmax=max(gdf.Data(:,2)) - c.Results.PreCutInTimeUnits;
   cut_times=cat(1,cat(1,tmin,cut_times),tmax);
   m=elements(cut_times);
   d1 =  cut_times(2:m-1) - cut_times(1:m-2);
   d2 =  cut_times(3:m)   - cut_times(2:m-1);
   d  = -c.Results.PreCutInTimeUnits + c.Results.PostCutInTimeUnits;
   cut_times = cut_times( 1 + find(d1>d & d2>d));
   if elements(cut_times)<m-2
     disp([int2str(m-2-elements(cut_times)) ' cut events excluded']);
 end
                                                  
 case 'causal'
   tmin=min(gdf.Data(:,2));
   tmax=max(gdf.Data(:,2));
   cut_times=cat(1,tmin-c.Results.PostCutInTimeUnits,cut_times);
   cut_times=cut_times(find(cut_times+c.Results.PostCutInTimeUnits<=tmax));
   m=elements(cut_times);
   d1 =  cut_times(2:m) - cut_times(1:m-1);
   d  = -c.Results.PreCutInTimeUnits + c.Results.PostCutInTimeUnits;
   cut_times = cut_times( 1 + find(d1>d));
   if elements(cut_times)<m-1
     disp([int2str(m-1-elements(cut_times)) ' cut events excluded']); 
   end

 otherwise
  error('cut_gdf::UnkownOverlapDirection');
 end

% ****************************************************************
% * cut interval ranges                                          *
% *                                                              *
% ****************************************************************
% number of trials
c.Results.NumberOfTrials = elements(cut_times);

% trial list
c.Results.TrialList      = 1:c.Results.NumberOfTrials;

cut_interval=zeros(c.Results.NumberOfTrials,2);
cut_interval(:,1)=cut_times+c.Results.PreCutInTimeUnits;
cut_interval(:,2)=cut_times+c.Results.PostCutInTimeUnits;


% ****************************************************************
% *                                                              *
% * 1. allocate Cell structures for Spikes and Events            *
% * 2. separate in spikes and events                             *
% * 3. fill Cell structures by first computing the 3d indices    *
% *     for each spike/event:                                    *
% *       i, neuron index (obtained from NEURON_LIST)            *
% *       j, time in trial (relative to cut_interval(k,1) )      *
% *       k, trial index                                         *
% *                                                              *
% **************************************************************** 

switch format
 case 'gdfcell'
  c.Results.Data=cell(c.Results.NumberOfNeurons,1);
  c.Results.EventData=cell(c.Results.NumberOfEvents,1);    
 case 'workcell'
  c.Results.Data=zeros(c.Results.TrialLengthInTimeUnits, ...
                       c.Results.NumberOfTrials,         ...
		       c.Results.NumberOfNeurons);
  c.Results.EventData=zeros(c.Results.TrialLengthInTimeUnits,...
                            c.Results.NumberOfTrials,        ...
			    c.Results.NumberOfEvents); 
 otherwise
  error('cut_gdf::UnkownOutputFormat');
end


%
% here you do not realize, if a single neuronID / eventID 
% does not have any spikes / events
% since all are computed/selected together
%


if ~isempty(spike_pos)
 s_gdf = gdf.Data(spike_pos,:);
 [e,k] = inrange(s_gdf(:,2),cut_interval);
 if ~isempty(e)
  j=s_gdf(e,2)-cut_interval(k,1) + 1;  % <---- CORRECT HERE ??????????, YES !
  i=s_gdf(e,1);
  [i, dummy]=where(i,c.Parameters.NeuronList');

% i neuron, j time, k trial

  switch format
   case 'gdfcell'
    for ni=1:c.Results.NumberOfNeurons
     ii=find(i==ni);
     c.Results.Data{ni}=cat(2,k(ii),j(ii));
    end
   case 'workcell'
    c.Results.Data(sub2ind(size(c.Results.Data),j,k,i))=ones(length(i),1);
  end
 else
  disp('WARNING::cut_gdf::NoSpikesInAllCutIntervals');
 end
 clear s_gdf;
end

for i=1:c.Results.NumberOfNeurons
 if isempty(c.Results.Data{i})
disp(['WARNING::cut_gdf::NoEventsFoundforNeuronID:' int2str(c.Parameters.NeuronList(i))]);
 end
end


if ~isempty(event_pos)
 e_gdf = gdf.Data(event_pos,:);
 [e,k] = inrange(e_gdf(:,2),cut_interval);
 if ~isempty(e)
  j=e_gdf(e,2)-cut_interval(k,1) + 1;
  i=e_gdf(e,1);
  [i, dummy]=where(i,c.Parameters.EventList');

  switch format
   case 'gdfcell'
    for ni=1:c.Results.NumberOfEvents
     ii=find(i==ni);
     c.Results.EventData{ni}=cat(2,k(ii),j(ii));
    end
   case 'workcell'
    c.Results.EventData(sub2ind(size(c.Results.EventData),j,k,i))=ones(length(i),1);
  end 
  
 else
  disp('WARNING::cut_gdf::NoEventsInAllCutIntervals');
 end
 clear e_gdf;
end

for i=1:c.Results.NumberOfEvents
 if isempty(c.Results.EventData{i})
disp(['WARNING::cut_gdf::NoEventsFoundforEventID:' int2str(c.Parameters.EventList(i))]);
 end
end
