function [geometry,listui]=makeSuperGUItable(nsFile,pageentries,myguiprops)
% This function generates a cell array for use with supergui.
% Supergui is part of the open source eeglab software (Makeig et al). 
% Here we use it for the FIND GUI.
%
% function [geometry,listui]=makeSuperGUItable(nsFile,pageentries,myguiprops)
% For all futher details please refer to the EEGLAB / SUPERGUI
% documentation
%
% Or see 'help supergui' for syntax details containing the elements of the
% table shown by browseEntitiesGUI.
%
% LICENCE ISSUES: see licence.txt for futher details 
% Contact: Ralph Meier, BCCN Freiburg
%
% This function belongs to FIND_GUI Toolbox project
% http://find.bccn.uni-freiburg.de


% make FIND_GUIdata available in current scope
FIND_GUIdata=get(findobj('Tag','FIND_GUI'),'UserData');
warning off
global nsFile
warning on

no_props=length(FIND_GUIdata.displayOptions);

for ii=1:no_props
    mydots=findstr('.',FIND_GUIdata.displayOptions{ii});
    propnames{ii}=FIND_GUIdata.displayOptions{ii}(mydots(end)+1:end);
end

% get indices for different data types
eventidx=find([nsFile.EntityInfo.EntityType]==1);
analogidx=find([nsFile.EntityInfo.EntityType]==2);
segmentidx=find([nsFile.EntityInfo.EntityType]==3);
neuralidx=find([nsFile.EntityInfo.EntityType]==4);

%initialize listui
listui={};


%first generate column labels
listui{1}={'style','text','string',''};
listui{2}={'style','text','string','EntityID','FontWeight','bold'};

for ii=1:no_props
    tempstring=propnames{ii};
    listui{length(listui)+1}={'style','text','string',tempstring,'FontWeight','bold'};
end

% then generate appropriate column width

% geometry{1}(1:2)=[];


for ii=1:no_props
    geometry{1}(ii+2)=length(propnames{ii});
end

geometry{1}(2)=8;
geometry{1}(1)=ceil(sum(geometry{1}(2:end))/10);

%loop over all entities on current page
for ii = 1:length(pageentries)
    % ... and all entityproperties for each entity
    for jj=1:no_props
        if jj==1
            listui{length(listui)+1}={'style','checkbox','Tag',num2str(nsFile.EntityInfo(pageentries(ii)).EntityID),'Callback','setselectedentityID()'};
            listui{length(listui)+1}={'style','text','string',strcat('EntityID: ',num2str(nsFile.EntityInfo(pageentries(ii)).EntityID))};
        end
        if findstr('.EntityInfo.',FIND_GUIdata.displayOptions{jj})
            if findstr('.EntityInfo.EntityType',FIND_GUIdata.displayOptions{jj})
                mydots=findstr('.',FIND_GUIdata.displayOptions{jj});
                tempstring=eval([FIND_GUIdata.displayOptions{jj}(1:mydots(end)-1),'(',num2str(pageentries(ii)),')',FIND_GUIdata.displayOptions{jj}(mydots(end):end)]);
                if tempstring==0;
                    tempstring='unknown';
                elseif tempstring==1;
                    tempstring='Event';
                elseif tempstring==2;
                    tempstring='Analog';
                elseif tempstring==3;
                    tempstring='Segment';
                elseif tempstring==4;
                    tempstring='Neural';
                end
                listui{length(listui)+1}={'style','text','string',tempstring};
            else
                mydots=findstr('.',FIND_GUIdata.displayOptions{jj});
                tempstring=eval([FIND_GUIdata.displayOptions{jj}(1:mydots(end)-1),'(',num2str(pageentries(ii)),')',FIND_GUIdata.displayOptions{jj}(mydots(end):end)]);
                listui{length(listui)+1}={'style','text','string',tempstring};
            end
        elseif findstr('.Event.',FIND_GUIdata.displayOptions{jj})
            relativeidx=find(eventidx==pageentries(ii));
            if ~isempty(relativeidx)
                mydots=findstr('.',FIND_GUIdata.displayOptions{jj});
                tempstring=eval([FIND_GUIdata.displayOptions{jj}(1:mydots(end)-1),'(',num2str(relativeidx),')',FIND_GUIdata.displayOptions{jj}(mydots(end):end)]);
                listui{length(listui)+1}={'style','text','string',tempstring};
            else
                listui{length(listui)+1}={'style','text','string','n/a'};
            end
        elseif findstr('.Analog.',FIND_GUIdata.displayOptions{jj})
            relativeidx=find(analogidx==pageentries(ii));
            if ~isempty(relativeidx)
                mydots=findstr('.',FIND_GUIdata.displayOptions{jj});
                tempstring=eval([FIND_GUIdata.displayOptions{jj}(1:mydots(end)-1),'(',num2str(relativeidx),')',FIND_GUIdata.displayOptions{jj}(mydots(end):end)]);
                listui{length(listui)+1}={'style','text','string',tempstring};
            else
                listui{length(listui)+1}={'style','text','string','n/a'};
            end
        elseif findstr('.Segment.',FIND_GUIdata.displayOptions{jj})
            relativeidx=find(segmentidx==pageentries(ii));
            if ~isempty(relativeidx)
                mydots=findstr('.',FIND_GUIdata.displayOptions{jj});
                tempstring=eval([FIND_GUIdata.displayOptions{jj}(1:mydots(end)-1),'(',num2str(relativeidx),')',FIND_GUIdata.displayOptions{jj}(mydots(end):end)]);
                listui{length(listui)+1}={'style','text','string',tempstring};
            else
                listui{length(listui)+1}={'style','text','string','n/a'};
            end
        elseif findstr('.Neural.',FIND_GUIdata.displayOptions{jj})
            relativeidx=find(neuralidx==pageentries(ii));
        end
    end
end

for ii=1:length(pageentries)
    geometry{ii+1}=repmat(geometry{1},1,1);
end

% geometry{ii}=[1 4 4 4];
% listui{ii*4-3}={'style','checkbox','Tag',num2str(nsFile.EntityInfo(pageentries(ii)).EntityID),'Callback','setselectedentityID()'};
% listui{ii*4-2}={'style','text','string',strcat('EntityID: ',num2str(nsFile.EntityInfo(pageentries(ii)).EntityID))};
% switch nsFile.EntityInfo(pageentries(ii)).EntityType
%     case 1
%         listui{ii*4-1}={'style','text','string','Type: event'};
%     case 2
%         listui{ii*4-1}={'style','text','string','Type: analog'};
%     case 3
%         listui{ii*4-1}={'style','text','string','Type: segment'};
%     case 4
%         listui{ii*4-1}={'style','text','string','Type: neural'};
% end
% listui{ii*4}={'style','text','string',strcat('ItemCount: ',num2str(nsFile.EntityInfo(pageentries(ii)).ItemCount))};
% 
%     
    
%if there are less than 20 entries for this page, the remainder of the list
%is filled with empty entries.
if length(pageentries)<20
    for ii=(length(pageentries)+2):21
        geometry{ii}=[1];
        listui{length(listui)+1}={'style','text','string',''};
    end
end
