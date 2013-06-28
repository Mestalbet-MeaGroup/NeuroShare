%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function varargout = PlotRaster4(varargin);

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
    'gui_Singleton',  gui_Singleton, ...
    'gui_OpeningFcn', @PlotRaster4_OpeningFcn, ...
    'gui_OutputFcn',  @PlotRaster4_OutputFcn, ...
    'gui_LayoutFcn',  [] , ...
    'gui_Callback',   []);
if nargin & isstr(varargin{1})
    gui_State.gui_Callback = str2func(varargin{1});
end

if nargout
    [varargout{1:nargout}] = gui_mainfcn(gui_State, varargin{:});
else
    gui_mainfcn(gui_State, varargin{:});
end
% End initialization code - DO NOT EDIT


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% --- Executes just before PlotRaster4 is made visible.
function varargout=PlotRaster4_OpeningFcn(hObject, eventdata, handles, varargin);
handles.output = hObject;

handles.t=varargin{1};
handles.indexchannel=[varargin{2};ones(1,size(varargin{2},2))]; %add a 5th line that says which channels are displayed.
handles.indexMarker=[];
% if size(handles.indexchannel,2)>72,
%     error('ERROR: cannot display more then 72 neurons !!!!!');
% end
if ~isempty(find(handles.indexchannel(1,:)==0)),
    handles.indexMarker=handles.indexchannel(:,find(handles.indexchannel(1,:)==0));
    %sort Markers:
    [sortMarker,sortIndex]=sort(handles.indexMarker(2,:));
    handles.indexMarker=handles.indexMarker(:,sortIndex);
    %shrink indexchannel to neurons only:
    handles.indexchannel(:,find(handles.indexchannel(1,:)==0))=[];
end
handles.TimeBase=1; %default time base mode is t in [sec/12000]

handles=SetInitialParameters(handles);

setSlider(handles);

%set available channels:
SetChannels(handles);
SetMarkers(handles);

%plot raster:
axes(handles.Raster)
%PlotRasterImage(handles.t,handles.indexchannel,handles.indexMarker,handles.Tscale,handles.Tcenter,handles.WindowRes,handles.SpikeWidth,handles.Tmin,handles.Tmax);  %build image matrix
PlotRasterImage(handles);  %build image matrix
handles=updateTimings(handles);
%plot time scale on top:
axes(handles.Recording)
MakeRecordingImage(handles);
guidata(hObject,handles);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [handles]=SetInitialParameters(handles);
handles.WindowRes=2000;  %number of points in widow view
handles.SpikeWidth=3;
handles.Tscale=12000*60;   %1sec
handles.Tmin=0;
handles.Tmax=max(handles.t);    %
handles.Tcenter=handles.Tmin;   %sec/12000

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function setSlider(handles);
set(handles.slider1,'max',handles.Tmax);
set(handles.slider1,'min',handles.Tmin);
set(handles.slider1,'sliderstep',[0.01 0.10]);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function handles=updateTimings(handles)
%update timings for the different handles.

TB=handles.TimeBase; %convertion in case input is in msec

