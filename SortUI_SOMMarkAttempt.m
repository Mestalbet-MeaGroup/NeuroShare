function varargout = SortUI_SOMMark(varargin)
%insert into THIS file all hand-written functions.
% Last Modified by GUIDE v2.5 12-Apr-2008 13:40:26

% Jan 14, 2003 - nadav - updated version

%Oct 05 , 2006 - nadav.
%do not spike-sort when there are classes but an empty .txt file.
%at the end, fix sort_channel so there are NaN in cases of neurons that do not spike.

if nargin == 0  % LAUNCH GUI
    fig = openfig(mfilename,'reuse');

    % Use system color scheme for figure:
    set(fig,'Color',get(0,'defaultUicontrolBackgroundColor'));

    % Generate a structure of handles to pass to callbacks, and store it.
    handles = guihandles(fig);
    guidata(fig, handles);
    DataStr.num_folder=0;
    DataStr.classes=[];
    %    DataStr.num_files=0;
    set(handles.SortUI_SOM9,'userData',DataStr);
    if nargout > 0
        varargout{1} = fig;
    end
elseif ischar(varargin{1}) % INVOKE NAMED SUBFUNCTION OR CALLBACK
    try
        if (nargout)
            [varargout{1:nargout}] = feval(varargin{:}); % FEVAL switchyard
        else
            feval(varargin{:}); % FEVAL switchyard
        end
    catch
        disp(lasterr);
    end
end

%read channels
function varargout = channels_number_Callback(h, eventdata, handles, varargin)
DataStr=get(handles.SortUI_SOM9,'userData');
set(handles.SortUI_SOM9,'userData',DataStr);

%read folders
function varargout = folder_names_Callback(h, eventdata, handles, varargin)
DataStr=get(handles.SortUI_SOM9,'userData');
DataStr.folder=(get(handles.folder_names,'string'));
set(handles.List_folders,'visible','on');
set(handles.SortUI_SOM9,'userData',DataStr);
List_folders_Callback(h, eventdata, handles, varargin);

function varargout = List_folders_Callback(h, eventdata, handles, varargin)
DataStr=get(handles.SortUI_SOM9,'userData');
DataStr.num_folder=DataStr.num_folder+1;
DataStr.folders{DataStr.num_folder}=DataStr.folder;
set(handles.List_folders,'string',DataStr.folders)
set(handles.SortUI_SOM9,'userData',DataStr);

function varargout = sort_file_Callback(h, eventdata, handles, varargin)

% --------------------------------------------------------------------

