% [t,ic,V,WPC,SpikeData]=SpikeDetection(McdFile,SelectedChannels,SpikeDetectionThresh,RemoveSubThreshSpikes,AddWaveletCoeff);
% Function purpose : Detects all spikes and gives back times maximal amplitudes and 9 wavelet coefficients
%
% Recives :     McdFile- the mcd to extract amplitudes
%               SelectedChannels - the list of selected channels (mcd format) - if 0 takes all channels
%               SpikeDetectionThresh - wavelet based Spike decection threshold.
%               RemoveSubThreshSpikes - boolean to remove spikes below real recording threshold (1==remove) (default=1).
%               AddWaveletCoeff - boolean to add wavelet coefficients (1==add) (default=1)
% Function give back :  t [ms] - firing timings
%                                                  ic - index chanel
%                                                   V [uV] - peak voltages.
%                                                   WPC - 9 WP coefficients
%                                                   SpikeData
%                                                       .Voltages-the peak voltages of the spikes
%                                                       .Times- the times of spikes.
%                                                       .WPCoeffs - 9 wavelet coefficients 
%                                                   
% Recomended usage  : [SD]=SpikeDetection('test.mcd',[42 51 62],50,1,1);
% Last updated : 18/10/08
% Modified by Noah Levine-Small for Neuroshare compatibility (2011)

function SpikeDetection_mod4Batch(McdFile) %,SpikeDetectionThresh,RemoveSubThreshSpikes,AddWaveletCoeff)


MinSpikesInIndexChannel=5;
Params.SpikeDetectionThresh=3e-5;
Params.AddWaveletCoeff=1;
Params.RemoveSubThreshSpikes=0;
%%
% set path to access FIND neuroshare_loader_all.m and DLL
hostname = char( getHostName( java.net.InetAddress.getLocalHost ) );
if strcmp(hostname,'CZC2X')
    DllPath= 'D:\Users\zeiss\Documents\GitHub\NeuroShare\FIND';
else
    if strcmp(hostname,'NoahLaptop')
        DllPath='D:\Users\zeiss\Documents\GitHub\NeuroShare\FIND';
    else
        error('You need the assert function from FIND toolbox. Change the path for this computer');
    end
end

% DllPath='C:\Neuroshare\FIND\';% FIND_2.0 path
DLLName = 'nsMCDLibrary64.dll';
DLLfile = fullfile(DllPath, DLLName);
[ns_RESULT] = ns_SetLibrary(DLLfile);
[ns_RESULT, hfile] = ns_OpenFile(McdFile);
[ns_RESULT, FileInfo] = ns_GetFileInfo(hfile);
[ns_RESULT, EntityInfo] = ns_GetEntityInfo(hfile, 1:FileInfo.EntityCount);
 segmententityIDs = find(cell2mat({EntityInfo.EntityType})==3);
  
 % skip all empty channels
segmententityIDs = segmententityIDs([EntityInfo(segmententityIDs).ItemCount] ~= 0);
ChannelLabel = {EntityInfo(segmententityIDs).EntityLabel};
channels     = [cellfun(@(x) str2num(x(end-2:end)), ChannelLabel,'UniformOutput', 1 )];
% ChannelID equals former entityID under FIND

%For windows larger than 20ms.
SpikeSortingWindow=0.02; %Original spike sorting window in [sec]
[ns_RESULT, SegmentInfo] = ns_GetSegmentInfo(hfile, segmententityIDs);
SamplingRate=unique([SegmentInfo(:).SampleRate]);   
RecWindow=(unique([SegmentInfo(:).MinSampleCount])/SamplingRate); % assuming
%the same samplingrate on every CH and the same cutout size for all detected spikes
if RecWindow==0
   keyboard; 
end
PPW=floor(RecWindow/SpikeSortingWindow);
if PPW<1
    PPW = 1;
end % Determines the number of 20ms frames in one window
NWindowSamples=RecWindow*SamplingRate;
NSubWindowSamples=NWindowSamples/PPW;
if NSubWindowSamples<1
    NSubWindowSamples=1;
end

WinTimeAddition = ((0:SpikeSortingWindow:abs(RecWindow-SpikeSortingWindow))- RecWindow/2+SpikeSortingWindow/2)*12000;

%%
SelectedChannels=segmententityIDs;

NSelectedChannels=length(SelectedChannels);
for ii=1:NSelectedChannels
    SpikeData(ii).Times=[];
    SpikeData(ii).Voltages=[];
    SpikeData(ii).WPCoeffes=[];
end

%Begin Data preparation
 h=waitbar(0,'Running spike detection...');

co=0;
for ij=1:length(SelectedChannels)
    i=SelectedChannels(ij);
    co=co+1;
    [~, TimeData, VoltageData , ~, ~] = ns_GetSegmentData(hfile,i, 1:EntityInfo(i).ItemCount);
    Params.SpikeDetectionThresh=-1*(abs(min(min(VoltageData)))-0.1*abs(min(min(VoltageData)))); %Threshold for taking only largest spikes
    TimeData=TimeData.*1000.*12;
    if size(VoltageData,1)==1 
        VoltageData=VoltageData';
    end
    
    VoltageOffset=mean(mean(VoltageData));
    VoltageData=VoltageData-VoltageOffset;
   
    if size(VoltageData,2)~=0 && size(VoltageData,1)~=0,

      for j=1:size(VoltageData,2) %goes over every window for a single channel during time semgment [Tstart T]
        for k=1:PPW %divides the every window to 20ms windows.
             VoltageDataTmp(:,(j-1)*PPW+k)=spline(1:NSubWindowSamples, VoltageData(((k-1)*NSubWindowSamples+1):k*NSubWindowSamples,j),linspace(1,NSubWindowSamples,237));      
        end
      end
      
    L_tmp=length(TimeData);
    TimeDataTmp=(TimeData*ones(1,PPW)+ones(L_tmp,1)*WinTimeAddition)';
    TimeData=TimeDataTmp(:);
    
    clear VoltageData;
    VoltageData=VoltageDataTmp';

        for frame=1:size(VoltageData,1)
             temp(frame)=-4*(max(abs(VoltageData(frame,:))));
        end
