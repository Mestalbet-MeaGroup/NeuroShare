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

function [t,ic,V,WPC,SpikeData]=SpikeDetection(McdFile,SelectedChannels,SpikeDetectionThresh,RemoveSubThreshSpikes,AddWaveletCoeff)

MinSpikesInIndexChannel=5;

Params.SpikeDetectionThresh=SpikeDetectionThresh;
if exist('RemoveSubThreshSpikes','var')
    Params.RemoveSubThreshSpikes=RemoveSubThreshSpikes;
else
    Params.RemoveSubThreshSpikes=1;
end
if exist('AddWaveletCoeff','var')
    Params.AddWaveletCoeff=AddWaveletCoeff;
else
    Params.AddWaveletCoeff=1;
end

DataFile=datastrm(McdFile);
SpikeInfo = getfield(DataFile,'StreamInfo',{1});
ChannelNames=getfield(DataFile,'ChannelNames2',{1});ChannelNames=str2double(ChannelNames{1});
ChannelID=getfield(DataFile,'ChannelID2',{1});ChannelID=ChannelID{1};
[MEAindex indx]=sort(ChannelID');
channels=ChannelNames(indx)'; %Regular MCS setup
Thresholds_uV=SpikeInfo{1}.Level*1e6;Thresholds_uV=Thresholds_uV(indx);

if SelectedChannels==0
    SelectedChannels=channels;
else
    SelectedChannels=sort(SelectedChannels);
end

NSelectedChannels=length(SelectedChannels);
for i=1:NSelectedChannels
    SpikeData(i).Times=[];
    SpikeData(i).Voltages=[];
    SpikeData(i).WPCoeffes=[];
end

Tstart = getfield(DataFile,'sweepStartTime',{1});
Tend = getfield(DataFile,'sweepStopTime',{1});
T=Tstart;
Tstep=1000*60; % units of Tstart and Tend is in msec, read data every 1 minute.
SamplingRate=getfield(DataFile,'MillisamplesPerSecond2',{1})/1000;   %in khz

%Begin Data preparation
h=waitbar(0,'Running spike detection...');
while T<Tend, %read minute by minute
    Tstart=T;
    T=T+Tstep;
    if T>Tend,
        T=Tend;
    end
    waitbar(T/Tend,h);
    c = nextdata(DataFile,'streamname','Spikes 1','startend',[Tstart T]);
    for i=1:NSelectedChannels
        VoltageData=ad2muvolt(DataFile,c.spikevalues{MEAindex(find(channels==SelectedChannels(i)))},'Spikes 1')';
        VoltageOffset=mean(mean(VoltageData));
        VoltageData=VoltageData-VoltageOffset;
        if size(VoltageData,2)~=0 & size(VoltageData,1)~=0,
            TimeData=c.spiketimes{MEAindex(find(channels==SelectedChannels(i)))}*12;   %convert msec to 12 khz
            for j=1:size(VoltageData,1),
                VoltageDataTmp(j,:)=spline(1:length(VoltageData(j,:)),VoltageData(j,:),linspace(1,length(VoltageData(j,:)),237));
            end
            for frame=1:length(TimeData)
                [PeakAmpData,WPCoeffs]=WP3(VoltageDataTmp(frame,:),Thresholds_uV(i)-VoltageOffset,Params); %The function recieves the threshold setting and spike detection parameters
                if ~isempty(PeakAmpData)
                    PeakAmpData(2,:)=PeakAmpData(2,:)+TimeData(frame)+12;%-120;
                    SpikeData(i).Voltages=[SpikeData(i).Voltages PeakAmpData(1,:)];%Removes the offset
                    SpikeData(i).Times=[SpikeData(i).Times PeakAmpData(2,:)];
                    SpikeData(i).WPCoeffes=[SpikeData(i).WPCoeffes WPCoeffs];
                end
            end     
        end
    end
end
t=[];V=[];WPC=[];ic=[];
for i=1:NSelectedChannels
    if length(SpikeData(i).Times)<MinSpikesInIndexChannel
        continue;
    else
        ic=[ic [SelectedChannels(i);1;length(t)+1;length(t)+length(SpikeData(i).Times)]];
        t=[t SpikeData(i).Times];
        V=[V SpikeData(i).Voltages];
        WPC=[WPC SpikeData(i).WPCoeffes];
    end
end
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
V=V(find(abs(V)>Params.SpikeDetectionThresh));
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
            a1=max(find(I<1)); if isempty(a1), a1=0; end;
            a2=min(find(I>256)); if isempty(a2), a2=129; end;
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