s{1}=[ num2str(floor((handles.Tcenter*TB-0.5*handles.Tscale)/12000/60/60)) ,':', num2str(floor(mod(handles.Tcenter*TB-0.5*handles.Tscale,12000*60*60)/12000/60)),':',num2str(floor(mod(handles.Tcenter*TB-0.5*handles.Tscale,12000*60)/12000)),':',num2str(mod(handles.Tcenter*TB-0.5*handles.Tscale,12000)/12)];
s{2}=[num2str(floor((handles.Tcenter*TB)/12000/60/60)),':',num2str(floor(mod(handles.Tcenter*TB,12000*60*60)/12000/60)),':',num2str(floor(mod(handles.Tcenter*TB,12000*60)/12000)),':',num2str(mod(handles.Tcenter*TB,12000)/12)];
s{3}=[num2str(floor((handles.Tcenter*TB+0.5*handles.Tscale)/12000/60/60)),':',num2str(floor(mod(handles.Tcenter*TB+0.5*handles.Tscale,12000*60*60)/12000/60)),':',num2str(floor(mod(handles.Tcenter*TB+0.5*handles.Tscale,12000*60)/12000)),':',num2str(mod(handles.Tcenter*TB+0.5*handles.Tscale,12000)/12)];
%s{1}=[ num2str(floor((handles.Tcenter-0.5*handles.Tscale+handles.tBeginRecord)/12000/60/60)) ,':', num2str(floor(mod(handles.Tcenter-0.5*handles.Tscale+handles.tBeginRecord,12000*60*60)/12000/60)),':',num2str(floor(mod(handles.Tcenter-0.5*handles.Tscale+handles.tBeginRecord,12000*60)/12000)),':',num2str(mod(handles.Tcenter-0.5*handles.Tscale+handles.tBeginRecord,12000))];
%s{2}=[num2str(floor((handles.Tcenter+handles.tBeginRecord)/12000/60/60)),':',num2str(floor(mod(handles.Tcenter+handles.tBeginRecord,12000*60*60)/12000/60)),':',num2str(floor(mod(handles.Tcenter+handles.tBeginRecord,12000*60)/12000)),':',num2str(mod(handles.Tcenter+handles.tBeginRecord,12000))];
%s{3}=[num2str(floor((handles.Tcenter+0.5*handles.Tscale+handles.tBeginRecord)/12000/60/60)),':',num2str(floor(mod(handles.Tcenter+0.5*handles.Tscale+handles.tBeginRecord,12000*60*60)/12000/60)),':',num2str(floor(mod(handles.Tcenter+0.5*handles.Tscale+handles.tBeginRecord,12000*60)/12000)),':',num2str(mod(handles.Tcenter+0.5*handles.Tscale+handles.tBeginRecord,12000))];
set(handles.TstartValue,'String',s{1});
set(handles.TcenterValue,'String',s{2});
set(handles.TendValue,'String',s{3});
%s{4}=[num2str(floor((handles.Tscale)/12000/60/60)),':',num2str(floor(mod(handles.Tscale,12000*60*60)/12000/60)),':',num2str(floor(mod(handles.Tscale,12000*60)/12000)),':',num2str(mod(handles.Tscale,12000))];
%mi time res is [sec/1000]
s{4}=[num2str(floor((handles.Tscale)/12000/60/60)),':',num2str(floor(mod(handles.Tscale,12000*60*60)/12000/60)),':',num2str(floor(mod(handles.Tscale,12000*60)/12000)),':',num2str(mod(handles.Tscale,12000)/12)];
set(handles.TscaleValue,'String',s{4});
set(handles.slider1,'value',handles.Tcenter);



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function PlotRasterImage(handles); 
%function m=MakeDataForRaster(indexchannel,Tscale,Tstart,WindowRes,SpikeWidth); 
%a function that builds image matrix m from data.
%t -time vector of recordings.
%indexchannel - index it t of neurons
%Tscale - scale of time for plotting:
%Tscale=1            1/12000 sec
%Tscale=12000    1 sec
%Tscale=12000*60 1 min.  etc.
%Tcenter - center image in units of 1/12000 sec
%TimeBase - if input data is in [msec], convert to sec/12000;
%WindowRes - how many bins in window of size Tscale
%SpikeWidth is width of spike in units of WindowReS
%m has zero where there is a spike, and 1 otherwise
t=handles.t*handles.TimeBase;
indexchannel=handles.indexchannel;
indexMarker=handles.indexMarker;
Tscale=handles.Tscale;
%Tscale=handles.Tscale*handles.TimeBase;
Tcenter=handles.Tcenter*handles.TimeBase;
WindowRes=handles.WindowRes;
SpikeWidth=handles.SpikeWidth;
Tmin=handles.Tmin*handles.TimeBase;
Tmax=handles.Tmax*handles.TimeBase;

Tstart=Tcenter-0.5*Tscale;
Tend=Tcenter+0.5*Tscale;
Nneurons=length(find(indexchannel(5,:)==1)); %number of neurons
%set Nmarkers: the number of markers to draw.
if length(indexMarker)~=0,
    Nmarkers=length(find(indexMarker(5,:)==1)); %number of markers
else
    Nmarkers=0;
