function time=AutoAlignTrace2MCD(t,data,time)
% Calculates the firing rate of t to have the same number of data points as
% time in the Ca imaging trace and then multiplies and shifts the most 
% highly correlated trace to find the best alignment. 
% 
% steps=((max(t)-min(t))./12000)/length(time);
% window=steps*2; %Averaging
% 
% matlabpool open 2;
% Spk=GlobalSpikeCount2(t,ic,window,steps);
%     if length(Spk)~=length(data)
%         difference=length(Spk)-length(data);
%         Spk(end-difference:end)=[];
%     end
% maxcorr=zeros(legnth(data),1);
%     parfor i=1:size(data,2)
%         maxcorr(i)=max(xcorr(Spk,data(:,i),500));
%     end
% maxcorr=max(maxcorr);
% 
% counter=1;
% for i=0:0.01:2
%     tempdata = data(:,3).*i;
%     a(counter)=max(xcorr(Spk(:,1),tempdata,500));
%     counter=counter+1;
% end
% 
% for i=1:length(locs)-1;
%     a(i) = (time(locs2(i+1))-time(locs2(i)))/(Spk(locs(i+1),2)-Spk(locs(i),2));
% end
% 
% 
% trace=data(:,4)./max(data(:,4));
% fr=Spk(:,1)./max(Spk(:,1));
% plot(Spk(:,2),Spk(:,1),time,trace,'r');
% [trpks,trloc]= findpeaks(trace,'minpeakheight',0.8*max(trace));
% [frpks,frloc]= findpeaks(fr,'minpeakheight',0.7*max(fr));
% a=xcorr(Spk(:,1),data(:,3),500);
% frtimes=Spk(frloc,2);
% trtimes=time(trloc);
% vec=0:0.01:3;
% for i=1:length(vec)
%     diffs(i)=mean(abs( trtimes(1:length(frtimes)).*vec(i)-frtimes));
% end
% answer = vec(find(b==min(b)));  
fileList = getAllFiles(uigetdir);

    for i=1:length(fileList)
        [Starts,Stops,triggers]=GetTriggers(fileList{i});
%         time=resample(triggers,1,round(length(time)/length(triggers)));
        save([fileList{i}(1:end-4) '_triggers.mat'],'triggers');
    end
    