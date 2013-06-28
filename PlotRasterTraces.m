function varargout = PlotRasterTraces(varargin)
% PLOTRASTERTRACES MATLAB code for PlotRasterTraces.fig
%      PLOTRASTERTRACES, by itself, creates a new PLOTRASTERTRACES or raises the existing
%      singleton*.
%
%      H = PLOTRASTERTRACES returns the handle to a new PLOTRASTERTRACES or the handle to
%      the existing singleton*.
%
%      PLOTRASTERTRACES('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in PLOTRASTERTRACES.M with the given input arguments.
%
%      PLOTRASTERTRACES('Property','Value',...) creates a new PLOTRASTERTRACES or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before PlotRasterTraces_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to PlotRasterTraces_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help PlotRasterTraces

% Last Modified by GUIDE v2.5 14-Jul-2011 11:00:33

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @PlotRasterTraces_OpeningFcn, ...
                   'gui_OutputFcn',  @PlotRasterTraces_OutputFcn, ...
                   'gui_LayoutFcn',  [] , ...
                   'gui_Callback',   []);
if nargin && ischar(varargin{1})
    gui_State.gui_Callback = str2func(varargin{1});
end

if nargout
    [varargout{1:nargout}] = gui_mainfcn(gui_State, varargin{:});
else
    gui_mainfcn(gui_State, varargin{:});
end
% End initialization code - DO NOT EDIT


% --- Executes just before PlotRasterTraces is made visible.
function varargout=PlotRasterTraces_OpeningFcn(hObject, eventdata, handles, varargin)
handles.output = hObject;
% guidata(hObject, handles);
i=1;
% [filename pathname]=uigetfile();
% handles.loaded=[pathname filename];
% load(handles.loaded);
% axes1 = plot(time,data(:,i));
handles.i=i;
    if iscell(varargin{3})
        handles.celldata=varargin{3}
        handles.data=varargin{3}{handles.i}(:,1);
        handles.time=varargin{3}{handles.i}(:,2);
        handles.numTraces=size(varargin{3},2);
    else
        handles.data=varargin{3};
        handles.time=varargin{4};
        handles.numTraces=size(handles.data,2);
    end

handles.accepted=[];
% guidata(hObject,handles);
handles.t=varargin{1};
handles.indexchannel=[varargin{2};ones(1,size(varargin{2},2))]; %add a 5th line that says which channels are displayed.
handles.indexMarker=[];
handles.listbox1=[];
    if length(varargin)>4
     handles.loaded=varargin{5};
    else
     handles.loaded='unknown.mat'
    end
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
SetChannels(handles);
% SetMarkers(handles);
handles.slider1=[];
set(handles.slider1,'max',handles.Tmax);
set(handles.slider1,'min',handles.Tmin);
set(handles.slider1,'sliderstep',[0.01 0.10]);
%plot raster:
axes(handles.Raster)
PlotRasterImage(handles);  %build image matrix
% MakeRecordingImage(handles);
handles.WindowRes=2000;  %number of points in window view
handles.SpikeWidth=3;
handles.Tscale=12000*60;   %1sec
handles.Tmin=0;
handles.Tmax=max(handles.t);    %
handles.Tcenter=handles.Tmin; 
guidata(hObject,handles);

function SetChannels(handles);
set(handles.listbox1,'Value',[]);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [handles]=SetInitialParameters(handles);
handles.WindowRes=2000;  %number of points in window view
handles.SpikeWidth=3;
handles.Tscale=12000*60;   %1sec
handles.Tmin=0;
handles.Tmax=max(handles.t);    %
handles.Tcenter=handles.Tmin;   %sec/12000

function setSlider(handles);
set(handles.slider1,'max',handles.Tmax);
set(handles.slider1,'min',handles.Tmin);
set(handles.slider1,'sliderstep',[0.01 0.10]);

function PlotRasterImage(handles); 
t=handles.t*handles.TimeBase;
indexchannel=handles.indexchannel;
indexMarker=handles.indexMarker;
Tscale=handles.Tscale;
Tcenter=handles.Tcenter*handles.TimeBase;
WindowRes=handles.WindowRes;
SpikeWidth=handles.SpikeWidth;
Tmin=handles.Tmin*handles.TimeBase;
Tmax=handles.Tmax*handles.TimeBase;
Tstart=Tcenter-0.5*Tscale;
Tend=Tcenter+0.5*Tscale;
        
axes(handles.axes1);
    if size(handles.data,2)==1
        handles.data=handles.celldata{handles.i}(:,1);
        handles.time=handles.celldata{handles.i}(:,2);
        plot(handles.time,handles.data);
    else
        plot(handles.time,handles.data(:,handles.i));
    end
xlim([Tstart./12000 Tend./12000]);
axes(handles.Raster);
Nneurons=length(find(indexchannel(5,:)==1)); %number of neurons
Nmarkers=0;
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
set(handles.Raster,'XTick',[1 WindowRes/2 WindowRes]);
s{1}=num2str(Tcenter-0.5*Tscale);
s{2}=num2str(Tcenter);
s{3}=num2str(Tcenter+0.5*Tscale);
set(handles.Raster,'XTickLabel',s);
set(handles.Raster,'YTick',1:Nneurons+Nmarkers);
for i=1:Nneurons,
    s{i}=[num2str(indexchannel(1,Cindex(i))),' ',num2str(indexchannel(2,Cindex(i)))];
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
set(handles.Raster,'YTickLabel',s,'FontSize',SetFontSize);
text(0,-50,[num2str(floor((Tcenter-0.5*Tscale)/12000/60/60)) ,':', num2str(floor(mod(Tcenter-0.5*Tscale,12000*60*60)/12000/60)),':',num2str(floor(mod(Tcenter-0.5*Tscale,12000*60)/12000)),':',num2str(mod(Tcenter-0.5*Tscale,12000)/12)],'FontSize',25);

