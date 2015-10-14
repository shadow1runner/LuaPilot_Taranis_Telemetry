-- ###############################################################
-- #                                                             #
-- #       Telemetry Lua Script APM/Pixhawk, Version 1.5.0       #
-- #                                                             #
-- #  + only with opentx2.12 and above                           #
-- #    tested with D4r-II & D8R & x4R                           #
-- #  + works with Pixhawk and AUAV-X2                           #
-- #                                                             #
-- #  License (Script & images): Share alike                     #
-- #  Can be used and changed non commercial, OWN RISK           #
-- #                                                             #
-- #  Inspired by SockEye, Richardoe, Schicksie, lichtl          #                                                       
-- #  modified by: Jace25 FPV-Community & ilihack             #
-- #                                                             #
-- ###############################################################
-- #  Config:                                                    #
     local cellLowVolt = 3.3  --Cell Empety Voltage             #
     local cellHightVolt = 4.2 --Cell Full Voltage              #
     local TimeOrVSpeed = 1      --draw Timer? 0 or Ver.Speed 1 #
-- #                                                             #
-- ###############################################################
  
  local function getTelemetryId(name)
      field = getFieldInfo(name)
      if getFieldInfo(name) then return field.id end
    return -1
  end


  
  local NextTimeRuntime = getTime() --Vspeed calc
  local NextTime2Runtime = getTime() --BatteryComsum calc
  local prevAlt = 0.0
  local verticalSpeed = 0
  local totalbatteryComsum = 0
  
  local battsumid =    getTelemetryId("VFAS")
 	local altid =        getTelemetryId("Alt")
	local spdid =        getTelemetryId("Gspd")
	local currentid =    getTelemetryId("Curr")
	local flightmodeId = getTelemetryId("Tem1")
	local rssiId =       getTelemetryId("RSSI")
	local gpsid =        getTelemetryId("Temp")
	local headingid =    getTelemetryId("Hdg")


local function run(event)
  
    lcd.clear()

-- ###############################################################
-- Lipo Range Calculate and Drawing
-- ###############################################################
--  
    local battype = 0             
    local battpercent = 0
    
    local batt_sum =  getValue(battsumid)

    if batt_sum>2.5 and batt_sum<cellHightVolt*12  then --ifbetween 2.5 volt and 50,4 volt 12s than calc the typ of the battery 
        battype=math.ceil(batt_sum/(cellHightVolt+0.05))
    end
     
    local lowvoltage   =    battype*cellLowVolt
    local hightvoltage =    battype*cellHightVolt
    local rangevoltage =    hightvoltage-lowvoltage 
       
    battpercent = (batt_sum-lowvoltage)*(100/(rangevoltage))
   

    local myPxHeight = math.floor(battpercent * 0.37) --draw level
    local myPxY = 11 + 37 - myPxHeight

    lcd.drawPixmap(3, 2, "/SCRIPTS/BMP/battery.bmp")

    if battpercent > 0 then
        lcd.drawFilledRectangle(8, myPxY, 21, myPxHeight, FILL_WHITE )
    end

    local i = 36
    while (i > 0) do 
    lcd.drawLine(8, 11 + i, 27, 11 +i, SOLID, GREY_DEFAULT)
    i= i-2
    end
    
--    if 1 then
--        lcd.drawNumber(15,25, battpercent ,SMLSIZE)
--        lcd.drawText(lcd.getLastPos(), 35, "%", SMLSIZE)
--    end
   

    if (battpercent < 15) then
        lcd.drawNumber(4,57, batt_sum ,PREC2 + LEFT + BLINK)
    else
        lcd.drawNumber(4,57, batt_sum ,PREC2 + LEFT)
    end
    
    lcd.drawText(lcd.getLastPos(), 57, "V ", 0)
    lcd.drawText(lcd.getLastPos(), 58, getValue(battype) , SMLSIZE)
    lcd.drawText(lcd.getLastPos(), 58,"s", SMLSIZE)



-- ###############################################################
-- Timer 
-- ###############################################################
   
    if TimeOrVSpeed == 0 then 
        local timer = model.getTimer(0)
        lcd.drawText(38, 45, "Timer: ",SMLSIZE, 0)
        lcd.drawTimer(lcd.getLastPos(), 41, timer.value, MIDSIZE)
    
    
