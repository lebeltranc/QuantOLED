%--------------------------------------------------------------------------
%--------------------------------------------------------------------------
% GRUPO DE FÍSICA APLICADA
% PROGRAMA PARA CARACTERIZACIÓN DE DISPOSITIVOS OLED
%   
% RECOMENDACIONES GENERALES
% - Verificar que el ordenador cuente con los drivers de los equipos de
% de medición y software necesarios para poder compilar y ejecutar el
% programa (Drivers GPIB-Prologix, Drivers Espectrómetro, Drivers 
% multímetros USB).
% - Es FUNDAMENTAL que la versión de MATLAB instalada en el ordenador
% cuente con el paquete (toolbox) 'Instrument Control Toolbox' para 
% que el programa pueda funcionar correctamente. Esto es necesario para
% establecer las conexiones entre los dispositivos y el ordenador.
% - Varias características del programa están diseñadas con utilidades
% DEPRECATED (o en desuso), por lo que el mantenimiento del código 
% fuente requiere de la consulta de la documentación para saber si 
% es compatible con la actual versión de MATLAB. La interfaz gráfica 
% se diseñó con la utilidad GUIDE. Este entorno será removido en versiones 
% futuras de MATLAB.
% - Windows asigna automáticamente los puertos de conexión COM en cuanto
% un dispositivo es conectado. De estos puertos depende la conexión de los
% instrumentos. Si el número de puerto no corresponde con el indicado 
% en el código, entonces la línea de inicialización debe cambiarse 
% para que la conexión funcione. Si Windows indica que el GPIB tiene
% como puerto COM9, entonces en la línea de inicialización dentro del 
% código este puerto debe indicarse dentro de la sintaxis de serial().
% MODIFIQUE ÚNICAMENTE ESTE CAMPO.
% - Verificar que todas las dependencias del programa estén presentes 
% en el directorio del código fuente. Estas dependencias son: Archivos
% de calibración y librerías para el espectrómetro, así como la curva
% de sensibilidad fotópica necesaria para el programa.
% - Verificar que las conexiones entre los instrumentos de medición 
% estén correctas. Se requiere: Una fuente de voltaje para alimentar el 
% el circuito (cables rojo/negro), un multímetro en modo voltaje 
% (cables negro y blanco/input), un multìmetro en modo amperaje
% (cables amarillo/negro).
% - Verificar que la escala del luxómetro sea la adeacuada comparándola
% con el valor del voltaje obtenido.
% - Orientar adecuadamente el espectrómetro y luxómetro hacia el
% dispositivo emisor de luz. Asegurarse de que no hay fuentes de luz
% cercanas que puedan afectar la medida.
% - Haga uso del modo J vs V (caracterísitca densidad de corriente contra
% voltaje) para realizar una medición rápida y verificar que todo se 
% encuentre en orden.
%
% INCISO 1  
% IMPORTANTE: ENCENDIDO DE APARATOS
% - Primero se debe encender la fuente de voltaje.
% - Después el multímetro keithley 2000, debe estar en modo de medición 
% de voltaje.
% - Por último dispositivos USB (Bk - precision, OWON, ASEQinstruments).
% - Ejecutar GPIB-CONFIGURATOR (programa) antes de usar MATLAB o 
% ejecutar el programa. Esto se debe hacer SIEMPRE o el programa 
% NO FUNCIONARÁ.
% - Asegurarse de que no existan malos contactos o factores que puedan
% afectar lecturas erróneas de los aparatos. Si observa que hay lecturas
% incoherentes, reinicie tanto los instrumentos como el programa.
%
% INCISO 2
% USO DEL PROGRAMA:
% - Modo general: llenar primero los campos que corresponden a la pestaña
% 'SPECTRA', it est, tiempo de exposición y número de promedios. Luego
% tome el fondo del ambiente con el espectrómetro y seleccione
% 'Quitar fondo'. También escoja un valor de luminancia tal que se tomen
% espectros si dicho valor de luminancia es alcanzado. Parámetros 
% comunes en estos campos son 200 ms de tiempo de exposición y 20 
% promedios.
% - Aségure de que los valores para el voltaje que será suministrado
% no excedan las especificaciones del dispositivo que desea utilizar.
% Coloque un número de paso adecuado para obtener una medición precisa.
% - En la pestaña principal, asegúrese de colocar la medida 
% del área del dispositivo teniendo en cuenta la unidad de medida indicada
% en la interfaz gráfica.
% - Luego de llenar los campos, seguir el orden: 'Capturar', 'Ejecutar'.
% Si desea abortar la medición por caulquier motivo, utilice el botón
% de 'ABORTAR'. Recuerde que si desea salir del programa es recomendable
% hacer uso del botón 'SALIR' para cerrar adecuadamente las conexiones 
% entre los dispositivos y el ordenador.
% - Recuerde hacer uso del Modo J vs V para obtener mediciones rápidas
% de la curva característica.
% - Se pueden exportar los datos obtenidos en la medida haciendo uso
% de la pestaña Archivo -> Exportar datos.


