function UESetupCreateDefaultParameterFile()
% function UESetupCreateDefaultParameterFile()
% ******************************************************************
% *                                                                *
% * creates new UEParameters_Default.mat file                      *
% *                                                                *
% * Usage:   Function creates a new UEParameters_Default.mat file, *
% *          containing a DataFile structure with members set in   *
% *          the "Write new default Parameter File" section.       *
% *                                                                *
% * History: 2) introduced CSR parameters and UEMWA WindowShift    *
% *             PM, 14.9.02, FfM                                   *
% *          1) first version                                      *
% *             PM, 16.8.02, FfM                                   *
% *                                                                *
% ******************************************************************

% ******************************************************************
% *                                                                *
% *  Initialize Default Parameters of DataFile structure           *
% *                                                                *
% ******************************************************************
    
DataFile.FileName =  '';
DataFile.OutPath = '';
DataFile.OutFileName = '';
DataFile.SaveResult.Mode = 'off'; % 'on'
DataFile.ListofallEvents = []; % only used by gui, not relevant for analysis
DataFile.NeuronList = [];
DataFile.EventList = [];
DataFile.CutEvent = [];
DataFile.TPre = -500;
DataFile.TPost = 1500;
DataFile.TimeUnits = 1;
DataFile.TrialOverlapMode = 'off'; % 'exclusive', 'causal'
DataFile.GeneralOptions.Compatibility = '';  % 'IDLVersion'
DataFile.GeneralOptions.TimeDisplayMode = 'discrete';      % 'real'
DataFile.GeneralOptions.SpikeDataFormat = 'gdfcell';   % 'workcell'
DataFile.GeneralOptions.ShowSplashScreen = 'on';       % 'off'
DataFile.SelectMode = 'none'; % 'first','last','even','odd','explicit','repeat','random','eliminate'
DataFile.SelectEvent = [];
DataFile.SortMode = 'none'; % 'duration','difference','random'
DataFile.SortEvent = [];
DataFile.ShiftMode = 'none'; % 'on'
DataFile.ShiftWidth = [];
DataFile.ShiftNeuronList = [];
DataFile.Analysis.Alpha = 0.05;
DataFile.Analysis.Complexity = 2;
DataFile.Analysis.Binsize = 5;
DataFile.Analysis.TSlid = 100;
DataFile.Analysis.UEMethod = 'trialaverage';  % 'trialaverage','csr'
DataFile.Analysis.Wildcard = 'off';           % 'off'
DataFile.Analysis.WindowShift = 1;
DataFile.PVM.ParallelMode = 'off';  % 'off'
DataFile.PVM.ScratchDirName = '/scratch/messer/';
DataFile.PVM.AutomaticDelete = 'on';  % 'off'
DataFile.PVM.NumberOfJobs = 8;
DataFile.PVM.NumberOfProcessors = 1;
DataFile.CSR.NShuffleElements = 1000;
DataFile.CSR.NMCSteps = 10000;
DataFile.CSR.gen_case = 'random'; % 'allper'
DataFile.UEMWAFigure.Display = 'screen'; % 'off'
DataFile.UEMWAFigure.FileDevice = 'off'; % 'ps','eps'
DataFile.UEMWAFigure.PrintDevice = 'off'; % 'on'
DataFile.UEMWAFigure.Text = ''; 
DataFile.UEMWAFigure.FileName = '';
DataFile.UEMWAFigure.EventsToPlot = ''; % DataFile.EventList
DataFile.UEMWAFigure.TextFontSize = 18;
DataFile.UEMWAFigure.VerticalLinePosInMS = [-500 0 500 1000 1500];  
DataFile.UEMWAFigure.VerticalLineStyle = {'-','-','-','-','-'}; % empty: ''
DataFile.UEMWAFigure.VerticalLineWidth = {0.75, 0.75, 0.75, 0.75, 0.75}; % empty: []
DataFile.UEMWAFigure.VerticalLineText = {'-500' '0' '500' '1000' '1500'}; % empty: []
DataFile.SignFigure.Display = 'screen'; % 'off'
DataFile.SignFigure.FileDevice = 'off'; % 'ps','eps'
DataFile.SignFigure.PrintDevice = 'off'; % 'on'
DataFile.SignFigure.FileName = ''; % DataFile.OutFileName;
DataFile.SignFigure.Text = ''; 
DataFile.SignFigure.PatSel = ':'; % ':' % [1 0 0] specify pattern
DataFile.SignFigure.TextFontSize = 18; %DataFile.UEMWAFigure.TextFontSize; 
DataFile.SignFigure.EventsToPlot = []; %DataFile.UEMWAFigure.EventsToPlot;
DataFile.SignFigure.VerticalLinePosInMS = []; %DataFile.UEMWAFigure.VerticalLinePosInMS;
DataFile.SignFigure.VerticalLineStyle = ''; %DataFile.UEMWAFigure.VerticalLineStyle;
DataFile.SignFigure.VerticalLineWidth = []; %DataFile.UEMWAFigure.VerticalLineWidth;
DataFile.SignFigure.VerticalLineText = ''; %DataFile.UEMWAFigure.VerticalLineText;
DataFile.DotDisplay.TrialDisplayMode = 'from_top'; %'from_bottom'
DataFile.DotDisplay.Interactive = 'off'; %'on'
DataFile.DotDisplay.DotMarker = 'o'; 
DataFile.DotDisplay.DotColor = [0 0 0];
DataFile.DotDisplay.DotHeightPercentage = 0.01;
DataFile.DotDisplay.Raw.Marker = 's';
DataFile.DotDisplay.Raw.Color = [0 1 0];
DataFile.DotDisplay.Raw.MarkerHeightPercentage = 0.1;
DataFile.DotDisplay.UE.Marker = 's';
DataFile.DotDisplay.UE.Color = [1 0 0];
DataFile.DotDisplay.UE.MarkerHeightPercentage = 0.1;
DataFile.DotDisplay.Behavior.Marker = 'd';
DataFile.DotDisplay.Behavior.Color = [0 0 1];
DataFile.DotDisplay.Behavior.MarkerHeightPercentage = 0.1;
DataFile.FontSize = 14;

save UEParameters_Default DataFile;
