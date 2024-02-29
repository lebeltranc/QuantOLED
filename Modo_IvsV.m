function varargout = Modo_IvsV(varargin)
% Código de inicio - No editar
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @Modo_IvsV_OpeningFcn, ...
                   'gui_OutputFcn',  @Modo_IvsV_OutputFcn, ...
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
function Modo_IvsV_OpeningFcn(hObject, eventdata, handles, varargin)
handles.output = hObject;
global aux_detener;
global aux_detener1;
aux_detener=0;
aux_detener1=0;

guidata(hObject, handles);

%--------------------------------------------------------------------------
%--------------------------------------------------------------------------
function varargout = Modo_IvsV_OutputFcn(hObject, eventdata, handles)
varargout{1} = handles.output;

%--------------------------------------------------------------------------
%--------------------------------------------------------------------------
function edit1_Callback(hObject, eventdata, handles)

%--------------------------------------------------------------------------
%--------------------------------------------------------------------------
function edit1_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), ...
        get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

%--------------------------------------------------------------------------
%--------------------------------------------------------------------------
function Vo_Callback(hObject, eventdata, handles)
global vo;
vo = get(hObject,'String');
vo = str2double(vo);

%--------------------------------------------------------------------------
%--------------------------------------------------------------------------
function Vo_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), ...
        get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

%--------------------------------------------------------------------------
%--------------------------------------------------------------------------
function txtpaso_Callback(hObject, eventdata, handles)

%--------------------------------------------------------------------------
%--------------------------------------------------------------------------
function txtpaso_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), ...
        get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

%--------------------------------------------------------------------------
%--------------------------------------------------------------------------
function Paso_Callback(hObject, eventdata, handles)
global paso
paso = get(hObject,'String');
paso = str2double(paso);

%--------------------------------------------------------------------------
%--------------------------------------------------------------------------
function Paso_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), ...
        get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function textvf_Callback(hObject, eventdata, handles)

%--------------------------------------------------------------------------
%--------------------------------------------------------------------------
function textvf_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), ...
        get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

%--------------------------------------------------------------------------
%--------------------------------------------------------------------------
function Vf_Callback(hObject, eventdata, handles)
global vf
vf = get(hObject,'String');
vf = str2double(vf);

%--------------------------------------------------------------------------
%--------------------------------------------------------------------------
function Vf_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), ....
        get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

%--------------------------------------------------------------------------
%--------------------------------------------------------------------------
% Proporcionar el área del dispositivo
function edit9_Callback(hObject, eventdata, handles)
global area;
area = get(hObject, 'String');
area = str2double(area);

%--------------------------------------------------------------------------
%--------------------------------------------------------------------------
function edit9_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), ...
        get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

%--------------------------------------------------------------------------
%--------------------------------------------------------------------------
function Boton_empezar_Callback(hObject, eventdata, handles)
%--------------------------------------------------------------------------
%PRESIONAR EL BOTON EMPEZAR:
%--------------------------------------------------------------------------

global GPIB;
global vo;
global vf;
global paso;
global volt_input2;
global dens_curr_input2;
global ow;
global area;
global curr_input2;
global resist_input2;
global trucazo;
global s;
global aux_detener1;
aux_detener1=0;
%aux_volt = 0;


% Settings iniciales
fprintf(ow, 'RATE F');
fprintf(ow, 'CONF:CURR:DC AUTO');

% Magnitudes a calcular:
volt_input2 = [];
dens_curr_input2 = [];


% Variable del loop:
k=0;
%--------------------------------------------------------------------------
%try
    for i = vo: paso: vf
        
        % Alimentación de voltaje.
        fprintf(GPIB,'++addr 13' );
        step=num2str(i);
        v_o=num2str(vo);
        input = ':VOLT';
        fprintf(GPIB, strcat(input,32,step));
        %---------
        if aux_detener1==1
            fprintf(GPIB, '++addr 13' );
            fprintf(GPIB, ':VOLT 0' );
            break
        else
            
        end
        %--------
        %pause(1);
        % Medida de corriente con OWON
        fprintf(ow, 'MEAS1?');
        meas_curr = fscanf(ow);
        meas_curr = str2num(meas_curr);
        meas_curr = meas_curr / area;
        
        
        
        % Medida de voltaje con Keithley 2000
        fprintf(GPIB,'++addr 16');
        pause(0.2);
        fprintf(GPIB, ':MEAS:VOLT?');
        meas_volt = fgetl(GPIB);
        meas_volt = str2num(meas_volt);
               
        % Iterador para guardar dato en arreglo.
        k = k + 1;
        
        % Asignación dato por dato.
        volt_input2(k) = meas_volt;
        dens_curr_input2(k) = meas_curr;
        sd= meas_volt;
        set(handles.Valor_V_est,'String',meas_volt);
        set(handles. Valor_A_est,'String',meas_curr);
        
        % Gráfica en 'tiempo real'.
        % En realidad se puede comunicar al handler con 'axes'
        % para graficar los datos deseados. Hay que tener en cuenta
        % el primer argumento de la función plot en este caso.
        % Graficar curva característica.
        axes(handles.axes1);
        plot(volt_input2, dens_curr_input2, 'gs-');
        xlabel('Voltaje (V)');
        ylabel('Densidad de Corriente (A/cm2)');
        title('Característica I vs V');
        grid on;
        
        axes(handles.axes2);
        loglog(volt_input2, dens_curr_input2,'rs-');
        xlabel('Voltaje (V)');
        ylabel('Densidad de corriente (A/cm2)');
        title('Característica I vs V escala log');
        grid on;
        
        drawnow;
             
    end
    
curr_input2=area*dens_curr_input2;
resist_input2=volt_input2./curr_input2;