%--------------------------------------------------------------------------
%Medición Tungsteno a temperatura ambiente:
%--------------------------------------------------------------------------
%Temperatura: 18 C
%Resistencia 2.6 ohms
%--------------------------------------------------------------------------

%--------------------------------------------------------------------------
%--------------------------------------------------------------------------
% Código de inicialización - interfaz (NO TOCAR).
function varargout = oled_meas(varargin)
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @oled_meas_OpeningFcn, ...
                   'gui_OutputFcn',  @oled_meas_OutputFcn, ...
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

%--------------------------------------------------------------------------
%--------------------------------------------------------------------------
% Se ejecuta antes de que al ventana sea visible.
% Acá se inicializarán las conexiones.
function oled_meas_OpeningFcn(hObject, eventdata, handles, varargin)
clc

% Settings para la conexión de los dispositivos con GPIB.
% Se escoge el puerto que se esté usando (Windows lo asigna automático).
global GPIB;
global Coeficientes;
Coeficientes=ones(2075,1);
GPIB = serial ( 'COM9' ) ; 

% Tipo de lectura (finalización de línea).
GPIB.Terminator = 'CR/LF' ;         

% Timeout (tiempo de chance para responder).
GPIB.Timeout = 0.5; 

% 'abrir' conexión GPIB.
fopen(GPIB);

% Funciones propias del prologix.
fprintf(GPIB, '++eos 0');           
fprintf(GPIB, '++auto 1');
fprintf(GPIB, '++eoi 1');

% Direcciones GPIB: ++addr 13 -> fuente de voltaje,
% ++addr 22 -> PM2525, ++addr 16 -> Keithley2000
% Opciones de arranque para la fuente
fprintf(GPIB, '++addr 13' );
fprintf(GPIB, ':INST:STAT ON' );
fprintf(GPIB, ':VOLT 0'); 


%--------------------------------------------------------------------------
%--------------------------------------------------------------------------
% Dispositivo USB, conexión serial, OWON XDM1041.
% Settings iniciales de conexión, windows asigna automático puerto COM.
% Solo funciona con este baudrate.
% Usar rate=Fast para que de mejor el resultado y 50 mA de rango.
global ow;
ow = serial('COM11', 'BaudRate', 115200, 'Terminator', 'CR');
ow.DataBits = 8;
ow.StopBits = 1;
%set(ow, 'Tag', 'multi');

% Tiempo de respuesta
set(ow, 'Timeout', 0.1);

% 'abrir' conexión serial
fopen(ow);

% Settings iniciales
fprintf(ow, 'RATE F');
fprintf(ow, 'CONF:CURR:DC AUTO');


%--------------------------------------------------------------------------
%--------------------------------------------------------------------------
% Dispositivo USB, conexión serial, bk precision 2831e, consultar manual.
% Settings iniciales de conexión, windows asigna automático puerto COM
global s;
s = serial('com10', 'BaudRate', 9600, 'Terminator', 'LF');
s.DataBits = 8;
s.Parity = 'even';
s.StopBits = 1;
set(s, 'Tag', 'multi');

%Tiempo de respuesta
set(s, 'Timeout', 1.5);

%'abrir' conexión serial
fopen(s);

