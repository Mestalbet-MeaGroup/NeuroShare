function meabench2neuroshare_old(fn,range,freq)
% this is the old version !!!!!!!!!
% Don't use this - doesn't work well
%
% Load Meabench File and convert it to neuroshare conform data structure 
% function meabench2neuroshare(fn,range,freq)
% converts times to seconds and width to
% milliseconds using the specified frequency, and the height and
% context data to microvolts by multiplying by RANGE/2048.
% As a special case, range=0..3 is interpreted as a MultiChannel Systems 
% gain setting:
% 
% range value   electrode range (uV)    auxillary range (mV)
%      0               3410                 4092
%      1               1205                 1446
%      2                683                  819.6
%      3                341                  409.2
% 
% "electrode range" is applied to channels 0..59, auxillary range is
% applied to channels 60..63.
% In this case, the frequency is set to 25 kHz unless specified.
%
% Finally results are stored in the global nsFile variable.
% Only Segment Data is generated !   
% 
% rmeier 07
% This function belongs to FIND_GUI Toolbox project
% http://find.bccn.uni-freiburg.de


%%%%%%%%%%%%%%%%%%
disp('this is an old version !  DO NOT USE! ');
error(' Call of deprecated function! ')
return;

% catch abuse version -- will be removed soon!
% Rmeier , 22. Okt. 2007
%%%%%%%%%%%%%%%%%%

global nsFile;


% this is pointless...
% if ~exist('nsFile')
%     error('no data variable specified')
%     return
% end

% is this necessary? when this program is run, nsFile normally hasn't been
% created...
% if ~isstruct(nsFile)
%     error('data variable (nsFile) is not a struct')
%     return
% end

if nargin<2
    range=nan;
end
if nargin<3
    freq=nan;
end

fid = fopen(fn,'rb');
if (fid<0)
    error('Cannot open the specified file');
end
raw = fread(fid,[132 inf],'int16');     %fills an 82xinf matrix, where inf actually means until the end of file, i.e. the whole file
% correct for that to read a file
% only partially
%'int16' is a data type specifier,
%i.e. int with a size of 16 bits
%(2byte)
fclose(fid);
ti0 = raw(1,:); idx = find(ti0<0); ti0(idx) = ti0(idx)+65536;
ti1 = raw(2,:); idx = find(ti1<0); ti1(idx) = ti1(idx)+65536;
ti2 = raw(3,:); idx = find(ti2<0); ti2(idx) = ti2(idx)+65536;
ti3 = raw(4,:); idx = find(ti3<0); ti3(idx) = ti3(idx)+65536;
y.time = (ti0 + 65536*(ti1 + 65536*(ti2 + 65536*ti3)));
y.channel = raw(5,:);
y.height = raw(6,:);
y.width = raw(7,:);
y.context = raw(8:131,:);
y.thresh = raw(132,:);

%the following part is for the case when a gain argument is given
if ~isnan(range)
    if ~isempty(find([0 1 2 3]==range))
        ranges= [ 3410,1205,683,341 ];
        range = ranges(range+1);
        auxrange = range*1.2;
        %if isnan(freq)
        % freq = 25.0;
        %end
        isaux = find(y.channel>=60);
        iselc = find(y.channel<60);
        y.height(iselc) = y.height(iselc) .* range/2048;
        y.thresh(iselc) = y.thresh(iselc) .* range/2048;
        y.context(:,iselc) = y.context(:,iselc) .* range/2048;
        y.context = y.context-range;
        y.height(isaux) = y.height(isaux) .* auxrange/2048;
        y.thresh(isaux) = y.thresh(isaux) .* auxrange/2048;
        y.context(:,isaux) = y.context(:,isaux) .* auxrange/2048;
    else
        y.height = y.height  .* range/2048;
        y.thresh = y.thresh  .* range/2048;
        y.context= y.context .* range/2048;
    end
end


%this is the part where it imports data without any conversion of the time
%or voltage, i.em when no argument is given
if ~isnan(freq)
    y.time = y.time ./ (freq*1000);
    y.width = y.width ./ freq;
else
    warning('TIME WAS NOT CONVERTED TO SECONDS! using Sample Points instead! NOT Neuroshare API Conform!');
end

%%% push into nsFile Structure

count=1;
for kk=1:length(y.time)
    newdata.Segment.Data(:,count)=y.context(:,kk);
    newdata.Segment.SampleCount(count)=length(y.context(:,kk)); % REDUNDAND
    newdata.Segment.UnitID(count)=0; % UNSORTED --> DEFAULT
    newdata.Segment.TimeStamp(count)=y.time(kk); % in seconds
    newdata.Segment.DataEntityID(count)=y.channel(kk);
    count=count+1;
end


UCHAN=unique(y.channel);
for kk=1:length(UCHAN)
    nsFile.EntityInfo(kk).EntityLabel=['Meabench EL ' num2str(hw2cr(UCHAN(kk)))];
    nsFile.EntityInfo(kk).EntityType=3;
    nsFile.EntityInfo(kk).ItemCount=125;
    nsFile.EntityInfo(kk).EntityID=UCHAN(kk)+1;
end

% push the cutouts into the nsFile Variable
tempidx=1;
store_ns_newsegmentdata;
clear newdata; %% Clean up!


nsFile.FileInfo.FileType='MEABench Spike Data';
nsFile.FileInfo.EntityCount= 63
nsFile.FileInfo.TimeStampResolution=1/(1000*freq);
nsFile.FileInfo.TimeSpan=y.time(end);
nsFile.FileInfo.AppName='FIND 0.01'
% Dummy from here on ...
% nsFile.FileInfo.Time_Year=9999
% nsFile.FileInfo.Time_Month: 10
%                nsFile.FileInfo.Time_Day: 23
%               nsFile.FileInfo.Time_Hour: 11
%                nsFile.FileInfo.Time_Min: 31
%                nsFile.FileInfo.Time_Sec: 31
%           nsFile.FileInfo.Time_MilliSec: 112
%             nsFile.FileInfo.FileComment: ''
%        nsFile.FileInfo.Datatypespresent: [0 0 1]
global nsFile