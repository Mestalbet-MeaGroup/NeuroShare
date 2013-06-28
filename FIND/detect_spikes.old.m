function txt_report=detect_spikes(varargin)
% function txt_report=detect_spikes(varargin)
% Perform Spike Detection in Analog Data
%
%
% RMeier

% the Varargin variables - with some DEFAULTS for safety

Data_Vectors='[1]';
ThresholdFactor=5;
Method_Number=1;
SORT_SPIKES=0;
CUTOUTS=1;
CUT_PRE=0.001;
CUT_POST=0.001;

pvpmod(varargin);

Data_Vectors=eval(Data_Vectors);

global nsFile

switch Method_Number

    case 1 % The mean +/- SD
        disp('chosen Method: Mean +/- SD');
        for ii=Data_Vectors  % Go over the data traces
            MeanDataTrace(ii)=mean(nsFile.Analog.Data(:,ii));
            SDDataTrace(ii)=std(nsFile.Analog.Data(:,ii));
            Threshold(ii)=MeanDataTrace(ii) +ThresholdFactor * SDDataTrace(ii);

            %% do the Detection
            temp=nsFile.Analog.Data(:,ii)>Threshold(ii);
            spike_times{ii}=find(diff([0;temp])==1);

            % Return the Values to the NS structure
                wh=nsFile.Analog.DataentityIDs(ii);
            srate=nsFile.Analog.Info(wh).SampleRate;
            nsFile.NeuralEvent.Data{ii}=spike_times{ii} / srate ; % UNITS: SECONDS!
            nsFile.NeuralEvent.EntityID(ii)=nsFile.Analog.DataentityIDs(ii);
        end

    case 2 % The rect. mean +/- SD
        disp('chosen Method: rect. Mean +/- SD');
        for ii=Data_Vectors  % Go over the data traces
            MeanDataTrace(ii)=mean(abs(nsFile.Analog.Data(:,ii)));
            SDDataTrace(ii)=std(abs(nsFile.Analog.Data(:,ii)));
            Threshold(ii)=MeanDataTrace(ii) +ThresholdFactor * SDDataTrace(ii);

            %% do the Detection
            temp=abs(nsFile.Analog.Data(:,ii))>Threshold(ii);
            spike_times{ii}=find(diff([0;temp])==1);

            % Return the Values to the NS structure
            wh=nsFile.Analog.DataentityIDs(ii);
            srate=nsFile.Analog.Info(wh).SampleRate;
            nsFile.NeuralEvent.Data{ii}=spike_times{ii} / srate ; % UNITS: SECONDS!
            nsFile.NeuralEvent.EntityID(ii)=nsFile.Analog.DataentityIDs(ii);
        end

    case 3 % The rect. N times median
        disp('chosen Method: rect. N* Median');
        for ii=Data_Vectors  % Go over the data traces
            MedianDataTrace(ii)=median(abs(nsFile.Analog.Data(:,ii)));

            Threshold(ii)=MedianDataTrace(ii) *ThresholdFactor;

            %% do the Detection
            temp=abs(nsFile.Analog.Data(:,ii))>Threshold(ii);
            spike_times{ii}=find(diff([0;temp])==1);
            % Return the Values to the NS structure
            wh=nsFile.Analog.DataentityIDs(ii);
            srate=nsFile.Analog.Info(wh).SampleRate;
            nsFile.NeuralEvent.Data{ii}=spike_times{ii} / srate ; % UNITS: SECONDS!
            nsFile.NeuralEvent.EntityID(ii)=nsFile.Analog.DataentityIDs(ii);
        end
    otherwise
        disp('Unknown method.');
end

%disp('Finished Spike Detection');
%%%%  if COUTOUTS are desired:
if CUTOUTS
    %  disp('cutting the spikes');


    txt_array=repmat(' ',length(Data_Vectors)+3,10); % Report Text

    txt_array(1,1:2)='ID';
    txt_array(1,6:10)='#Spks';

    count=1;
    for ii=Data_Vectors

        % Safety first -> get the actual ! Samplingrate!
        wh=nsFile.Analog.DataentityIDs(ii);
        srate=nsFile.Analog.Info(wh).SampleRate;
        all_spikes=spike_times{ii};
        txt_array(ii+1,1:3)=num2str(ii,'%03g'); % Data Trace ID
        txt_array(ii+1,6:10)=num2str(length(all_spikes),'%05g'); % Number of Spikes

        current_cutout_ids=[];
        for kk=1:length(all_spikes)
            curr_spike_time=all_spikes(kk);
            cut_vector=curr_spike_time-(CUT_PRE * srate): curr_spike_time+(CUT_POST *srate);
            if (cut_vector(1)>0) && (cut_vector(end)<=length(nsFile.Analog.Data(:,ii)))
                newdata.Segment.Data(:,count)=nsFile.Analog.Data(cut_vector,ii);
                newdata.Segment.SampleCount(count)=length(cut_vector); % REDUNDAND
                newdata.Segment.UnitID(count)=0; % UNSORTED --> DEFAULT
                newdata.Segment.TimeStamp(count)=curr_spike_time / srate; % in seconds
                newdata.Segment.DataEntityID(count)=-1; % NOT DEFINED HERE ! CHECK
                current_cutout_ids=[current_cutout_ids count];
                count=count+1;
            else
                disp('#lost a spike due to cutout boundary conditions!');
                disp(['#Timestamp = '  num2str(curr_spike_time)]);
                disp(['#Trace No. = '  num2str(ii)]);
            end
        end
        %% if needed --> SORT THEM
        if CUTOUTS && SORT_SPIKES
            disp('Starting the Spike Sorting for current channel ...')
            tmp_2sort=newdata.Segment.Data(:,current_cutout_ids);
            %% extracting features of the spikes --> squeezing them to max. 48
            %% dimensions -- > Be carfull here - some selection might be
            %% usefull!
            tmp_2sort_resampled=resample(tmp_2sort,48,size(tmp_2sort,2));
            this_clusters=callklustakwik(tmp_2sort_resampled');
            newdata.Segment.UnitID(current_cutout_ids)=this_clusters;
        end
    end
    % push the cutouts into the nsFile Variable
    tempidx=1;
    store_ns_newsegmentdata;
    clear newdata; %% Clean up!
    %disp('done with cutting');
else
    disp(' cutouts were not generated!');
end

txt_array(end,1:9)=['Method: ' num2str(Method_Number)];

txt_report=txt_array;


