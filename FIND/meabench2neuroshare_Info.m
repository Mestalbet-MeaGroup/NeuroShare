function meabench2neuroshare_Info(varargin)
% load parts of Meabench '.spike' File and convert it to neuroshare conform data structure
%
% meabench2neuroshare_Info loads the Infos, the spiketimes and the
% reffering channels of meabench '.spike' files. Maximal 1.500.000 spike
% times can be loaded from a file.
% This loading routine presumes the usage of multi electrode arrays with 64
% electrodes, were hardware channel 0-59 are used to collect data and hw CH
% 60-63 detecting trigger pulses.
% The data (referring to meabench2neuroshare_Data) were
% converted to microvolts by multiplying by range/2048.
% As a special case, range=0..3 is interpreted as a MultiChannel Systems
% gain setting (digital zero: 2048):
%
% range value   electrode range (uV)    auxillary range (mV)
%      0               3410                 4092
%      1               1205                 1446
%      2                683                  819.6
%      3                341                  409.2
%
% Finally results are stored in the global nsFile variable.
% meabench2neuroshare_Info uses the following parameters, all to passed as
% parameter-value-pairs.
%
% %%%%% Obligatory Parameters %%%%%
%
% 'fileName': Name of the data file to be loaded, including a relative or
% absolute path.
%
% %%%%% Optional Parameters %%%%%
%
% 'descFileName' :
%   Name of the description file - necessesary to load up additional infos
%
% 'freq' :
%   sampling frequency - necessesary input to convert time steps into seconds
%
% 'range' :
%   digital resolution - necessesary input to convert measured data into
%   voltage
%
% 'loadMode': This argument controls what to do with previously loaded data
% when new data of the same type is loaded to the nsFile variable.
% Possible values:
%   'prompt' - this is the default setting. The user will be prompted about
%   whether the new data should be appended or the old data be overwritten.
%   With the next two options this behaviour can be set directly.
%
%   'append' - new data is automatically appended to the existing data.
%   This may require zero padding and in consequence additional memory. See
%   the argument 'zeroPadding' below, which controls the behaviour in this
%   case.
%
% %%%% NOTE : %%%%
%
% depending on the exsitance of a description file, different information
% about file and data are uploaded
%
% --------------------------
% a.kilias, r.meier 07 
% (last general revision 08/08 by kilias)
%
% This function belongs to FIND_GUI Toolbox project
% http://find.bccn.uni-freiburg.de

global nsFile;

