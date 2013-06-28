function finalarray=formatstructtree(arr2,cellwidth);
% Formats the output of cssm to readable text.
% Pads Text with given number of blanks!
%
% cellwidth=15; is a useful value.
%
% Rmeier, Markus Nenniger 06
% This function belongs to FIND_GUI Toolbox project
% http://find.bccn.uni-freiburg.de


newarray={};
done=arr2;
allesklar=0;
ii=1;
originalsize=size(done,1);

while ii<originalsize
    ii=ii+1;
    if ~isstr([done{ii,:}])
        if ii>1
            done=[done([1:ii-1],:); done([ii+1:end],:);cell(1,size(done,2))];
            ii=ii-1;
            originalsize=originalsize-1;
        else
            done=[done([2:end],:);cells(1,size(done,2))];
            ii=ii-1;
            originalsize=originalsize-1;
        end
    else
        for kk=1:size(done,2)
            mydot=strfind(done{ii,kk},'.');
            if ~isempty(mydot)
                done{ii,kk}=done{ii,kk}(1:mydot-1);
            end
        end
    end
end


for ii=1:size(done,1)
    for jj=1:size(done,2)
        if isstr(done{ii,jj})
            newarray{ii,jj}=[done{ii,jj},repmat(' ',1,cellwidth-length(done{ii,jj}))];
        else
            newarray{ii,jj}=repmat(' ',1,cellwidth);
        end
    end
end

for ii=1:size(newarray,1)
    finalarray{ii}=[newarray{ii,:}];
end
temp=[finalarray(1)];
for ii=2:size(finalarray,2)
    temp=[temp;finalarray(ii)];
end
