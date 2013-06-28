function structure2text_out=structure2text(nsFile)
% extract structure-fields and return some nicely formatted 
% text for display
% 
% function structure2text=structure2text(nsFile)
%
% This function belongs to FIND_GUI Toolbox project
% http://find.bccn.uni-freiburg.de

if ~isempty(nsFile)
    structure2text_out=formatstructtree(cssm2cell(cssm(nsFile,'nsFile',1),'nsFile'),15);
else
    structure2text_out='No data loaded';
end