%--------------------------------------------------------------------------
%--------------------------------------------------------------------------
% Configuración del espectrómetro.
global x1;
global norm_pot;
global norm;
global fondo1;
global waveLength;
global coeff;
global waveinterv;
global curva_fotopica;
global Long_min;
global Long_max;

coeff = 0.163;
fondo1 = zeros(3653,1);
x1 = textread('Y 2793.txt');                                                               
waveLength = x1(3:3655);
norm = x1(3656:7308);
norm_pot = x1(7310:10962);
norm_pot = transpose(norm_pot);                                                                       
norm_pot = double(norm_pot);
norm = transpose(norm);                                                                       
norm = double(norm);

waveinterv = [];
waveL = length(waveLength);

% Leer la curva de sensibilidad fotópica
C= readtable('curva_fotopica.xlsx');
curva_fotopica = C(:,2);
curva_fotopica = table2array(curva_fotopica);

% Estaablecer límites para las integrales.
Long_min = 3654-786;
Long_max = 3654-2860;

% Intervalos entre los valores de longitudes de onda.
for d=1:1:(waveL-1)
    waveinterv(d)= waveLength(d) - waveLength(d+1);
end     
waveinterv(waveL)=0.2;

%--------------------------------------------------------------------------
%--------------------------------------------------------------------------
% Output línea de comandos.
handles.output = hObject;

% Actualizar handles structure
guidata(hObject, handles);

%--------------------------------------------------------------------------
%--------------------------------------------------------------------------
% --- Outputs a la línea de comandos.
function varargout = oled_meas_OutputFcn(hObject, eventdata, handles) 
% Get default command line output from handles structure
varargout{1} = handles.output;

%--------------------------------------------------------------------------
%--------------------------------------------------------------------------
% ELEMENTOS GRÁFICOS Y CALLBACKS
%--------------------------------------------------------------------------
%--------------------------------------------------------------------------
% PANELES.
function paneL_jv_CreateFcn(hObject, eventdata, handles)
function panel_jlum_CreateFcn(hObject, eventdata, handles)

%--------------------------------------------------------------------------
%--------------------------------------------------------------------------
% Botones para cambiar de tab (oculta o muestra).
function button_tab1_Callback(hObject, eventdata, handles)
set(handles.paneL_jv,'visible','on');
set(handles.panel_jlum,'visible','off');
set(handles.spectra_panel,'visible','off');

function button_tab2_Callback(hObject, eventdata, handles)
set(handles.paneL_jv,'visible','off');
set(handles.panel_jlum,'visible','on');
set(handles.spectra_panel,'visible','off');

function button_tab3_Callback(hObject, eventdata, handles)
set(handles.paneL_jv,'visible','off');
set(handles.panel_jlum,'visible','off');
set(handles.spectra_panel,'visible','on');

%--------------------------------------------------------------------------
%--------------------------------------------------------------------------
function edit_volt_ini_Callback(hObject, eventdata, handles)

function edit_volt_ini_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), ...
        get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

%--------------------------------------------------------------------------
%--------------------------------------------------------------------------
function edit_volt_fin_Callback(hObject, eventdata, handles)

function edit_volt_fin_CreateFcn(hObject, eventdata, handles)

if ispc && isequal(get(hObject,'BackgroundColor'), ...
        get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

%--------------------------------------------------------------------------
%--------------------------------------------------------------------------
function edit_volt_step_Callback(hObject, eventdata, handles)

function edit_volt_step_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), ...
        get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

%--------------------------------------------------------------------------
%--------------------------------------------------------------------------
function edit_area_Callback(hObject, eventdata, handles)

function edit_area_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), ...
        get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

%--------------------------------------------------------------------------
%--------------------------------------------------------------------------
% establecer tiempo de exposicion(*100 para pasar a decenas de microsegundo)
function tiempo_Callback(hObject, eventdata, handles)
global numOfBlankScans;
global exposureTime;

numOfBlankScans=0;
exposureTime=get(hObject,'String');
exposureTime=str2double(exposureTime);
exposureTime=exposureTime*100;

