function out=cellstr2num(in)
% Converts a cell array of numbers as strings to doubles similar to cell2num, but works with strings.
% cell array may only contain numbers as strings.
%
% Markus Nenniger 7/2006
%
% This function belongs to FIND_GUI Toolbox project
% http://find.bccn.uni-freiburg.de

if ~iscell(in);error('input is not a cell array');end
if ndims(in)>2;error('input has more than 2 dimensions');end
if ~size(in,2)>=2;error('only singledigits, use cell2num instead');end

temp=str2mat(in);

rowdone=zeros(size(temp,1),1);
while any(rowdone~=1);
    for ii=1:size(temp,1)
        for jj=size(temp,2):-1:2
            if isspace(temp(ii,jj))
                temp(ii,jj)=temp(ii,jj-1);
                temp(ii,jj-1)=' ';
            end
        end
    end
    for kk=1:size(temp,1)
        if any(isspace(temp(kk,:)))
            if ~any(find(~isspace(temp(kk,:)))<find(isspace(temp(kk,:))))
                rowdone(kk)=1;
            end
        else
            rowdone(kk)=1;
        end
    end
end

temp=str2num(temp);
out=temp;
