function PlotSortedNeurons()
wdir=cd;
Nchannels_file=[wdir,'\channels.txt'];
%Nsiz=dir('channels.txt');
%Nchannel=ceil((Nsiz.bytes)/3);

Nchannel_fid=fopen(Nchannels_file,'r');
Nchannel=fgetl(Nchannel_fid); 
figure;
%          set(gcf,'units','centimeters','Position',[0.63,0.63,19.72,28.41]);
set(gcf,'PaperType','A4');
set(gcf,'PaperUnits','centimeters');
set(gcf,'PaperPosition',[0.63,0.63,19.72,28.41]);
if (Nchannel_fid ~=-1)    
    j=1;
    while (~isempty(Nchannel) & Nchannel~=-1)
        if j==16 
            figure;
            %           set(gcf,'units','centimeters','Position',[0.63,0.63,19.72,28.41]);
            set(gcf,'PaperType','A4');
            set(gcf,'PaperUnits','centimeters');
            set(gcf,'PaperPosition',[0.63,0.63,19.72,28.41]);
            j=1;
        end
        eval(['load ' wdir '\Channel' Nchannel '.mat']);
        if exist('all_groups')
            for i=1:size(all_groups,1)
                subplot(5,3,j);             
                plot(all_groups(i,:));
                title(['Ch#' Nchannel '-' num2str(i) ' #Sp:' num2str(all_group_showings(i))]);
                %               title(['Ch#' Nchannel '-' num2str(i)]);
                j=j+1;
                if j==16 
                    figure;
                    %            set(gcf,'units','centimeters','Position',[0.63,0.63,19.72,28.41]);
                    set(gcf,'PaperType','A4');
                    set(gcf,'PaperUnits','centimeters');
                    set(gcf,'PaperPosition',[0.63,0.63,19.72,28.41]);
                    j=1;
                end
            end
        end
        clear D* R* T* b* c* s* a*;
        Nchannel=fgetl(Nchannel_fid);
    end       
else
    fprinft('Missing Channels file');  
end
fclose(Nchannel_fid);

