function InstallUE(varargin)
% function InstallUE(varargin)
% **************************************************************
% *                                                            *
% * Installation script.                                       *
% *                                                            *
% * This script should be executed once, whenever you moved    *
% * the programm to a new architecture.                        *
% * In order to perform all compiling steps without failure    *
% * It is necessary, that you have a matlab compiler mcc       *
% * with at least version 3.0 installed on your system.        *
% *                                                            *
% * Options:  1) no input: normal Install                      *
% *           2) input = 'clean': remove all files that get    *
% *                               created in Install process   *
% *                                                            *
% * The routine tries to compile the UE in 3 steps:            *
% *                                                            *
% * 1) Building a mex file of the the CSR method.              *
% *                                                            *
% *    For this task you only need a c-compiler installed on   *
% *    your system. If this fails you will neither be able to  *
% *    use the CSR Method, the Parallel Mode or the Standalone *
% *    Mode. You will still be able to use the rest of the     *
% *    programm.                                               *
% *                                                            *
% * 2) Compiling the Moving Window Analysis Routine            *
% *                                                            *
% *    (Will only be executed if 1) did not fail)              *
% *    For this task you will need the matlab compiler mcc     *
% *    (Version 3.0 or higher, 2.x will not work !!!)          *
% *    installed on your system. If this procedure fails you   *
% *    can not use Parallel Mode and Standalone Mode.          *
% *                                                            *
% * 3) Compiling the whole programm                            *
% *                                                            *
% *    (Will only be executed if 1) & 2) did not fail)         *
% *    For this task you will need the matlab compiler mcc     *
% *    (Version 3.0 or higher, 2.x will not work !!!)          *
% *    installed on your system. If this procedure fails you   *
% *    can not use Standalone Mode.                            *
% *                                                            *
% * Afterwards  the script will display a summary of all tasks *
% *                                                            *
% * Uses:  mex, mcc                                            *
% *                                                            *
% * History:                                                   *
% *                                                            *
% *     1) first version                                       *
% *       PM, 27.9.02, Goettingen                              *
% *                                                            *
% **************************************************************

disp(' ');
disp(' ');

if nargin == 0
    
 % **************************************************************
 % *                                                            *
 % *  Compiling CSR Routine                                     *
 % *                                                            *
 % **************************************************************

 try
    disp('1) Compiling new CSR routine');
    mex MC_histogramm_mex_AnsiC.c;
    compiledCSR = 'yes';
 catch
    CSRerror = lasterr;
    compiledCSR = 'no';
 end

 disp(' ');

 % **************************************************************
 % *                                                            *
 % *  Compiling UEMainAnalyseWindow for Parallel Mode           *
 % *                                                            *
 % **************************************************************

 if isequal(compiledCSR,'yes')
   try
      disp('2) Compiling analysis routine for Parallel Mode');
      mcc -m UEMainAnalyseWindow
      compiledAnalysis = 'yes';
   catch
      Analysiserror = lasterr;
      compiledAnalysis = 'no';
   end
   disp(' ');
 else
   compiledAnalysis = 'no';
 end

 % **************************************************************
 % *                                                            *
 % *  Building Standalone Application of whole programm         *
 % *                                                            *
 % **************************************************************

 if isequal(compiledCSR,'yes') & isequal(compiledAnalysis,'yes')
   try
      disp('3) Compiling whole programm to standalone application');
      mcc -B sgl startue
      %mcc -m startue
      compiledstartue = 'yes';
   catch
      startueerror = lasterr;
      compiledstartue = 'no';
   end
   disp(' ');
 else
   compiledstartue = 'no';
 end


 % **************************************************************
 % *                                                            *
 % *  Presenting summary of installation process                *
 % *                                                            *
 % **************************************************************

 disp(' ');
 disp(' ');
 disp('Summary of installation process:');
 disp(' ');
 if isequal(compiledCSR,'yes')
    disp(' 1) Created mex-file of CSR Method.');
    disp('    CSR Method should work properly.');
  if isequal(compiledAnalysis,'yes')
      disp(' ');
      disp(' 2) Created executable version of analysis routine.');
      disp('    Parallel Mode should work properly.');
    if isequal(compiledstartue,'yes')
        disp(' ');
        disp(' 3) Created standalone application of whole programm.');
        disp('    You should be able to execute "startue" without matlab.');
    else
        disp(' ');
        disp(' 3) The following error ocurred while building standalone application: ');
        disp(' ');
        disp(['    ' startueerror ]);
        disp(' ');
        disp(['    You will not be able to use Standalone Mode.']);
    end
  else
      disp(' ');
      disp(' 2) The following error ocurred while compiling analysis routine: ');
      disp(' ');
      disp(['    ' Analysiserror ]);
      disp(' ');
      disp(['    You will not be able to use Parallel Mode and Standalone Mode.']);
  end
 else 
    disp(' 1) The following error ocurred while compiling of CSR Method: ');
    disp(' ');
    disp(['    ' CSRerror ]);
    disp(' ');
    disp('    You will not be able to use CSR Method, Parallel and Standalone Mode.');
 end
 disp(' ');
 disp('To remove all files generated during installation process, type:');
 disp('InstallUE with "clean" as a string input argument.');
 disp(' ');
 
end

if nargin == 1

  if isequal(varargin{1},'clean')
      
      % ***********************************************************
      % *                                                         *
      % * Try to delete all *.c *.h files and executables         *
      % * Warning: Do not remove MC_histogramm_mex_AnsiC.c !!!!!  *
      % *                                                         *
      % ***********************************************************
      
      !mv MC_histogramm_mex_AnsiC.c MC_histogramm_mex_AnsiC.old
      
      try
          !rm *.c
      catch
          disp(lasterr);
      end
      
      try 
          !rm *.h
      catch
          disp(lasterr);
      end
      
      try
          !rm *.mex*
      catch
          disp(lasterr);
      end
      
      try
          !rm UEMainAnalyseWindow
      catch
          disp(lasterr);
      end
      
      try
          !rm startue
      catch
          disp(lasterr);
      end
      
      try
          !rm ./bin/*
      catch
          disp(lasterr);
      end
      
      try
          !rmdir ./bin
      catch
          disp(lasterr);
      end
      
      !mv MC_histogramm_mex_AnsiC.old MC_histogramm_mex_AnsiC.c
      
      disp(' ');
      disp('Cleaned up compiled files');
      disp(' ');
      
  else
      disp('invalid input parameter')
  end
  
end
