function UEMain(DataFile)
% function UEMain(DataFile)
% *****************************************************************
% * UE Software Version 2.0                                       *
% * -------------------------                                     *
% *  SG, 7.10.98                                                  *
% *                                                               *
% * copyright (c) see licensetext.txt                             *
% *                                                               *
% *                    MAIN PROGRAM                               *
% *                                                               *
% *                                                               *
% *                                                               *
% *****************************************************************
% *                                                               *
% * Input:  DataFile: Datafile-structure, initialized in setup-   *
% *                   file, containing analysis parameters and    *
% *                   gdf-data (see setup-file for description    *
% *                   of all needed structure members)            *
% *                                                               *
% * Output: various analysis plots and saved data of Unitary      *
% *         Event analysis, depending on analysis parameters      *
% *                                                               *
% * Uses:   UEversion()                                           *
% *         read_gdf()                                            *
% *         cut_gdf()                                             *
% *         SelectTrials()                                        *
% *         sortdata()                                            *
% *         shiftdata()                                           *
% *         binclip()                                             *
% *         UE()                                                  *
% *         sandclock()                                           *
% *         UEMWASetParameters()                                  *
% *         UEMWACutAnalysisWindow()                              *
% *         UEMWAAnalyseWindow()                                  *
% *         UEMWACollectData()                                    *
% *         spar2psth()                                           *
% *         SaveResults()                                         *
% *         UEmwaPlot()                                           *
% *         inv_hash()                                            *
% *         SignPlot()                                            *
% *                                                               *
% *                                                               *
% * History (of parallelized version)                             *
% *                                                               *
% *         (6) - parallel mode can now handle multiple scratch   *
% *               directories                                     *
% *             - the load balancing by randomizing the window    *
% *               ids has been implemented                        *
% *             - the nice priority value can now be set          *
% *            MSK, 22.06.05, Berlin                              *
% *         (5) UEMain() can now be run either in serial mode or  *
% *             in parallel mode                                  *
% *            PM, 19.9.02, Goettingen                            *
% *         (4) passed CSR parameters and introduced              *
% *             UEMWA WindowShift.                                *
% *            PM, 14.9.02, FfM                                   *
% *         (3) Removed all global variables                      *
% *             (Cut, Raw, Bin, UE, Psth, UEmwa, uw)              *
% *            PM, 6.8.02, FfM                                    *
% *         (2) Replaced global GeneralOptions by member of       *
% *             DataFile-structure                                *
% *            PM, 11.3.02, FfM                                   *
% *         (1) Splitting of original UEMWA.m.                    *
% *             Structure of UEMWA-analysis should now allow      *         
% *             parallel execution                                *
% *            PM, 20.2.02, FfM                                   *
% *                                                               *
% *****************************************************************

% ***************************************
% *                                     *
% *    display version information      *
% *                                     *
% ***************************************

UEversion(DataFile(1).GeneralOptions.ShowSplashScreen);


% ***************************************
% *                                     *
% *  loop over analysis descriptions    *
% *                                     *
% ***************************************

for i=1:length(DataFile)

% ***************************************
% *                                     *
% *  read data                          *
% *                                     *
% ***************************************

disp([DataFile(i).FileName '.gdf'])
gdf=read_gdf([DataFile(i).FileName '.gdf']);

% ***************************************
% *                                     *
% *  cut data                           *
% *                                     *
% ***************************************

Cut=cut_gdf(gdf,DataFile(i));

% ***************************************
% *                                     *
% *  select some (all) trials           *
% *                                     *
% ***************************************

if ~strcmp(DataFile(i).SelectMode,'none')
  Cut = SelectTrials(DataFile(i).SelectMode, DataFile(i).SelectEvent,Cut);
end

if ~strcmp(DataFile(i).SortMode,'none')
  Cut = sortdata(Cut,DataFile(i).SortMode,...
                   DataFile(i).SortEvent,...
                   DataFile(i).GeneralOptions.SpikeDataFormat);
end

if ~strcmp(DataFile(i).ShiftMode,'none')
  Cut = shiftdata(Cut,...
                   DataFile(i).ShiftMode,...
                   DataFile(i).ShiftWidth,...
                   DataFile(i).ShiftNeuronList,...
                   DataFile(i).GeneralOptions.SpikeDataFormat);
end