try
    % obligatory argument names & validity test functions
    obligatoryArgs={{'fileName',@(val) ischar(val) && isfile(val)}};

    % optional arguments names with default values
    optionalArgs={{'descFileName',@(val) ischar(val) && isfile(val)},...
        {'freq',@(val) val>0},...
        {'rangeID',@(val) ismember(val,[0 1 2 3])},...
        {'loadMode',@(val) ismember(val,{'overwrite','append','prompt'})}};

    % default parameter values
    loadMode = 'prompt';

    % parameter check
    errorMessage=checkPVP(varargin,obligatoryArgs,optionalArgs);
    if ~isempty(errorMessage)
        error(errorMessage,'');
    end
    pvpmod(varargin);

    % convert rangeID into value
    if exist('rangeID')==1
        RangePos=(find([0 1 2 3]==RangeID));
        rangeElec= [ 3410,1205,683,341 ]; %  Gain: '0.333496 uV/digistep [+- 683 uV range]'
        range=rangeElec(RangePos)/2048;      % divide by Digital_zero: '2048'
    end

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%% searching for desc File and loading Info out of it

    if exist('descFileName')==1
        descInfo=meabench2neuroshare_Desc(descFileName);

        %%%%%% Example descInfos:
        %  Data_filename: '23_10_06_289stim.spike'
        %            Creating_program: 'record (meabench)'
        %              Creating_user: 'meabench,,, (meabench)'
        %                        Date: 'Mon Oct 23 18:32:31 2006'
        %                    Comments: [1x0 char]
        %                   Data_type: 'spike'
        %            Immediate_source: 'spike'
        %      Buffer_use_percentages: '3 11'
        %     Recording_terminated_by: 'End of source stream'
        %                   Triggered: 'No'
        %                    Hardware: 'No hardware problems detected'
        %                Digital_zero: '2048'
        %            Digital_min_rail: '0'
        %            Digital_max_rail: '4095'
        %          Nominal_half_range: '2048'
        %             Raw_sample_freq: '25 kHz'
        %                        Gain: '0.333496 uV/digistep [+- 683 uV range]'
        %                    Aux_gain: '0.400195 mV/digistep [+- 819.6 uV range]'
        %              Spike_detector: 'BandFlt-25'
        %                   Threshold: '7.0'
        %            Number_of_spikes: '3837'
        %              Threshold_unit: 'uV'
        %            Threshold_values: {1x8 cell}


        %1.) set FileInfos
        nsFile.FileInfo.Date=descInfo.Date;
        nsFile.FileInfo.FileComment=descInfo.Comments;
        nsFile.FileInfo.HardwareComment=descInfo.Hardware;
        nsFile.FileInfo.FileType=strcat('meabench *.',descInfo.Data_type);

        %2.) set Trigger and Data Infos
        for kk=1:64
            if kk>61 % Trigger Channels
                nsFile.Event.Info(kk-60).EntityID=kk;
                nsFile.Event.Info(kk-60).ItemCount=[];
                nsFile.Event.Info(kk-60).EntityLabel=['MEABench Data, Trigger of CH: ', num2str(hw2cr(kk-1))];
            else % Data Channels
                nsFile.Segment.Info(kk).DataentityIDs=kk;
            end
            %3.) set EntityInfos.Info (general EntityInfo see below)
            nsFile.EntityInfo(kk).Info.Threshold=strcat(descInfo.Threshold,descInfo.Threshold_unit);
            nsFile.EntityInfo(kk).Info.BandFilterType=descInfo.Spike_detector;
            nsFile.EntityInfo(kk).Info.RangeInfo=descInfo.Gain;
            nsFile.EntityInfo(kk).Info.Range=cell2mat(textscan(descInfo.Gain,'%n')); % (resolution of the data channels)
            nsFile.EntityInfo(kk).Info.SampleRate=cell2mat(textscan(descInfo.Raw_sample_freq,'%n'))*1000; %[Hz]
        end


        %%%%% request input of frequency and range
    elseif (exist('freq')~=1 || exist('range')~=1) && ~exist('descFileName')

        %1.) set FileInfos
        nsFile.FileInfo.Date='00.00.00 00:00';
        nsFile.FileInfo.FileComment='';
        nsFile.FileInfo.HardwareComment='';

        prompt = {'Enter sampling frequency: [Hz]','Enter range: (0-3)'};
        dlg_title = 'Input for loading meabench data';
        num_lines = 1;
        def = {'25000','2'};
        answer = inputdlg(prompt,dlg_title,num_lines,def);

        freq = str2num(answer{1});
        % get the range
        RangeID= str2num(answer{2});
        RangePos=(find([0 1 2 3]==RangeID));
        rangeElec= [ 3410,1205,683,341 ]; %  Gain: '0.333496 uV/digistep [+- 683 uV range]'
        range=rangeElec(RangePos)/2048;      % divide by Digital_zero: '2048'

        % check the parameters
        if         freq<=0;
            error( 'ERROR - frequency has to be positiv ');
        elseif RangeID>3 || RangeID<0 ||length(RangeID)~=1
            error( 'ERROR - invalid value for range (0-3)');
        end

        %2.) push Trigger and Data Infos into nsFile
        for kk=1:64
            if kk>64 % Trigger Channels
                nsFile.Event.Info(kk-60).EntityID=kk;
                nsFile.Event.Info(kk-60).ItemCount=[];
                nsFile.Event.Info(kk-60).EntityLabel=['MEABench Data, Trigger of CH: ', num2str(hw2cr(kk-1))];
            else % Data Channels
                nsFile.Segment.Info(kk).DataentityIDs=kk;
            end
            %3.) set EntityInfos.Info (general EntityInfo see below)
            nsFile.EntityInfo(kk).Info.RangeInfo='uV/digistep';
            nsFile.EntityInfo(kk).Info.Range=range; % (resolution of the data channels)
            nsFile.EntityInfo(kk).Info.SampleRate=freq; %[Hz]
        end

        % give some Report
        disp(['sampling frequency was set to: ', num2str(freq), ' Hz']);
        disp(['range was set to: ', num2str(range)]);
    end

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%% open and read the meabench file

    % the only way to loade meabench segment data is to previously get the
    % spike times and store them sorted by channel in the variable
    % nsFile.Segment.TimeStamp and nsFile.Neural.Data without any
    % external loading command

    fid = fopen(fileName,'rb');
    if (fid<0)
        error('Cannot open the specified file');
    end

    reach=1500000;   %load reach no. of spikes

    fseek(fid,0,1);  %go to the end of file
    len = ftell(fid);   %get the length of the file (in bytes)
    fseek(fid,0,-1);   %go to the beginning again
    no_spikes=len/264 ;  %since every spike is stored as a 164byte vector
    if (no_spikes-reach)>0
        disp(['WARNING - last ', num2str(no_spikes-reach),...
            'spikes could not be loaded (max # 1.5*10^6)']);
    end
    spikes_read=0;
    read_cycle=0;
    while spikes_read < no_spikes

        [raw count] = fread(fid,[7 reach],'7*int16',250);

        spikes_read=spikes_read + count/7;
        read_cycle = read_cycle+1;
        filepos=ftell(fid);
        fseek(fid,filepos,-1);
    end

    fclose(fid);
    ti0 = raw(1,:); idx = find(ti0<0); ti0(idx) = ti0(idx)+65536;
    ti1 = raw(2,:); idx = find(ti1<0); ti1(idx) = ti1(idx)+65536;
    ti2 = raw(3,:); idx = find(ti2<0); ti2(idx) = ti2(idx)+65536;
    ti3 = raw(4,:); idx = find(ti3<0); ti3(idx) = ti3(idx)+65536;
    y.time = (ti0 + 65536*(ti1 + 65536*(ti2 + 65536*ti3)));
    y.channel = raw(5,:);


    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%% push into nsFile Structure

    %%%1.) set EntityInfos - segment, neural and event
    for kk=1:124
        nsFile.EntityInfo(kk).EntityID=kk;
        if kk>60 && kk<65 %Trigger Channel
             nsFile.EntityInfo(kk).ItemCount=length(find(y.channel==(kk-1)));
             nsFile.EntityInfo(kk).EntityLabel=['trigger Meabench EL ' num2str(hw2cr(kk-1))];
            nsFile.EntityInfo(kk).EntityType=1;
        elseif kk<=60  % the segment data (and neural data)
             nsFile.EntityInfo(kk).ItemCount=length(find(y.channel==(kk-1)));
             nsFile.EntityInfo(kk).EntityLabel=['cutouts Meabench EL ' num2str(hw2cr(kk-1))];
            nsFile.EntityInfo(kk).EntityType=3;
            % storing the spike times
            SpikePos{kk}=find(y.channel==(kk-1));
            nsFile.Segment.TimeStamp{kk}=y.time(SpikePos{kk})*(nsFile.EntityInfo(kk).Info.SampleRate);
            %converte only timestamps into sec
        else % neural entitys
             nsFile.EntityInfo(kk).ItemCount=length(find(y.channel==(kk-65)));
             nsFile.EntityInfo(kk).EntityLabel=['spike times Meabench EL ' num2str(hw2cr(kk-65))];
             nsFile.EntityInfo(kk).EntityType=4;
             NeuralDataOrigin{kk-64}='MEABench Spike Data (.*spike)';
        end
    end
  
    %%%2.) store_ns_new...data
    newdata.Neural.Data=nsFile.Segment.TimeStamp; % store spike times also as neural data
    newdata.Neural.EntityID=[65:124];
    % store_ns_newneuraldata implemented
    store_ns_newneuraldata('newdata',newdata,'DataOrigin',NeuralDataOrigin);


    clear newdata;


    %%%3.) include some general FileInfos independent of the descFile
    nsFile.FileInfo.FileType=' MEABench Spike Data';
    nsFile.FileInfo.EntityCount= 64;
    nsFile.FileInfo.TimeStampResolution=1/(nsFile.EntityInfo(1).Info.SampleRate);
    nsFile.FileInfo.TimeSpan=(y.time(end))/(nsFile.EntityInfo(1).Info.SampleRate);
    nsFile.FileInfo.AppName=' FIND 1.0 - MeaBench Import';

catch
    rethrow(lasterror);
end