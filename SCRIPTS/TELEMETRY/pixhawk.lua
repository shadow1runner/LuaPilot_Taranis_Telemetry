-- ###############################################################
-- #     LuaPilot  0.97                                          #
-- #     Telemetry Lua Script APM/Pixhawk                        #
-- #                                                             #
-- #  + only with opentx 2.13 and above                          #
-- #    tested with D4r-II & D8R & X4R                           #
-- #  + works with Pixhawk and AUAV-X2                           #
-- #                                                             #
-- #  License (Script & images): Share alike                     #
-- #  Can be used and changed non commercial, OWN RISK           #
-- #                                                             #
-- #  Based from the work of SockEye,Richardoe,Schicksie,lichtl  #                                                       
-- #  & Jace25(FPV-Community) and improved by me ilihack         #
-- #                                                             #
-- ###############################################################
-- #  Config:                                                    #
--                                                               #
     local TimeOrVSpeed = 1      --draw Timer? 0 or Ver.Speed 1  #
-- #                                                             #
-- ###############################################################
  
  
  local function getTelemetryId(name)
      field = getFieldInfo(name)
      if getFieldInfo(name) then return field.id end
    return -1
  end
  
  
local function round(num, idp)
    local mult = 10^(idp or 0)
    if num >= 0 then return math.floor(num * mult + 0.5) / mult
    else return math.ceil(num * mult - 0.5) / mult end
end

 
  --get the Ids
  local battsumid =    getTelemetryId("VFAS")
 	local altid =        getTelemetryId("Alt")
  local gpsaltid =     getTelemetryId("GAlt") 
	local spdid =        getTelemetryId("GSpd")
  local gpsid =        getTelemetryId("GPS")
	local currentid =    getTelemetryId("Curr")
	local flightmodeId = getTelemetryId("Temp")
	local rssiId =       getTelemetryId("RSSI")
	local gpssatsid =    getTelemetryId("Tem1")
	local headingid =    getTelemetryId("Hdg")
  
  
  --Fallback if dont find the Telemetry by the name than take the standart ID
  if battsumid    == -1 then battsumid=    208 end
  if altid        == -1 then altid=        226 end
  if gpsaltid     == -1 then altid=        223 end
  if spdid        == -1 then spdid=        205 end
  if currentid    == -1 then currentid=    232 end
  if flightmodeId == -1 then flightmodeId= 202 end
  if rssiId       == -1 then rssiId=       214 end
  if headingid    == -1 then headingid=    235 end
  if gpssatsid    == -1 then gpssatsid=    220 end
  if gpsid        == -1 then gpsid=        199 end
 
  --init Variables --dont change

  local oldlocaltime =0 --for BatteryComsum
  local localtime =0  --for BatteryComsum
  local oldlocaltime2 =0 --for vspeed
  local localtime2 =0  --for vspeed
  local altverticalSpeed=0
  local fildredVSpeed = 0
  local prevAlt = 0.0
  local verticalSpeed = 0.0
  local totalbatteryComsum = 0.0
  local cellHightVolt=0.0
  local cellLowVolt=0.0
  
  local battype=0
  local HVlipoDetected = 0 
 
--##### Main run Loop with temp Variables ##### 
  local function run(event)   
  
  local rxpercent = 0
  
  
  local battsum =    getValue(battsumid)
 	local alt =        getValue(altid)
	local spd =        getValue(spdid)*1.851 --knotes per h to kmh
	local current =    getValue(currentid)
	local flightmode = getValue(flightmodeId)
	local rssi =       getValue(rssiId)
	local gps =        getValue(gpssatsid)
	local heading =    getValue(headingid)


  lcd.lock() 
  lcd.clear()