% ***************************************
% *                                     *
% *  bin data                           *
% *                                     *
% ***************************************
disp('bin data ...')
Bin = binclip(DataFile(i).Analysis.Binsize,Cut);

% ***************************************
% *                                     *
% *  Unitary Events Analysis            *   
% *                                     *
% ***************************************

[Raw,UE]= ue(DataFile(i).Analysis.Alpha, ...
             DataFile(i).Analysis.Complexity,...
             Cut,Bin);
	 

         
% ***************************************
% *                                     *
% *  Unitary Events Analysis            *
% *  with moving window                 *
% *                                     *
% ***************************************


    % *****************************************************
    % * set parameters for UEMWA-analysis and store them  *
    % * in structure uw                                   *
    % *****************************************************
     
    uw = UEMWASetParameters(DataFile(i).Analysis.TSlid,...
                            DataFile(i).Analysis.Alpha,...
                            DataFile(i).Analysis.Complexity,...
                            DataFile(i).Analysis.UEMethod,...
                            DataFile(i).Analysis.Wildcard,...
                            DataFile(i).Analysis.WindowShift,...
                            Cut.Parameters.TimeUnits,...
                            Bin.Results.BinsizeInTimeUnits,...
                            Bin.Results.TrialLengthInBins,...
                            DataFile(i).GeneralOptions.Compatibility,...
                            DataFile(i).CSR.NShuffleElements,...
                            DataFile(i).CSR.NMCSteps,...
                            DataFile(i).CSR.gen_case,...
                            DataFile(i).PVM.AllScratchesDir,...
                            DataFile(i).PVM.UsersScratchLink,...
                            DataFile(i).PVM.PartScratchesList,...
                            DataFile(i).PVM.NumberOfJobs,...
                            DataFile(i).PVM.ParallelMode,...
                            DataFile(i).PVM.NumberOfProcessors,...
                            DataFile(i).PVM.AutomaticDelete,...
                            DataFile(i).PVM.NicePriority,...
                            DataFile(i).PVM.RandomizeWindows);
      
    % *********************************************************
    % *                                                       *
    % *          start UE Moving Window Analysis              *
    % *                                                       *
    % *********************************************************

    
    % *********************************************************
    % * check whether analysis should be performed in         *
    % * parallel or serial mode                               *
    % *********************************************************
     
    switch uw.Results.ParallelMode
        
        case 'on'   % PARALLEL MODE
            
            % *************************************************************
            disp(' TO DO (SG, 8.8.2003) option for local/mount disk')
            % Here a number of options regarding the file system should be 
            % included: 
            % 1) only one local disk (as implemented here)
            % 2) each node uses its own local disk, and disks are
            %    visible to all by NFS ('mount')
            % 3) each node uses its own local disk, and disks are
            %    NOT visible to all by NFS, but results must be copied via scp
            % *************************************************************
            
            % Create new structure AnalysisInputData containing all data and
            % parameters, that are needed in the analysis of any moving window
            % and store these data to a file called AnalysisInputData.mat in
            % the directory specified by uw.Results.ScratchDirName.
            % This file does then get loaded by each job in the Makefile.
            
            AnalysisInputData.WindowBinCenter = uw.Results.WindowBinCenter;
            AnalysisInputData.WindowBinIndices = uw.Results.WindowBinIndices;
            AnalysisInputData.WrapAround = uw.Results.WrapAround;
            AnalysisInputData.TrialLengthInBins = Bin.Results.TrialLengthInBins;
            AnalysisInputData.Cell = Bin.Results.Cell;
            AnalysisInputData.Alpha = uw.Results.Alpha;
            AnalysisInputData.Complexity = uw.Results.Complexity;
            AnalysisInputData.UEMethod = uw.Results.UEMethod;
            AnalysisInputData.Wildcard = uw.Results.Wildcard;
            AnalysisInputData.Basis = Bin.Results.Basis;
            AnalysisInputData.ExistingPatterns = Raw.Results.ExistingPatterns;
            AnalysisInputData.NShuffleElements = uw.Results.NShuffleElements;
            AnalysisInputData.NMCSteps = uw.Results.NMCSteps;
            AnalysisInputData.gen_case = uw.Results.gen_case;
            
% MSK ---------------------------------------------------------------------
            %savefilename = [uw.Results.ScratchDirName 'AnalysisInputData.mat'];
            savefilename = 'AnalysisInputData.mat';
