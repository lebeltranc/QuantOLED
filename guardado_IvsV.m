function varargout = guardado_IvsV(varargin)
% Código de inicio - No editar
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @guardado_IvsV_OpeningFcn, ...
                   'gui_OutputFcn',  @guardado_IvsV_OutputFcn, ...
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
% NO EDITAR

%--------------------------------------------------------------------------
%--------------------------------------------------------------------------
function guardado_IvsV_OpeningFcn(hObject, eventdata, handles, varargin)
handles.output = hObject;

guidata(hObject, handles);

%--------------------------------------------------------------------------
%--------------------------------------------------------------------------
function varargout = guardado_IvsV_OutputFcn(hObject, eventdata, handles) 
varargout{1} = handles.output;

%--------------------------------------------------------------------------
%--------------------------------------------------------------------------
function nombre_Callback(hObject, eventdata, handles)
global volt_input2;
global curr_input2;
global resist_input2;
global nombre;
nombre=get(hObject,'String');

%--------------------------------------------------------------------------
%--------------------------------------------------------------------------
function nombre_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), ...
        get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

%--------------------------------------------------------------------------
%--------------------------------------------------------------------------
% Exportar datos a archivo de excel.
function boton_guardar_Callback(hObject, eventdata, handles)
global volt_input2;
global dens_curr_input2;
global curr_input2;
global resist_input2;
global area;
global nombre;

%dens_curr_input2 DEBERÌA LLAMARSE ALGO ASÌ COMO DENSdens_curr_input2
volt_input2=transpose(volt_input2);
dens_curr_input2=transpose(dens_curr_input2);
curr_input2=transpose(curr_input2);
resist_input2=transpose(resist_input2);


volt_input2=double(volt_input2);
dens_curr_input2=double(dens_curr_input2);
curr_input2=double(curr_input2);
resist_input2=double(resist_input2);

volt_input2=num2cell(volt_input2);
dens_curr_input2=num2cell(dens_curr_input2);
curr_input2=num2cell(curr_input2);
resist_input2=num2cell(resist_input2);



T=table(volt_input2, curr_input2, dens_curr_input2, resist_input2, ...
    'VariableNames', {'voltaje', 'corriente', 'J', ... 
    'Resistencia'});

filename = strcat(nombre,'.xlsx'); 
writetable(T,filename);