-- ###############################################################
-- Lipo Range Calculate and Drawing
-- ###############################################################
--  
              
    local battpercent = 0
    
     
       
       if math.ceil(battsum/4.40) > battype and battsum>2.5 and battsum<4.4*8 then 
          battype=math.ceil(battsum/(4.40))
          
           if battsum > 4.25*battype then --HVLI is detect
              HVlipoDetected=1
              cellHightVolt=4.35
              cellLowVolt=3.35
           else
              HVlipoDetected=0
              cellHightVolt=4.2
              cellLowVolt=3.2
           end
       end
    
    --battpercent = ( ( battpercent *0.9) + (0.1* ( battsum-cellLowVolt*battype  ) * ( 100/ (cellHightVolt*battype -cellLowVolt*battype ) ) ) ) --with smothfilter don'work ?!
    battpercent = ( ( battsum-cellLowVolt*battype  ) * ( 100/ (cellHightVolt*battype -cellLowVolt*battype ) ) ) 
  
  
    local myPxHeight = math.floor(battpercent * 0.37) --draw level
    local myPxY = 13 + 37 - myPxHeight

    lcd.drawPixmap(1, 3, "/SCRIPTS/BMP/battery.bmp")

    if battpercent > 0 and battpercent < 105 then
       lcd.drawFilledRectangle(5, myPxY, 24, myPxHeight, FILL_WHITE )
    end

    local i = 38
    while (i > 0) do 
    lcd.drawLine(6, 12 + i, 26, 12 +i, SOLID, GREY_DEFAULT)
    i= i-2
  end
  
   if battsum==0 or battype==0 then battpercent = 0 end 
   if battpercent < 0          then battpercent = -5 end
   if battpercent > 105        then battpercent = 105 end
   
   if battpercent < 10 then
      lcd.drawNumber(17,1, battpercent ,0 + BLINK)
      lcd.drawText(lcd.getLastPos(), 1, "%  ", 0 + BLINK)
   else
      lcd.drawNumber(20,0, battpercent ,SMLSIZE)
      lcd.drawText(lcd.getLastPos(), 0, "%  ", SMLSIZE)
   end


   if HVlipoDetected == 1 and battsum >=10 then
     lcd.drawNumber(0,57, round(battsum,1) ,PREC2 + LEFT )
   else
     lcd.drawNumber(0,57, battsum,PREC2 + LEFT )
   end
   
    
    if HVlipoDetected == 1 then
      lcd.drawText(lcd.getLastPos(), 57,"H", BLINK, 0)
    end
    lcd.drawText(lcd.getLastPos(), 57, "V ", 0)
    lcd.drawText(lcd.getLastPos(), 58, battype , SMLSIZE)
    lcd.drawText(lcd.getLastPos(), 58,"s", SMLSIZE)
    
      

-- ###############################################################
-- Timer 
-- ###############################################################
   
    if TimeOrVSpeed == 0 then 
        local timer = model.getTimer(0)
        lcd.drawText(36, 44, "Timer: ",SMLSIZE, 0)
        lcd.drawTimer(lcd.getLastPos(), 41, timer.value, MIDSIZE)
    
    
-- ###############################################################
-- Vertical Speed
-- ###############################################################
  
  --else --TimerOrSVpeed is 1 --OLD  VERTICAL SPEED CALCULATION; 
     -- if getTime() >= NextTimeRuntime then
    -- NextTimeRuntime = NextTimeRuntime + 100 --last time + one sec
        --verticalSpeed=alt-prevAlt
        --prevAlt=alt
      --end
      
      --lcd.drawText(36,45, "Vspeed: ",SMLSIZE)
      --lcd.drawText(lcd.getLastPos(), 41, verticalSpeed, MIDSIZE)
      --lcd.drawText(lcd.getLastPos(), 45, 'm/s', 0)
  --end
  
   
  
    
  else --TimerOrSVpeed is 1

      localtime2 = localtime2 + (getTime() - oldlocaltime2)
      if not alt==prevAlt or localtime2>100 then --100 ms
        verticalSpeed  = (alt-prevAlt) / (localtime2/100) 
        localtime2 = 0 
        prevAlt=alt
      end
      oldlocaltime2 = getTime() 
      
      if fildredVSpeed <10 then
        fildredVSpeed=verticalSpeed*0.3 + fildredVSpeed*0.7
      else 
        fildredVSpeed=verticalSpeed*0.1 + fildredVSpeed*0.90
      end
     
   
      lcd.drawText(36,44, "Vspeed: ",SMLSIZE)
      lcd.drawText(lcd.getLastPos(), 40, round(fildredVSpeed,1) , MIDSIZE)
      lcd.drawText(lcd.getLastPos(), 44, 'ms', 0)
   
  end  

 
