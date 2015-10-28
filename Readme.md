# Readme
This Script LuaPilot should work with Arducopter (Pixhawk, Fixhawk, AUAV-X2, etc.) which
is connected to a FrSky D-Receiver & X-Receiver.

It displays the Voltage, Batterylevel, Rssi in %, current and total comsumption, altitude, GPS Speed and in Future the distance from home, the currently used flightmode and GPS infos like 3D Fix, DGPS... also the Calculate Vertical Speed and the Flight efficiency.

it base on the greats and Beautiful works from SockEye, Richardoe, Schicksie, lichtl  for the Naza flightcontroller convertet to Arducopter & openTx 2.1 and Modified by Jace25 (FPV-Community) and Improve from my ilihack (more than 4s Battery, HVlipo, Batteryconsum, Vspeed, Gps Speed, Hdg, efficiency Calc and Code Improvments like Backround Task, flexible Configs and Error Handling.

Lets improve togheter it and made Folks&Pull requests or if you have an issues zell it me please.


## Old Screenshots
![Displayed content while in user controlled mode](https://raw.githubusercontent.com/Jace25/LUA-Taranis-Pixhawk/master/lua1.JPG)

Displayed content while in user controlled mode



![Displayed content while in GPS controlled mode](https://raw.githubusercontent.com/Jace25/LUA-Taranis-Pixhawk/master/lua2.JPG)

Displayed content while in GPS controlled mode

## Flightcontroller D-port Setup
1. Connect the Pixhawk with a RS232 TTL level converter (not need to be a FrSky, a cheaper one from Ebay also works fine (watch for correct specifications)) and connect RS232 TTL level converter with your Frysky Receiver
2. Activate the FrSky D protocol in the parameters for the appropriate port. baute rate 9kbs

## Flightcontroller S-port Setup (Arducopter > V3.3)
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
8. Very Recommed is to Check if the sensors Named correct  especially the two Temp, so the lua script can make use of them and not from the Fallback IDs. Naming is casesensitive!
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