%--------------------------------------------------------------------------
%--------------------------------------------------------------------------
function tiempo_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'),...
        get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

%--------------------------------------------------------------------------
%Definir la cantidad de mediciones de espectrómetro
%--------------------------------------------------------------------------
function promedios_Callback(hObject, eventdata, handles)
% crear n promedios según lo defina el usuario.
global numOfScans;

numOfScans=get(hObject,'String');
numOfScans=str2double(numOfScans);

%--------------------------------------------------------------------------
%--------------------------------------------------------------------------
function promedios_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'),...
        get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

%--------------------------------------------------------------------------
%--------------------------------------------------------------------------
%luminacia mínima para sacar espectro
function Lum_minim_Callback(hObject, eventdata, handles)
global luminancia_min;
luminancia_min = get(hObject,'String');
luminancia_min = str2double(luminancia_min);

function Lum_minim_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'),...
        get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

%--------------------------------------------------------------------------
%--------------------------------------------------------------------------
% --- Tomar fondo con el aseq.
function botonTomarFondo_Callback(hObject, eventdata, handles)
global fondo;
global waveLength;
global numOfScans;
global numOfBlankScans;
global exposureTime;
global norm;
fondo = getSpectraASEQ(numOfScans,numOfBlankScans,exposureTime);
fondo = double(fondo);
fondo = fondo./norm;

%--------------------------------------------------------------------------
%--------------------------------------------------------------------------
function botonTomarFondo_CreateFcn(hObject, eventdata, handles)

%--------------------------------------------------------------------------
%--------------------------------------------------------------------------
function Modos_Callback(hObject, eventdata, handles)

%--------------------------------------------------------------------------
%--------------------------------------------------------------------------
function modo_ivsv_Callback(hObject, eventdata, handles)
Modo_IvsV

%--------------------------------------------------------------------------
%--------------------------------------------------------------------------
function eficienciaButton_Callback(hObject, eventdata, handles)
EQE_ventana();

%--------------------------------------------------------------------------
%--------------------------------------------------------------------------
% Si se activa el checkbox, se quita el fondo.
function checkbox_quitarFondo_Callback(hObject, eventdata, handles)
global fondo;
global fondo1;
fondo1=fondo;

%--------------------------------------------------------------------------
%--------------------------------------------------------------------------
% --- Captura los datos para su posterior uso
function button_capturar_Callback(hObject, eventdata, handles)
global volt_ini;
global volt_fin;
global volt_step;
global area;

volt_ini = str2double(get(handles.edit_volt_ini,'String'));
volt_fin = str2double(get(handles.edit_volt_fin,'String'));
volt_step = str2double(get(handles.edit_volt_step,'String'));
area = str2double(get(handles.edit_area,'String'));

%--------------------------------------------------------------------------
%--------------------------------------------------------------------------
% --- Ejecuta el proceso principal del programa. (loop principal)
function button_ejecutar_Callback(hObject, eventdata, handles)
% Característica.
global volt_ini;
global volt_fin;
global volt_step;
global area;
global GPIB;
global ow;
global s;
global kill;
kill=0;

% Espectro.
global fondo;
global fondo1;
global waveLength;
global numOfScans;
global numOfBlankScans;
global exposureTime;
global intensidad;
global irradiancia;
global norm;
global norm_pot;
global coeff;
global waveinterv;
global nofondo;
global luminancia_min;
global irrad_total;

% magnitudes a calcular:
global volt_input;
global curr_input;
global lum_input; 

% valores EQE:
global coef_Integral;
global curva_fotopica;
global Long_min;
global Long_max;
global Np;
global Ne;
global EQE;
global Coeficientes;
global Espectros;
global it;
% Variables propias del bucle.
k = 0;
alfa_inicial = 10;
alfa = alfa_inicial;
statement1 = 0;
statement2 = 0;
statement3 = 0;
statement4 = 0;

% Se usan estas estructuras para graficar posteriormente.
volt_input = [];
curr_input = [];
lum_input = [];
irrad_total = [];
Espectros = [];
Np = [];
Ne = [];
EQE = [];

% Carga Placeholder para la gráfica.
% J vs V
axes(handles.axes1);

