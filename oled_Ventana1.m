function varargout = oled_Ventana1(varargin)
% C�digo de inicio - No editar
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
    'gui_Singleton',  gui_Singleton, ...
    'gui_OpeningFcn', @oled_Ventana1_OpeningFcn, ...
    'gui_OutputFcn',  @oled_Ventana1_OutputFcn, ...
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
function oled_Ventana1_OpeningFcn(hObject, eventdata, handles, varargin)
global volt_input;
global curr_input;
global lum_input;
global waveLength;
global intensidad

handles.output = hObject;

% Gr�fica final corriente voltaje
axes(handles.axes1);
plot(volt_input, curr_input, 'gs-');
xlabel('Voltaje (Volts)');
ylabel('Densidad de corriente (Amp / cm2)');
title('Caracter�stica J vs V');
grid on;

% Gr�fica luminacia vs Voltaje
axes(handles.axes4);
plot(volt_input, lum_input, 'rs-');
xlabel('Voltaje (Volts)');
ylabel('luminancia (cd/m2)');
title('luminancia vs V');
grid on;

% Eficiencia de corriente.
axes(handles.axes2);
currentEfficiency = lum_input ./ curr_input;
plot(curr_input, currentEfficiency);
xlabel('Densidad de Corriente (A/cm2)');
ylabel('L / J [cd/A]');
title('Eficiencia de corriente');
grid on;

% GRAFICAR EFICIENCIA DE POTENCIA
axes(handles.axes3);
electricPower = volt_input .* curr_input;
powerEfficiency = (lum_input * pi) ./ (electricPower);
plot(curr_input, powerEfficiency, 'rs-');
xlabel('Dens. De corriente (A /cm2)');
ylabel('Eficiencia de Pot. (cd / W)');
title('J vs EP');
grid on;

% Update handles structure
guidata(hObject, handles);

%--------------------------------------------------------------------------
%--------------------------------------------------------------------------
function varargout = oled_Ventana1_OutputFcn(hObject, eventdata, handles)
varargout{1} = handles.output;

%--------------------------------------------------------------------------
%--------------------------------------------------------------------------
function lista_Callback(hObject, eventdata, handles)

%--------------------------------------------------------------------------
%--------------------------------------------------------------------------
function lista_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), ...
        get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

%--------------------------------------------------------------------------
%--------------------------------------------------------------------------
function popupmenu1_Callback(hObject, eventdata, handles)
global volt_input;
global curr_input;
global lum_input;
global waveLength;
global intensidad
val = get(hObject,'Value');

if val == 1
    % Luminancia
    axes(handles.axes4);
    plot(volt_input, lum_input, 'rs-');
    xlabel('Voltaje (Volts)');
    ylabel('luminancia (cd/m2)');
    title('luminancia vs V');
    grid on;
elseif val == 2
    % Luminancia
    axes(handles.axes4);
    semilogy(volt_input, lum_input,'b-o');
    xlabel('Voltaje (Volts)');
    ylabel('luminancia (cd/m2)');
    title('luminancia vs V (semilog)');
    grid on;
end

function popupmenu1_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), ...
        get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

%--------------------------------------------------------------------------
%--------------------------------------------------------------------------
% Cambiar la escala de las gr�ficas
function popupmenu2_Callback(hObject, eventdata, handles)
global volt_input;
global curr_input;
global lum_input;
global waveLength;
global intensidad
val1=get(hObject,'Value');

if val1 == 1
    axes(handles.axes1);
    plot(volt_input, curr_input, 'rs-');
    xlabel('Voltaje (Volts)');
    ylabel('Densidad de corriente (A / cm2)');
    title('V vs J escala Lineal');
    grid on;
    
elseif val1 == 2
    axes(handles.axes1);
    loglog(volt_input, curr_input,'b-o');
    xlabel('Voltaje (Volts)');
    ylabel('Corriente (A)');
    title('V vs J escala logaritmica');
    grid on;
end

function popupmenu2_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), ...
        get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