end
m=zeros(Nneurons+Nmarkers,WindowRes); 
Cindex=find(indexchannel(5,:)==1);
%set neurons:
for i=1:Nneurons,
    tNeuron=t(indexchannel(3,Cindex(i)):indexchannel(4,Cindex(i)));  %find t on neuron i
    tNeuron=tNeuron(find(tNeuron>Tstart & tNeuron<Tend));   %reduce t to required window
    m(i,:)=hist(tNeuron,linspace(Tstart,Tend,WindowRes));   %build image histogram
end
%thiken spike lines:
for j=1:SpikeWidth,
    m(:,j:end)=m(:,j:end)+m(:,1:end-j+1);
end
%set markers:
if Nmarkers>0,
    Mindex=find(indexMarker(5,:)==1);
    for i=1:Nmarkers,
        tMarker=t(indexMarker(3,Mindex(i)):indexMarker(4,Mindex(i)));  %find t on neuron i
        tMarker=tMarker(find(tMarker>Tstart & tMarker<Tend));   %reduce t to required window
        m(Nneurons+i,:)=hist(tMarker,linspace(Tstart,Tend,WindowRes));   %build image histogram
    end
end
m(find(m>1))=1;
m=1-m;  %reverse image for black/white;
%color range out of t:
if Tstart<Tmin,
    m(:,find(linspace(Tstart,Tend,WindowRes)<Tmin))=0.7;
end
if Tend>Tmax,
    m(:,find(linspace(Tstart,Tend,WindowRes)>Tmax))=0.7;
end    
%make RGB:
m(:,:,1)=m;
m(:,:,2)=m(:,:,1);
m(:,:,3)=m(:,:,1);
image(m);
%plot markers:
%colors of markers:
markerColor(:,1)=[0;0/255;255/255];markerColor(:,2)=[255/255;0;0];markerColor(:,3)=[0;255/255;64/255];markerColor(:,4)=[255/255;0;255/255];
if length(indexMarker)~=0,
    NeuronsNum=find(indexMarker(5,:)==1);
    for i=1:Nmarkers,
        markerLocations=find(m(Nneurons+i,:,1)==0);
        for j=1:length(markerLocations),
            line([markerLocations(j),markerLocations(j)],[0.5,Nneurons+0.5],'Color',markerColor(:,NeuronsNum(i)));
        end
    end
end
%axis off;
set(gca,'XTick',[1 WindowRes/2 WindowRes]);
s{1}=num2str(Tcenter-0.5*Tscale);
s{2}=num2str(Tcenter);
s{3}=num2str(Tcenter+0.5*Tscale);
set(gca,'XTickLabel',s);
set(gca,'YTick',1:Nneurons+Nmarkers);
for i=1:Nneurons,
    s{i}=[num2str(indexchannel(1,Cindex(i))),' ',num2str(indexchannel(2,Cindex(i)))];
end
for i=1:Nmarkers,
    s{i+Nneurons}=[num2str(indexMarker(1,Mindex(i))),' ',num2str(indexMarker(2,Mindex(i)))];
end
if length(find(indexchannel(5,:)==1))>64,
    SetFontSize=4.2;
elseif length(find(indexchannel(5,:)==1))>54,
    SetFontSize=5;
elseif length(find(indexchannel(5,:)==1))>30,
    SetFontSize=6;
else
    SetFontSize=7;
end
set(gca,'YTickLabel',s,'FontSize',SetFontSize);
%text(0,-50,[num2str(floor((Tcenter-0.5*Tscale)/12000/60/60)) ,':', num2str(floor(mod(Tcenter-0.5*Tscale,12000*60*60)/12000/60)),':',num2str(floor(mod(Tcenter-0.5*Tscale,12000*60)/12000)),':',num2str(mod(Tcenter-0.5*Tscale,12000))],'FontSize',25);
%last time res is [sec/1000]
text(0,-50,[num2str(floor((Tcenter-0.5*Tscale)/12000/60/60)) ,':', num2str(floor(mod(Tcenter-0.5*Tscale,12000*60*60)/12000/60)),':',num2str(floor(mod(Tcenter-0.5*Tscale,12000*60)/12000)),':',num2str(mod(Tcenter-0.5*Tscale,12000)/12)],'FontSize',25);


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function mRecording=MakeRecordingImage(handles); 
%function m=MakeDataForRaster(indexchannel,Tscale,Tstart,WindowRes,SpikeWidth); 
%a function that builds image matrix m from data.
%t -time vector of recordings.
%indexchannel - index it t of neurons
%Tscale - scale of time for plotting:
%t=1            1/12000 sec
%t=12000    1 sec
%t=12000*60 1 min.  etc.
%Tcenter - center of image in units of 1/12000 sec
%WindowRes - how many bins in window of size Tscale
%SpikeWidth is width of spike in units of WindowReS
%m has zero where there is a spike, and 1 otherwise
%TimeBase - if input data is in msec, convert to sec/12000

