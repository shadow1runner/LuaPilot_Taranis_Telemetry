# Readme
This Script LuaPilot is a nice Telemetry screen for Taranis I want you to presentat my Script LuaPilot it is a nice Telemetry screen script  for Taranis and should work with Arducopter (Pixhawk, Fixhawk, AUAV-X2, etc.) and maybe others Flightcontrollers which are connected to a FrSky D-Receiver & X-Receiver.

It base on the greats and beautiful works from SockEye, Richardoe, Schicksie, lichtl, Jace25 (FPV-Community) and Improve and extended from my (HVlipo and add 5s,6s,8s,10s,12s Batterycell compatibilityt , Batteryconsum, Vspeed, Gps Speed, Hdg, efficiency Calc, Backround Task, flexible Configs and Error Handling)

Lets improve it together and have one nice all in one Taranis Telemtry Script , made Pull Requests and if you have an issue please report it :)

This is Version 1 for the next Version 2 its planed to add more Screens,more FlightControllers and a Gps/Compass "Radar" screen.

## Old Screenshots
![Displayed content while in user controlled mode](https://raw.githubusercontent.com/Jace25/LUA-Taranis-Pixhawk/master/lua1.JPG)

Displayed content while in user controlled mode



![Displayed content while in GPS controlled mode](https://raw.githubusercontent.com/Jace25/LUA-Taranis-Pixhawk/master/lua2.JPG)

Displayed content while in GPS controlled mode

#Installing:
## Flightcontroller D-port Setup
1. Connect the arducopter with a RS232 TTL level converter (not need to be a FrSky, a cheaper one from Ebay also works fine (watch for correct specifications)) and connect RS232 TTL level converter with your Frysky Receiver
2. Activate the FrSky D protocol in the parameters for the appropriate port. baute rate 9kbs

## Flightcontroller S-port Setup (if Arducopter then only > V3.3)
1. Connect the Pixhawk with a RS232 TTL level converter (not need to be a FrSky, a cheaper one from Ebay (MAX3232CSE also works fine & is easy to solder) and connect RS232 TTL level converter with your Frysky Receiver
2. Buy the frsky spc cable, but its only one normal diode and you can soldering the diode direct to the RS 232 TTL converter and dosnt need the SPC Adapter
3. Activate the FrSky S protocol in the parameters for the appropriate port. baute rate: 57kbs

## Taranis Setup OpenTx 2.1.3 or newer
1. Make sure you have LUA-Scripting enabled in companion
2. Download the scripts folder from here and copy to the sd card root
3. Start your Taranis, go into your desired Model Settings by shortpressing the Menu button
4. Navigate to the last Page by long pressing the page button
5. Delete all Sensors
6. Discovery new Sensors
7. There will be a lot of sensors listed depending on your receiver (d8r, d4r, x8r etc)
8. Very Recommed is to Check if the sensors Named correct especially the two Temp and using withoud Arducopter, so the lua script can make use of them and not from the arducopter Fallback IDs. Naming is casesensitive!
9. Set this lua script as Telemety screen.

### Sensor Names
* VFAS -> Lipo Voltage
* Alt -> Altitude
* Curr -> Current drain
* Gspd -> GPS Speed
* Hdg -> Compass Direction
* Temp -> Flightmode
* Tem1 -> GPS Fix (something like 103 for 10 satelites and 3d fix or 93 for 9 satelites and 3d fix are mostly the second of the two Temp and must be renamed to Tem1)
* RSSI -> Rssi Value

##useful links
1. http://copter.ardupilot.com/wiki/common-optional-hardware/common-telemetry-landingpage/common-frsky-telemetry/ (How to connect your Converter)
