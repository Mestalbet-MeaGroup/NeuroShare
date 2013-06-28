function edist=euclidDist(matrix)
% function to calculate the euclidean distance
%
% (0) R. Meier Feb 07 meier@biologie.uni-freiburg.de
% This function belongs to FIND_GUI Toolbox project
% http://find.bccn.uni-freiburg.de

% this is inefficient but convenient
for ii=1:size(matrix,2)
    for kk=1:size(matrix,2)
        edist(ii,kk)=sqrt(sum((matrix(:,ii) -  matrix(:,kk)).^2));
    end
end
