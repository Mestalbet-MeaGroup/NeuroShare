function varargout = ppgui_CodeDisplayGui(varargin)
% PPGUI_CODEDISPLAYGUI M-file for ppgui_CodeDisplayGui.fig
%      PPGUI_CODEDISPLAYGUI, by itself, creates a new PPGUI_CODEDISPLAYGUI or raises the existing
%      singleton*.
%
%      H = PPGUI_CODEDISPLAYGUI returns the handle to a new PPGUI_CODEDISPLAYGUI or the handle to
%      the existing singleton*.
%
%      PPGUI_CODEDISPLAYGUI('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in PPGUI_CODEDISPLAYGUI.M with the given input arguments.
%
%      PPGUI_CODEDISPLAYGUI('Property','Value',...) creates a new PPGUI_CODEDISPLAYGUI or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before ppgui_CodeDisplayGui_OpeningFunction gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to ppgui_CodeDisplayGui_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help ppgui_CodeDisplayGui

% Last Modified by GUIDE v2.5 16-Dec-2005 17:38:05

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @ppgui_CodeDisplayGui_OpeningFcn, ...
                   'gui_OutputFcn',  @ppgui_CodeDisplayGui_OutputFcn, ...
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


% --- Executes just before ppgui_CodeDisplayGui is made visible.
function ppgui_CodeDisplayGui_OpeningFcn(hObject, eventdata, handles, varargin)
handles.output = hObject;
guidata(hObject, handles);
set(handles.CodeDisplay_txt,'String',varargin{1})


function varargout = ppgui_CodeDisplayGui_OutputFcn(hObject, eventdata, handles) 
varargout{1} = handles.output;

function CodeDisplay_txt_Callback(hObject, eventdata, handles)
function CodeDisplay_txt_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


