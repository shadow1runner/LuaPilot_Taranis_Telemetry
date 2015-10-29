# Readme
This Script LuaPilot is a nice Telemetry screen for Taranis with openTx >2.1 and should work with Arducopter (Pixhawk, Fixhawk, AUAV-X2, etc.) and maybe others Flight controllers which are connected to an FrSky D-Receiver & X-Receiver.

It base on the greats and beautiful works from SockEye, Richardoe, Schicksie, lichtl, Jace25 (FPV-Community) and Improve and extended from my (HVlipo and add 5s,6s,8s,10s,12s Battery cell compatibility , Battery consume, Vspeed, GPS Speed, Hdg, efficiency Calc, Background Task, flexible Configs and Error Handling)

Let’s improve it together and have one nice all in one Taranis Telemetry Script, made Pull Requests and if you have an issue please report it :)

This is Version 1 for the next Version 2 it’s planned to add more Screens, more Flight Controllers and a GPS/Compass "Radar" screen.

## Screenshots




![Displayed content while in GPS controlled mode](https://raw.githubusercontent.com/ilihack/LuaPilot_Taranis_Telemetry/master/LuaPilot.jpg)

Displayed content while in GPS controlled mode

#Installing:
## Flight controller D-port Setup
1. Connect the Arducopter with a RS232 TTL level converter (not need to be a FrSky, a cheaper one from EBay also works fine (watch for correct specifications)) and connect RS232 TTL level converter with your FrSky Receiver
2. Activate the FrSky D protocol in the parameters for the appropriate port. baute rate 9kbs

## Flight controller S-port Setup (if Arducopter then only > V3.3)
1. Connect the Pixhawk with a RS232 TTL level converter (not need to be a FrSky, a cheaper one from EBay (MAX3232CSE also works fine & is easy to solder) and connect RS232 TTL level converter with your FrSky Receiver
2. Buy the FrSky spc cable, but its only one normal diode and you can soldering the diode direct to the RS 232 TTL converter like https://goo.gl/y9XCq8 and doesn’t need the SPC Adapter
3. Activate the FrSky S protocol in the parameters for the appropriate port. baute rate: 57kbs



## Taranis Setup OpenTx 2.1.3 or newer
1. Make sure you have LUA-Scripting enabled in companion
2. Download the scripts folder from here and copy to the SD card root
3. Start your Taranis, go into your desired Model Settings by short pressing the Menu button
4. Navigate to the last Page by long pressing the page button
5. Delete all Sensors
6. Discovery new Sensors
7. There will be a lot of sensors listed depending on your receiver (d8r, d4r, x8r etc.)
8. Very Recommend is to Check if the sensors Named correct especially the two Temp and using without Arducopter, so the lua script can make use of them and not from the Arducopter Fallback IDs. Naming is case sensitive!
9. Set this lua script as Telemetry screen.

### Sensor Namens
* VFAS -> Lipo Voltage
* Alt -> Altitude
* Curr -> Current drain
* Gspd -> GPS Speed
* Hdg -> Compass Direction
* Temp -> Flight mode
* Tem1 -> GPS Fix (something like 103 for 10 satellites’ and 3d fix or 93 for 9 satellites’ and 3d fix are mostly the second    of the two Temp and must be renamed to Tem1)
* RSSI -> Rssi Value

##useful links
1. http://copter.ardupilot.com/wiki/common-optional-hardware/common-telemetry-landingpage/common-frsky-telemetry/ (How to connect your Converter)

##LuaPilot Script Dowload
https://github.com/ilihack/LuaPilot_Taranis_Telemetry/archive/master.zip