function mRecording=MakeRecordingImage(handles); 
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
axes(handles.Raster);
image(mRecording);
set(handles.Raster,'YTick',[]);
set(handles.Raster,'XTick',linspace(1,WinSize,10));
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

% --- Outputs from this function are returned to the command line.
function varargout = PlotRasterTraces_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on button press in forward_window.
function forward_window_Callback(hObject, eventdata, handles, varargin);
    axes(handles.Raster)
if handles.Tcenter+handles.Tscale/handles.TimeBase<handles.Tmax,
    handles.Tcenter=handles.Tcenter+handles.Tscale/handles.TimeBase;   %sec/12000
    PlotRasterImage(handles);  %build image matrix
else
    sound(sin(1:1000)/4);
end
guidata(hObject,handles);
% guidata(hObject,handles);


% --- Executes on button press in Backward_window.
function Backward_window_Callback(hObject, eventdata, handles)
axes(handles.Raster);
%if handles.Tcenter-0.5*handles.Tscale>handles.Tmin
if handles.Tcenter-handles.Tscale/handles.TimeBase>handles.Tmin
    handles.Tcenter=handles.Tcenter-handles.Tscale/handles.TimeBase;   %sec/12000
    PlotRasterImage(handles)  %build image matrix
else
    sound(sin(1:1000)/4);
end
guidata(hObject,handles);


function Forward_Small_Callback(hObject, eventdata, handles)
axes(handles.Raster)
if handles.Tcenter+0.1*handles.Tscale/handles.TimeBase<handles.Tmax,
    handles.Tcenter=handles.Tcenter+0.1*handles.Tscale/handles.TimeBase;   %sec/12000
    PlotRasterImage(handles)  %build image matrix
else
    sound(sin(1:1000)/4);
end
guidata(hObject,handles);


% --- Executes on button press in backward_Small.
function backward_Small_Callback(hObject, eventdata, handles)
axes(handles.Raster);
if handles.Tcenter-0.1*handles.Tscale/handles.TimeBase>handles.Tmin
    handles.Tcenter=handles.Tcenter-0.1*handles.Tscale/handles.TimeBase;   %sec/12000
    PlotRasterImage(handles)  %build image matrix
else
    sound(sin(1:1000)/4);
end
guidata(hObject,handles);

% --- Executes on button press in Zoom_out.
function Zoom_out_Callback(hObject, eventdata, handles)
axes(handles.Raster)
handles.Tscale=handles.Tscale*2;
PlotRasterImage(handles)  %build image matrix
guidata(hObject,handles);


% --- Executes on button press in Zoom_In.
function Zoom_In_Callback(hObject, eventdata, handles)
axes(handles.Raster)
if handles.Tscale/2>1,
    handles.Tscale=handles.Tscale/2;
else
    sound(sin(1:1000)/4);
end
PlotRasterImage(handles)  %build image matrix
guidata(hObject,handles);


% --- Executes on button press in NextTrace.
function handles = NextTrace_Callback(hObject, eventdata, handles)
% hObject    handle to NextTrace (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
if handles.i<handles.numTraces
    handles.i=handles.i+1;
    display(handles.i);
    %     axes(handles.axes1);
%     plot(handles.time,handles.data(:,handles.i));
%     title(['ROI ' num2str(handles.i)] ,'FontSize',7);
PlotRasterImage(handles); 
else 
     sound(sin(1:1000)/4);
end
guidata(hObject,handles);


% --- Executes on button press in BackTrace.
function handles = BackTrace_Callback(hObject, eventdata, handles)
% hObject    handle to BackTrace (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
if handles.i>1
    handles.i=handles.i-1;
%     axes(handles.axes1);
%     plot(handles.time,handles.data(:,handles.i));
%     title(['ROI ' num2str(handles.i)] ,'FontSize',7);
PlotRasterImage(handles); 
else 
    sound(sin(1:1000)/4);
end
guidata(hObject,handles);

% --- Executes on button press in AcceptTrace.
function handles = AcceptTrace_Callback(hObject, eventdata, handles)
% hObject    handle to AcceptTrace (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
 handles.accepted = [handles.accepted handles.i];
 guidata(hObject,handles);


% --- Executes on button press in SaveGliaVariable.
function SaveGliaVariable_Callback(hObject, eventdata, handles)
% hObject    handle to SaveGliaVariable (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles.accepted=unique(handles.accepted);
assignin('base', 'GliaTraces', handles.data(:,handles.accepted));
assignin('base', 'time', handles.time);
GliaTraces=handles.data(:,handles.accepted);
time=handles.time;
save([handles.loaded(1:end-4) '_Glia.mat'],'GliaTraces','time');
close;

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

% --- Executes during object creation, after setting all properties.
function listbox1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to listbox1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
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
function handles=updateImage(handles,checkboxNum)
%to update image after mark/unmark checkbox
 if eval(['handles.indexchannel(5,',num2str(checkboxNum),')==0'])
       eval(['handles.indexchannel(5,',num2str(checkboxNum),')=1;']);
 else
    eval(['handles.indexchannel(5,',num2str(checkboxNum),')=0;']);
 end
axes(handles.Raster)
PlotRasterImage(handles)  %build image matrix

% --- Executes on button press in Make_Image.
function Make_Image_Callback(hObject, eventdata, handles)
figure;
PlotRasterImage(handles)  %build image matrix
handles=updateTimings(handles);

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