%             Params.SpikeDetectionThresh=(mean(abs(temp)));
            Thresholds_uV=max(temp);
             
        for frame=1:length(TimeData)
%             figure; hold on; plot(VoltageData); line(1:size(VoltageData,1),Thresholds_uV); hold off;
            [PeakAmpData,WPCoeffs]=WP3(VoltageData(frame,:),Thresholds_uV,Params); %The function recieves the threshold setting and spike detection parameters
            
            if ~isempty(PeakAmpData)
                PeakAmpData(2,:)=PeakAmpData(2,:)+TimeData(frame)+12;%-120;
                SpikeData(co).Voltages=[SpikeData(co).Voltages PeakAmpData(1,:)];%Removes the offset
                SpikeData(co).Times=[SpikeData(co).Times PeakAmpData(2,:)];
                SpikeData(co).WPCoeffes=[SpikeData(co).WPCoeffes WPCoeffs];
            end
        end
    end
    
    percent=co/length(segmententityIDs)*100;
    waitbar(co/length(segmententityIDs),h,sprintf('%12.1f',percent));

end

t=[];V=[];WPC=[];ic=[];
for i=1:NSelectedChannels
    if length(SpikeData(i).Times)<MinSpikesInIndexChannel
        continue;
    else
        ic=[ic [str2num(EntityInfo(SelectedChannels(i)).EntityLabel(23:27));1;length(t)+1;length(t)+length(SpikeData(i).Times)]];
        t=[t SpikeData(i).Times];
        V=[V SpikeData(i).Voltages];
        WPC=[WPC SpikeData(i).WPCoeffes];
    end
end
  save([McdFile(1:end-4) '.mat'],'t','ic');
close(h)

function [Peaks,WPCoeffs]=WP3(RawData,realTHRESH,Params)
WPCoeffs=[];
D=5;
IND=[7,8,13,25,26,50,51,72,89];
wpIND=[519,520,525,409,410,306,307,456,729];
% The packets are:
%     4     4     4     3     3     2     2     3     5
%     0     0     1     1     1     1     1     4    22
%     6     7     4     8     9    17    18     7     0
%STEP=1;

MAXNUM=10;
CENTER=66;
MOTHERW='Coiflet';
WPARAM=3;
WAVELET=[MOTHERW num2str(WPARAM)];
QMF=MakeONFilter(MOTHERW,WPARAM);			%%%%%% WaveLab's MakeONFilter

rdata=RawData;
rdata=rdata-mean(rdata);
rd=[zeros(1,11),rdata(1:end),zeros(1,11)];

I1=1:256; d1=rd(I1); wpd1=WPAnalysis(d1,2,QMF); D1=wpd1(packet(2,0,256),3)'; %blue
I2=2:257; d2=rd(I2); wpd2=WPAnalysis(d2,2,QMF); D2=wpd2(packet(2,0,256),3)'; %green
I3=3:258; d3=rd(I3); wpd3=WPAnalysis(d3,2,QMF); D3=wpd3(packet(2,0,256),3)'; %red
I4=4:259; d4=rd(I4); wpd4=WPAnalysis(d4,2,QMF); D4=wpd4(packet(2,0,256),3)'; %cyan
DD=[D1;D2;D3;D4];
V=min(DD);
V=V(2+find( V(3:end-2)<V(2:end-3) & V(3:end-2)<V(4:end-1) ));%finding real minima
V=sort(V);	%when not searching for real minima, [V,O]=sort(V);
V=V(abs(V)>Params.SpikeDetectionThresh);
Peaks=[];
WPCoeffs=[];
for j=1:min(MAXNUM,length(V))
    [offset,pack]=find(DD==V(j));
    pack=pack-1; 	% turning to real packet indicing.
    rrdata=rd(offset+(0:255));
    if (pack+5) < 56 & (pack+5)>9
        Place=(pack+5)*4+offset-2;
        reg=2;
        [tmpVoltage Shift]=max(abs(rd((Place-reg):(Place+reg))));
        Place=Place+(Shift-(reg+1))-11;
        Voltage=RawData(Place);
        IsOverRealThresh=abs(Voltage)>=abs(realTHRESH);
        if (Params.AddWaveletCoeff && ~Params.RemoveSubThreshSpikes) || (Params.AddWaveletCoeff && Params.RemoveSubThreshSpikes && IsOverRealThresh)
            I=((pack+5)*4-1)-CENTER+(1:128); %(-2,0,0) refers to index 19 as center of packet
            a1=find(I<1, 1, 'last' ); if isempty(a1), a1=0; end;
            a2=find(I>256, 1 ); if isempty(a2), a2=129; end;
            data=[zeros(1,a1),rrdata(I(a1+1:a2-1)),zeros(1,129-a2)];	%data=rrdata(I);
            data=data-mean(data);
            wp=WPAnalysis(data,D,QMF);
            WPCoeffs=[WPCoeffs wp(wpIND)'];
        end
        if Params.RemoveSubThreshSpikes & IsOverRealThresh
            Peaks=[Peaks [Voltage;Place]];
        end
        if ~Params.RemoveSubThreshSpikes
            Peaks=[Peaks [Voltage;Place]];
        end
    end
end