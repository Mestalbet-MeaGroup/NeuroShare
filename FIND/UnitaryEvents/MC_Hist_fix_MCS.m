function [area,MCS_steps_done,MC_hist]...
   =MC_Hist_fix_MCS_VerMatlab(Experimental_set,Nr_Elements_to_use,test_value,MC_steps)

%   	version 1.3 : by Gordon Pipa 10/01/03  Eamil : pipa@mpih-frankfurt.mpg.de    
%+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
% input: 
%+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
%		 Experimental_set   : row vector of data to be resampled (coinc counts per permutation)
%        Nr_Elements_to_use : size of subset (number of trials)
%        test_value         : actual number of coincidences 
%		 MC_steps		    : number of MC steps
%

%++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
% output:
%++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
%	    area			   : contains effec. sig. value
%	    MCS_steps_done	   : needed MCS step to reach both barriers
%       MC_hist            : Monte-Carlo Histogramm
%++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

Version_Matlab_or_C ='Matlab';  
   
test_bin            =test_value+1;
Maximal_Value       =max(Experimental_set);
Max_MC_Hist_value   =max(Experimental_set)*Nr_Elements_to_use;
if test_bin>1   
    [dummy,Nr_shuffled_Elements]=size(Experimental_set);    
    if test_bin<=Max_MC_Hist_value      
        if Version_Matlab_or_C =='Matlab';              
            
            Matrix_bootstrap_Indices=ceil(rand(MC_steps,Nr_Elements_to_use)*length(Experimental_set));
            
            bootstrap_sample=Experimental_set(Matrix_bootstrap_Indices);
            bootstrap_sum=sum(bootstrap_sample');
            
            MC_hist=hist(bootstrap_sum,0:Max_MC_Hist_value);        
            Cum_MC_hist=cumsum(MC_hist(1,:)/MC_steps);
            area=Cum_MC_hist(test_bin-1); 
            MCS_steps_done=MC_steps;
            %else
          %  Rand_init_value=ceil(rand(1,1)*15000);
          %  MC_hist=  MC_hist_fix_NRS_mex_AnsiC(MC_steps,Rand_init_value,Nr_Elements_to_use,Maximal_Value,Experimental_set);
          %  Cum_MC_hist=cumsum(MC_hist(1,:)/MC_steps);
          %  area=Cum_MC_hist(test_bin-1); 
          %  MCS_steps_done=MC_steps;
        end
    else 
        area=0;
        MCS_steps_done=0;
        MC_hist= zeros(1,Max_MC_Hist_value+1);        
    end
else
    area=1;
    MCS_steps_done=0;
    MC_hist= zeros(1,Max_MC_Hist_value+1);
end