function varargout = load_channels_Callback(h, eventdata, handles, varargin)
DataStr=get(handles.SortUI_SOM9,'userData');
[fname,pname] = uigetfile('*.txt','Select the channels file');
load([pname,fname]);
DataStr.channels=channels;
set(handles.channels_number,'string',num2str(channels'));
set(handles.SortUI_SOM9,'userData',DataStr);

function varargout = load_folders_Callback(h, eventdata, handles, varargin)
DataStr=get(handles.SortUI_SOM9,'userData');
[fname,pname] = uigetfile('*.map','Select the file you want to sort');
DataStr.folders{DataStr.num_folder+1}=[pname,fname];
DataStr.num_folder=length(DataStr.folders);
set(handles.List_folders,'visible','on');
set(handles.List_folders,'string',DataStr.folders)
set(handles.SortUI_SOM9,'userData',DataStr);

function varargout = som_sort_Callback(h, eventdata, handles, varargin)
sort=1;
set(handles.som_sort,'value',1);
if strcmp(get(handles.som_channel,'visible'),'on'),
    if strcmp(questdlg(['Do you want to SOM data again ??????']),'Yes')==0,
        sort=0;
    end
end
if sort==1,
    fprintf('SOM processing, please wait....\n');
    DataStr=get(handles.SortUI_SOM9,'userData');
    DataStr.Coefs={};
    DataStr.Data={};
    DataStr.Raw={};
    DataStr.channels=str2num(get(handles.channels_number,'string'));
    Ch=DataStr.channels;
    DataStr.classes=zeros(1,length(Ch))-1;
    [pathstr,name,ext,versn] = fileparts(DataStr.folders{1});
    St2=[pathstr '\'];
    fprintf('testing length of data files...\n');
    DataLength=2000;
    %        DataLength=str2num(get(handles.FrameCount,'string'));

    handles.IgnoredChannelsList=zeros(1,length(Ch));    % a list of channels to be ignored. if marked 1, channels is ignored.

    h=waitbar(0,'Preparing SOM data...');
    for j=1:length(Ch)
        St3=num2str(Ch(j));
         if(Ch(j)<10)
            St3=['00' St3];
        elseif(Ch(j)<100)
            St3=['0' St3];
        end
%         if(Ch(j)<10)
%             St3=['0' St3];
%         end
        DataStr.EstimatedLength(j)=2*floor(EstimateDataLength([St2 St3],DataLength)/2); %make sure the result is a paired number
        if DataStr.EstimatedLength(j)<DataLength,
            fprintf(['******    Channel ' St3 ': reading ' num2str(DataStr.EstimatedLength(j)) ' frames.\n']);
        else
            fprintf(['Channel ' St3 ': reading 2000 frames.\n']);
            DataStr.EstimatedLength(j)=DataLength;
        end
    end
    for j=1:length(Ch)
        waitbar(j/length(Ch),h);
        St3=num2str(Ch(j));
        if(Ch(j)<10)
            St3=['00' St3];
        elseif(Ch(j)<100)
            St3=['0' St3];
        end
        %PrepDataNEW is at end of THIS file.
        [DataStr.Coefs{j},DataStr.Data{j},DataStr.Raw{j}]=PrepDataNEW([St2 St3],DataStr.EstimatedLength(j));
        %        DataEstimatedLength(j)=size(DataStr.Data(j),1);
        %                [DataStr.Coefs{j},DataStr.Data{j},DataStr.Raw{j}]=PrepDataNEW([St2 St3],DataLength,num2str(get(handles.GroupNumber,'string')));
    end
    close(h);
    set(handles.som_channel,'visible','on');
    set(handles.text3,'visible','on');
    set(handles.test_group_som,'visible','on');
    set(handles.text8,'visible','on');
    set(handles.N_groups_som,'visible','on');
    set(handles.text9,'visible','on');
    set(handles.clear_fig,'visible','on');
    set(handles.NextChannel,'visible','on');
    set(handles.FeedGroups,'visible','on');
    set(handles.Run,'visible','on');
    set(handles.GroupNumber,'visible','on');
    set(handles.Groups,'visible','on');
    set(handles.text18,'visible','on');
    %    set(handles.IgnoreChannel,'visible','on');
    beep;
end
DataStr.CurrentChannel=0;
set(handles.SortUI_SOM9,'userData',DataStr);
fprintf('done!!!\r\n');

function EstimatedLength=EstimateDataLength(fname,N);
%test channel if has minimum length of required for SOM.
dext='.txt';
fext='.dat';
fid=fopen([fname,fext],'r');
Coefs=fread(fid,N*13,'float');
fclose(fid);
Coefs=reshape(Coefs,13,length(Coefs)/13);
EstimatedLength=size(Coefs,2);
%read channel number and show clusters:
function varargout = som_channel_Callback(h, eventdata, handles, varargin)
% ClearFigures(handles);
DataStr=get(handles.SortUI_SOM9,'userData');
ch=str2num(get(handles.som_channel,'string'));
DataStr.CurrentChannel=ch;
ind=find(DataStr.channels==ch);
if ~isempty(ind),
    
    %     if DataStr.classes(ind)==-1,
    %         set(handles.IgnoreChannel,'Value',1)
    %     else
    %         set(handles.IgnoreChannel,'Value',0)
    %     end
    
else
    beep;
    fprintf('Channel does not exist!\n');
end

% %som_spikeNEW is located at end of THIS file.
% [DataStr.sMap{ind}, DataStr.clusters{ind}, DataStr.SG{ind}, DataStr.best_k{ind},DataStr.all_groups{ind},DataStr.all_group_showings{ind},DataStr.FiguresCount]=som_spikeNEW(DataStr.Raw{ind},DataStr.Data{ind},DataStr.Coefs{ind},handles)
% %DataStr.Current_k_count=DataStr.best_k{ind};
set(handles.SortUI_SOM9,'userData',DataStr);
% move to next channel:
function NextChannel_Callback(hObject, eventdata, handles)
ClearFigures(handles);
DataStr=get(handles.SortUI_SOM9,'userData');
ch=str2num(get(handles.som_channel,'string'));
ind=find(DataStr.channels==ch);
% if DataStr.classes(ind)==-1,
%     set(handles.IgnoreChannel,'Value',1);
% else
%     set(handles.IgnoreChannel,'Value',0);
% end
if ind==length(DataStr.channels),
    beep;
else
    ind=ind+1;
    set(handles.som_channel,'string',num2str(DataStr.channels(ind)));
    set(handles.text18,'string',['Frames: ' num2str(DataStr.EstimatedLength(ind))] );
    ch=str2num(get(handles.som_channel,'string'));
    %som_spikeNEW is located at end of THIS file.
    if DataStr.EstimatedLength(ind)>10,
        [DataStr.sMap{ind}, DataStr.clusters{ind}, DataStr.SG{ind}, DataStr.best_k{ind},DataStr.all_groups{ind},DataStr.all_group_showings{ind},DataStr.FiguresCount]=som_spikeNEW(DataStr.Raw{ind},DataStr.Data{ind},DataStr.Coefs{ind},handles);
        %    DataStr.Current_k_count=DataStr.best_k{ind};
    else
        fprintf(['Not enough data for channel ' num2str(ch) ' !\n']);
        beep;
        set(handles.N_groups_som,'string','0');
    end
    set(handles.SortUI_SOM9,'userData',DataStr);
end
% run same channel run:
function Run_Callback(hObject, eventdata, handles)
ClearFigures(handles);
DataStr=get(handles.SortUI_SOM9,'userData');
ch=str2num(get(handles.som_channel,'string'));
ind=find(DataStr.channels==ch);
set(handles.som_channel,'string',num2str(DataStr.channels(ind)));
set(handles.text18,'string',['Frames: ' num2str(DataStr.EstimatedLength(ind))] );
%som_spikeNEW is located at end of THIS file.
if DataStr.EstimatedLength(ind)>10,
    [DataStr.sMap{ind}, DataStr.clusters{ind}, DataStr.SG{ind}, DataStr.best_k{ind},DataStr.all_groups{ind},DataStr.all_group_showings{ind},DataStr.FiguresCount]=som_spikeNEW(DataStr.Raw{ind},DataStr.Data{ind},DataStr.Coefs{ind},handles);
else
    fprintf(['Not enough data for channel ' num2str(ch) ' !\n']);
    beep;
    set(handles.N_groups_som,'string','0');
end
set(handles.SortUI_SOM9,'userData',DataStr);

function varargout = N_groups_som_Callback(h, eventdata, handles, varargin)

function FeedGroups_Callback(hObject, eventdata, handles)

% if get(handles.IgnoreChannel,'Value')==1,
%     beep;
%     fprintf('Channel is ignored!');
% else,
DataStr=get(handles.SortUI_SOM9,'userData');
ch=str2num(get(handles.som_channel,'string'));
ng=str2num(get(handles.N_groups_som,'string'));
if ~strcmp(get(handles.N_groups_som,'string'),'0'),
    fprintf(['Selected classes for channel ' num2str(ch) ' -----> ' num2str(ng) '\n']);
    ChNam=find(DataStr.channels==ch);
    all_groups=DataStr.all_groups{ChNam}; %
    all_groups=all_groups(ng,:);      %
    DataStr.all_groups{ChNam}=all_groups; %
    all_group_showings=DataStr.all_group_showings{ChNam};
    all_group_showings=all_group_showings(ng);
    DataStr.all_group_showings{ChNam}=all_group_showings;
    gr=DataStr.best_k{ChNam};
    order=[1:gr];
    order(ng)=[];
    order=[ng order];
    G=indexconvertNEW(DataStr.SG{ChNam},(order));
   
    %%%%%%%%%%%%%%%%%%%% Nadav & Eyal 23/7/04 %%%%%%%%%%%%%%%%%
    % It so happens, that using the SOM as a classifier, the grouping of the
    % data was NOT according to the new order, but according to the original
    % order as in clusters(best_k)!
    % Hence, we alter the order in clusters(best_k) to suit the new ordering.
    %
    DataStr.clusters{ChNam}{gr}=indexconvertNEW(DataStr.clusters{ChNam}{gr},order)';
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    Classes=length(ng);

    if ch<10
        ch=['00' num2str(ch)];
    elseif ch<100
        ch=['0' num2str(ch)];
    else
        ch=num2str(ch);
    end
    eval(['T' ch '=DataStr.Coefs{ChNam};']);
    eval(['TG' ch '=G;']);
    eval(['D' ch '=DataStr.Data{ChNam};']);
    eval(['R' ch '=DataStr.Raw{ChNam};']);
    eval(['sMap' ch '=DataStr.sMap{ChNam};']);
    eval(['clusters' ch '=DataStr.clusters{ChNam};']);
    eval(['best_k' ch '=DataStr.best_k{ChNam};']);
    eval(['Classes' ch '=Classes;']);
    eval(['save Channel' ch '.mat' ' T' ch  ' TG' ch ' D' ch  ' R' ch ' sMap' ch ' clusters' ch ' Classes' ch ' best_k' ch ' all_groups all_group_showings']);
    DataStr.classes(ChNam)=length(ng);
else
    fprintf(['Selected classes for channel ' num2str(ch) ' : Ignored !\n']);
    ChNam=find(DataStr.channels==ch);
    Classes=0;
    if ch<10
        ch=['00' num2str(ch)];
    elseif ch<100
        ch=['0' num2str(ch)];
    else
        ch=num2str(ch);
    end
    eval(['Classes' ch '=Classes;']);
    eval(['save Channel' ch '.mat' ' Classes' ch ]);
    DataStr.classes(ChNam)=0;
end
set(handles.SortUI_SOM9,'userData',DataStr);

function varargout = test_group_som_Callback(h, eventdata, handles, varargin)
DataStr=get(handles.SortUI_SOM9,'userData');
ch=str2num(get(handles.som_channel,'string'));
ChNam=find(DataStr.channels==ch);
gr=DataStr.best_k{ChNam};
gr2=str2num(get(handles.test_group_som,'string'));
Ver={};
Ver{1}=DataStr.Raw{ChNam};
Ver{2}=DataStr.Data{ChNam};
Ver{3}=DataStr.Coefs{ChNam};
Ver{4}=DataStr.SG{ChNam};
Ver{5}=find(DataStr.SG{ChNam}==gr2);
Ver{6}=gr+3;
figure;
SequalSpikesUI('InitializeControl',Ver);

function varargout = clear_fig_Callback(h, eventdata, handles, varargin)
ClearFigures(handles);

function ClearFigures(handles);
DataStr=get(handles.SortUI_SOM9,'userData');
%ch=str2num(get(handles.som_channel,'string'));
ch=DataStr.CurrentChannel;
if ch~=0,
    ChNam=find(DataStr.channels==ch);
    if sum(strcmp(fieldnames(DataStr),'best_k'))==1,    %check if a field named 'best_k' exists.
        for i=1:DataStr.FiguresCount;
            close(figure(i))
        end
    end
end

function varargout = sort_channels_Callback(h, eventdata, handles, varargin)
DataStr=get(handles.SortUI_SOM9,'userData');
%ClearFigures(handles);
%check what Classes exist:
fprintf('Loading classes....\n');
DataStr.folders=pwd;
DataStr.classes=[];
channels=DataStr.channels;
DataStr.channels=[];
TxtFiles=[];
files=dir;
for i=1:length(channels)
    if channels(i)<10,
        ch=['00' num2str(channels(i))];
    elseif channels(i)<100,
        ch=['0' num2str(channels(i))];
    else
        ch=num2str(channels(i));
    end
    %list Channels files:
    filename=['Channel' ch '.mat'];
    if ~isempty(dir(filename)),
        eval(['load ' filename]);
        eval(['Classes=Classes' ch ';']);
        DataStr.channels=[DataStr.channels,channels(i)];
        DataStr.classes=[DataStr.classes,Classes];
    end
    %list .txt files:
    filename=[ch '.txt'];
    if ~isempty(dir(filename)),
        TxtFiles=[TxtFiles, channels(i)];
    end
end

%compare channels list and txt list:
emptyC=0;
emptyTXT=0;
fprintf('txt files without classes: ');
for i=1:length(TxtFiles),
    if isempty(find(DataStr.channels==TxtFiles(i))),
        fprintf([num2str(TxtFiles(i)), ' ']);
        emptyTXT=1;
    end
end
if emptyTXT==0,
    fprintf(' none.\n');
end
fprintf('\nchannel files without txt files: ');
ChannelsTmp=DataStr.channels;
for i=1:length(ChannelsTmp),
    if isempty(find(TxtFiles==ChannelsTmp(i))),
        fprintf([num2str(ChannelsTmp(i)), ' ']);
        %remove channels that have no txt file:
        DataStr.classes(find(ChannelsTmp==i))=[];
        DataStr.channels(find(ChannelsTmp==i))=[];
        emptyC=1;
    end
end
clear ChannelsTmp;
if emptyC==0,
    fprintf(' none.\n');
end

RunAllFiles='Yes';
fprintf('\n');
if (emptyTXT==1 | emptyC==1),
    beep;
    button = questdlg('No match between txt files and channels! Do you want to continue?','Continue Operation','Yes','No','No');
    if strcmp(button,'No')
        RunAllFiles='No';
    end
end
if strcmp(RunAllFiles,'Yes'),
    path=cd;
    channels_file=[path 'channels.txt'];
    fid=fopen(channels_file,'wb');
    for j=1:length(DataStr.channels)
        if DataStr.channels(j)<10,
            ChannelStr=['00',num2str(DataStr.channels(j))];
        elseif DataStr.channels(j)<100,
            ChannelStr=['0',num2str(DataStr.channels(j))];
        else
            ChannelStr=num2str(DataStr.channels(j));
        end
        fprintf(fid,'%s',[ChannelStr]);
        fprintf(fid,'%s\n','');
    end
    fclose(fid);
    %write folders file:
    folders_file=[path '\folders.txt'];
    fid=fopen(folders_file,'wb');
    fprintf(fid,'%s',[cd,'\']);
    fprintf(fid,'%s\n','');
    fclose(fid);
    set(handles.SortUI_SOM9,'userData',DataStr);
    fprintf('done!!!\r\n');

    if isempty(find(DataStr.classes==-1))
        SerialSpikeIndexNEW
        SerialSpikeIndex2NEW
    else
        error(['Missing sorting for channel: ' num2str((DataStr.channels(find(DataStr.classes==-1))))]);
    end
    fprintf('Done sorting channels!!!\r\n');
    beep;
end

function [Coefs,Data,Raw,Group]=PrepDataNEW(fname,N,G);

% [Coefs,Data,Raw]=PrepData(fname,N);
% [Coefs,Data,Raw,Group]=PrepData(fname,N,G);
% function PrepData is used to initiate the classfication procedure:
% fname is the file name (full path)
% N is the number of spikes to pre-classify
% G (if specified) is the number of groups for k-means classification
%
% Coefs holds the features (size [14,N] ).
% Data holds the windows (size [N,128] ).
% Raw holds the rawdata (size [240,n]).
% Group holds the k-means result only if G is specified

Coefs=[];
Data=[];
Raw=[];
Group=[];
if N>0,
    dext='.txt';
    fext='.dat';
    fid=fopen([fname,fext],'r');
    Coefs=fread(fid,N*13,'float');
    fclose(fid);
    Coefs=reshape(Coefs,13,length(Coefs)/13);
    di=max(Coefs(11,:));
    if size(Coefs,2)<N,
        beep;
        error('Not enough events in data file!');
    end
    N=size(Coefs,2);
    fid=fopen([fname,dext],'r');
    D=fscanf(fid,'%d',240*di); 
    fclose(fid);
    Raw=reshape(D,240,di)';
%     FrameCount=floor(length(D)/240);
%     if FrameCount~=size(Coefs,2),
%         fprintf([fname,' :   There is a different Coefs size than frame count !!!!\n']);
%     end
%         Raw=reshape(D(1:FrameCount*240),240,FrameCount)';
%         Coefs=Coefs(:,1:FrameCount);
% 
%     %ignore frames that have a voltage amplitude too high:
%     TooHighVoltage=[];
%     for i=1:di,
%         if ~isempty(find(Raw(i,4:240)>10000)),
%             TooHighVoltage=[TooHighVoltage,i];
%         end
%     end
%     Raw(TooHighVoltage,:)=[];
%     di=size(Raw,1);
%     N=di;

    CENTER=66;
    %    for i=1:FrameCount,
    for i=1:N,
        rdata=Raw(Coefs(11,i),4:end);
        offset=Coefs(end-1,i);
        pack=Coefs(end,i);
        rd=[zeros(1,11),rdata(1:end),zeros(1,11)];
        rrdata=rd(offset+(0:255));
        I=((pack+5)*4-1)-CENTER+(1:128);
        a1=max(find(I<1)); if isempty(a1), a1=0; end;
        a2=min(find(I>256)); if isempty(a2), a2=129; end;
        data=[zeros(1,a1),rrdata(I(a1+1:a2-1)),zeros(1,129-a2)];	%data=rrdata(I);
        Data(i,1:128)=data*1e-7;
    end;
    if nargin==3
        Group=ClassifyData(Coefs,Data,G);
    end;
end

function [sMap,clusters,Xs,best_k,all_groups,all_group_showings,FiguresCount]=som_spikeNEW(Raw,Data,Test,handles)
Train=Test(1:9,1:floor(size(Test,2)./2))';
X=Test(1:9,length(Test)./2+1:end)';
sTrain = som_data_struct(Train,'name','5 spikes 3 noise',...
    'comp_names',{'c1','c2','c3','c4','c5','c6','c7','c8','c9'});
sTrain = som_label(sTrain,'add',[1:length(Test)./2],num2str( ((1:length(Test)./2))',8 ));
sMap=som_make(sTrain);
%sMap=som_make(sTrain,'msize',[5,5]);
sMap = som_autolabel(sMap,sTrain,'add');
[centers, clusters, err, ind] = kmeans_clusters(sMap);
[dummy,best_k]=min(ind(4:min(length(ind),10))); best_k=best_k+3; % to avoid the first 2 posibilities
if str2num(get(handles.GroupNumber,'string'))~=0,
    best_k=str2num(get(handles.GroupNumber,'string'));
end
k=best_k;	%%% k-means
train_order=[]; train_class=[]; som_class=[];
for j=1:k,
    for i=1:size(sMap.labels,2),
        temp=str2num([sMap.labels{find(clusters{k}==j),i}]);
        train_order=[train_order,floor(temp)];
        train_class=[train_class,10*(temp-floor(temp))];
        som_class=[som_class,j*ones(size(temp))];
    end
end
Xs=clusters{best_k}(som_bmus(sMap,Test(1:9,:)'));
for j=1:best_k
    figure('name',['Fig. ',num2str(j)]);
    all_groups(j,:)=mean(Data(find(Xs==j),:));
    plot(all_groups(j,:));
    all_group_showings(j)=size(Data(find(Xs==j),:),1);
    title(['#' num2str(j) '    ' num2str(all_group_showings(j))]);
end
DataStr.Current_k_count=best_k;
%    figure(best_k+1);
%plot of relations between groups:
%    som_show(sMap,'color',{clusters{best_k},sprintf('%d clusters',best_k)});
[PC,SCORE,latent,tsquare] = princomp(Test(1:9,:)');
PlotDensity_New(SCORE(:,1),SCORE(:,2));
figure;plot(SCORE(:,1),SCORE(:,2),'.');
figure;
cm=colormap;
for (j=1:best_k)
    plot(SCORE(find(Xs==j),1),SCORE(find(Xs==j),2),'.','color',cm(round(64*j/best_k),:));
    hold on;
    xpl=linspace(mean(SCORE(find(Xs==j),1))-std(SCORE(find(Xs==j),1)),mean(SCORE(find(Xs==j),1))+std(SCORE(find(Xs==j),1)),128);
    plot(xpl,mean(SCORE(find(Xs==j),2))+mean(Data(find(Xs==j),:)));
    text(mean(SCORE(find(Xs==j),1)),mean(SCORE(find(Xs==j),2)),num2str(j),'fontsize',14,'FontWeight','bold');
end
axis([min(SCORE(:,1)),max(SCORE(:,1)),min(SCORE(:,2)),max(SCORE(:,2))]);
FiguresCount=best_k+2;

function G=indexconvertNEW(oldG,order)
% 	G=indexconvert(oldG,order);
%
% This function is used while creating a training set for a channel (with different spike types and noise).
% After performing kmeans of order G on the Coefs matrix, there are G unique classes.
% In order to simpilfy the rest of the analysis, the class numbers should be sorted as follows:
%		first the spikes (at whatever order, e.g. strongest to weakest), then mixed classes,
%		and finally noise classes.
%
% oldG is the result of the kmeans, order is the requiered order of classes (sorting unique(oldG) as needed).
% G is the new classification vector using the new sorted class order.
G=[];
for i=1:length(order)
    I=find(oldG==order(i));
    G(I)=i;
end;

function SerialSpikeIndexNEW;
% This function serially extracts only the spike classes.
% Note that SerialClassify creates a XXXc.dat file for each channel with G classes,
%	CheckData and SequalSpikes helps observing which of the classes has spikes.
% This function considers only specified classes, and re-classifies with a new G.
%cd c:\project;
fprintf('Extract classes...\n');
N=2000;
path=cd;
channels_file=[path 'channels.txt'];
folders_file=[path 'folders.txt'];
channel_fid=fopen(channels_file,'r');
if channel_fid ~=-1
    channel=fgetl(channel_fid);
%     if channel<10,
%         ch=['00' num2str(channel)];
%     elseif channel<100,
%         ch=['0' num2str(channel)];
%     else
%         ch=num2str(channel);
%     end
    while ~isempty(channel) & channel ~=-1

        eval (['load channel',channel,';']);
        %eval (['load5 channel',num2str(channel),';']);

        eval(['classes=Classes',channel,';']);

        if classes~=0,
            eval(['NT=T',channel,'(1:9,:);']);
            eval(['NTG=TG',channel,';']);
            eval(['sMap=sMap',channel,';']);
            eval(['best_k=best_k',channel,';']);
            eval(['clusters=clusters',channel,';']);

            folder_fid=fopen(folders_file,'r');
            if folder_fid~=-1
                folder=fgetl(folder_fid);
                while ~isempty(folder) & folder~=-1
                    PrintFolder=folder;
                    PrintFolder(find(folder=='\'))='/';
                    fprintf([PrintFolder,channel,'\n']),
                    [NT,NTG]=TestFile_somNEW([folder,channel],N,NT,NTG,sMap,clusters,best_k);
                    folder=fgetl(folder_fid);
                end;
                fclose(folder_fid);
            else
                fprintf(['channel ' channel ' : ignored !\n']);
            end;
        end
        channel=fgetl(channel_fid);
    end;
    fclose(channel_fid);
end;

function [NT,NTG]=TestFile_somNEW(fname,N,T,TG,sMap,clusters,best_k,Ithresh);
% [NTraining,NTrainingG]=TestFile(fname,N,Training,TrainingG,Ithresh);
% This function test a file acording to a training set in blocks of N spikes.
%
% fname is the file we're working on
% N is the size of an individual block of spikes
% Training is a training set of coefficients
% TrainingG is the grouping of the training sequence
% Ithresh - if the noise group is put last and Ithresh is G-1 (where G is the number
%		of clusters including the noise group), then the result file will not include
%		the noise group.
% NTraining and NTrainingG contain the new training set.
%		This set is the first N spikes of the file, classified acording to the training
%		set Training and TrainingG.  The rest of the file is classified acording to
%		NTraining and NTrainingG.
fext='.dat';
cext='c.dat';
if nargin==7
    Ithresh=max(unique(TG));
end;
fid=fopen([fname,fext],'r');
if fid~=-1
    Coefs=fread(fid,N*13,'float');
    Coefs=reshape(Coefs,13,length(Coefs)/13);
    if ~isempty(Coefs)
        %Group=kmeanstest(Coefs(1:9,:),T,TG);
        Group=(clusters{best_k}(som_bmus(sMap,Coefs(1:9,:)')))';
        if size(Coefs,2)>N/2 & hist(Group,max(TG))>20
            NT=Coefs(1:9,:);
            NTG=Group;
        else
            N=size(Coefs,2);
            NT=T;
            NTG=TG;
        end;
        I=find(Group<=Ithresh);
        X=[1:length(Group);Coefs(12:13,:);Group];
        if ~isempty(I)
            wfid=fopen([fname,cext],'w');
            fwrite(wfid,X(:,I),'float');
            fclose(wfid);
        end;
        step=1;
        F=fread(fid,N*13,'float');
        while length(F)==N*13
            F=reshape(F,13,N);
            %G=kmeanstest(F(1:9,:),NT,NTG);
            G=(clusters{best_k}(som_bmus(sMap,F(1:9,:)')))';
            I=find(G<=Ithresh);
            X=[step*N+(1:N);F(12:13,:);G];
            if ~isempty(I)
                wfid=fopen([fname,cext],'a');
                fwrite(wfid,X(:,I),'float');
                fclose(wfid);
            end;
            step=step+1;
            F=fread(fid,N*13,'float');
        end;
        L=floor(length(F)/13);
        if L*13~=length(F),
            fprintf('RECORDING ERROR: size of data file is improper to usual recordings!\nMight be a missed bit!');
        end
        if L>0
            F2=reshape(F(1:L*13),13,L);
            G=(clusters{best_k}(som_bmus(sMap,F2(1:9,:)')))';
            I=find(G<=Ithresh);
            X=[step*N+(1:L);F2(12:13,:);G];
            if ~isempty(I)
                wfid=fopen([fname,cext],'a');
                fwrite(wfid,X(:,I),'float');
                fclose(wfid);
            end;
        end;
        fclose(fid);
    else
        NT=T;
        NTG=TG;
    end;
else
    NT=T;
    NTG=TG;
end;

function SerialSpikeIndex2NEW;
% SerialSpikeIndex2;
%
% This function creates the sort_channel matrix.
% The function runs for each channel on all specified folders. For each of the spikes
%		in the channel (the number of spike classes is specified for each channel), it
%		extracts the exact time of event (using the XXXi.dat file and the offset and packet
%		indices from the XXX.dat file).
%
% The output is a long vector t that holds time samples sequentially for each of the individual spikes
% The out put is a matrix named indexchannel (that holds for each spike in each channel
%		the first and last indices of events)
%serially extracts only the spike classes.
% Note that SerialClassify creates a XXXc.dat file for each channel with G classes,
%	CheckData and SequalSpikes helps observing which of the classes has spikes.
% This function considers only specified classes, and re-classifies with a new G.
fprintf('Make sort_channel...\n');
wdir=cd;
channels_file=[wdir,'channels.txt'];
classes_file=[wdir,'classes.txt'];
folders_file=[wdir,'folders.txt'];
N=2000;
indexchannel=[];
t=[];
first=1;
last=0;
channel_fid=fopen(channels_file,'r');
%classes_fid=fopen(classes_file,'r');
%if channel_fid ~=-1 & classes_fid~=-1
if channel_fid ~=-1
    channel=fgetl(channel_fid);
%     if channel<10,
%         ch=['00' num2str(channel)];
%     elseif channel<100,
%         ch=['0' num2str(channel)];
%     else
%         ch=num2str(channel);
%     end
    %    while (~isempty(channel) & channel ~=-1) & (~isempty(classes) & classes ~=-1)
    while (~isempty(channel) & channel ~=-1),
        FileInfo=dir([channel,'.txt']);
        if FileInfo.bytes>0,
            %        eval (['load5 channel',num2str(channel),';']);
            eval (['load channel',channel,';']);
            eval(['classes=Classes',channel,';']);
            %   classes=fgetl(classes_fid);
            if classes(1)~=0,
                t1=[];	t2=[];	t3=[];	t4=[];	t5=[];	t6=[];	t7=[];	t8=[];	t9=[];	t10=[];
                tindexchannel=[];
                %            classes=str2num(classes);
                folder_fid=fopen(folders_file,'r');
                if folder_fid~=-1
                    folder=fgetl(folder_fid);
                    while ~isempty(folder) & folder~=-1
                        PrintFolder=folder;
                        PrintFolder(find(folder=='\'))='/';
                        fprintf([PrintFolder,channel,'\n']),
                        [tt1,tt2,tt3,tt4,tt5,tt6,tt7,tt8,tt9,tt10]=TestFile2NEW([folder,channel],classes);
                        for i=1:classes
                            eval(['t',num2str(i),'=[t',num2str(i),',tt',num2str(i),'];']);
                        end;
                        folder=fgetl(folder_fid);
                    end;
                    fclose(folder_fid);
                end;
                tt=[t1,t2,t3,t4,t5,t6,t7,t8,t9,t10];
                if ~isempty(tt)
                    for i=1:classes
                        eval(['last=last+length(t',num2str(i),');']);
                        tindexchannel(1,i)=channel;
                        tindexchannel(2,i)=i;
                        tindexchannel(3,i)=first;
                        tindexchannel(4,i)=last;
                        first=last+1;
                    end;
                end;
                indexchannel=[indexchannel,tindexchannel];
                t=[t,tt];
            else
                fprintf(['Channel ' channel ' : ignored because of no classes! \n']);
            end;
        else
            fprintf(['Channel ' channel ' : ignored because of no .txt data! \n']);
        end
        channel=fgetl(channel_fid);
        %        classes=fgetl(classes_fid);
    end
    fclose(channel_fid);
end;
[t,indexchannel]=FixSortChannelAtEndOfSOM(t,indexchannel);
save([wdir,'\sort_channel'],'t','indexchannel');

function [tt1,tt2,tt3,tt4,tt5,tt6,tt7,tt8,tt9,tt10]=TestFile2NEW(fname,classes);
% [tt1,tt2,tt3,tt4,tt5,tt6,tt7,tt8,tt9,tt10]=TestFile2(fname,classes);
tt1=[];
tt2=[];
tt3=[];
tt4=[];
tt5=[];
tt6=[];
tt7=[];
tt8=[];
tt9=[];
tt10=[];
cext='c.dat';
iext='i.dat';
N=2000;
fid=fopen([fname,cext],'r');
ifid=fopen([fname,iext],'r');
if (fid ~=-1 & ifid ~=-1)
    Group=fread(fid,N*4,'float');
    Time=fread(ifid,N,'int32')';
    if ~isempty(Group)
        while length(Group)==N*4
            Group=reshape(Group,4,length(Group)/4);
            II=find(Time<0);
            Time(II)=Time(II)+2^32;
            for i=1:classes
                I=find(Group(end,:)==i);
                if ~isempty(I)
                    offset=Group(end-2,I);
                    pack=Group(end-1,I);
                    tt=Time(I)+offset+(pack+5)*4;
                    eval(['tt',num2str(i),'=[tt',num2str(i),',tt];']);
                end;
            end;
            Group=fread(fid,N*4,'float');
            Time=fread(ifid,N,'int32')';
        end;
        L=length(Group)/4;
        if L>0
            Group=reshape(Group,4,length(Group)/4);
            II=find(Time<0);
            Time(II)=Time(II)+2^32;
            for i=1:classes
                I=find(Group(end,:)==i);
                if ~isempty(I)
                    offset=Group(end-2,I);
                    pack=Group(end-1,I);
                    tt=Time(I)+offset+(pack+5)*4;
                    eval(['tt',num2str(i),'=[tt',num2str(i),',tt];']);
                end;
            end;
        end;
    end;
end;
fclose(fid);
fclose(ifid);
tt1=sort(tt1(find(tt1>237)));
tt2=sort(tt2(find(tt2>237)));
tt3=sort(tt3(find(tt3>237)));
tt4=sort(tt4(find(tt4>237)));
tt5=sort(tt5(find(tt5>237)));
tt6=sort(tt6(find(tt6>237)));
tt7=sort(tt7(find(tt7>237)));
tt8=sort(tt8(find(tt8>237)));
tt9=sort(tt9(find(tt9>237)));
tt10=sort(tt10(find(tt10>237)));

function GroupNumber_CreateFcn(hObject, eventdata, handles)

function GroupNumber_Callback(hObject, eventdata, handles)

function PlotDensity_New(data1,data2);
%plots the 2D data points by density in space.
if length(data1)~=length(data2)
    error('Improper data sizes!');
end
BinNum=80;
Xbins=linspace(min(data1),max(data1),BinNum);
dBinX=(Xbins(2)-Xbins(1))/2;
Ybins=linspace(min(data2),max(data2),BinNum);
dBinY=(Ybins(2)-Ybins(1))/2;
HistData=zeros(BinNum,BinNum);
for i=1:BinNum,
    HistData(i,:)=hist(data1(find(data2>Ybins(i)-dBinY & data2<Ybins(i)+dBinY)),Xbins);
end
HistData=HistData;
figure('name','Density');
%figure;
imagesc(flipud(HistData));

function [t,indexchannel]=FixSortChannelAtEndOfSOM(t,indexchannel);
%check if there are neurons that do not spike, and add NaN in the t vector.
NeuronIndex=find(  (indexchannel(4,:)-indexchannel(3,:))==-1  );
if ~isempty(NeuronIndex)
    fprintf(['There are ' num2str(length(NeuronIndex)) ' neurons without spikes. Fixing sort_channel.\n']);
    NeuronNum=size(indexchannel,2);
    for neuron=1:length(NeuronIndex),
        if NeuronIndex(neuron)~=1,
            tbefore=t(1:indexchannel(4,NeuronIndex(neuron)-1));
        else
            tbefore=[];
        end
        if NeuronIndex(neuron)~=NeuronNum,
            tafter=t(indexchannel(3,NeuronIndex(neuron)+1):end);
            indexchannel(3,(NeuronIndex(neuron)+1):NeuronNum)=indexchannel(3,(NeuronIndex(neuron)+1):NeuronNum)+2;
            indexchannel(4,NeuronIndex(neuron):NeuronNum)=indexchannel(4,NeuronIndex(neuron):NeuronNum)+2;
        else
            tafter=[];
            indexchannel(4,NeuronNum)=indexchannel(4,NeuronNum)+2;
        end
        t=[tbefore,NaN,NaN,tafter];
    end
end