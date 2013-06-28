function Permutation_array= shuffel_indices(Neurons,Trials,Rand_permutations,gen_case)
% function Permutation_array= shuffel_indices(Neurons,Trials,Rand_permutations)generates the complete independent shuffel combinations ( all or Rand_permutations)
% 
%
% **************************************************************
%       Neurons =   Number of Neurons to be suffled
%       Trials      =   Number of Trials
%       Rand_permutations = Number of randomly generated shuffel tupel if the Number of all possible permutations is bigger than 51^3
%**************************************************************
%       Permutation_array  = Output Matrix
%
% Version 1.3 - Gordon Pipa 25/07/01 - pipa@mpih-frankfurt.mpg.de


Permutations=Trials^Neurons;

if Permutations<Rand_permutations
   gen_case='allper';
end

if or(gen_case=='random',Permutations>10000)
    gen_case='random';
else
    gen_case='allper';
end;


if gen_case=='random' 
   Counter=0;
   length_Per=1;
 
   while (length_Per<Rand_permutations)
      Counter=Counter+1;
      if Counter==1
          New_permutation=ceil((Rand_permutations+50)*1.2);
          if New_permutation<100
             New_permutation=100;
         end;
         Permutation_array    =ceil(rand(Neurons,New_permutation)*Trials);
         [Hist_value,trash]     =hist(Permutation_array,1:Trials);
         Index=0;
         for Neuron_index=1:Trials
            Index_temp          =find(Hist_value(Neuron_index,:)>1); 
            if Neuron_index==1
               Index                =Index_temp;
            else
               length_temp     =length(Index_temp);
               length_Index    =length(Index);
               Index(length_Index+1:length_temp+length_Index)=Index_temp;
            end; 
         end
         if ~isempty(Index)
             Permutation_array(:,Index)=[];
         end;
        
         length_Per=length(Permutation_array);
         Index=[];
         Permutation_array_t(1,:)=Permutation_array(1,:);
         for Neuron_Index=2:Neurons
              Permutation_array_t=Permutation_array(Neuron_Index,:)*(Trials^(Neuron_Index-1))+Permutation_array_t;
         end
         [Number Index_Number]=sort(Permutation_array_t);
         Index_dual_kill=1;
         for Index_dual=2:length_Per
             if Number(Index_dual)==Number(Index_dual-1);
                 Index(Index_dual_kill)=Index_Number(Index_dual);
                 Index_dual_kill=Index_dual_kill+1;
             end
         end;
         if ~isempty(Index)
             Permutation_array(:,Index)=[];
         end;
         length_Per=length(Permutation_array);
      else
         New_permutation=ceil((Rand_permutations-length_Per+50)*(Rand_permutations/length_Per)*1.1);
         if New_permutation<100
             New_permutation=100;
         end;
         
         Permutation_array_temp  =ceil(rand(Neurons,New_permutation)*Trials);
         [Hist_value,trash]=hist(Permutation_array_temp,1:Trials);
         Index=0;
         for Neuron_index=1:Trials
            Index_temp=find(Hist_value(Neuron_index,:)>1); 
            if Neuron_index==1
               Index=Index_temp;
            else
               length_temp=length(Index_temp);
               length_Index=length(Index);
               Index(length_Index+1:length_temp+length_Index)=Index_temp;
            end; 
         end
         if ~isempty(Index)
             Permutation_array_temp(:,Index)=[]; 
         end;
         length_array                =length(Permutation_array);
         length_array_temp           =length(Permutation_array_temp);
         if and(length_array_temp >1,length_array>1 )
             Permutation_array_temp(:,length_array_temp+1:length_array_temp+length_array)=Permutation_array;
         else
             if length_array >1
                 Permutation_array_temp=Permutation_array;
             end
         end
         
         length_array_temp           =length(Permutation_array_temp);         
         Permutation_array_t=Permutation_array_temp(1,:);
         
         for Neuron_Index=2:Neurons
              Permutation_array_t=Permutation_array_temp(Neuron_Index,:)*(Trials^(Neuron_Index-1))+Permutation_array_t;
         end
         [Number Index_Number]=sort(Permutation_array_t);
         Index_dual_kill=1;
         for Index_dual=2:length_array_temp 
             if Number(Index_dual)==Number(Index_dual-1);
                 Index(Index_dual_kill)=Index_Number(Index_dual);
                 Index_dual_kill=Index_dual_kill+1;
             end
         end;
         if ~isempty(Index)
             Permutation_array_temp(:,Index)=[]; 
         end;        
         Permutation_array=Permutation_array_temp;      
         length_Per=length(Permutation_array);
      end 
   end
   Permutation_array=Permutation_array(:,1:Rand_permutations);
else
    Permuatain_vec=(1:Permutations)-1;
    Permutation_array=zeros(Neurons,Permutations);
    for Neuron_index=1:Neurons
        Permutation_array(Neuron_index,:)=floor(mod(Permuatain_vec,Trials^Neuron_index)/Trials^(Neuron_index-1))+1;
    end
    [Hist_value,trash]     =hist(Permutation_array,1:Trials);
    Index=0;
    for Neuron_index=1:Trials
        Index_temp          =find(Hist_value(Neuron_index,:)>1); 
        if Neuron_index==1
            Index                =Index_temp;
        else
            length_temp     =length(Index_temp);
            length_Index    =length(Index);
            Index(length_Index+1:length_temp+length_Index)=Index_temp;
        end; 
    end
    if ~isempty(Index)
        Permutation_array(:,Index)=[];
    end;
end;



