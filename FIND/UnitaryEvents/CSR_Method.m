function  [p_value_array,mean_counts_simulaneous,mean_counts_shuffled,corresponding_hashv]=CSR_Method(Spiketrain_array,Number_of_shuffle_ele,gen_case,Number_of_MC_steps)
% function  [p_value_array,mean_array,corresponding_hashv]=CSR_Method(Spiketrain_array,Number_of_shuffle_ele,gen_case,Number_of_MC_steps)
% version 1.0.1 : by Gordon Pipa 19/09/02  Eamil : pipa@mpih-frankfurt.mpg.de
%  
% Input
% **************************************************************
%       Spiketrain_array        =   Array of spiketrains (it is neccesary that data is binary) 
%                                   trials x time x neuron
%       
%       Number_of_shuffle_ele   =   Wished number of randomly generated shuffle tuple.
%
%       gen_case                =   'random' or 'allper' :
%                                   'random'    :   tuple are randomly generated without repations
%                                   'allper'    :   all possible tuple without repations are generated.  
%                                                   If the Number of all possible permutations is bigger than 10000 only 10000 randomly selected will be used
%
%       Number_of_MC_steps      =   Number of Monte-Carlo Steps used to estimate distribution
%**************************************************************
%
%
%
% Ouput
% **************************************************************
%       p_value_array           =   Array of P values for all existing hashvalues 
%       
%       mean_array              =   Array of the mean of coincident counts per trial per hash value 
%
%       corresponding_hashv     =   Corresponding hash values. Only hash values with Counts >0 in simultaneous trials was taken into account
%**************************************************************


[nr_trials nr_time_steps nr_neuron]=size(Spiketrain_array);
Spiketrain_array_clip=Spiketrain_array; % Muss schon binary sein, sonst klappt hinten die Zaehlung der Pattern nicht
Spiketrain_array_clip(find(Spiketrain_array_clip))=1;
% Evalute hash values of simulateous trials


hash_values=[];
for trial_index=1:nr_trials 
    spiketrain_set=reshape(Spiketrain_array_clip(trial_index,:,:),nr_time_steps,nr_neuron);
    order_vec=sum(spiketrain_set')';
    Pattern_order2_to_n_t_index=find(order_vec>1);
    Nr_pattern_order2_to_n_t(trial_index)=length(Pattern_order2_to_n_t_index);
    temp=hash(spiketrain_set(Pattern_order2_to_n_t_index,:),nr_neuron,2);
    hash_values=[hash_values temp'];
end

existing_hash_order2_to_n=unique(hash_values);
Nr_pattern_order2_to_n=length(existing_hash_order2_to_n);

if Nr_pattern_order2_to_n>0
    if Nr_pattern_order2_to_n>1
        sum_counts_simulaneous=hist(hash_values,existing_hash_order2_to_n);  
    else
        sum_counts_simulaneous=length(find(hash_values==existing_hash_order2_to_n)); 
    end
    mean_counts_simulaneous=sum_counts_simulaneous./nr_trials;
    %% Shuffling
    Sh_Indices=shuffel_indices(nr_neuron,nr_trials,Number_of_shuffle_ele,gen_case);
    [trash Act_Number_of_shuffle_ele]=size(Sh_Indices);
    
    if Nr_pattern_order2_to_n==1
        for shuffle_index=1:Act_Number_of_shuffle_ele
            for neuron_index=1:nr_neuron
                spiketrain_set_shuffled(:,neuron_index)=Spiketrain_array_clip(Sh_Indices(neuron_index,shuffle_index),:,neuron_index)';
            end
            order_vec_shuffled=sum(spiketrain_set_shuffled')';            
            Pattern_order2_to_n_shuffled_index=find(order_vec_shuffled>1);
            if isempty(Pattern_order2_to_n_shuffled_index)               
                counts_shuffled(:,shuffle_index)=0;               
            else
                hash_values_shuffled = hash(spiketrain_set_shuffled(Pattern_order2_to_n_shuffled_index,:),nr_neuron,2);
                counts_shuffled(:,shuffle_index)=length(find(hash_values_shuffled==existing_hash_order2_to_n));      
            end
        end         
    else
        for shuffle_index=1:Act_Number_of_shuffle_ele
            for neuron_index=1:nr_neuron
                spiketrain_set_shuffled(:,neuron_index)=Spiketrain_array_clip(Sh_Indices(neuron_index,shuffle_index),:,neuron_index)';
            end
            order_vec_shuffled=sum(spiketrain_set_shuffled')';
            Pattern_order2_to_n_shuffled_index=find(order_vec_shuffled>1);
            if isempty(Pattern_order2_to_n_shuffled_index)
                counts_shuffled(:,shuffle_index)=zeros(Nr_pattern_order2_to_n,1);               
            else
                hash_values_shuffled = hash(spiketrain_set_shuffled(Pattern_order2_to_n_shuffled_index,:),nr_neuron,2);
                counts_shuffled(:,shuffle_index)=hist(hash_values_shuffled,existing_hash_order2_to_n)';      
            end  
        end   
    end
    
    for Pattern_index=1:Nr_pattern_order2_to_n
        [area,Number_of_MC_steps,MC_hist]=MC_Hist_fix_MCS(counts_shuffled(Pattern_index,:),nr_trials,sum_counts_simulaneous(Pattern_index),Number_of_MC_steps);
        p_value_array(Pattern_index)=area;  
        mean_counts_shuffled(Pattern_index)=mean(counts_shuffled(Pattern_index,:));           
    end
    
else
    corresponding_hashv=[];  
    p_value_array=[];
    mean_counts_simulaneous=[]; 
    mean_counts_shuffled=[]; 
end
corresponding_hashv=existing_hash_order2_to_n';