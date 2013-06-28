function out=cssm2cell(in,main)
% Helper function to de-compose structures
% function out=cssm2cell(in,main)
%
% This function belongs to FIND_GUI Toolbox project
% http://find.bccn.uni-freiburg.de

out={};
lastdot=1;
layer=[];
element=1;
in=[[main,'.1'];in];

for ii=1:numel(in)
    if ~isempty(findstr(in{ii},'.'))
        a=in{ii}(1:end-2);
        for kk=lastdot:ii-1
            if strcmp(in{kk},a)
                in{kk}=[];
            end
        end
    end
end

for ii=1:numel(in)
    element=element+1;
    if ~isempty(findstr(in{ii},'.'))
        layer=str2num(in{ii}(end));
        out{element,layer}=in{ii};
        %element=element-1;
        lastdot=ii;
    else

        out{element,layer+1}=in{ii};
    end
end

%out


%
% for ii=size(out,2):-1:1
%     for jj=1:size(out,1)
%         if ~isempty(findstr(out{jj,ii},'.'))
%             
%         end
%     end
% end
