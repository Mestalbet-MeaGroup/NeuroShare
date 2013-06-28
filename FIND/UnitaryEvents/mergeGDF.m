function [eGdf]=mergeGDF(varargin)
% [eGdf]=mergeGDF(varargin): merge gdf-spike trains data
% **************************************************************
% *   input: 
% *           
% *         varargin  : vairable number of gdf-input data     
% *                      
% *   output:    eGdf:  merged and sorted gdf-data
% * 
% *   Uses :
% *
% *   NOTE :
% *
% *   See also:
% *
% *   History: (0) SG, 7.3.2000, FfM
% *   
% ***************************************************************

if isempty(varargin)
 error('mergeGDF::NoInputsToMerge');
end

numberOfFilesToMerge = size(varargin,2);

eGdf = varargin{1,1};
for i=2:numberOfFilesToMerge
 eGdf    = cat(1,eGdf,varargin{1,i});

end

[y,idx]=sort(eGdf(:,2));
eGdf=eGdf(idx,:);