-- ###############################################################
-- Vertical Speed
-- ###############################################################
  else --TimerOrSVpeed is 1
    
      if getTime() >= NextTimeRuntime then
        NextTimeRuntime = NextTimeRuntime + 100 --last time + one sec
        verticalSpeed=getValue(altid)-prevAlt
        prevAlt=getValue(altid)
      end
      
      lcd.drawText(38,45, "Vspeed: ",SMLSIZE)
      lcd.drawText(lcd.getLastPos(), 41, verticalSpeed, MIDSIZE)
     
      lcd.drawText(lcd.getLastPos(), 45, 'm/s', 0)
    
  end
--  
-- ###############################################################
-- Speed
-- ###############################################################

      lcd.drawText(40,29, "Speed : ",SMLSIZE,0)
      lcd.drawText(lcd.getLastPos(), 25, getValue(spdid), MIDSIZE)
      lcd.drawText(lcd.getLastPos(), 29, 'kmh', 0)
        
     
-- ###############################################################
-- Altitude
-- ###############################################################
    
   lcd.drawText(114,45, "Alt: ",SMLSIZE,0)
   lcd.drawText(lcd.getLastPos(), 43, getValue(altid), MIDSIZE)
   lcd.drawText(lcd.getLastPos(), 45, 'm', 0)
    

-- ###############################################################
-- Distance TODO above rssi whenn gps telemetry working
-- ###############################################################
   
-- ###############################################################
-- Heading temp above rssi
-- ###############################################################

  lcd.drawText(170,0, "Hdg: ",SMLSIZE)
  lcd.drawText(lcd.getLastPos(), 0, getValue(headingid), SMLSIZE)
  lcd.drawText(lcd.getLastPos(), -2, 'o', SMLSIZE)  
   
   
-- ###############################################################
-- CurrentTotal Calc Consum function
-- ###############################################################

   function batteryusedcalc()
      if getTime() >= NextTime2Runtime then --go to this event ~every 200 ms maybe must improve timehandling
        NextTime2Runtime = NextTime2Runtime + 20 -- 20 are 200 ms
        totalbatteryComsum = totalbatteryComsum + (getValue(currentid)/3600*5) --3600*5 because we calc 5hz and divide it with 3600 sec (1h)
      end
   end
    

-- ###############################################################
-- CurrentTotal Draw Consum
-- ###############################################################
        
	batteryusedcalc()
    lcd.drawText(48, 58, "Used: ",SMLSIZE)
    lcd.drawText(lcd.getLastPos(), 58, totalbatteryComsum, SMLSIZE)
    lcd.drawText(lcd.getLastPos(), 58, 'mAh', SMLSIZE)
      
  
-- ###############################################################
-- efficient 
-- ###############################################################
   
   local speed = getValue(spdid)
  
  if speed > 2 then --draw wh per km
     local efficientPerKM = getValue(currentid)*getValue(battsumid)/speed --spdint can not be 0 because the previus if
     lcd.drawText(98, 58, "  effiz: ",SMLSIZE)
     lcd.drawText(lcd.getLastPos(), 58, efficientPerKM, SMLSIZE)
     lcd.drawText(lcd.getLastPos(), 58, 'Wh/km', SMLSIZE)  
   end
   
   if speed < 2 then --draw wh per h
     
     local efficientPerH = getValue(currentid)*getValue(battsumid)
     lcd.drawText(103, 58, "  cons: ",SMLSIZE)
     lcd.drawText(lcd.getLastPos(), 58, efficientPerH, SMLSIZE)
     lcd.drawText(lcd.getLastPos(), 58, 'W', SMLSIZE)  
   end

-- ###############################################################
-- Current
-- ###############################################################

    lcd.drawText(113, 29, "Cur: ",SMLSIZE)
    lcd.drawText(lcd.getLastPos(), 25, getValue(currentid),MIDSIZE)
    lcd.drawText(lcd.getLastPos(), 29, 'A', 0)
    