% Inicio del bucle.
%try
    for i = volt_ini: volt_step: volt_fin
        % Abortar programa.
        if kill>0
            pause(3);
            fprintf(GPIB, '++addr 13' );
            fprintf(GPIB, ':VOLT 0' );
            break
        else    
        end
        
        % Alimentación de voltaje.
        fprintf(GPIB,'++addr 13' );
        step = num2str(i);
        input = ':VOLT';
        fprintf(GPIB, strcat(input,32,step));
        pause(2.5);
        
        % Medida de corriente con OWON
        fprintf(ow, 'MEAS1?');
        meas_curr = fscanf(ow);
        meas_curr = str2num(meas_curr);
        meas_curr = meas_curr / area;
        
        % Medida de voltaje con Keithley 2000
        fprintf(GPIB,'++addr 16');
        fprintf(GPIB, ':MEAS:VOLT?');
        meas_volt = fgetl(GPIB);
        meas_volt = str2num(meas_volt);
        
        % Medida de voltaje de luminancia con BK precision 2831E
        fprintf(s,':FETC?');
        meas_vlux = fscanf(s);
        meas_vlux = str2num(meas_vlux);
        meas_int = meas_vlux * alfa;
        
        % Cambios de escala para el luxómetro.
%         switch meas_int
%             case meas_int > 1.99
%                 h = warndlg('Mover el luxómetro al nivel 2');
%                 pause(10);
%                 alfa = 100;
%                 fprintf(s,':FETC?');
%                 meas_vlux = fscanf(s);
%                 meas_vlux = str2num(meas_vlux);
%                 meas_int = meas_vlux * alfa;
%                 
%             case meas_int > 20
%                 h = warndlg('Mover el luxómetro al nivel 2');
%                 pause(10);
%                 alfa = 1000;
%                 fprintf(s,':FETC?');
%                 meas_vlux = fscanf(s);
%                 meas_vlux = str2num(meas_vlux);
%                 meas_int = meas_vlux * alfa;
%         end
        if meas_int > 1.99
            if statement1 == 0
                statement1 = 1;
                alfa = 100;
                h = warndlg('Mover el luxómetro al nivel 2');
                pause(10)
                fprintf(s,':FETC?');
                meas_vlux = fscanf(s);
                meas_vlux = str2num(meas_vlux);
                meas_int = meas_vlux * alfa;
            else
                perro = 1;
            end
        else
            perro = 1;
        end
        
        if meas_int > 20
            if statement2 == 0
                statement2 = 1;
                h = warndlg('Mover el luxómetro al nivel 3');
                pause(10)
                alfa = 1000;
                fprintf(s,':FETC?');
                meas_vlux = fscanf(s);
                meas_vlux = str2num(meas_vlux);
                meas_int = meas_vlux * alfa;
            else
                perro = 1;
            end
        else
            perro = 1;
        end
        
        if meas_int > 200
            if statement3 == 0
                statement3 = 1;
                h = warndlg('Mover el luxómetro al nivel 4');
                pause(10)
                alfa = 10000;
                fprintf(s,':FETC?');
                meas_vlux = fscanf(s);
                meas_vlux = str2num(meas_vlux);
                meas_int = meas_vlux * alfa;
            else
                perro=1;
            end
        else
            perro = 1;
        end
        
        if meas_int > 2000
            if statement4 == 0
                statement4 = 1;
                h = warndlg('Mover el luxómetro al nivel 5');
                pause(10)
                alfa=100000;
                fprintf(s,':FETC?');
                meas_vlux = fscanf(s);
                meas_vlux = str2num(meas_vlux);
                meas_int=meas_vlux*alfa;
            else
                perro=1;
            end
        else
            perro=1;
        end
        
        % Iterador para guardar dato en arreglo.
        k = k + 1;
        
        % Asignación dato por dato.
        volt_input(k) = meas_volt;
        curr_input(k) = meas_curr;
        
        %Calcular la luminancia, it est, 100
        % (factor por la geometria del tubo)
        %  multiplicado por meas_int (unidades fotométricas)
        lum_input(k)  = meas_int * 100;
        
        %---------------------------------------------------------
        %condicional:
        %---------------------------------------------------------
        set(handles.lum_actual,'String',lum_input(k));
        if lum_input(k) < luminancia_min
            
            % NO tomar espectro si la luminancia no supera al valor
            % mínimo
            % REVISAR VALOR ASIGNADO SI NO SE CUMPLE:
            intensidad = fondo1 - fondo1;
            irradiancia = intensidad;
            
            irrad_total(k) =- 500;
            set(handles.textRta,'String','nA')
        else
            % Para el espectrómetro
            intensidad = getSpectraASEQ(numOfScans,numOfBlankScans, ...
                exposureTime);
            
            % BUg: el programa se congelaba al quitar el fondo. Sol:
            % Transformar el espectro obtenido a double.
            intensidad = double(intensidad);
            intensidad = intensidad ./ norm;
            intensidad = intensidad - fondo1;
            
            % Calcular la irradiancia:
            % multiplicar por los coeficientes de irradiancia.
            % multiplicar por el tiempo de exposiciòn
            % el factor de 10^(7) es porque el programa lo pide en ms
            irradiancia = intensidad .* norm_pot;
            %irradiancia = coeff * (exposureTime / 10000000) * irradiancia;
            irradiancia = 1/(coeff *exposureTime) * irradiancia;
          
            % Calcular la potencia por área total ( espectro visible):
            % ACLARACIÓN:'irradiancia' es irradiancia espectral
            
            pot = irradiancia(891:2868);
            waveinterv2 = waveinterv(891:2868);
            waveinterv2 = transpose(waveinterv2);
            pot = pot .* waveinterv2;
            suma = sum(pot);
            irrad_total(k) = suma;
            set(handles.textRta,'String',suma);
            
            % Cálculo de la EQE
            % Primero se calcula la integral de la irradiancia multiplicada
            % por curva fotopica para encontrar A.
            waveintervalo = transpose(waveinterv);
            
            aux_array = irradiancia(Long_max:Long_min).* ...
                curva_fotopica(Long_max:Long_min);
            aux_array=Coeficientes.*aux_array;
            coef_Integral = aux_array.*waveintervalo(Long_max:Long_min); 
            sum_coef_Integral = sum(coef_Integral);
            AA = (lum_input(k) / sum_coef_Integral);
            %L_lambda = AA * aux_array;
            hc = 1.98644e-25; 
            normal_fotopica = 683; 
            integral_const = pi * AA / (normal_fotopica * hc);
            
            waveLe = transpose(waveLength);
            aux_np = irradiancia(Long_max:Long_min).*...
                waveLe(Long_max:Long_min)*1e-9;
            aux_np=aux_np.*Coeficientes;
            % FALTAN LOS COEFICIENTES DE CALIBRACIÒN!!!! (ESfera INT)
            np = aux_np.*waveintervalo(Long_max:Long_min);
            Np(k) = integral_const*sum(np);
            C_e = 1.60217*1e-19;
            Ne(k) = curr_input(k)*10000/ C_e;
            EQE(k) = Np(k) / Ne(k)*100;
            
            
            
        end
        %Espectros(k) = irradiancia(Long_max:Long_min);
        % Gráfica en 'tiempo real'.
        % En realidad se puede comunicar al handler con 'axes'
        % para graficar los datos deseados. Hay que tener en cuenta
        % el primer argumento de la función plot en este caso.
        % Graficar curva característica.
        axes(handles.axes1);
        plot(volt_input, curr_input, 'gs-');
        xlabel('Voltaje (Volts)');
        ylabel('Densidad de corriente (Amp / cm2)');
        title('Característica J vs V');
        grid on;
        
        % Graficar espectro (tiempo real)
        axes(handles.axes7);
        plot(waveLength, irradiancia);
        xlabel('Longitud de onda (nm)');
        ylabel('irradiancia (uW/cm2 nm)');
        title('espectro de medida final');
        grid on;
        
        % Graficar luminancia (tiempo real)
        axes(handles.axes8);
        plot(volt_input, lum_input, 'rs-');
        xlabel('Voltaje (Volts)');
        ylabel('luminancia (cd/m2)');
        title('luminancia vs V');
        drawnow; 
    end
    
    it=k;
    % Graficar LUEGO de terminar el proceso.
    % Luminancia.
    axes(handles.axes4);
    plot(lum_input, curr_input, 'rs-');
    xlabel('Voltaje Lum (Volts)');
    ylabel('Densidad de corriente (Amp / cm2)');
    title('Característica J vs VLum');
    grid on;
     
    % Espectro
    axes(handles.axes5);
    plot(waveLength, intensidad);
    xlabel('Longitud de onda (nm)');
    ylabel('intensidad (cuentas)');
    title('espectro de medida final');
     
    % Irradiancia absoluta:
    axes(handles.axes10);
    plot(waveLength, irradiancia);
    xlabel('Longitud de onda (nm)');
    ylabel('irradiancia (uW/cm^2 nm)');
    title('espectro de irradiancia de la medida final');
     
    %---------------------------------------------------------------------
    % TERMINA DE GRAFICAR 
    %---------------------------------------------------------------------
    % Resetear fuente de voltaje.
    fprintf(GPIB, '++addr 13' );
    fprintf(GPIB, ':VOLT 0' );
     
    % Finalización del bucle principal.
    meas_message = warndlg('Medición finalizada.');
