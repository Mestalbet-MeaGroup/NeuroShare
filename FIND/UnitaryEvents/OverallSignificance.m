function OverallSignificance(d,c,b,r,uw,psth)
% OverallSignificance(d,c,b,r,uw,psth): average significance for M. Munk 
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
% * output:  write asci-files for each pattern (>complexity)
% *          to filename
% *          SaveNamePat = [d.OutPath d.FileName patString 'Aver.asc'];
% *          containing 
% *          sumact: sum of empirical coincidences from all 
% *                  sliding windows
% *          sumexp: sum of expected coincidences from all
% *                  sliding windows
% *          jp    : joint-p-value of sumact given sumexp
% *          js    : joint-surprise of sumact given sumexp
% *          
% *         
% * 
% * See also: SignPlot.m, SaveResults.m
% *									*
% * Example: OverallSignificance(DataFile(i),Cut,Bin,Raw,UEmwa,Psth)
% * 									*
% * Problems:								*
% *									*
% * History :								*
% *           (0) first version						*
% *              SG 24.6.02, FFM					*
% *									*
% ***********************************************************************


% ***************************************
% *					*
% *    Write per Pattern                *
% *					*
% ***************************************

basis = 2;

 if isempty(r.Results.ExistingPatterns)
  error('SaveResults::NoPatternExist');
 else
  % extract existing patterns  
  pat = inv_hash(r.Results.ExistingPatterns,c.Results.NumberOfNeurons,basis);

  % reduce to requested complexity
  cpat    = sum(pat,2);
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

   sumact = sum(uw.Results.UEmwaResults(:,11,pat_idx(i)));
   sumexp = sum(uw.Results.UEmwaResults(:,12,pat_idx(i)));
   jp           = jp_val(sumact,sumexp);
   js           = logP(sumact,sumexp);

   disp(['... save results of ' patString ' to ' SaveNamePat]);
   save(SaveNamePat, '-ascii', 'sumact', 'sumexp', 'jp', 'js');

   clear sumact sumexp jp js;
  end % loop over pattern
end % of if pattern exist