Tcenter=handles.Tcenter*handles.TimeBase;
Tscale=handles.Tscale;
Tmin=handles.Tmin*handles.TimeBase;
Tmax=handles.Tmax*handles.TimeBase;

WinSize=300;
mRecording=ones(1,300);
tWindowMin=Tcenter-0.5*Tscale;
if tWindowMin<Tmin,
    tWindowMin=Tmin;
end
tWindowMax=Tcenter+0.5*Tscale;
if tWindowMax>Tmax,
    tWindowMax=Tmax;
end
mRecording(round((tWindowMin-Tmin)/(Tmax-Tmin)*(WinSize-1)+1):round((tWindowMax-Tmin)/(Tmax-Tmin)*(WinSize-1)+1))=0;
mRecording(:,:,1)=mRecording;
mRecording(:,:,2)=mRecording(:,:,1);
mRecording(:,:,3)=ones(1,300);
image(mRecording);
%axis off;
set(gca,'YTick',[]);
set(gca,'XTick',linspace(1,WinSize,10));
if Tmax>12000*60*60,
    set(handles.text1,'String','hours');
    x=linspace(round(Tmin/12000/60/60),round(Tmax/12000/60/60),10);   %hours
else
   set(handles.text1,'String','minutes');
    x=linspace(round(Tmin/12000/60),round(Tmax/12000/60),10);   %min.
end
for i=1:length(x),
    s{i}=num2str(x(i));
end
set(gca,'XTickLabel',s);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%set time base mode.
%default is sec/12000.
function TimeBaseSetting_Callback(hObject, eventdata, handles)
if get(handles.TimeBaseSetting,'value')==1,
    handles.TimeBase=1;
else
    handles.TimeBase=12;
end
guidata(hObject,handles);
axes(handles.Raster);
[handles]=SetInitialParameters(handles);
setSlider(handles);
PlotRasterImage(handles)  %build image matrix
handles=updateTimings(handles);
axes(handles.Recording);
MakeRecordingImage(handles);
guidata(hObject,handles);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function TimeBaseSetting_ButtonDownFcn(hObject, eventdata, handles)


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% --- Executes on slider movement.
function slider1_Callback(hObject, eventdata, handles)
axes(handles.Raster)
handles.Tcenter=get(handles.slider1,'value');
PlotRasterImage(handles)  %build image matrix
handles=updateTimings(handles);
axes(handles.Recording)
MakeRecordingImage(handles);
guidata(hObject,handles);



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function varargout = PlotRaster4_OutputFcn(hObject, eventdata, handles);
varargout{1} = handles.output;


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function forward_window_Callback(hObject, eventdata, handles, varargin);
axes(handles.Raster)
%if handles.Tcenter+0.5*handles.Tscale<handles.Tmax,
if handles.Tcenter+handles.Tscale/handles.TimeBase<handles.Tmax,
    handles.Tcenter=handles.Tcenter+handles.Tscale/handles.TimeBase;   %sec/12000
    PlotRasterImage(handles)  %build image matrix
    handles=updateTimings(handles);
    axes(handles.Recording)
    MakeRecordingImage(handles);
else
    sound(sin(1:1000)/4);
end
guidata(hObject,handles);


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function Forward_Small_Callback(hObject, eventdata, handles)
axes(handles.Raster)
if handles.Tcenter+0.1*handles.Tscale/handles.TimeBase<handles.Tmax,
    handles.Tcenter=handles.Tcenter+0.1*handles.Tscale/handles.TimeBase;   %sec/12000
    PlotRasterImage(handles)  %build image matrix