%--------------------------------------------------------------------------     
     
     %---------------------------------------------------------------------
     % Finalización del bucle principal.
     meas_message = warndlg('Medición finalizada.');
     
     % Resetear fuente de voltaje.
     fprintf(GPIB, '++addr 13' );
     fprintf(GPIB, ':VOLT 0' );
% catch 
%     fclose(ow);
%     delete(ow);
%     fclose(GPIB); 
%     delete(GPIB);
% end

%--------------------------------------------------------------------------
%--------------------------------------------------------------------------
%Para luego poner una variable al presionar el seleccionar modo de
%corriente y voltaje para que asi pueda usar otros botones o no haya
%problemas con ventana1
function boton_salir_Callback(hObject, eventdata, handles)
clc;
closereq();


% --------------------------------------------------------------------
function exportar_IvsV_Callback(hObject, eventdata, handles)
guardado_IvsV;



function truco_Callback(hObject, eventdata, handles)
global trucazo;
trucazo = get(hObject,'String');
trucazo = str2double(trucazo);
% hObject    handle to truco (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of truco as text
%        str2double(get(hObject,'String')) returns contents of truco as a double


% --- Executes during object creation, after setting all properties.
function truco_CreateFcn(hObject, eventdata, handles)
% hObject    handle to truco (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



% --- Executes during object creation, after setting all properties.
function volt_est_CreateFcn(hObject, eventdata, handles)
% hObject    handle to volt_est (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit_area_est_Callback(hObject, eventdata, handles)
global a_est
a_est = get(hObject,'String');
a_est = str2double(a_est);


% --- Executes during object creation, after setting all properties.
function edit_area_est_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_area_est (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end




% --- Executes on button press in Comienzo_est_boton.
function Comienzo_est_boton_Callback(hObject, eventdata, handles)
%--------------------------------------------------------------------------
%PRESIONAR EL BOTON EMPEZAR:
%--------------------------------------------------------------------------

global GPIB;
global v_est;
global volt_input2;
global dens_curr_input2;
global ow;
global a_est;
global curr_input2;
global resist_input2;
global aux_detener;
%aux_volt = 0;

aux_detener = 0;
% Settings iniciales
fprintf(ow, 'RATE F');
fprintf(ow, 'CONF:CURR:DC AUTO');

% Magnitudes a calcular:
volt_input2 = [];
dens_curr_input2 = [];
fprintf(GPIB, '++addr 13' );
v_est=num2str(v_est);
fprintf(GPIB, strcat(':VOLT',32,v_est));


% Variable del loop:
k=0;
%--------------------------------------------------------------------------
try
    while 1
        
        % Alimentación de voltaje.
        fprintf(GPIB,'++addr 13' );
        
        input = ':VOLT';
        if aux_detener==1
            fprintf(GPIB, '++addr 13' );
            fprintf(GPIB, ':VOLT 0' );
            break
        else
            
        end
        
        % Medida de corriente con OWON
        fprintf(ow, 'MEAS1?');
        meas_curr = fscanf(ow);
        meas_curr = str2num(meas_curr);
        meas_curr = meas_curr / a_est;
        
        % Medida de voltaje con Keithley 2000
        fprintf(GPIB,'++addr 16');
        fprintf(GPIB, ':MEAS:VOLT?');
        meas_volt = fgetl(GPIB);
        meas_volt = str2num(meas_volt);
        
        % Iterador para guardar dato en arreglo.
        k = k + 1;
        
        % Asignación dato por dato.
        volt_input2(k) = meas_volt;
        dens_curr_input2(k) = meas_curr;
        set(handles.Valor_V_est,'String',meas_volt);
        set(handles. Valor_A_est,'String',meas_curr);
       
        
        
        % Gráfica en 'tiempo real'.
        % En realidad se puede comunicar al handler con 'axes'
        % para graficar los datos deseados. Hay que tener en cuenta
        % el primer argumento de la función plot en este caso.
        % Graficar curva característica.
        axes(handles.axes1);
        plot(volt_input2, dens_curr_input2, 'gs-');
        xlabel('Voltaje (V)');
        ylabel('Densidad de Corriente (A/cm2)');
        title('Característica I vs V');
        grid on;
        
        axes(handles.axes2);
        loglog(volt_input2, dens_curr_input2,'rs-');
        xlabel('Voltaje (V)');
        ylabel('Densidad de corriente (A/cm2)');
        title('Característica I vs V escala log');
        grid on;
        
        drawnow; 
    end   
curr_input2=a_est*dens_curr_input2
resist_input2=volt_input2./curr_input2
aux_detener=0;
%--------------------------------------------------------------------------     

catch 
    %fclose(ow);
    %delete(ow);
    %fclose(GPIB); 
    %delete(GPIB);
end
% hObject    handle to Comienzo_est_boton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)



function edit_volt_est_Callback(hObject, eventdata, handles)
global v_est
v_est = get(hObject,'String');
v_est = str2double(v_est);


% --- Executes during object creation, after setting all properties.
function edit_volt_est_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_volt_est (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in pushbutton_detener.
function pushbutton_detener_Callback(hObject, eventdata, handles)


global aux_detener;
aux_detener=1;
% hObject    handle to pushbutton_detener (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes during object creation, after setting all properties.
function Valor_V_est_CreateFcn(hObject, eventdata, handles)
% hObject    handle to Valor_V_est (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called


% --- Executes during object creation, after setting all properties.
function Valor_A_est_CreateFcn(hObject, eventdata, handles)
% hObject    handle to Valor_A_est (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called


% --- Executes on button press in pushbutton_detener1.
function pushbutton_detener1_Callback(hObject, eventdata, handles)
global aux_detener1;
aux_detener1=1;
% hObject    handle to pushbutton_detener1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