% -------------------------------------------------------------------------
            save(savefilename,'AnalysisInputData')
            
            % ********************************************************
            % * perform UEMWA analysis in parallel mode using ppmake *
            % ********************************************************
            
            methodstring = ['UEMWA-Analysis using: ' uw.Results.UEMethod ...
                    ' (parallel Mode)'];
            disp(methodstring)
            
            % make sure number of jobs is not greater than number of windows
            if (uw.Results.NumberOfWindows < uw.Results.NumberOfJobs)
                uw.Results.NumberOfJobs = uw.Results.NumberOfWindows;
                disp(['There are more jobs than windows. '...
                        'Reduced number of jobs to : ' uw.Results.NumberOfJobs ]);
            end
            
            
% MSK ---------------------------------------------------------------------
            % *************************************************************
            % * The load balancing option can be turned 'on' and 'off' in *
            % * the parameter DataFile.PVM.RandomizeWindows. The value    *
            % * for the nice priority can be set in the parameter         *
            % * DataFile.PVM.NicePriority and should lie between 19       *
            % * (lowest priority) and 0 (highest priority)                *
            % *************************************************************
            
            % extract CTF archive before distribution
            system(sprintf('%s/toolbox/compiler/deploy/%s/extractCTF %s/UEMainAnalyseWindow.ctf',...
                   matlabroot,getenv('ARCH'),pwd));
            
            CreateMakeFile(uw.Results.UsersScratchLink,...
                uw.Results.NumberOfWindows,...
                uw.Results.WindowShift,...
                uw.Results.NumberOfJobs,...
                uw.Results.NicePriority,...
                uw.Results.RandomizeWindows);
% -------------------------------------------------------------------------
            
            execstring = ['!ppmake -b -m' num2str(uw.Results.NumberOfProcessors) ];
            eval(execstring);
            
            % delete AnalysisInputData.mat if desired
            if isequal(uw.Results.AutomaticDelete,'on')
                execstring = ['!rm ' savefilename ];
                eval(execstring);
                execstring = ['!rm Makefile' ];
                %eval(execstring);
            end
                      
% MSK ---------------------------------------------------------------------
          % *************************************************************
          % * Move result files from the scratch directory of each host *
          % * into a temporary scratch directory                        *
          % *************************************************************
                    
          TempScratchDir = sprintf('%s/tmp_scratch/',getenv('HOME'));
          try
              mkdir(TempScratchDir)
          catch
              disp(lasterr)
          end
          for x = 1:size(uw.Results.PartScratchesList,1)
              try
                  movefile(sprintf('%s%s/%s/UEResultsOfJob*',uw.Results.AllScratchesDir,...
                           uw.Results.PartScratchesList{x},getenv('USER')),TempScratchDir)
              catch
                  disp(sprintf('No result file(s) in %s%s/%s/',uw.Results.AllScratchesDir,...
                       uw.Results.PartScratchesList{x},getenv('USER')))
              end
          end
% -------------------------------------------------------------------------

          % ****************************************************
          % * collect all result files and save them to UEinMW *
          % ****************************************************


          for ii = 1:uw.Results.NumberOfJobs

              % Load results file of each job. 
              %
              % These files will contain a UEMWAResults structure
              % and a PositionArray.
              % Member UEMWAResults(i) will contain the analysis results 
              % of the moving window analysis of the ith window, that was 
              % performed in that job.
              % The PositionArray has stored the positions of all the 
              % analysed windows of that particular job. 
              
              disp(['reading Analysis Results of Job: ' num2str(ii) ]);
              PositionArray = [];
                           
%               loadfilename = [uw.Results.ScratchDirName 'UEResultsOfJob' ...
%                               num2str(ii) '.mat'];
%               load(loadfilename);
              
% MSK----------------------------------------------------------------------              
              loadfilename = [TempScratchDir 'UEResultsOfJob' num2str(ii) '.mat'];
              load(loadfilename);