handles=updateTimings(handles);
    axes(handles.Recording)
    MakeRecordingImage(handles);
else
    sound(sin(1:1000)/4);
end
guidata(hObject,handles);




%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function Backward_window_Callback(hObject, eventdata, handles)
axes(handles.Raster);
%if handles.Tcenter-0.5*handles.Tscale>handles.Tmin
if handles.Tcenter-handles.Tscale/handles.TimeBase>handles.Tmin
    handles.Tcenter=handles.Tcenter-handles.Tscale/handles.TimeBase;   %sec/12000
    PlotRasterImage(handles)  %build image matrix
handles=updateTimings(handles);
    axes(handles.Recording)
    MakeRecordingImage(handles);
else
    sound(sin(1:1000)/4);
end
guidata(hObject,handles);



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function JumpToFirstSpike_Callback(hObject, eventdata, handles)
axes(handles.Raster);
handles.Tcenter=min(handles.t);
PlotRasterImage(handles)  %build image matrix
handles=updateTimings(handles);
axes(handles.Recording);
MakeRecordingImage(handles);
guidata(hObject,handles);


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function backward_Small_Callback(hObject, eventdata, handles)
axes(handles.Raster);
if handles.Tcenter-0.1*handles.Tscale/handles.TimeBase>handles.Tmin
    handles.Tcenter=handles.Tcenter-0.1*handles.Tscale/handles.TimeBase;   %sec/12000
    PlotRasterImage(handles)  %build image matrix
handles=updateTimings(handles);
    axes(handles.Recording)
    MakeRecordingImage(handles);
else
    sound(sin(1:1000)/4);
end
guidata(hObject,handles);


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function Expand_line_Callback(hObject, eventdata, handles)
axes(handles.Raster)
handles.SpikeWidth=handles.SpikeWidth+1;
PlotRasterImage(handles)  %build image matrix
handles=updateTimings(handles);
guidata(hObject,handles);


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function Thin_Lines_Callback(hObject, eventdata, handles)
axes(handles.Raster)
if handles.SpikeWidth>1,
    handles.SpikeWidth=handles.SpikeWidth-1;
else
    sound(sin(1:1000)/4);
end
PlotRasterImage(handles)  %build image matrix
handles=updateTimings(handles);
guidata(hObject,handles);


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function Zoom_out_Callback(hObject, eventdata, handles)
axes(handles.Raster)
handles.Tscale=handles.Tscale*2;
PlotRasterImage(handles)  %build image matrix
handles=updateTimings(handles);
axes(handles.Recording)
MakeRecordingImage(handles);
guidata(hObject,handles);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function Zoom_In_Callback(hObject, eventdata, handles)
axes(handles.Raster)
if handles.Tscale/2>1,
    handles.Tscale=handles.Tscale/2;
else
    sound(sin(1:1000)/4);
end
PlotRasterImage(handles)  %build image matrix
handles=updateTimings(handles);
axes(handles.Recording)
MakeRecordingImage(handles);
guidata(hObject,handles);


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function IncreaseWindowSize_Callback(hObject, eventdata, handles)
axes(handles.Raster)
if handles.WindowRes==300,
    handles.WindowRes=1000;
elseif handles.WindowRes==1000,
    handles.WindowRes=2000;
else
    sound(sin(1:1000)/4);
end
PlotRasterImage(handles)  %build image matrix
handles=updateTimings(handles);
guidata(hObject,handles);


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function DecreaseWindowSize_Callback(hObject, eventdata, handles)
axes(handles.Raster)
if handles.WindowRes==2000,
    handles.WindowRes=1000;
elseif handles.WindowRes==1000,
    handles.WindowRes=300;
else
    sound(sin(1:1000)/4);
end
PlotRasterImage(handles)  %build image matrix
handles=updateTimings(handles);
guidata(hObject,handles);


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%make image for print
function Make_Image_Callback(hObject, eventdata, handles)
figure;
PlotRasterImage(handles)  %build image matrix
handles=updateTimings(handles);



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% --- Executes on button press in ResetChannels.
function ResetChannels_Callback(hObject, eventdata, handles)
handles.indexchannel(5,:)=1;
SetChannels(handles);
if ~isempty(handles.indexMarker)
    handles.indexMarker(5,:)=1;
    SetMarkers(handles);
