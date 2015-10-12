# Readme
This Script should work with every Pixhawk (Pixhawk, Fixhawk, AUAV-X2, etc.) which
is connected to a FrSky D-Receiver (D4R, D8R,X4r and maybe more)

It displays the voltage, current and total comsumption, beside the altitude and distance from home below the currently used flightmode and 3D Fix informations.
Also RSSI is displayed on the left side. All values are based on converted mavlink Data.
## Screenshots
![Displayed content while in user controlled mode]
(https://raw.githubusercontent.com/Jace25/LUA-Taranis-Pixhawk/master/lua1.JPG)
Displayed content while in user controlled mode
![Displayed content while in GPS controlled mode]
(https://raw.githubusercontent.com/Jace25/LUA-Taranis-Pixhawk/master/lua2.JPG)
Displayed content while in GPS controlled mode

## Flightcontroller D port Setup
1. Connect the Pixhawk with a RS232 TTL level converter (not need to be a FrSky, a cheaper one from Ebay also works fine (watch for correct specifications)) and connect RS232 TTL level converter with your Frysky Receiver
2. Activate the FrSky D protocol in the parameters for the appropriate port

## Flightcontroller S port Setup
1. Connect the Pixhawk with a RS232 TTL level converter (not need to be a FrSky, a cheaper one from Ebay also works fine (watch for correct specifications)) and connect RS232 TTL level converter with your Frysky Receiver
2. Buy the frsky spc cable, but its only one normal diode and you can soldering the diode direct to the RS 232 TTL converter and dosnt need the spc adapter
3. Activate the FrSky S protocol in the parameters for the appropriate port


## Taranis Setup OpenTx 2.1.2 or newer
1. Make sure you have LUA-Scripting enabled in companion
2. Download the scripts folder from here and copy to the sd card root
3. Start your Taranis, go into your desired Model Settings by shortpressing the Menu button
4. Navigate to the last Page by long pressing the page button
5. Discovery new Sensors
6. There will be a lot of sensors listed depending on your receiver (d8r, d4r, x8r etc)
7. Now its your turn to name the sensors right if they dont automatic right especially Temp, so the lua script can make use of them. Naming is casesensitive!
8. Set this lua script as Telemety screen.

### Sensor Setup
* VFAS -> Lipo Voltage
* Alt -> Altitude
* Curr -> Current drain
* Tem1 -> This sensor was found as Temp besides another sensor named temp. The sensor, which sends the flightmode data has to be named to Tem1
* Temp -> GPS Fix (something like 103 for 10 satelites and 3d fix or 93 for 9 satelites and 3d fix)
* RSSI -> Rssi Value


##useful links
1. http://copter.ardupilot.com/wiki/common-optional-hardware/common-telemetry-landingpage/common-frsky-telemetry/ (How to connect your Converter)
2. http://fpv-community.de/showthread.php?63147-Telemetriedaten-vom-AUAV-X2-mit-D4R-II (How to connect a AUAV-X2 or Pixhawk with a D4R-II)
3. http://fpv-community.de/showthread.php?57636-Naze32-amp-FRSky-D4R-II-Telemetrie-LUA-Script (My Script gets its fancy graphics from this script)