% -------------------------------------------------------------------------

              
              if ~isempty(PositionArray)
                 % assign UEMWAResults.position to structure UEinMW
                 for j = 1:length(PositionArray)
                     if ~(PositionArray(j) == 1)
                          NumberOfWindow = ((PositionArray(j) - 1)/...
                                            uw.Results.WindowShift) + 1;
                     else
                          NumberOfWindow = 1;
                     end
                     UEinMW(NumberOfWindow) = UEMWAResults(j);
                 end
                 clear UEMWAResults;
                 clear PositionArray;
              else
                 errorstring = ['Could not load valid results from ' ...
                                 loadfilename ];
                 error(errorstring);
              end
              
              % delete the file if desired
              if isequal(uw.Results.AutomaticDelete,'on')
                 execstring = ['!rm ' loadfilename ];
                 eval(execstring);
              end
 
          end % of collecting for-loop
          
% MSK ---------------------------------------------------------------------
          % delete temporary scratch directory 
          try
              rmdir(TempScratchDir,'s')
          catch
              disp(lasterr)
          end
% -------------------------------------------------------------------------
          
   
     case 'off'   % SERIAL MODE
           
          
          % ****************************************
          % * loop over all window positions       *
          % ****************************************
    
          methodstring = ['UEMWA-Analysis using: ' uw.Results.UEMethod ...
                          ' (serial Mode)'];
          disp(methodstring)
          
          sandclock('create',uw.Results.NumberOfWindows);

          position = 1;
                   
          for ii=1:uw.Results.NumberOfWindows

              sandclock('set',ii);
              
              % cut window ii out of binned Data 
              Window = UEMWACutAnalysisWindow(ii,position,...
                                        uw.Results.WindowBinCenter,...
                                        uw.Results.WindowBinIndices,...
                                        uw.Results.WrapAround,...
                                        Bin.Results.TrialLengthInBins,...
                                        Bin.Results.Cell);
              
              % perform analysis in window
              UEinMW(ii) = UEMWAAnalyseWindow(uw.Results.Alpha,...
                                        uw.Results.Complexity,...
                                        uw.Results.UEMethod,...
                                        uw.Results.Wildcard,...
                                        Bin.Results.Basis,...
                                        Raw.Results.ExistingPatterns,...
                                        Window,...
                                        uw.Results.NShuffleElements,...
                                        uw.Results.NMCSteps,...
                                        uw.Results.gen_case);
                            
              % shift position by Window Shift
              position = position + uw.Results.WindowShift;

          end
          
          sandclock('close');
    
     end   % end of switch uw.Results.ParallelMode
     
    
% ***************************************************
% *  collect analysis-data of each window stored in *         
% *  UEinMW("WindowNumber") and write it to UEmwa   *
% ***************************************************
     
UEmwa = UEMWACollectData(UEinMW,uw,Raw,Cut,Bin);


% ***************************************
% *                                     *
% *  Calculate Psth                     *               
% *                                     *
% ***************************************

Psth=spar2psth(Cut,UEmwa,'boxwindow');
  
	  
% ***************************************
% *                                     *
% *  Save informations to file          *
% *                                     *
% ***************************************

% TO DO !!!!!!!!!
if strcmp(DataFile(i).SaveResult.Mode,'on')
 SaveResults(DataFile(i),Cut,Bin,Raw,UEmwa,Psth);
end


% ***************************************
% *                                     *
% *  Plot Unitary Events                * 
% *                                     *
% ***************************************

UEmwaPlot(UEmwa,Raw,Bin,DataFile,Cut);


% ***************************************
% *                                     *
% *  Plot Unitary Events                *
% *  of selected pattern                *
% *                                     *
% ***************************************

minc = DataFile(i).Analysis.Complexity;
%maxc = Cut.Results.NumberOfNeurons;

maxc = DataFile.Analysis.ComplexityMax;

if strcmp(DataFile(i).SignFigure.PatSel, ':')         
  patseltmp = inv_hash(Raw.Results.ExistingPatterns,...
                       Cut.Results.NumberOfNeurons,...
                       Bin.Results.Basis);
  patseltmp = patseltmp(find(sum(patseltmp,2)>=minc & ...
                             sum(patseltmp,2)<=maxc ),:);
  
  for p=1:size(patseltmp,1)
    SignPlot(Psth,UEmwa,Raw,Bin,Cut,patseltmp(p,:),DataFile(i));
  end  
else
    SignPlot(Psth,UEmwa,Raw,Bin,Cut,DataFile(i).SignFigure.PatSel,DataFile(i));
end


% ***************************************
% *                                     *
% *  end of loop over all analysis      *
% *  descriptions                       *
% *                                     *
% ***************************************

end


%-------------------------------------------------
% end
%-------------------------------------------------
