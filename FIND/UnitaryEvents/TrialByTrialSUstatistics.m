function pt = TrialByTrialSUstatistics(c)
% pt = TrialByTrialSUstatistics(c): trial by trial statistics of single units
%
% input: 
% 
%  c: result of cut_gdf.m
%            here used: c.Results.NumberOfTrials
%                       c.Results.NumberOfNeurons
%                       c.Results.TrialList
%                       c.Results.Data
% output:
%
%  pt.NumberOfSpikes  : per neuron total number of 
%                       spikes per trial 
%                       pt.NumberOfSpikes{j,1}(i,1)  : trial ids
%                       pt.NumberOfSpikes{j,1}(i,2)  : spike counts
%                                 of neuron j (running index)
%                                 may be mapped to neuron id
%                                 using c.Parameters.NeuronList
% 
%  pt.Gdf             : gdf data per trial (not sorted according to time)
%                       pt.Gdf{j,1}: gdf-data (along column) of neuron j
%                       neuron_nr   time_in_trial (time resolution of the data)
%
% Compare to: TrialByTrialStatistics.m for coincidence statistics       
%       
% History:     (0) first version
%                 SG, 20.3.02, FFM
% 
%***************************************************************************
                
for i=1:c.Results.NumberOfTrials
tmpdata = [];
 for j=1:c.Results.NumberOfNeurons
  idx = find(c.Results.Data{j,1}(:,1)==c.Results.TrialList(i));
   % trial by trial spike counts
   pt.NumberOfSpikes{j,1}(i,2) = length(idx);
   pt.NumberOfSpikes{j,1}(i,1) = c.Results.TrialList(i);
 
  if ~isempty(idx)
     tmpgdf = [j+zeros(size(idx)) c.Results.Data{j,1}(idx,2)];
  else
   tmpgdf = [];
  end
  % concatenate per trial the gdf-data of the neurons
  tmpdata = cat(1,tmpdata, tmpgdf);
 end
  pt.Gdf{i,1} = tmpdata;
end


