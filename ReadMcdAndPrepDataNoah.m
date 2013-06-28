function ReadMcdAndPrepDataNoah(file,Params)
% A function that reads the mcd file and prepares the data for sorting.
% matlabpool open 4;
% try
c1=clock;
[pathstr,name,ext] = fileparts(file);
cd(pathstr);

%make a fake map file (for sortui_som function)
fid=fopen([pwd,'\tmp.map'],'wb');
fclose(fid);

% set path to access FIND neuroshare_loader_all.m and DLL
DllPath='C:\Neuroshare\FIND\';% FIND_2.0 path
DLLName = 'nsMCDLibrary64.dll';
DLLfile = fullfile(DllPath, DLLName);
[ns_RESULT] = ns_SetLibrary(DLLfile);
[ns_RESULT, hfile] = ns_OpenFile(file);
[ns_RESULT, FileInfo] = ns_GetFileInfo(hfile);
[ns_RESULT, EntityInfo] = ns_GetEntityInfo(hfile, 1:FileInfo.EntityCount);
 segmententityIDs = find(cell2mat({EntityInfo.EntityType})==3);
  
 % skip all empty channels
segmententityIDs = segmententityIDs([EntityInfo(segmententityIDs).ItemCount] ~= 0);
ChannelLabel = {EntityInfo(segmententityIDs).EntityLabel};
channels     = [cellfun(@(x) str2num(x(end-2:end)), ChannelLabel,'UniformOutput', 1 )];
% ChannelID equals former entityID under FIND

