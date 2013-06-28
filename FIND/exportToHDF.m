function exportToHDF(varargin)
% function exportToHDF5(filename,recordName)
% Exports the data available in nsFile within the FIND-Toolbox
% to the HDF5 Format and writes the file to disk.
%
% (0) A. Werber and R. Meier - April 2008
%
% This function is part of the FIND-Toolbox.
% see http://find.bccn.uni-freiburg.de
% Note:
% THIS IS WORK IN PROGRESS!
% DATA REPRESENTATION MIGHT CHANGE WITHOUT NOTICE.

%%%
% (C) Andreas Werber
% 15_03_2008
% Ver 8
%%%

%%%
%   usage: exportToHDF('filename to be written',nsFile,'record name to be
%   written')
%%%

global nsFile;

% obligatory argument names
obligatoryArgs={'filename','recordName'}; %-% e.g. {'x','y'}

% optional arguments names with default values
optionalArgs={};

errorMessage=checkPVP(varargin,obligatoryArgs,optionalArgs);
if ~isempty(errorMessage)
    error(errorMessage,'missing or wrong input arguments'); %used this format so that the '\n' are converted
end

% loading parameter value pairs into workspace, overwriting defaul values
pvpmod(varargin);

intwarning('off');

record_root  = [ '/' recordName ];

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% FILEINFO
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
fileinfo.FileType               = char(nsFile.FileInfo.FileType);
fileinfo.EntityCount            = uint32(nsFile.FileInfo.EntityCount);
fileInfo.TimeStampResolution    = double(nsFile.FileInfo.TimeStampResolution);
fileInfo.TimeSpan               = uint32(nsFile.FileInfo.TimeSpan);
fileinfo.AppName                = char(nsFile.FileInfo.AppName);
fileinfo.Time_Year              = uint32(nsFile.FileInfo.Time_Year);
fileinfo.Time_Month             = uint32(nsFile.FileInfo.Time_Month);
fileinfo.Time_Day               = uint32(nsFile.FileInfo.Time_Day);
fileinfo.Time_Hour              = uint32(nsFile.FileInfo.Time_Hour);
fileinfo.Time_Min               = uint32(nsFile.FileInfo.Time_Min);
fileinfo.Time_Sec               = uint32(nsFile.FileInfo.Time_Sec);
fileinfo.Time_MilliSec          = uint32(nsFile.FileInfo.Time_MilliSec);
fileinfo.FileComment            = char(nsFile.FileInfo.FileComment);
fileinfo.Datatypespresent       = uint8(nsFile.FileInfo.Datatypespresent);

fileinfo_root = [ record_root '/FileInfo' ];
hdf5write(filename,fileinfo_root,fileinfo);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% ANALOG
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
N = size(nsFile.Analog.DataentityIDs,2);

for i=1:N,
    analog_root = [ record_root '/Analog/' sprintf('%d',i) ];

    analog_leaf = [ analog_root '/Data' ];
    analogData  = double( nsFile.Analog.Data(:,i) );

    hdf5write(filename,analog_leaf,analogData,'writemode','append');

    attribute.AttachedTo = analog_leaf;
    attribute.AttachType = 'dataset';

    attribute.Name = 'SampleRate';      SampleRate      = double(nsFile.Analog.Info(i).SampleRate);     hdf5write(filename,attribute,SampleRate,'writemode','append');
    attribute.Name = 'MinVal';          MinVal          = double(nsFile.Analog.Info(i).MinVal);         hdf5write(filename,attribute,MinVal,'writemode','append');
    attribute.Name = 'MaxVal';          MaxVal          = double(nsFile.Analog.Info(i).MaxVal);         hdf5write(filename,attribute,MaxVal,'writemode','append');
    attribute.Name = 'Units';           Units           = char(nsFile.Analog.Info(i).Units);            hdf5write(filename,attribute,Units,'writemode','append');
    attribute.Name = 'Resolution';      Resolution      = double(nsFile.Analog.Info(i).Resolution);     hdf5write(filename,attribute,Resolution,'writemode','append');
    attribute.Name = 'LocationX';       LocationX       = double(nsFile.Analog.Info(i).LocationX);      hdf5write(filename,attribute,LocationX,'writemode','append');
    attribute.Name = 'LocationY';       LocationY       = double(nsFile.Analog.Info(i).LocationY);      hdf5write(filename,attribute,LocationY,'writemode','append');
    attribute.Name = 'LocationZ';       LocationZ       = double(nsFile.Analog.Info(i).LocationZ);      hdf5write(filename,attribute,LocationZ,'writemode','append');
    attribute.Name = 'LocationUser';    LocationUser    = double(nsFile.Analog.Info(i).LocationUser);   hdf5write(filename,attribute,LocationUser,'writemode','append');
    attribute.Name = 'HighFreqCorner';  HighFreqCorner  = double(nsFile.Analog.Info(i).HighFreqCorner); hdf5write(filename,attribute,HighFreqCorner,'writemode','append');
    attribute.Name = 'HighFreqOrder';   HighFreqOrder   = uint32(nsFile.Analog.Info(i).HighFreqOrder);  hdf5write(filename,attribute,HighFreqOrder,'writemode','append');
    attribute.Name = 'HighFilterType';  HighFilterType  = char(nsFile.Analog.Info(i).HighFilterType);   hdf5write(filename,attribute,HighFilterType,'writemode','append');
    attribute.Name = 'LowFreqCorner';   LowFreqCorner   = double(nsFile.Analog.Info(i).LowFreqCorner);  hdf5write(filename,attribute,LowFreqCorner,'writemode','append');
    attribute.Name = 'LowFreqOrder';    LowFreqOrder    = uint32(nsFile.Analog.Info(i).LowFreqOrder);   hdf5write(filename,attribute,LowFreqOrder,'writemode','append');
    attribute.Name = 'LowFilterType';   LowFilterType   = char(nsFile.Analog.Info(i).LowFilterType);    hdf5write(filename,attribute,LowFilterType,'writemode','append');
    attribute.Name = 'ProbeInfo';       ProbeInfo       = char(nsFile.Analog.Info(i).ProbeInfo);        hdf5write(filename,attribute,ProbeInfo,'writemode','append');
    attribute.Name = 'EntityID';        EntityID        = uint32(nsFile.Analog.Info(i).EntityID);       hdf5write(filename,attribute,EntityID,'writemode','append');
    attribute.Name = 'ItemCount';       ItemCount       = uint32(nsFile.Analog.Info(i).ItemCount);      hdf5write(filename,attribute,ItemCount,'writemode','append');
    attribute.Name = 'EntityLabel';     EntityLabel     = char(nsFile.Analog.Info(i).EntityLabel);      hdf5write(filename,attribute,EntityLabel,'writemode','append');

end;


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% EVENT
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

N = length([nsFile.Event.Info(:).EntityID]);

for i=1:N,
    event_root = [ record_root '/Event/' sprintf('%d',i) ];
    event_leaf = [ event_root '/Data' ];

    eventData.TimeStamp             = double(nsFile.Event.TimeStamp{i});
    eventData.Data                  = uint32(nsFile.Event.Data{i});
    eventData.DataSize              = uint32(nsFile.Event.DataSize{i});

    hdf5write(filename,event_leaf,eventData,'writemode','append');

    attribute.AttachedTo = event_leaf;
    attribute.AttachType = 'dataset';

    attribute.Name = 'EventType';       EventType       = char(nsFile.Event.Info(i).EventType);         hdf5write(filename,attribute,EventType,'writemode','append');
    attribute.Name = 'MinDataLength'; 	MinDataLength   = uint32(nsFile.Event.Info(i).MinDataLength);   hdf5write(filename,attribute,MinDataLength,'writemode','append');
    attribute.Name = 'MaxDataLength'; 	MaxDataLength   = uint32(nsFile.Event.Info(i).MaxDataLength);   hdf5write(filename,attribute,MaxDataLength,'writemode','append');
    attribute.Name = 'CSVDesc';         CSVDesc         = char(nsFile.Event.Info(i).CSVDesc);           hdf5write(filename,attribute,CSVDesc,'writemode','append');
    attribute.Name = 'EntityID';        EntityID        = uint32(nsFile.Event.Info(i).EntityID);        hdf5write(filename,attribute,EntityID,'writemode','append');
    attribute.Name = 'ItemCount';       ItemCount       = uint32(nsFile.Event.Info(i).ItemCount);       hdf5write(filename,attribute,ItemCount,'writemode','append');
    attribute.Name = 'EntityLabel';     EntityLabel     = char(nsFile.Event.Info(i).EntityLabel);       hdf5write(filename,attribute,EntityLabel,'writemode','append');

end;


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% NEURAL
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
N = size(nsFile.Neural.EntityID,2);

for i=1:N,
    neural_root = [ record_root '/Neural/' sprintf('%d',i) ];
    neural_leaf = [ neural_root '/Data' ];

    neuralData = double(nsFile.Neural.Data{i});

    hdf5write(filename,neural_leaf,neuralData,'writemode','append');

    attribute.AttachedTo = neural_leaf;
    attribute.AttachType = 'dataset';

    attribute.Name  = 'EntityID';   EntityID = uint32(nsFile.Neural.EntityID(i)); hdf5write(filename,attribute,EntityID,'writemode','append');
end;


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% SEGMENT
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
N = size(nsFile.Segment.DataentityIDs,2);

for i=1:N,
    segment_root = [ record_root '/Segment/' sprintf('%d',i) ];

    segment_leaf_data = [ segment_root '/Data' ];
    data = double(nsFile.Segment.Data{i});
    hdf5write(filename,segment_leaf_data,data,'writemode','append');

    attribute.AttachedTo = segment_leaf_data;
    attribute.AttachType = 'dataset';

    attribute.Name = 'DataentityID';   DataentityID = uint32(nsFile.Segment.DataentityIDs(i));  hdf5write(filename,attribute,DataentityID,'writemode','append');

    segment_leaf_timestamp = [ segment_root '/TimeStamp' ];
    timestamp = nsFile.Segment.TimeStamp(:,1);
    timestamp = timestamp{1,1};
    timestamp = double(timestamp);
    hdf5write(filename,segment_leaf_timestamp,timestamp,'writemode','append');
    
    segment_leaf_unitid = [ segment_root '/UnitID' ];
    unitid = nsFile.Segment.UnitID(:,i);
    unitid = unitid{1,1};
    unitid = uint32(unitid);
    hdf5write(filename,segment_leaf_unitid,unitid,'writemode','append');

    segment_leaf_samplecount = [ segment_root '/SampleCount' ];
    samplecount = nsFile.Segment.SampleCount(:,i);
    samplecount = samplecount{1,1};
    samplecount = uint32(samplecount);
    hdf5write(filename,segment_leaf_samplecount,samplecount,'writemode','append');
end;