--  
-- ###############################################################
-- Speed
-- ###############################################################
      
      lcd.drawText(38,29, "Speed : ",SMLSIZE,0)
      lcd.drawText(lcd.getLastPos(), 25, round(spd), MIDSIZE)
      lcd.drawText(lcd.getLastPos(), 29, 'kmh', 0)
        
     
-- ###############################################################
-- Altitude
-- ###############################################################
    
   lcd.drawText(114,44, "Alt: ",SMLSIZE,0)
  
   if alt >=10 then
      lcd.drawText(lcd.getLastPos(), 40, round(alt), MIDSIZE)
   elseif alt<=0.0 and alt>=-0.1 then
      lcd.drawText(lcd.getLastPos(), 40, 0, MIDSIZE)
   elseif alt<-0.1 then
      lcd.drawText(lcd.getLastPos(), 40, round(alt), MIDSIZE)
   else 
      lcd.drawText(lcd.getLastPos(), 40, alt, MIDSIZE)
   end
   
   lcd.drawText(lcd.getLastPos(), 44, 'm', 0)
    

-- ###############################################################
-- Distance TODO above rssi whenn gps telemetry working
-- ###############################################################
   
   
   
-- ###############################################################
-- Heading  above rssi
-- ###############################################################

  lcd.drawText(170,0, "Hdg: ",SMLSIZE)
  lcd.drawText(lcd.getLastPos(), 0, heading, SMLSIZE)
  lcd.drawText(lcd.getLastPos(), -2, 'o', SMLSIZE)  
   
   
-- ###############################################################
-- CurrentTotal Calc Consum function
-- ###############################################################


   function batteryusedcalc()
      localtime = localtime + (getTime() - oldlocaltime)
      if localtime >=10 then --100 ms
        totalbatteryComsum  = totalbatteryComsum + ( current * (localtime/360))
        localtime = 0
      end
      oldlocaltime = getTime() 
    end
    

-- ###############################################################
-- CurrentTotal Draw Consum
-- ###############################################################
        
	batteryusedcalc()
    lcd.drawText(46, 58, "Used: ",SMLSIZE)
    lcd.drawText(lcd.getLastPos(), 58, round(totalbatteryComsum), SMLSIZE)
    lcd.drawText(lcd.getLastPos(), 58, 'mAh', SMLSIZE)
      
  
-- ###############################################################
-- efficient 
-- ############################################################### 
  
  if spd > 10 then --draw wh per km
     local efficientPerKM = current*battsum/spd--spdint can not be 0 because the previus if
     lcd.drawText(98, 58, "  effiz: ",SMLSIZE)
     
     if efficientPerKM >= 10 then
        lcd.drawText(lcd.getLastPos(), 58, round(efficientPerKM,1), SMLSIZE)
     else
        lcd.drawText(lcd.getLastPos(), 58, round(efficientPerKM,2), SMLSIZE)
     end
     
     lcd.drawText(lcd.getLastPos(), 58, 'Wh/km', SMLSIZE)  
   end
   
   if spd < 10 then --draw wh per h
     
     local efficientPerH = current*battsum
     lcd.drawText(104, 58, " draw: ",SMLSIZE)
     lcd.drawText(lcd.getLastPos(), 58, round(efficientPerH,2), SMLSIZE)
     lcd.drawText(lcd.getLastPos(), 58, 'W', SMLSIZE)  
   end

