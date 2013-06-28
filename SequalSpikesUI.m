function SequalSpikesUI(action,varargin);
% SequalSpikes(rdd,Data,Coefs,G,I,fig);
% sequal plotting of all selected spikes in group N;
% rdd is the rawdata of the channel, Data holds slices in raws, Coefs holds the coefficients
% G holds the grouping of the spikes, I holds selected indices and fig is figure number.



if nargin<1,
    action='InitializeControl';
end;





feval(action,varargin{:})
return;

function InitializeControl(Ver)
global rdd Da Co G I fig i NUMOFCOEFS SLICECOEF SLICEOFFSET WAV
rdd=Ver{1};
Da=Ver{2};
Co=Ver{3};
G=Ver{4};
I=Ver{5};
fig=Ver{6};
figure(fig);
uicontrol('Parent', gcf, ...
    'BusyAction','Queue','Interruptible','off',...
    'Enable', 'on', ...
    'Units','pixels', ...
    'Position',[5 2 50 20], ...
    'Horiz','left', ...
    'Background',[0.5 0.5 0.5], ...
    'Foreground','black',...
    'Callback','SequalSpikesUI(''Go_Next'')',...
    'String','NEXT');

uicontrol('Parent', gcf, ...
    'BusyAction','Queue','Interruptible','off',...
    'Enable', 'on', ...
    'Units','pixels', ...
    'Position',[60 2 50 20], ...
    'Horiz','left', ...
    'Background',[0.5 0.5 0.5], ...
    'Foreground','black',...
    'Callback','close',...
    'String','EXIT');

i=1;
load ldbdata;
WAV=LDB_wavelets(:,IND);
if size(Co,2)==length(G),
    Co=Co';
end;

NUMOFCOEFS=size(Co,2);
SLICECOEF=11;
SLICEOFFSET=min(Co(:,SLICECOEF))-1;
if ~isempty(I)
    peaks=sort(Da(I,66));
    ax=-peaks(min(length(peaks),5));
    
    off=Co(I(i),end-1);
    rd=[zeros(1,11),rdd(Co(I(i),SLICECOEF)-SLICEOFFSET,end-236:end),zeros(1,11)];
    %      rd=rd(off+(0:255));
    subplot(211); 
    zoom on;
    plot(rd);
    title(num2str([i,I(i),Co(I(i),SLICECOEF)-SLICEOFFSET,G(I(i))]));
    subplot(223);
    zoom on;
    plot(Da(I(i),:));
    axis auto; %([1,128,-ax,ax]);
    subplot(224);
    plot(WAV*Co(I(i),1:9)');
    axis auto; %([1,128,-ax,ax]);
end;

%end



function Go_Next()
global rdd Da Co G I fig i NUMOFCOEFS SLICECOEF SLICEOFFSET WAV

if (i<length(I))
    i=i+1;
end

if ~isempty(I)
    peaks=sort(Da(I,66));
    ax=-peaks(min(length(peaks),5));
    
    off=Co(I(i),end-1);
    rd=[zeros(1,11),rdd(Co(I(i),SLICECOEF)-SLICEOFFSET,end-236:end),zeros(1,11)];
    %      rd=rd(off+(0:255));
    subplot(211); 
    zoom on;
    plot(rd);
    title(num2str([i,I(i),Co(I(i),SLICECOEF)-SLICEOFFSET,G(I(i))]));
    subplot(223);
    zoom on;
    plot(Da(I(i),:));
    axis auto; %([1,128,-ax,ax]);
    subplot(224);
    plot(WAV*Co(I(i),1:9)');
    axis auto; %([1,128,-ax,ax]);
end;
