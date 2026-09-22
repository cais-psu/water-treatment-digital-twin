# Water Treatment Digital Twin

This repository contains the current version of the water treatment digital twin project developed with ProtoTwin, MATLAB, MQTT, and ESP32.

The current setup focuses on interactive control between the ProtoTwin model and the physical water treatment testbed.

## Current System

`ProtoTwin -> MQTT -> MATLAB -> ESP32 -> Physical Testbed`

Connected and tested actuators:
- Pump 1
- Pump 2
- Valve 1
- Valve 2
- Valve 3
- Valve 4

The water-level sensor integration is still in progress because the Arduino/sensor system is being updated.

## Files

- `the best 6.ptm` - Current ProtoTwin model.
- `start_full_digital_twin_lastversion` - MATLAB startup and communication script.
- `README.md` - Project setup and startup instructions.

## Startup

1. Open `the best 6.ptm`.
2. Keep the physical motor driver OFF.
3. Open MATLAB.
4. Run `start_full_digital_twin_lastversion.m`.
5. Wait until MATLAB confirms that MQTT and the ESP32 are connected and the system is ready.
6. Open ProtoTwin Connect and put the model in PLAY mode.
7. Confirm that all pump and valve controls are OFF / FALSE.
8. Turn the physical motor driver ON.
9. Use the ProtoTwin controls to operate the physical system.

## MQTT Setup

Local Mosquitto broker:
- Host: `127.0.0.1`
- Port: `1884`

The MATLAB script checks if Mosquitto is running and starts it automatically if needed.

Current topics:
- `water/city_return` -> physical Pump 1
- `water/pump2` -> physical Pump 2
- `water/valve1` -> physical Valve 1
- `water/valve2` -> physical Valve 2
- `water/valve3` -> physical Valve 3
- `water/valve4` -> physical Valve 4

## MATLAB

The MATLAB script:
- Starts Mosquitto automatically if needed.
- Connects to the local MQTT broker.
- Detects and connects to the ESP32.
- Sets Pump 1 and Pump 2 speed to 150.
- Initializes both pumps and all four valves OFF.
- Subscribes to all ProtoTwin actuator topics.
- Converts MQTT `true/false` commands into ESP32 `1/0` commands.

## Current Status

### Working
- ProtoTwin water treatment model
- MQTT communication through Mosquitto
- MATLAB-to-ESP32 serial communication
- ProtoTwin control of Pump 1 and Pump 2
- ProtoTwin control of Valves 1-4
- Automatic Mosquitto startup from MATLAB

### In Progress
- Water-level sensor connection back into ProtoTwin
- Arduino / sensor architecture update
- Real-time monitoring from the physical testbed to the digital model

## Notes

- Keep the motor driver OFF while starting the system.
- Make sure all ProtoTwin actuator controls are OFF before turning the motor driver ON.
- Do not clear the MATLAB variables `mq` or `esp` while the system is running.
- Do not run the pumps dry.