%catch 
    %fclose(ow);
    %delete(ow);
    %fclose(s);
    %delete(s);
    %fclose(GPIB); 
    %delete(GPIB);
%end

%--------------------------------------------------------------------------
%--------------------------------------------------------------------------
function text15_CreateFcn(hObject, eventdata, handles)

%--------------------------------------------------------------------------
% Pestaña de GRÁFICAS
%--------------------------------------------------------------------------
function graficas_boton_Callback(hObject, eventdata, handles)
oled_Ventana1;

%--------------------------------------------------------------------------
%--------------------------------------------------------------------------
function Archivo_Callback(hObject, eventdata, handles)

%--------------------------------------------------------------------------
% Pestaña de GUARDADO
%--------------------------------------------------------------------------
function exportar_datos_Callback(hObject, eventdata, handles)
guardado;

%--------------------------------------------------------------------------
% Botón 'ABORTAR'
%--------------------------------------------------------------------------
function boton_kill_Callback(hObject, eventdata, handles)
global kill;
pause(1);
kill=1;

%--------------------------------------------------------------------------
% Botón 'SALIR'
%--------------------------------------------------------------------------
% --- Cierra el programa.
function button_term_Callback(hObject, eventdata, handles)
clc;
global GPIB;
global ow;
global s;
global kill;
fclose(ow);
delete(ow);
fclose(s);
delete(s);
fclose(GPIB); 
delete(GPIB);
closereq();