path=cd;
folders_file=[path '\folders.txt'];
fid=fopen(folders_file,'wb');
fprintf(fid,'%s',[path '\']);
fprintf(fid,'%s\n','');
fclose(fid);
TotalFrames=0;

j=1;
%Preparation of files for writing
%build *.dat , *i.dat  files from *.txt file.
%*.dat file is the wpextract coeficients of each suspected spike
%*i.dat file is the time of each suspected file
%*.txt file is the recorded data frame by frame.
%'c' is the channels data: time and voltages.

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

%Begin Data Preperation
h=waitbar(0,'Reading data and converting. Please wait...');
step=cell(1,length(segmententityIDs));

c=0;
for i=segmententityIDs
    c=c+1;
    if (i<10)
        ch=['00' num2str(i)];
    elseif (i <100)
        ch=['0' num2str(i)];
    else
        ch=[num2str(i)];
    end
     wfid_dat(c)=fopen([path,'\',ch,'.dat'],'w');
     wfid_idat(c)=fopen([path,'\',ch,'i.dat'],'w');
     wfid_txt(c)=fopen([path,'\',ch,'.txt'],'w');
     step{c}=0; %'step{c}' counts the steps for each channel c
     percent=c/length(channels)*100;
     waitbar(c/length(channels),h,sprintf('%12.1f',percent));
     
     [ss, TimeData, VoltageData ,sss, ssss] = ns_GetSegmentData(hfile,i, 1:EntityInfo(i).ItemCount);

    if size(VoltageData,1)==1 
        VoltageData=VoltageData';
    end
        
    MVData=mean(mean(VoltageData,1));
    VoltageData=VoltageData-MVData;
    
    TimeData=TimeData*12; %convert msec to 12 khz
    
    L_tmp=length(TimeData);
    TimeDataTmp=(TimeData*ones(1,PPW)+ones(L_tmp,1)*WinTimeAddition)';
    TimeData=TimeDataTmp(:);
     
      for j=1:size(VoltageData,2) %goes over every window for a single channel during time semgment [Tstart T]
        for k=1:PPW %divides the every window to 20ms windows.
             VoltageDataTmp(:,(j-1)*PPW+k)=spline(1:NSubWindowSamples, VoltageData(((k-1)*NSubWindowSamples+1):k*NSubWindowSamples,j),linspace(1,NSubWindowSamples,237));      
        end
      end
   
    clear VoltageData;
    VoltageData=VoltageDataTmp;
    frame=1;
    a=VoltageData(:,frame)';
    a2=VoltageData(:,frame)';
    a22=a;
    b=TimeData(frame);
   
    %'b' is the time of recorded frame. 'a(1)' is the channel number.
    %'327' is probably the threshold level set somewhere in the past.
    
    a=[i 327 b a];
    Coefs_data=[];
    Time_data=[];
    txt_data=[];
%% Perform Wavelet Calculation
   stp=step{c};
   spmd
        test=codistributed(TimeData);
        for frame=drange(2:(length(test)))
           Coefs=WPextractMark(a,-1*(max(abs(a(4:end))).*0.8),Params); %The function recieves the threshold setting and spike detection parameters
            if ~isempty(Coefs)
              Time=Coefs(:,12);
              Coefs=Coefs(:,[1:11,13:14]);
              Coefs(:,11)=Coefs(:,11)+stp;
              Coefs_data=[Coefs_data,Coefs'];
              Time_data=[Time_data; Time];
              a(4:end)=a(4:end).*10^7; % Unit issue in SortUI if not re-scaled. Perhaps receiving ADC values instead of uV.
              txt_data=[txt_data; round(a(1:240))];
              stp=stp+1;
            end
            a22=VoltageData(:,frame)';
            b=TimeData(frame);
            a2=a22;
            a=a22;
            a=[i 327 b a];
            
        end
   end
    step{c}=stp{1};
   if size(Coefs,2)==numlabs
    Coefs = cat(1,Coefs{1:numlabs});
    Time  = cat(1,Time{1:numlabs});
    a     = cat(1,a{1:numlabs});
    a2    = cat(1,a2{1:numlabs});
    a22   = cat(1,a22{1:numlabs});
    frame = cat(1,frame{1:numlabs});
    clear test;
   end
   
    Coefs_data  = cat(2,Coefs_data{1:numlabs}); %keep working here
    Time_data  = cat(1,Time_data{1:numlabs});
    txt_data = cat(1,txt_data{1:numlabs});
    
%   fprintf(['\nSize of Coefs_data is: ', num2str(size(Coefs_data,2)), '\nSize of Time_data is: ', num2str(size(Time_data,1)),'\nSize of txt_data is: ', num2str(size(txt_data,1))]);
%% End Wavelet Calculation

     fwrite(wfid_dat(c),Coefs_data,'float');
     fwrite(wfid_idat(c),Time_data,'int32');
    
    for write_index=1:size(txt_data,1),
        fprintf(wfid_txt(c),'%1d\t',txt_data(write_index,:)');
        fprintf(wfid_txt(c),'\n');
    end

    fclose(wfid_dat(c));
    fclose(wfid_idat(c));
    fclose(wfid_txt(c));  
   
end

close(h);
fprintf('done !\n');
channels_file=[path, '\channels.txt'];
fid=fopen(channels_file,'wb');

for i=segmententityIDs
    if (i<10)
        fprintf(fid,'%s',['00' num2str(i)]);
    elseif (i <100)
        fprintf(fid,'%s',['0' num2str(i)]);
    else
        fprintf(fid,'%s',num2str(i));
    end
        fprintf(fid,'%s\n','');    
end

fclose(fid);
fprintf('done !\n\n');
c2=clock;

% catch
%     close(h);
%     matlabpool close;
%     pctRunDeployedCleanup;    
%     rethrow(lasterror);
%     ns_CloseFile(hfile);
% end

matlabpool close;
pctRunDeployedCleanup;    
ns_CloseFile(hfile);
clear mexprog;
fprintf(['elapsed time: ' num2str((c2(3)-c1(3))*24+(c2(4)-c1(4))) ....
    ' hours, ' num2str((c2(5)-c1(5))) ' minutes, ' num2str((c2(6)-c1(6))) ' seconds\n']);
end




