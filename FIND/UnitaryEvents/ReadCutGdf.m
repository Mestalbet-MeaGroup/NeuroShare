% script 

% *****************************************************************
% * UE Software Version 1.3.7                                     *
% * -------------------------                                     *
% *                                                               *
% *  PM, 5.8.02                                                   * 
% *     updated                                                   *
% *  SG, 25.9.00                                                  *
% *     READ and CUT gdf-data script                              *
% *                                                               *
% *                                                               *
% *                                                               *
% *****************************************************************


% ***************************************
% *					*
% * display version information         *
% *					*
% ***************************************
UEversion(DataFile(1).GeneralOptions.ShowSplashScreen);


% ***************************************
% * loop over analysis descriptions     *
% *                                     *
% *                                     *
% ***************************************
for i=1:size(DataFile,1)

% ***************************************
% *					*
% * read data				*
% *					*
% ***************************************
gdf=read_gdf([DataFile(i).FileName '.gdf']);


% ***************************************
% *					*
% * cut data				*
% *					*
% ***************************************
Cut=cut_gdf(gdf,DataFile(i));


% ***************************************
% *					*
% * select some (all) trials	        *
% *					*
% ***************************************
if ~strcmp(DataFile(i).SelectMode,'none')
  Cut = SelectTrials(DataFile(i).SelectMode, DataFile(i).SelectEvent,Cut);
end

if ~strcmp(DataFile(i).SortMode,'none')
 Cut=sortdata(Cut,DataFile(i).SortMode,...
                  DataFile(i).SortEvent,...
                  DataFile(i).GeneralOptions.SpikeDataFormat);
end

if ~strcmp(DataFile(i).ShiftMode,'none')
 Cut = shiftdata(Cut,...
                 DataFile(i).ShiftMode,...
                 DataFile(1).ShiftWidth,...
                 DataFile(1).ShiftNeuronList);
end


% ***************************************
% *					*
% * bin data				*
% *					*
% ***************************************
Bin = binclip(DataFile(i).Analysis.Binsize,Cut);


end
%-------------------------------------------------
% end
%-------------------------------------------------
