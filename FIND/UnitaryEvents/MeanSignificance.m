function SaveFileNameMat  = OverallSignificance(d,c,b,r,uw,psth)
% SaveFileNameMat=SaveResults(d,c,b,r,uw,psth): save results in various files 
% ***********************************************************************
% *	                                                                *
% * input: structures containing results from different levels          *
% *        of analysis 							*
% *        d: DataFile, analysis parameters, defined in Main Script
% *        c: Cut,      results and parameter structure from 
% *                     Cut=cut_gdf(gdf,DataFile(i));
% *        b: Bin,      results and parameter structure from
% *                     Bin = binclip(DataFile(i).Analysis.Binsize,Cut);
% *        r: Raw,      results and parameter structure from
% *                     [Raw,UE]= UE(DataFile(i).Analysis.Alpha, ...
% *                               DataFile(i).Analysis.Complexity,...
% *                               Cut,Bin);
% *       uw:UEmwa,  	results and parameter structure from
% *                     UEmwa = UEMWA(DataFile(i).Analysis.TSlid,...
% *                                   DataFile(1).Analysis.Alpha,...
% *                                   DataFile(1).Analysis.Complexity, ...
% *                       	      DataFile(1).Analysis.UEMethod, ...
% *                                   DataFile(1).Analysis.Wildcard, ...
% *                                   Cut,Bin,Raw,UE);
% *     psth: Psth,     rates from Psth=spar2psth(Cut,UEmwa,'boxwindow');
% *
% *
% * output:
% *         1) write all data in a .mat file:
% *            SaveFileNameMat = [d.OutPath d.FileName '.mat'];
% *            eval(['save ' SaveFileNameMat  ' d, c, b, r, uw, psth' ]);
% * 
% *         2) write time axis and rates:
% *            SaveNameAscRates = [d.OutPath d.FileName 'Rates.asc'];
% *            with ratemat = ...
% *             [TimeCenterRangeInTimeUnits' 
% *              psth.Results.Mat(TimeIndexRangeInTimeUnits,i)];
% *            with i neuron index
% *
% *         3) write per pattern, results: 
% *             slidwinaxis actCoincRate expCoincRate jp js ue_p ue_n
% * 
% *             SaveNameAscPat = [d.OutPath d.FileName patString '.asc'];
% *
% *             resultmatrix = [BinCenterRangeInTimeUnits' ...
% *                             uw.Results.UEmwaResults(:,11,pat_idx) ...
% *                             uw.Results.UEmwaResults(:,12,pat_idx) ...
% *                             uw.Results.UEmwaResults(:,6,pat_idx) ...
% *                             uw.Results.UEmwaResults(:,9,pat_idx) ...
% *                             uw.Results.UEmwaResults(:,7,pat_idx) ...
% *                             uw.Results.UEmwaResults(:,8,pat_idx)];
% *
% *
% * 
% * See also: SignPlot.m        					*
% *									*
% * Example: SaveResults(DataFile(i),Cut,Bin,Raw,UEmwa,Psth)
% * 									*
% * Problems:								*
% *									*
% * History :								*
% *           (0) first version						*
% *              SG 3.10.97, Marseille					*
% *           (1) SG, 19.6.02, Marseille
% *									*
% ***********************************************************************

%******************************************
% write all structures in mat-file
%******************************************

% **************************************
% * create strings for output name
% **************************************

% save to file name

%SaveFileNameMat = [d.OutPath d.FileName '.mat'];

%eval(['save ' SaveFileNameMat  ' d, c, b, r, uw, psth' ]);

% ***************************************
% *					*
% *    Write Coinc Rates per Pattern    *
% *					*
% ***************************************

basis = 2;

 if isempty(r.Results.ExistingPatterns)
  error('SaveResults::NoPatternExist');
 else
  % extract existing patterns  
  pat = inv_hash(r.Results.ExistingPatterns,c.Results.NumberOfNeurons,basis);

  % reduce to requested complexity
  cpat = sum(pat,2);
  pat_idx = (find(cpat>= d.Analysis.Complexity));
  
  for i=1:length(pat_idx)
   % string generation of pattern
     patString ='_sp';
     sel_pat =  pat(pat_idx(i),:) 
     for ii=1:length(sel_pat)
      patString = strcat(patString, int2str(sel_pat(ii)));
     end
     patString
     SaveNamePat = [d.OutPath d.FileName patString 'Aver.asc'];

   % timeaxis actCoincRate expCoincRate jp js ue_p ue_n
   %resultmatrix = [BinCenterRangeInTimeUnits' ...
   %               uw.Results.UEmwaResults(:,11,pat_idx(i)) ...
   %               uw.Results.UEmwaResults(:,12,pat_idx(i)) ...
   %               uw.Results.UEmwaResults(:,6,pat_idx(i)) ...
   %               uw.Results.UEmwaResults(:,9,pat_idx(i)) ...
   %               uw.Results.UEmwaResults(:,7,pat_idx(i)) ...
   %               uw.Results.UEmwaResults(:,8,pat_idx(i))];

   sumact = sum(uw.Results.UEmwaResults(:,11,pat_idx(i)));
   sumexp = sum(uw.Results.UEmwaResults(:,12,pat_idx(i)));
   jp           = jp_val(sumact,sumexp);
   js           = logP(sumact,sumexp);
 

   disp(['... save results of ' patString ' to ' SaveNamePat]);
   save(SaveNamePat,'sumact','sumexp','jp','js','-ascii');
   %eval(['save -ascii ' SaveNamePat  'sumact,sumexp,jp,js']);
   clear sumact sumexp jp js;
  end % loop over pattern
end % of if pattern exist











