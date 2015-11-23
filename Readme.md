# Readme
This Script LuaPilot is a nice Telemetry screen for Taranis with openTx >2.16 and should work with Arducopter (Pixhawk, Fixhawk, AUAV-X2, etc.) and maybe others Flight controllers which are connected to an FrSky D-Receiver & X-Receiver.

Thank's to SockEye, Richardoe, Schicksie, lichtl, ben_&Jace25,Clooney82&fnoopdogg for they Previos Work.


Changlog:

V2:
Performance & less Memory Consum, Better Hdg, Distance, Battery Percent Calculation with capacity, Resistance Calc & Voltage Compensation, better Battery Regresion Curve , Audio Alerts for BattVoltage,Consume,Flightmode,Max Avarage Current & GPS State

V1:
Battery Consume, Vspeed, GPS Speed, Hdg, efficiency Calc, Background Task, flexible Configs. 

Let’s improve it together and have one nice all in one Taranis Telemetry Script, made Pull Requests or if you have an issue please report it :)

This is Version 2 for the next Version 3 it’s planned to add more Screens, more Flight Controllers and a GPS/Compass "Radar" screen. 

## Screenshots

![Welcome Screen](https://raw.githubusercontent.com/ilihack/LuaPilot_Taranis_Telemetry/master/LuaPilot.Logo.jpg)


![Displayed content while in GPS controlled mode](https://raw.githubusercontent.com/ilihack/LuaPilot_Taranis_Telemetry/master/LuaPilot.jpg)

Displayed content while in GPS controlled mode

#Installing:
## Flight controller D-port Setup (only for D-Reciver)
1. Connect the Arducopter with a RS232 TTL level converter (not need to be a FrSky, a cheaper one from EBay also works fine (watch for correct specifications)) and connect RS232 TTL level converter with your FrSky Receiver
2. Activate the FrSky D protocol in the parameters for the appropriate port. baute rate 9kbs

## Flight controller S-port Setup (X-Reciver with Arducopter V3.3)
1. Connect the Pixhawk with a RS232 TTL level converter (not need to be a FrSky, a cheaper one from EBay (MAX3232CSE also works fine & is better to solder) and connect RS232 TTL level converter with your FrSky Receiver
2. Buy the FrSky spc cable, but its only one normal diode and you can soldering the diode direct to the RS 232 TTL converter like https://goo.gl/y9XCq8 and doesn’t need the SPC Adapter
3. Activate the FrSky S protocol in the parameters* for the appropriate port. baute rate: 57kbs *(APMPlaner2)



## Taranis Setup OpenTx 2.1.3 or newer
1. Make sure you have LUA-Scripting enabled in companion
2. Download the scripts folder from here and copy to the SD card root
3. Optional: Edit with an txt Editor the Dowloaded Script to Change the Setup to you own Wishes
3. Start your Taranis, go into your desired Model Settings by short pressing the Menu button
4. Navigate to the last Page by long pressing the page button
5. Delete all Sensors
6. Discovery new Sensors
7. There will be a lot of sensors listed depending on your receiver (d8r, d4r, x8r etc.)
8. Very Recommend is to Check if the sensors Named correct especially the two Temp must be renamed so the script can make use of them. Naming is case sensitive! 
9. Set this lua script as Telemetry screen.

### Sensor Namens
* VFAS -> Lipo Voltage
* Alt -> Altitude
* Curr -> Current drain
* Gspd -> GPS Speed
* Hdg -> Compass Direction
* Tmp1 -> Flight mode (small Numbers)
* Tmp2 -> GPS Fix (something like 103 for 10 satellites’ and 3d fix or 93 for 9 satellites’ and 3d fix)
* RSSI -> Rssi Value


### Using:

Push in the Normal Taranis Screen Long The Page Button to see the LuaPilot Telemetry screens.

If you want to Reset LuaPilot because you have a new HomePosition or Reset you Battery Consumm or what else Push long Menu in LuaPilot.

##useful links
1. http://copter.ardupilot.com/wiki/common-optional-hardware/common-telemetry-landingpage/common-frsky-telemetry/ (How to connect your Converter)

##LuaPilot Script Dowload
https://github.com/ilihack/LuaPilot_Taranis_Telemetry/archive/master.zip
