function Coefs=WPextractMark(RawData,realTHRESH,Params)

% [Coefs]=WPextract(RawData,realTHRESH);
% This function extracts the selected 9 coefficients
%
% RawData is a vector or matrix of vectors to be analyzed
% realTHRESH is the original alpha-map threshold for this channel
% Params.MaxVoltageThresh is the maxmimum allowed voltage for a signal (above it the spike is removed from the spike list.
% Params.SpikeDetectionThresh is the threshold for detecting a spike with the detection wavelet (Original value was set to 100).

% Coefs contains the coefs. for each spike and also the frame number of the specific spike,
% 	the tip value from block (2,0), the offset of the tip and the packet of tip from (2,0).

% 14/6/05: only spikes that would have passed the original threshold are analyzed
% 16/01/05 - call to WPAnalysis2.dll -  looks like a faster version of
% WPanalysis.




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

%not clear what this is for:
if length(RawData)>237
    II=length(RawData)-237+(1:237); %rdd spike indices
    timeindex=(length(RawData)-237);
    Time=RawData(timeindex);
else
    II=1:237;
    Time=0;
end;
RawData=RawData(II);

Coefs=[];
spikenum=1;
%for i=STEP:STEP:size(RawData,1)

%   rdata=RawData(i,:);
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
% V=V(find(abs(V)>Params.SpikeDetectionThresh));
for j=1:min(MAXNUM,length(V))
    [offset,pack]=find(DD==V(j));
    pack=pack-1; 	% turning to real packet indicing.
    rrdata=rd(offset+(0:255));
    if (pack+5) < 56 & (pack+5)>9
        %& isempty(find(abs(O(1:(j-1))-pack)<=2)) % use when not searching for real minima
        %looking for a posible spike at the middle section only
        % the true limits for 128 clear idices are 18-47 (including), but we allow up
        % to 32 zero padding at either side.
        I=((pack+5)*4-1)-CENTER+(1:128); %(-2,0,0) refers to index 19 as center of packet
        a1=find(I<1, 1, 'last' ); if isempty(a1), a1=0; end;
        a2=find(I>256, 1 ); if isempty(a2), a2=129; end;
        data=[zeros(1,a1),rrdata(I(a1+1:a2-1)),zeros(1,129-a2)];	%data=rrdata(I);
        if Params.RemoveSubThreshSpikes
            %only spikes that would have passed the real threshold of the system are analyzed!
            if (max(abs(data(CENTER-2:CENTER+2)))>abs(realTHRESH)) & (isempty(find(abs(data)>Params.MaxVoltageThresh, 1))),
                data=data-mean(data);
                wp=WPAnalysis(data,D,QMF);		%%%%%% WaveLab's WPAnalysis
                Coefs(spikenum,:)=[wp(wpIND),V(j),1,Time,offset,pack];
                spikenum=spikenum+1;
            end
        else
            %examines all spikes
            if (isempty(find(abs(data)>Params.MaxVoltageThresh, 1))),
                data=data-mean(data);
                wp=WPAnalysis(data,D,QMF);		%%%%%% WaveLab's WPAnalysis
                Coefs(spikenum,:)=[wp(wpIND),V(j),1,Time,offset,pack];
                spikenum=spikenum+1;
            end
        end
    end
end

