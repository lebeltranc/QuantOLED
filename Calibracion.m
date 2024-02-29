function varargout = Calibracion(varargin)
% CALIBRACION MATLAB code for Calibracion.fig
%      CALIBRACION, by itself, creates a new CALIBRACION or raises the existing
%      singleton*.
%
%      H = CALIBRACION returns the handle to a new CALIBRACION or the handle to
%      the existing singleton*.
%
%      CALIBRACION('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in CALIBRACION.M with the given input arguments.
%
%      CALIBRACION('Property','Value',...) creates a new CALIBRACION or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before Calibracion_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to Calibracion_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help Calibracion

% Last Modified by GUIDE v2.5 21-Nov-2023 16:13:27

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @Calibracion_OpeningFcn, ...
                   'gui_OutputFcn',  @Calibracion_OutputFcn, ...
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


% --- Executes just before Calibracion is made visible.
function Calibracion_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to Calibracion (see VARARGIN)
global aux_deten;
aux_deten=0;
% Choose default command line output for Calibracion
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes Calibracion wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = Calibracion_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;



function Volt_funcionamiento_Callback(hObject, eventdata, handles)
global volt_calib;
volt_calib=get(hObject,'String');
volt_calib=str2double(volt_calib);
% hObject    handle to Volt_funcionamiento (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of Volt_funcionamiento as text
%        str2double(get(hObject,'String')) returns contents of Volt_funcionamiento as a double


% --- Executes during object creation, after setting all properties.
function Volt_funcionamiento_CreateFcn(hObject, eventdata, handles)
% hObject    handle to Volt_funcionamiento (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in Fondo_button.
function Fondo_button_Callback(hObject, eventdata, handles)

global norm_pot;
global norm;
global waveLength;
global coeff;
global waveinterv;
global Long_min;
global Long_max;

global numOfScans_calib;
global numOfBlankScans_calib;
global exposureTime_calib;
global fondo_calib;
global Tungs_irr_teorica;
D= readtable('Tungsteno_irrad_teorico.xlsx');
Tungs_irr_teorica = D(:,2);
Tungs_irr_teorica = table2array(Tungs_irr_teorica);

fondo_calib = getSpectraASEQ(numOfScans_calib,numOfBlankScans_calib,exposureTime_calib);
fondo_calib = double(fondo_calib);
fondo_calib = fondo_calib./norm;
% hObject    handle to Fondo_button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in Estab_volt_button.
function Estab_volt_button_Callback(hObject, eventdata, handles)
global volt_calib
global GPIB;
global v_est;
global volt_input2;
global dens_curr_input2;
global ow;
global a_est;
global curr_input2;
global resist_input2;
global aux_deten;
%aux_volt = 0;

aux_detener = 0;
% Settings iniciales
fprintf(ow, 'RATE F');
fprintf(ow, 'CONF:CURR:DC AUTO');

%fprintf(GPIB, '++addr 13' );
v1=volt_calib;
v2=num2str(v1);
%fprintf(GPIB, strcat(':VOLT',32,volt_calib_aux));


try
    while 1
        
        % Alimentación de voltaje.
        fprintf(GPIB,'++addr 13' );        
        input = ':VOLT';
        fprintf(GPIB, strcat(input,32,v2));
        % Medida de voltaje con Keithley 2000
        fprintf(GPIB,'++addr 16');
        fprintf(GPIB, ':MEAS:VOLT?');
        meas_volt = fgetl(GPIB);
        meas_volt = str2num(meas_volt);
        set(handles.volt_actual,'String',meas_volt);
        delta=(volt_calib-meas_volt);
        delta1=abs(delta);
        
        
        if delta1<0.001
            %fprintf(GPIB, '++addr 13' );
            %fprintf(GPIB, ':VOLT 0' );
            break
        else
            if delta>0
                if delta1>0.001
                  v1=v1+0.4*delta1;
                else
                  v1=v1+0.0075; 
                end
            else
                if delta1>0.001
                  v1=v1-0.4*delta1;
                else
                  v1=v1-0.0075; 
                end
                
            end
            v2=num2str(v1);
                
        end
        
        pause(1);
        if aux_deten==1
            fprintf(GPIB, '++addr 13' );
            fprintf(GPIB, ':VOLT 0' );
            break
        else
            
        end
        
              
        
    end   
aux_detener=0;
%--------------------------------------------------------------------------     

catch 
    %fclose(ow);
    %delete(ow);
    %fclose(GPIB); 
    %delete(GPIB);
end
% hObject    handle to Estab_volt_button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in Calibracion_button.
function Calibracion_button_Callback(hObject, eventdata, handles)

global norm_pot;
global norm;
global waveLength;
global coeff;
global waveinterv;
global Long_min;
global Long_max;

global numOfScans_calib;
global numOfBlankScans_calib;
global exposureTime_calib;
global fondo_calib;
global Tungs_irr_teorica;
global coeff_calib;

intensidad_tungs = getSpectraASEQ(numOfScans_calib,numOfBlankScans_calib, ...
                exposureTime_calib);
            
intensidad_tungs = double(intensidad_tungs);
intensidad_tungs = intensidad_tungs./ norm;
intensidad_tungs = intensidad_tungs - fondo_calib;
irradiancia_tungs = intensidad_tungs .* norm_pot;
irradiancia_tungs = 1/(coeff *exposureTime_calib) * irradiancia_tungs;
irradiancia_tungs_visib = irradiancia_tungs(Long_max:Long_min);
waveLe = transpose(waveLength);
waveLe=waveLe(Long_max:Long_min);
waveLe=waveLe*1e-9;
coeff_calib=Tungs_irr_teorica./irradiancia_tungs_visib;
calib=num2cell(coeff_calib);
T=table(calib,'VariableNames', {'coeficientes'});
axes(handles.axes2);
plot(waveLe,irradiancia_tungs_visib , 'gs-');
xlabel('Luminancia (Cd / cm2)');
ylabel('EQE %');
title('EQE vs LUM');
grid on;
%writetable(T,'coeficientes_calibracion.xlsx');










% hObject    handle to Calibracion_button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --------------------------------------------------------------------
function Archivo_tag_Callback(hObject, eventdata, handles)
% hObject    handle to Archivo_tag (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)



function Tiempo_exp_edit_Callback(hObject, eventdata, handles)
global numOfBlankScans_calib;
global exposureTime_calib;

numOfBlankScans_calib=0;
exposureTime_calib=get(hObject,'String');
exposureTime_calib=str2double(exposureTime_calib);
exposureTime_calib=exposureTime_calib*100;
% hObject    handle to Tiempo_exp_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of Tiempo_exp_edit as text
%        str2double(get(hObject,'String')) returns contents of Tiempo_exp_edit as a double


% --- Executes during object creation, after setting all properties.
function Tiempo_exp_edit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to Tiempo_exp_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function Promedios_edit_Callback(hObject, eventdata, handles)
global numOfScans_calib;

numOfScans_calib=get(hObject,'String');
numOfScans_calib=str2double(numOfScans_calib);
% hObject    handle to Promedios_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of Promedios_edit as text
%        str2double(get(hObject,'String')) returns contents of Promedios_edit as a double


% --- Executes during object creation, after setting all properties.
function Promedios_edit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to Promedios_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in detner_button.
function detner_button_Callback(hObject, eventdata, handles)
global aux_deten;
global GPIB;
aux_deten=1;
fprintf(GPIB, '++addr 13' );
fprintf(GPIB, ':VOLT 0' );


% hObject    handle to detner_button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes during object creation, after setting all properties.
function volt_actual_CreateFcn(hObject, eventdata, handles)
% hObject    handle to volt_actual (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
