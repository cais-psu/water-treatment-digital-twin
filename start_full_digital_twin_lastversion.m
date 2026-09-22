%% Water treatment digital twin startup
% Open the ProtoTwin file "the best 6" before running this script.
% Keep the motor driver OFF while everything is connecting.
%
% Current setup:
% City Return Pump -> physical Pump 1
% Pump 2           -> physical Pump 2
% Valve 1-4        -> physical Valve 1-4

clc
disp("Starting water treatment digital twin...")

% Clear old connections in case the script was already used before
clear mq esp cbPump1 cbPump2 cbValve1 cbValve2 cbValve3 cbValve4


%% MQTT / Mosquitto

brokerAddress = "tcp://127.0.0.1";
brokerPort = 1884;

mosquittoExe = '"C:\Program Files\mosquitto\mosquitto.exe"';
mosquittoConfig = '"C:\Users\lph5581\Documents\mosquitto.conf"';

disp("Checking Mosquitto...")

try
    mq = mqttclient(brokerAddress, Port=brokerPort);

    if mq.Connected
        disp("Mosquitto is already running.")
    end

catch
    disp("Mosquitto is not running, starting it now...")

    command = sprintf( ...
        'start "" /MIN %s -c %s', ...
        mosquittoExe, ...
        mosquittoConfig);

    system(command);
    pause(2);

    mq = mqttclient(brokerAddress, Port=brokerPort);
end

if ~mq.Connected
    error("Could not connect MATLAB to Mosquitto on port 1884.")
end

disp("MQTT connected.")


%% ESP32 connection

ports = serialportlist("available");

if isempty(ports)
    error("No serial ports found. Check the ESP32 USB connection.")
end

disp("Available serial ports:")
disp(ports)

% COM5 is the ESP32 in the current setup
preferredPort = "COM5";

if any(ports == preferredPort)

    espPort = preferredPort;

else

    % Ignore COM1 if another port is available
    candidates = ports(ports ~= "COM1");

    if numel(candidates) == 1
        espPort = candidates(1);
        warning("COM5 was not found. Using %s instead.", espPort)
    else
        error("Could not identify the ESP32. Check serialportlist(""all"").")
    end

end

esp = serialport(espPort,115200);
flush(esp);

disp("ESP32 connected on " + espPort)


%% Pump speeds

% Speeds currently used on the testbed
pump1Speed = 150;
pump2Speed = 150;

writeline(esp,"SET_SLIDER1 " + string(pump1Speed));
pause(0.15)

writeline(esp,"SET_SLIDER2 " + string(pump2Speed));
pause(0.15)

flush(esp);


%% Start everything OFF

% Pumps
writeline(esp,"SET_PUMP1 0");
writeline(esp,"SET_PUMP2 0");

% Valves
writeline(esp,"SET_VALVE1 0");
writeline(esp,"SET_VALVE2 0");
writeline(esp,"SET_VALVE3 0");
writeline(esp,"SET_VALVE4 0");

pause(0.2)
flush(esp);

disp("Pumps and valves initialized OFF.")


%% MQTT callbacks

% ProtoTwin sends true/false.
% MATLAB changes that to 1/0 for the ESP32.

cbPump1 = @(topic,data) writeline(esp, ...
    sprintf("SET_PUMP1 %d", strcmpi(strtrim(char(data)),'true')));

cbPump2 = @(topic,data) writeline(esp, ...
    sprintf("SET_PUMP2 %d", strcmpi(strtrim(char(data)),'true')));

cbValve1 = @(topic,data) writeline(esp, ...
    sprintf("SET_VALVE1 %d", strcmpi(strtrim(char(data)),'true')));

cbValve2 = @(topic,data) writeline(esp, ...
    sprintf("SET_VALVE2 %d", strcmpi(strtrim(char(data)),'true')));

cbValve3 = @(topic,data) writeline(esp, ...
    sprintf("SET_VALVE3 %d", strcmpi(strtrim(char(data)),'true')));

cbValve4 = @(topic,data) writeline(esp, ...
    sprintf("SET_VALVE4 %d", strcmpi(strtrim(char(data)),'true')));


%% Subscribe to ProtoTwin controls

subscribe(mq,"water/city_return",Callback=cbPump1);
subscribe(mq,"water/pump2",Callback=cbPump2);

subscribe(mq,"water/valve1",Callback=cbValve1);
subscribe(mq,"water/valve2",Callback=cbValve2);
subscribe(mq,"water/valve3",Callback=cbValve3);
subscribe(mq,"water/valve4",Callback=cbValve4);


%% Ready

disp(" ")
disp("System ready.")
disp("Put ProtoTwin Connect in PLAY mode.")
disp("Make sure all controls are OFF before turning the motor driver ON.")
disp(" ")
disp("Pump 1 speed: " + pump1Speed)
disp("Pump 2 speed: " + pump2Speed)
disp(" ")
disp("Do not clear mq or esp while the system is running.")
