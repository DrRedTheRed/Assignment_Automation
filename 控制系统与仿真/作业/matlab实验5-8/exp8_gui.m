function varargout = exp8_gui(varargin)
% EXP8_GUI MATLAB code for exp8_gui.fig
%      EXP8_GUI, by itself, creates a new EXP8_GUI or raises the existing
%      singleton*.
%
%      H = EXP8_GUI returns the handle to a new EXP8_GUI or the handle to
%      the existing singleton*.
%
%      EXP8_GUI('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in EXP8_GUI.M with the given input arguments.
%
%      EXP8_GUI('Property','Value',...) creates a new EXP8_GUI or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before exp8_gui_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to exp8_gui_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help exp8_gui

% Last Modified by GUIDE v2.5 10-May-2024 20:22:47

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @exp8_gui_OpeningFcn, ...
                   'gui_OutputFcn',  @exp8_gui_OutputFcn, ...
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


% --- Executes just before exp8_gui is made visible.
function exp8_gui_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to exp8_gui (see VARARGIN)

% Choose default command line output for exp8_gui
handles.output = hObject;
handles.peaks=peaks(35);
handles.membrane=membrane;
[x,y]=meshgrid(-8:0.5:8);
r=sqrt(x.^2+y.^2)+eps;
sinc=sin(r)./r;
handles.sinc=sinc;%创建结构体，保存3组数据
handles.current_data=handles.peaks;%默认绘制peaks图像
surf(handles.current_data);%绘制图形
% Choose default command line output for untitled
handles.output = hObject;%本来有的，选择默认命令行输出

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes exp8_gui wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = exp8_gui_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on button press in surf_pushbutton.
function surf_pushbutton_Callback(hObject, eventdata, handles)
% hObject    handle to surf_pushbutton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
surf(handles.current_data);%使用当前数据绘制surf图像

% --- Executes on button press in mesh_pushbutton.
function mesh_pushbutton_Callback(hObject, eventdata, handles)
% hObject    handle to mesh_pushbutton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
mesh(handles.current_data);%使用当前数据绘制surf图像

% --- Executes on button press in contour_pushbutton.
function contour_pushbutton_Callback(hObject, eventdata, handles)
% hObject    handle to contour_pushbutton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
contour(handles.current_data);%使用当前数据绘制surf图像

% --- Executes on selection change in popupmenu1.
function popupmenu1_Callback(hObject, eventdata, handles)
% hObject    handle to popupmenu1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
val=get(hObject,'Value');
str=get(hObject,'String');
switch str{val}%判断选择了哪一组数据，将当前内容更新为对应的数据
case 'peaks'
    handles.current_data = handles.peaks;
case 'membrane'
    handles.current_data = handles.membrane;  
case 'sinc'
    handles.current_data = handles.sinc;  
end
guidata(hObject,handles)%更新句柄handles结构和内容到hObject
% Hints: contents = cellstr(get(hObject,'String')) returns popupmenu1 contents as cell array
%        contents{get(hObject,'Value')} returns selected item from popupmenu1


% --- Executes during object creation, after setting all properties.
function popupmenu1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to popupmenu1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --------------------------------------------------------------------
function choose_menu_Callback(hObject, eventdata, handles)
% hObject    handle to choose_menu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --------------------------------------------------------------------
function Close_menu_Callback(hObject, eventdata, handles)
% hObject    handle to Close_menu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --------------------------------------------------------------------
function CloseF_botton_Callback(hObject, eventdata, handles)
% hObject    handle to CloseF_botton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
close(gcf)

% --------------------------------------------------------------------
function Surf_botton_Callback(hObject, eventdata, handles)
% hObject    handle to Surf_botton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
surf(handles.current_data);

% --------------------------------------------------------------------
function Mesh_botton_Callback(hObject, eventdata, handles)
% hObject    handle to Mesh_botton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
mesh(handles.current_data);

% --------------------------------------------------------------------
function Contour_botton_Callback(hObject, eventdata, handles)
% hObject    handle to Contour_botton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
contour(handles.current_data);