end
axes(handles.Raster)
PlotRasterImage(handles)  %build image matrix
handles=updateTimings(handles);
guidata(hObject,handles);


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%set active channels:
function SetChannels(handles);
set(handles.listbox1,'Value',[]);
% for i=1:size(handles.indexchannel,2)
%     if size(handles.indexchannel,2)>=i,
%         eval(['set(handles.listbox1',num2str(i),',''Enable'',''On'',''String'',[num2str(handles.indexchannel(1,i)),'' '',num2str(handles.indexchannel(2,i))])']);
%         if handles.indexchannel(5,i),
%             eval(['set(handles.checkbox',num2str(i),',''Value'',1)']);
%         else
%             eval(['set(handles.checkbox',num2str(i),',''Value'',0)']);;
%         end
%     else
%         eval(['set(handles.checkbox',num2str(i),',''Enable'',''Off'',''String'','''')']);
%     end
% end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%set active markers:
function SetMarkers(handles);
for i=1:4;
    if size(handles.indexMarker,2)>=i,
        eval(['set(handles.marker',num2str(i),',''Enable'',''On'',''String'',[num2str(handles.indexMarker(1,i)),'' '',num2str(handles.indexMarker(2,i))])']);
        if handles.indexMarker(5,i),
            eval(['set(handles.marker',num2str(i),',''Value'',1)']);
        else
            eval(['set(handles.marker',num2str(i),',''Value'',0)']);;
        end
    else
        eval(['set(handles.marker',num2str(i),',''Enable'',''Off'',''String'','''')']);
    end
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function TstartValue_CreateFcn(hObject, eventdata, handles)
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function TstartValue_Callback(hObject, eventdata, handles)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function TcenterValue_CreateFcn(hObject, eventdata, handles)
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function TcenterValue_Callback(hObject, eventdata, handles)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function TendValue_CreateFcn(hObject, eventdata, handles)
% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function TendValue_Callback(hObject, eventdata, handles)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function TscaleValue_CreateFcn(hObject, eventdata, handles)
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function TscaleValue_Callback(hObject, eventdata, handles)
% hObject    handle to TscaleValue (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of TscaleValue as text
%        str2double(get(hObject,'String')) returns contents of TscaleValue as a double


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function handles=updateImageForMarkers(handles,markerNum)
%to update image after mark/unmark marker
x=eval(['get(handles.marker',num2str(markerNum),',''Value'');']);
if x==1,
    eval(['handles.indexMarker(5,',num2str(markerNum),')=1;']);
else
    eval(['handles.indexMarker(5,',num2str(markerNum),')=0;']);
end
axes(handles.Raster)
PlotRasterImage(handles)  %build image matrix

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% --- Executes on button press in marker1.
function marker1_Callback(hObject, eventdata, handles)
markerNum=1;
handles=updateImageForMarkers(handles,markerNum);
guidata(hObject,handles);

function marker2_Callback(hObject, eventdata, handles)
markerNum=2;
handles=updateImageForMarkers(handles,markerNum);
guidata(hObject,handles);

function marker3_Callback(hObject, eventdata, handles)
markerNum=3;
handles=updateImageForMarkers(handles,markerNum);
guidata(hObject,handles);

function marker4_Callback(hObject, eventdata, handles)
markerNum=4;
handles=updateImageForMarkers(handles,markerNum);
guidata(hObject,handles);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%change Tcenter by Next/Prev. of markers.
function [handles]=updateTcenter(handles,markerNum,direction);
x=eval(['get(handles.marker',num2str(markerNum),',''Value'')']);
if x==1,
    tmpTcenter=handles.Tcenter;
    if direction==1, %move forward
        handles.Tcenter=min(handles.t(handles.indexMarker(3,markerNum)-1+find(handles.t(handles.indexMarker(3,markerNum):handles.indexMarker(4,markerNum))>handles.Tcenter)));
    else %move backward
        handles.Tcenter=max(handles.t(handles.indexMarker(3,markerNum)-1+find(handles.t(handles.indexMarker(3,markerNum):handles.indexMarker(4,markerNum))<handles.Tcenter)));
   end
    if isempty(handles.Tcenter),
        handles.Tcenter=tmpTcenter;
       sound(sin(1:1000)/4);
    end
    axes(handles.Raster)
    PlotRasterImage(handles)  %build image matrix
    handles=updateTimings(handles);
else
     sound(sin(1:1000)/4);
end    


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% --- Executes on button press in Marker1Next.
function Marker1Next_Callback(hObject, eventdata, handles)
markerNum=1;
direction=1;
handles=updateTcenter(handles,markerNum,direction);
guidata(hObject,handles);

% --- Executes on button press in Marker1Previous.
function Marker1Previous_Callback(hObject, eventdata, handles)
markerNum=1;
direction=0;
handles=updateTcenter(handles,markerNum,direction);
guidata(hObject,handles);

function Marker2Next_Callback(hObject, eventdata, handles)
markerNum=2;
direction=1;
handles=updateTcenter(handles,markerNum,direction);
guidata(hObject,handles);

function Marker2Previous_Callback(hObject, eventdata, handles)
markerNum=2;
direction=0;
handles=updateTcenter(handles,markerNum,direction);
guidata(hObject,handles);

function Marker3Next_Callback(hObject, eventdata, handles)
markerNum=3;
direction=1;
handles=updateTcenter(handles,markerNum,direction);
guidata(hObject,handles);

function Marker3Previous_Callback(hObject, eventdata, handles)
markerNum=3;
direction=0;
handles=updateTcenter(handles,markerNum,direction);
guidata(hObject,handles);

function Marker4Next_Callback(hObject, eventdata, handles)
markerNum=4;
direction=1;
handles=updateTcenter(handles,markerNum,direction);
guidata(hObject,handles);

function Marker4Previous_Callback(hObject, eventdata, handles)
markerNum=4;
direction=0;
handles=updateTcenter(handles,markerNum,direction);
guidata(hObject,handles);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function handles=updateImage(handles,checkboxNum)
%to update image after mark/unmark checkbox
 if eval(['handles.indexchannel(5,',num2str(checkboxNum),')==0'])
       eval(['handles.indexchannel(5,',num2str(checkboxNum),')=1;']);
 else
    eval(['handles.indexchannel(5,',num2str(checkboxNum),')=0;']);
 end
axes(handles.Raster)
PlotRasterImage(handles)  %build image matrix

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


% --- Executes during object creation, after setting all properties.
function slider1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to slider1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background, change
%       'usewhitebg' to 0 to use default.  See ISPC and COMPUTER.
usewhitebg = 1;
if usewhitebg
    set(hObject,'BackgroundColor',[.9 .9 .9]);
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end

% --- Executes during object creation, after setting all properties.
function TimeBaseSetting_CreateFcn(hObject, eventdata, handles)
% hObject    handle to TimeBaseSetting (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end


% --- Executes on selection change in listbox1.
function listbox1_Callback(hObject, eventdata, handles)
% hObject    handle to listbox1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
list_entries = get(handles.listbox1,'String');
temp = get(handles.listbox1,'Value');
for i=1:length(temp)
    checkboxNum=temp(i);
    handles=updateImage(handles,checkboxNum);
    guidata(hObject,handles);
end

% var1 = str2num(list_entries{index_selected(1)}(end-3:end)); 
% Hints: contents = cellstr(get(hObject,'String')) returns listbox1 contents as cell array
%        contents{get(hObject,'Value')} returns selected item from listbox1


% --- Executes during object creation, after setting all properties.
function listbox1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to listbox1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on key press with focus on listbox1 and none of its controls.
function listbox1_KeyPressFcn(hObject, eventdata, handles)
% hObject    handle to listbox1 (see GCBO)
% eventdata  structure with the following fields (see UICONTROL)
%	Key: name of the key that was pressed, in lower case
%	Character: character interpretation of the key(s) that was pressed
%	Modifier: name(s) of the modifier key(s) (i.e., control, shift) pressed
% handles    structure with handles and user data (see GUIDATA)