-- ###############################################################
-- Flightmodes for copter toto for plane
-- ###############################################################

    local FlightMode = {}
    local i

    for i=1, 17 do
        FlightMode[i] = {}
        FlightMode[i].Name=""
    end

    FlightMode[1].Name="Stabilize"
    FlightMode[2].Name="Acro"
    FlightMode[3].Name="Alt Hold"
    FlightMode[4].Name="Auto"
    FlightMode[5].Name="Guided"
    FlightMode[6].Name="Loiter"
    FlightMode[7].Name="RTL"
    FlightMode[8].Name="Circle"
    FlightMode[9].Name="Invalid Mode"
    FlightMode[10].Name="Land"
    FlightMode[11].Name="Optical Loiter"
    FlightMode[12].Name="Drift"
    FlightMode[13].Name="Invalid Mode"
    FlightMode[14].Name="Sport"
    FlightMode[15].Name="Flip Mode"
    FlightMode[16].Name="Auto Tune"
    FlightMode[17].Name="Pos Hold"
    
    
    local flightModeNumber = getValue(flightmodeId) + 1
    if flightModeNumber < 1 or flightModeNumber > 17 then
        flightModeNumber = 13
    end
    lcd.drawText(70, 1, FlightMode[flightModeNumber].Name, MIDSIZE)

-- ###############################################################
-- Flightmode Image
-- ###############################################################

    if flightModeNumber > -1 and flightModeNumber < 4 then
    lcd.drawPixmap(50, 2, "/SCRIPTS/BMP/fm.bmp")
    else
    lcd.drawPixmap(50, 2, "/SCRIPTS/BMP/gps.bmp")
    end

-- ###############################################################
-- GPS Fix
-- ###############################################################

    local satRaw = getValue(gpsid)
    local satCount =  (satRaw - (satRaw%10))/10
    local gpsFix = (satRaw%10)


    if gpsFix >= 4 then
        lcd.drawText(70, 15, "3D D.GPS, ", SMLSIZE)
        lcd.drawText(lcd.getLastPos(),15, satCount, SMLSIZE)
        lcd.drawText(lcd.getLastPos(),15, ' Sats', SMLSIZE)

    elseif gpsFix == 3 then
        lcd.drawText(70, 15, "3D FIX, ", SMLSIZE)
        lcd.drawText(lcd.getLastPos(),15, satCount, SMLSIZE)
        lcd.drawText(lcd.getLastPos(),15, ' Sats', SMLSIZE)
    
    else 
        lcd.drawText(70,15, "NO FIX, ", BLINK+SMLSIZE)
        lcd.drawText(lcd.getLastPos(),15, satCount, BLINK+SMLSIZE)
        lcd.drawText(lcd.getLastPos(),15, ' Sats', BLINK+SMLSIZE)
    end


-- ###############################################################
-- Display RSSI data
-- ###############################################################
    
    local rxpercent = 0
    
    if getValue(rssiId) > 38 then
    local rxpercent = ((math.log(getValue(rssiId)-28, 10)-1)/(math.log(72, 10)-1))*100
    end

if rxpercent > 90 then
        lcd.drawPixmap(164, 6, "/SCRIPTS/BMP/RSSI10.bmp")
    elseif rxpercent > 80 then
        lcd.drawPixmap(164, 6, "/SCRIPTS/BMP/RSSI09.bmp")
    elseif rxpercent > 70 then
        lcd.drawPixmap(164, 6, "/SCRIPTS/BMP/RSSI08.bmp")
    elseif rxpercent > 60 then
        lcd.drawPixmap(164, 6, "/SCRIPTS/BMP/RSSI07.bmp")
    elseif rxpercent > 50 then
        lcd.drawPixmap(164, 6, "/SCRIPTS/BMP/RSSI06.bmp")
    elseif rxpercent > 40 then
        lcd.drawPixmap(164, 6, "/SCRIPTS/BMP/RSSI05.bmp")
    elseif rxpercent > 30 then
        lcd.drawPixmap(164, 6, "/SCRIPTS/BMP/RSSI04.bmp")
    elseif rxpercent > 20 then
        lcd.drawPixmap(164, 6, "/SCRIPTS/BMP/RSSI03.bmp")
    elseif rxpercent > 10 then
        lcd.drawPixmap(164, 6, "/SCRIPTS/BMP/RSSI02.bmp")
    elseif rxpercent > 0 then
        lcd.drawPixmap(164, 6, "/SCRIPTS/BMP/RSSI01.bmp")
    else
          lcd.drawPixmap(164, 6, "/SCRIPTS/BMP/RSSI00.bmp")
    end

      lcd.drawText(188, 57, getValue(rssiId), 0)
      lcd.drawText(lcd.getLastPos(), 58, "dB", SMLSIZE)

end

return { run=run, background=batteryusedcalc}