-- ###############################################################
-- Current
-- ###############################################################

    lcd.drawText(113, 29, "Cur: ",SMLSIZE)
    
    if current >=100 then  
      lcd.drawText(lcd.getLastPos(), 25, round(current),MIDSIZE)
    else 
      lcd.drawText(lcd.getLastPos(), 25, current,MIDSIZE)
    end
    
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
    
    --if flightmodeId == -1  then --TODO
   --lcd.drawText(70, 1, "Unknown Mode" ,BLINK, MIDSIZE)
    --else
      local flightModeNumber = flightmode + 1
      if flightModeNumber < 1 or flightModeNumber > 17 then
          flightModeNumber = 13
      end
      lcd.drawText(70, 1, FlightMode[flightModeNumber].Name, MIDSIZE)
    --end

-- ###############################################################
-- Flightmode Image
-- ###############################################################

    if flightModeNumber > -1 and flightModeNumber < 4 then
    lcd.drawPixmap(50, 2, "/SCRIPTS/BMP/fm.bmp")
    else
    lcd.drawPixmap(50, 2, "/SCRIPTS/BMP/gps.bmp")
  end
  
--if flightModeNumber = 7 then --TODO more Picture of FLight State
--        lcd.drawPixmap(164, 6, "/SCRIPTS/BMP/RTL.bmp")
--    elseif flightModeNumber = 10 then
--        lcd.drawPixmap(164, 6, "/SCRIPTS/BMP/LAND.bmp")
--    elseif flightModeNumber = 4 then
--        lcd.drawPixmap(164, 6, "/SCRIPTS/BMP/AUTO.bmp")
--    elseif flightModeNumber = 2 then
--        lcd.drawPixmap(164, 6, "/SCRIPTS/BMP/ACRO.bmp")
--    elseif flightModeNumber > -1 and flightModeNumber < 4
--        lcd.drawPixmap(50, 2, "/SCRIPTS/BMP/fm.bmp")
--    else 
--         lcd.drawPixmap(50, 2, "/SCRIPTS/BMP/gps.bmp")
--    end

-- ###############################################################
-- GPS Fix
-- ###############################################################

    local satCount =   (gps -  (gps%10))/10
    local gpsFix =  (gps%10)


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
    
    
    if rssi > 38 then
    rxpercent =round( ((math.log(rssi-28, 10)-1)/(math.log(72, 10)-1))*100)
    
  end
  
if rxpercent > 90 then
        lcd.drawPixmap(164, 6, "/SCRIPTS/BMP/RSSI10.bmp")
    elseif rxpercent >= 80 then
        lcd.drawPixmap(164, 6, "/SCRIPTS/BMP/RSSI09.bmp")
    elseif rxpercent >= 70 then
        lcd.drawPixmap(164, 6, "/SCRIPTS/BMP/RSSI08.bmp")
    elseif rxpercent >= 60 then
        lcd.drawPixmap(164, 6, "/SCRIPTS/BMP/RSSI07.bmp")
    elseif rxpercent >= 50 then
        lcd.drawPixmap(164, 6, "/SCRIPTS/BMP/RSSI06.bmp")
    elseif rxpercent >= 40 then
        lcd.drawPixmap(164, 6, "/SCRIPTS/BMP/RSSI05.bmp")
    elseif rxpercent >= 30 then
        lcd.drawPixmap(164, 6, "/SCRIPTS/BMP/RSSI04.bmp")
    elseif rxpercent >= 20 then
        lcd.drawPixmap(164, 6, "/SCRIPTS/BMP/RSSI03.bmp")
    elseif rxpercent >= 10 then
        lcd.drawPixmap(164, 6, "/SCRIPTS/BMP/RSSI02.bmp")
    elseif rxpercent >= 0 then
        lcd.drawPixmap(164, 6, "/SCRIPTS/BMP/RSSI01.bmp")
    else
          lcd.drawPixmap(164, 6, "/SCRIPTS/BMP/RSSI00.bmp")
    end

      lcd.drawText(184, 57, rxpercent, 0)
      lcd.drawText(lcd.getLastPos(), 57, "%", 0)

end

return { run=run, background=batteryusedcalc}

