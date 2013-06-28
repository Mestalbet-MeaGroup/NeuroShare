function SON2neuroshare_Info(varargin)
% function SON2neuroshare_Info(varargin)
% This fuction imports smr\son files under linux or macos by using the SON
% library (Copyright � The Author & King's College London 2002-2006) and
% pushs the the data into the neuroshare based FIND structure.
%
% used SON functions:
%
%   SONChannelInfo          - reads the SON file channel header for a channel
%   SONFileHeader           - reads the file header for a SON file
%   SONGetChannel      - retds the SON data block headers
%
%%%%% Notes: %%%%%%%%%
%
% a.kilias 12/08 kilias@bccn.uni-freiburg.de
% This function belongs to FIND_GUI Toolbox project
% http://find.bccn.uni-freiburg.de


global nsFile;

try
    % obligatory argument names & validity test functions
    obligatoryArgs={{'fileName',@(val) ischar(val) && isfile(val)}};

    % optional arguments names with default values
    optionalArgs={};

    % parameter check
    errorMessage=checkPVP(varargin,obligatoryArgs,optionalArgs);
    if ~isempty(errorMessage)
        error(errorMessage,'');
    end
    pvpmod(varargin);

    addpath([pwd,'/son']);
    fid=fopen(fileName);
    FileInfo=SONFileHeader(fid);

    % FILE INFO:
    nsFile.FileInfo.FileType='Spike2 data';
    nsFile.FileInfo.TimeStampResolution=FileInfo.usPerTime*10^-7;
    nsFile.FileInfo.TimeSpan=FileInfo.maxFTime*(FileInfo.usPerTime*10^-7);
    nsFile.FileInfo.AppName=FileInfo.Creator;
    nsFile.FileInfo.Time_Year=FileInfo.timeDate.Year;
    nsFile.FileInfo.Time_Month=FileInfo.timeDate.Detail(6);
    nsFile.FileInfo.Time_Day=FileInfo.timeDate.Detail(5);
    nsFile.FileInfo.Time_Hour=FileInfo.timeDate.Detail(4);
    nsFile.FileInfo.Time_Min=FileInfo.timeDate.Detail(3);
    nsFile.FileInfo.Time_Sec=FileInfo.timeDate.Detail(2);
    nsFile.FileInfo.Time_MilliSec=FileInfo.timeDate.Detail(1)*10;
    nsFile.FileInfo.FileComment=strcat(FileInfo.fileComment{:});

    CHInfo=SONChanList(fid);

    nsFile.FileInfo.EntityCount=size(CHInfo,2);

    kk=1;
    for count=1:size(CHInfo,2)
        ignoreCH=0;
        neuralD=0;
        % Returns A code for the channel type or -3 if this is not a time,
        % XY or result view:
        %
        % 1 Waveform            = analog
        %
        % 6 WaveMark            = segment and neural
        % 9 Real wave           = segment
        %
        % 2 Event (Event-)      = event
        % 3 Event (Event+)      = event
        % 4 Level               = event
        % 5 Marker              = event
        % 7 RealMark            = event
        % 8 TextMark            = event
        %
        % 0 None/deleted        = ignored
        % 127 Result channel    = ignored (plots etc.)
        % 120 XY channel        = ignored (plots etc.)

        if CHInfo(count).kind==1 %analog
            nsFile.EntityInfo(kk).EntityType=2;
        elseif CHInfo(count).kind==6 % segment and neural
            nsFile.EntityInfo(kk).EntityType=3;
            neuralD=1;
        elseif CHInfo(count).kind==9 % segement
            nsFile.EntityInfo(kk).EntityType=4;
        elseif CHInfo(count).kind==2 || CHInfo(count).kind==3 || ...
                CHInfo(count).kind==4 ||CHInfo(count).kind==5 ||...
                CHInfo(count).kind==7 || CHInfo(count).kind==8  % event
            nsFile.EntityInfo(kk).EntityType=1;
        else
            ignoreCH=1;
            warning(['unknown or not supported spike2 specific entity type: ',num2str(CHInfo(count).kind)]);
        end
        if ~ignoreCH
            % --------------- non neural entitys --------------------
            % [dat,header]=SONGetChannel(fid,CHInfo(count).number);

            Info=SONChannelInfo(fid,CHInfo(count).number);
            startBlock=1;
            endBlock=Info.blocks;
            headerM=SONGetBlockHeaders(fid,CHInfo(count).number);
            if ~isempty(headerM)
                NumberOfMarkers=sum(headerM(5,startBlock:endBlock));
                header.npoints=NumberOfMarkers;
            else
                header.npoints=0;
            end

            % if someone has can extract the header by using
            % SONGetBlockHeaders - feel free to change
            nsFile.EntityInfo(kk).EntityID=kk;
            nsFile.EntityInfo(kk).EntityLabel=CHInfo(count).title;
            nsFile.EntityInfo(kk).ItemCount=header.npoints;
            nsFile.EntityInfo(kk).Info.channel=CHInfo(count).number; % DO NOT DELETE THIS!
            % this is not redundant and will be used for data import
            % later!!!!!
            if iscell(CHInfo(count).comment)
                nsFile.EntityInfo(kk).Info.Comment=strcat(CHInfo(count).comment{:});
            else
                nsFile.EntityInfo(kk).Info.Comment=CHInfo(count).comment;
            end

            % --------------- neural entitys --------------------
            if neuralD==1 % create an additional channel for neural data
                nsFile.EntityInfo(kk+1).EntityType=4;
                nsFile.EntityInfo(kk+1).EntityID=kk+1;
                nsFile.EntityInfo(kk+1).EntityLabel=CHInfo(count).title;
                nsFile.EntityInfo(kk+1).ItemCount=header.npoints;
                nsFile.EntityInfo(kk+1).Info.channel=CHInfo(count).number;
                % DO NOT DELETE THIS!
                % this is not redundant and will be used for data import
                % later!!!!!
                if iscell(CHInfo(count).comment)
                    nsFile.EntityInfo(kk+1).Info.Comment=strcat(CHInfo(count).comment{:});
                else
                    nsFile.EntityInfo(kk+1).Info.Comment=CHInfo(count).comment;
                end
                kk=kk+2;
            else
                kk=kk+1;
            end
        end
        count=count+1;
    end
    fclose(fid);
catch
    if exist('fid','var');
        fclose(fid);
    end
    rethrow(lasterror);
end