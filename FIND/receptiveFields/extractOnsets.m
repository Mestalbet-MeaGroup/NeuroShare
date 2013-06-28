function trigger=extractOnsets(varargin)
% reads in the stimulus and extracts starting points of black frames
%
%
% Parameters to be passed as parameter-value pairs:
%
% %%%%% Obligatory Parameters %%%%%
%
% 'analogEntityIndices': The ID of the recorded stimulus.
%
%%%%%%%%%%%%%%%%%%%%%%%%%%% Optional Parameters %%%%%
%
%
% % 'ifplot': the plots take large amounts of memory, so if the plots don't
%       need to be made, this should be 0 (DEFAULT)!
%
% 'MinBlack': The minimal number of black points found by a convolution.
%       Possible numbers: The number of one frame is 250, so with some
%       outlier this number should be around 247 (default).
%
%   'Shift': The number to points the trigger should be shifted.
%               Default:2.
%
%
%


global nsFile

% obligatory argument names
obligatoryArgs={'analogEntityIndices'};


% optional arguments names with default values
optionalArgs={'ifplot','MinBlack','Shift','trunks'};
ifplot=0;
MinBlack=220;
Shift=10;
trunks=4;

errorMessage=checkPVP(varargin,obligatoryArgs,optionalArgs);
if ~isempty(errorMessage)
    error(errorMessage,''); %used this format so that the '\n' are converted
end

% loading parameter value pairs into workspace, overwriting defaul values
pvpmod(varargin);

if ~isfield(nsFile,'Analog') || ~isfield(nsFile.Analog,'Data') ...
        || isempty(nsFile.Analog.Data)
    error('FIND:noAnalogData','No analog data found in nsFile variable.');
end

posEntityID=[];
for j=1:length(analogEntityIndices)
    posEntityID=[posEntityID,find(nsFile.Analog.DataentityIDs==analogEntityIndices(j))];
end
eventPosEntityID=find(nsFile.Analog.DataentityIDs==eventID);


trigger=[];
for c=posEntityID
    stimSize=nsFile.EntityInfo(c).ItemCount/trunks;
    for tr=1:trunks

        %%%%load data from stimulus channel
        % find black points
        black=zeros(nsFile.EntityInfo(c).ItemCount/trunks,1);%indx(2),1);
        black(find(nsFile.Analog.Data(((tr-1)*stimSize+1):tr*stimSize,c)<50))=1;
        %%% find black frames (250 points of which more than 240 are black)
        temp=conv(black,ones(250,1));
        temp=temp(1:(end-250));
        trigg=find(temp>MinBlack);
        difference=diff(trigg);
        trigger_pre=trigg(1);
        trigger_pre=[trigger_pre;trigg(find(difference>150000)+1)];
        trigger_pre=trigger_pre(1:end-1);
        twos=ones(size(trigger_pre));
        twos=Shift*twos;%+indx(ii-1);
        trigger=[trigger;trigger_pre+twos+(tr-1)*stimSize];%[trigger;trigger_pre+twos];
        %end

    end
    if ifplot
        %%%plot the whole data set with triggers
        h=figure;
        set(h, 'Visible', 'off');
        plot([1:nsFile.EntityInfo(c).ItemCount]/25, nsFile.Analog.Data(:,c),'k');
        hold on
        for ii=1:length(trigger)
            plot([trigger(ii)/25 trigger(ii)/25], [0 1000], 'r');
        end
        xlabel('time/ms')
        ylabel('intensity of signal')
        title('stimulus and extracted triggers')
        print -dpng triggers.png


        %%% plot the surround of the trigger to get an idea of the fuzziness
        trigger_surround=zeros(length(trigger), 2001);
        for t=1:length(trigger)
            trigger_surround(t,:)=nsFile.Analog.Data(trigger(t)-1000:trigger(t)+1000,c);
        end
        h1=figure;
        imagesc([-1000:+1000]/25,1:length(trigger),trigger_surround);
        hold on
        title('fuzzyness of trigger onset')
        xlabel('time around trigger/ms')
        ylabel('# of trials')
        plot([0 0],[0 length(trigger)],'r', 'LineWidth', 2)
        print -dpng trigger_surround.png
    end
    % %%%store data in nsFile%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    newdata.Event.Data{c}=trigger;
    newdata.Event.DataSize{c}=size(trigger);
    newdata.Event.TimeStamp{c}=trigger/nsFile.Analog.Info(c).SampleRate;
    StringEvent{c}='extracted Onsets';
    %save entityIDs of loaded data
end
newdata.Event.EntityID=analogEntityIndices;
store_ns_neweventdata('newdata',newdata,'DataOrigin',StringEvent);



