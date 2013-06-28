function Window = UEMWACutAnalysisWindow(ii,...
                                         position,...
                                         WindowBinCenter,...
                                         WindowBinIndices,...
                                         WrapAroundOption,...
                                         TrialLengthInBins,...
                                         BinCell)
% Window = UEMWACutAnalysisWindow(ii,...
%                                 position
%                                 WindowBinCenter,...
%                                 WindowBinIndices,...
%                                 WrapAroundOption,...
%                                 TrialLengthInBins,...
%                                 BinCell) 
% ***************************************************************
% *                                                               *
% * copyright (c) see licensetext.txt                             *
% *                                                               *
% *                                                             *
% * Usage:           COMMENT !!!!!!!!!!                         *
% *                                                             *
% * Input:    ii (Number of window to cut)                      *
% *           position (position of window)                     *
% *           uw.Results.WindowBinCenter (time to put result)   *
% *           uw.Results.WindowBinIndices (index array)         *
% *           uw.Results.WrapAround (option)                    *
% *           Bin.Results.TrialLengthInBins                     *
% *           Bin.Results.Cell (cell of binned data)            *
% *                                                             *
% * Output:   structure Window with fields:                     *
% *                                                             *
% *           Window.Data                                       *
% *           Window.Parameters.Windownumber                    *
% *           Window.Parameters.Wrange                          *
% *           Window.Parameters.Time                            *
% *                                                             *
% * Uses:     wraparound()                                      *
% *                                                             *
% * History: (2) implemented WindowShift                        *
% *             PM, 14.9.02, FfM                                *
% *          (1) function created while separating whole UEMWA- *
% *              analysis into individual functions             *
% *             PM, 20.2.02, FfM                                *
% *                                                             *
% * To Do:    Implementation of offset feature                  *
% *                                                             *
% ***************************************************************

Window.Parameters.Windownumber = ii;
Window.Parameters.Time = position + WindowBinCenter; 

switch  WrapAroundOption
  case 'off'
   Window.Parameters.Wrange = position + WindowBinIndices;
  case 'onIDLVersion'
   Window.Parameters.Wrange = wraparound(position + WindowBinIndices,...
                                         TrialLengthInBins);
  otherwise 
   error('UEMWA::UnknownWrapAroundOption');
end
  
% *******************************
% * cut window from BinWorkCell *
% *******************************

Window.Data = BinCell(Window.Parameters.Wrange,:,:);