% --- Executes during object creation, after setting all properties.
function textRta_CreateFcn(hObject, eventdata, handles)
% hObject    handle to textRta (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called


% --- If Enable == 'on', executes on mouse press in 5 pixel border.
% --- Otherwise, executes on mouse press in 5 pixel border or over textRta.
function textRta_ButtonDownFcn(hObject, eventdata, handles)
% hObject    handle to textRta (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes during object deletion, before destroying properties.
function textRta_DeleteFcn(hObject, eventdata, handles)
% hObject    handle to textRta (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes during object creation, after setting all properties.
function lum_actual_CreateFcn(hObject, eventdata, handles)
% hObject    handle to lum_actual (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called


% --- Executes during object creation, after setting all properties.
function axes10_CreateFcn(hObject, eventdata, handles)
% hObject    handle to axes10 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: place code in OpeningFcn to populate axes10


% --------------------------------------------------------------------
function Calibracion_menu_Callback(hObject, eventdata, handles)
Calibracion;
% hObject    handle to Calibracion_menu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --------------------------------------------------------------------
function Coeff_activar_Callback(hObject, eventdata, handles)
global Co;
global Coeficientes;
Co= readtable('coeficientes_calibracion.xlsx');
Coeficientes = Co(:,1);
Coeficientes = table2array(Coeficientes);
Coeficientes = double(Coeficientes);
% hObject    handle to Coeff_activar (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

