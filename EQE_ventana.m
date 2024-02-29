function varargout = EQE_ventana(varargin)
% NO EDITAR
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @EQE_ventana_OpeningFcn, ...
                   'gui_OutputFcn',  @EQE_ventana_OutputFcn, ...
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
function EQE_ventana_OpeningFcn(hObject, eventdata, handles, varargin)
handles.output = hObject;

global Np;
global waveLength;
global curr_input;
global lum_input;
global Ne;
global EQE;

axes(handles.axes1);
plot(curr_input, EQE, 'gs-');
xlabel('Densidad de Corriente (Amp / m2)');
ylabel('EQE %');
title('EQE vs J');
grid on;

axes(handles.axes2);
plot(lum_input, EQE, 'gs-');
xlabel('Luminancia (Cd / cm2)');
ylabel('EQE %');
title('EQE vs LUM');
grid on;

% Update handles structure
guidata(hObject, handles);

%--------------------------------------------------------------------------
%--------------------------------------------------------------------------
function varargout = EQE_ventana_OutputFcn(hObject, eventdata, handles) 
varargout{1} = handles.output;

%--------------------------------------------------------------------------
%--------------------------------------------------------------------------
function popupmenu_Callback(hObject, eventdata, handles)
global volt_input;
global curr_input;
global lum_input;
global waveLength;
global intensidad
global Np;
global Ne;
global EQE;

val = get(hObject,'Value');

if val == 1
    % EQE %
    axes(handles.axes1);
    plot(curr_input, EQE, 'rs-');
    xlabel('J(A/m2)');
    ylabel('EQE %');
    title('EQE vs J');
    grid on;
    
    axes(handles.axes2);
    plot(lum_input, EQE, 'gs-');
    xlabel('Luminancia (Cd / cm2)');
    ylabel('EQE %');
    title('EQE vs LUM');
    grid on;
    
elseif val == 2
    % EQE%
    axes(handles.axes1);
    semilogy(curr_input, EQE,'b-o');
    xlabel('J(A/m2)');
    ylabel('EQE %');
    title('EQE vs J');
    grid on;
    
    axes(handles.axes2);
    semilogy(lum_input, EQE, 'gs-');
    xlabel('Luminancia (Cd / cm2)');
    ylabel('EQE %');
    title('EQE vs LUM');
    grid on;
end    

%--------------------------------------------------------------------------
%--------------------------------------------------------------------------
function popupmenu_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), ...
        get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
