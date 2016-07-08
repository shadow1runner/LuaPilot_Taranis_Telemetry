-- This program is free software; you can redistribute it and/or modify
-- it under the terms of the GNU General Public License as published by
-- the Free Software Foundation; either version 2 of the License, or
-- (at your option) any later version.
--
-- This program is distributed in the hope that it will be useful,
-- but WITHOUT ANY WARRANTY, without even the implied warranty of
-- MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
-- GNU General Public License for more details.
--
-- You should have received a copy of the GNU General Public License
-- along with this program; if not, see <http://www.gnu.org/licenses>.


--#########################################################################################
--#   LuaPilot v2.006  Lua Telemetry Script for Taranis                                   #
--#                                                                                       #
--#  + with opentx 2.16 and above, tested with D4r-II & D8R & X4R                         #
--#  + works with Arducopter Flight  Controller like Pixhawk, APM and maybe others        #
--#                                                                                       #
--#  Thanks to SockEye, Richardoe, Schicksie,lichtl			                                  #    
--#  _ben&Jace25(FPV-Community) and Clooney82&fnoopdogg                                   #
--#         									                                                            #
--#  LuaPilot © 2015 ilihack 							                                                #
--#########################################################################################


--------------------------------------------------------------------------------  
--setup:                                                                                  
local headingOrDist = 2               -- 0 = draw distance; 1 = draw both; 2 = alternate  
local batterymAhAlarm = 0             -- 0 = off or e.g. 2200 for alarming if you used more than 2200 mAh      
local batteryPercentSpeechEnabled = 1 -- 0 = off or 1 enables battery percentage speech in 10 % steps
local cellVoltageAlarm = 3.3          -- 0 = off or e.g. 3.3 to get an Alarm if --                                                                                        #
--------------------------------------------------------------------------------  
-- advanced config:                                                                       #
local maxAverageAmpere = 0          -- 0 = Off, Alarm if the avarage 5s current is over this Value     #
local calcBattResistance = 0        -- 0 = off 1 = AutoCalc Lipo Resistance and correct Lipo.Level ALPHA #
local batType = 0                   -- 0 = Autodetection (1s,2s,3s,4s,6s,8s) or 7 for an 7s Battery Conf      #
local battLevelmAh = 5000         -- if 0 BatteryLevel calc from Volt else from this mAh Value        #
local gpsOk = 1                     -- 1 = play Wav files for Gps Stat , 0= Disable wav Playing for Gps Status   #
local sayFlightMode = 1           -- 0 = off 1 = on then play wav for Flightmodes changes                 #
local battCriticalPercentage = 10 -- battery level (in %) which is the threshold to a critical low battery #
--------------------------------------------------------------------------------  

local function getTelemetryId(name)
 field = getFieldInfo(name)
 if getFieldInfo(name) then return field.id end
 return -1
end

local data = {}
data.battsumid =    getTelemetryId("VFAS")
data.altid =        getTelemetryId("Alt")
--data.gpsaltid =   getTelemetryId("GAlt")
data.spdid =        getTelemetryId("GSpd")
data.gpsid =        getTelemetryId("GPS")
data.currentid =    getTelemetryId("Curr")
data.flightmodeId = getTelemetryId("Tmp1")
data.rssiId =       getTelemetryId("RSSI")
data.gpssatsid =    getTelemetryId("Tmp2")
data.headingid =    getTelemetryId("Hdg")

--init Telemetry Variables 
data.battsum      = 0
data.alt          = 0
data.spd          = 0
data.current      = 0
data.flightmodeNr = 0
data.rssi         = 0
data.gpssatcount  = 0
data.heading      = 0

--init Timer
local oldTime = {0,0,0,0,0,0}
local time    = {0,0,0,0,0,0}

--init vars for v.speed calculation
local vSpeed = 0.0
local prevAlt = 0.0

--init battery and consume
local totalBatteryConsumption = 0.0
local hvLiPoDetected          = 0
local batteryPercentage       = 0
local cellVoltage             = 0.0

local CurrA        = {}
local cellVoltageA = {}

local cellResistance = 0.0
local resCalcError   = 0
local arrayItem      = 0
local goodItems      = 0
local araySize       = 200 -- size of the resistance ring array

--init other
local efficiency                  = 0.0
local lastflightModeNumber        = 0
local currAvarg                   = 0.0
local gpsHorizontalDistance       = 0.0
local lastSpokenBatteryPercentage = 100
local rxPercent                   = 0
local firstTime                   = 0
local displayTimer                = 0
local settings                    = getGeneralSettings()

-- init flight modes
local FlightModeName = {}
-- APM Flight Modes
FlightModeName[0]  = "Stabilize"
FlightModeName[1]  = "Acro Mode"
FlightModeName[2]  = "Alt Hold"
FlightModeName[3]  = "Auto Mode"
FlightModeName[4]  = "Guided Mode"
FlightModeName[5]  = "Loiter Mode"
FlightModeName[6]  = "RTL Mode"
FlightModeName[7]  = "Circle Mode"
FlightModeName[8]  = "Invalid Mode"
FlightModeName[9]  = "Landing Mode"
FlightModeName[10] = "Optic Loiter"
FlightModeName[11] = "Drift Mode"
FlightModeName[12] = "Invalid Mode"
FlightModeName[13] = "Sport Mode"
FlightModeName[14] = "Flip Mode"
FlightModeName[15] = "Auto Tune"
FlightModeName[16] = "Pos Hold"
FlightModeName[17] = "Brake Mode"

-- PX4 Flight Modes
FlightModeName[18] = "Manual"
FlightModeName[19] = "Acro"
FlightModeName[20] = "Stabilized"
FlightModeName[21] = "RAttitude"
FlightModeName[22] = "Pos Control"
FlightModeName[23] = "Alt Control"
FlightModeName[24] = "Offb Control"
FlightModeName[25] = "Auto Takeoff"
FlightModeName[26] = "Auto Pause"
FlightModeName[27] = "Auto Mission"
FlightModeName[28] = "Auto RTL"
FlightModeName[29] = "Auto Landing"

FlightModeName[30] = "No Telemetry"


--------------------------------------------------------------------------------  
-- functions 
--------------------------------------------------------------------------------  
local function resetVar() 
  data.battsumid    = getTelemetryId("VFAS")
  data.altid        = getTelemetryId("Alt")
  --data.gpsaltid   = getTelemetryId("GAlt")
  data.spdid        = getTelemetryId("GSpd")
  data.gpsid        = getTelemetryId("GPS")
  data.currentid    = getTelemetryId("Curr")
  data.flightmodeId = getTelemetryId("Tmp1")
  data.rssiId       = getTelemetryId("RSSI")
  data.gpssatsid    = getTelemetryId("Tmp2")
  data.headingid    = getTelemetryId("Hdg")

  time = {0,0,0,0,0,0}
  vSpeed = 0.0
  prevAlt = 0.0
  totalBatteryConsumption = 0.0
  batteryPercentage = 0
  cellVoltage = 0.0
  CurrA = {}
  cellVoltageA = {}
  cellResistance = 0.0
  arrayItem = 0 
  efficiency = 0.0
  lastflightModeNumber = 0
  currAvarg = 0.0
  gpsHorizontalDistance = 0.0
  lastSpokenBatteryPercentage = 100
  batType = 0
  firstTime = 1
  settings = getGeneralSettings()
  data.lon = nil
  data.lat = nil
end

local function round(num, idp)
  local temp = 10^(idp or 0)
  if num >= 0 then 
    return math.floor(num * temp + 0.5) / temp
  else
   return math.ceil(num * temp - 0.5) / temp 
 end
end

local function speekBatteryPercentage()  

  if batteryPercentage < (lastSpokenBatteryPercentage-10) then --only say in 10 % steps

    time[6] = time[6] + (getTime() - oldTime[6]) 

    if time[6] > 700 then --and only say if batteryPercentage 10 % below for more than 10sec
      lastSpokenBatteryPercentage = round(batteryPercentage*0.1) * 10
      time[6] = 0
      playNumber(round(lastSpokenBatteryPercentage), 8, 0)
      if lastSpokenBatteryPercentage <= battCriticalPercentage then 
        playFile("batcrit.wav") 
      end
    end
    
    oldTime[6] = getTime() 

  else    
    time[6] = 0
    oldTime[6] = getTime() 
  end  
end

local function calcVSpeed()  

  local temp = 0.0 --Valueholder

  time[2] = time[2] + (getTime() - oldTime[2])
  if data.alt~=prevAlt or time[2] > 130 then --1300 ms
    temp = (data.alt-prevAlt) / (time[2]/100)
    time[2] = 0 
    prevAlt = data.alt
  end

  oldTime[2] = getTime() 
  
  if vSpeed<10 then
    vSpeed = temp*0.3 + vSpeed*0.7
  else 
    vSpeed = temp*0.1 + vSpeed*0.90
  end
end

local function calcBatterycellVoltageageAndType()  

  if math.ceil(data.battsum/4.37) > batType and data.battsum<4.37*8 then 
    batType = math.ceil(data.battsum/4.37)

    --don't Support 5S & 7S Battery, its dangerous to detect: if you have an empty 8S its looks like a 7S
    if batType == 7 then 
      batType = 8
    end
    if batType == 5 then 
      batType = 6 
    end 

    if data.battsum > 4.22*batType then --HVLI is detected
      hvLiPoDetected = 1
    else
      hvLiPoDetected = 0
    end
  end

  if batType > 0 then 
    cellVoltage = data.battsum/batType 
  end
end

local function calcBatteryResistance() --Need cellVoltage and current from Telemetry Sampels and Calc the Resistence with it

  local temp = 0 --only an Valueholder in calcs
  local sum_x = 0
  local sum_y = 0
  local sum_xx = 0
  local sum_xy = 0
  
  if arrayItem ==0 then --init Aray wenn its first time
    goodItems = 0
    resCalcError = 0
    for i = 1,araySize do
      CurrA[i] = 0
      cellVoltageA[i] = 0
    end
  end

  if arrayItem < araySize  then 
    arrayItem = arrayItem+1 
  else 
    arrayItem = 1  --if on the end Return to the beginn and overwrite old Values
  end 

  if cellVoltage>2.5 and cellVoltage<4.5 and data.current>0.1 and data.current<180 then --check if values are in range and Safe New Samples in Array
    if cellVoltageA[arrayItem] ==0 then 
      goodItems = goodItems+1 
    end
    cellVoltageA[arrayItem] = cellVoltage
    CurrA[arrayItem] = data.current
  else
    if cellVoltageA[arrayItem] ~= 0 then 
      goodItems = goodItems-1 
    end
    cellVoltageA[arrayItem] = 0
    CurrA[arrayItem] = 0
  end
  
  if goodItems>araySize*0.7 then --if cache 80 % filled begin to calc
    ---Start Liniar Regression over the Volt & Current Arrays    
    for i = 1,araySize do
      local curr = CurrA[i]
      local volt = cellVoltageA[i]
      sum_x = sum_x+curr
      sum_y = sum_y+volt
      sum_xx = sum_xx+curr*curr
      sum_xy = sum_xy+(curr*volt)
    end

    temp = (sum_x*sum_y-goodItems*sum_xy)/(goodItems*sum_xx-sum_x*sum_x) --calc the coeffiz m of an Liniar func and symbolise the Battery Resistance

    if (temp > 0.001 and temp < 0.20 ) then --check if in Range 1- 200mohm 
      if cellResistance ==0 then --init for faster filtering
        cellResistance = temp
      else
        cellResistance = cellResistance*0.99 +temp*0.01 --Update cellresistance             
      end
    end

    ---if Resistance okay correctet Voltage else counterror
    temp = (data.current*cellResistance) --Calc temp calc cellVoltage Drift
    if (hvLiPoDetected == 1 and cellVoltage+temp>4.45) or (cellVoltage+temp>4.3 and hvLiPoDetected == 0) then --not in Range
      resCalcError = resCalcError+1
      if resCalcError == 5 then 
        playFile("/SCRIPTS/WAV/errorres.wav")
        arrayItem = 0
      end
    elseif resCalcError < 10 and cellVoltage ~= 0 then --not much errors happened
      cellVoltage = cellVoltage+temp --correct Cell Voltage with calculated Cell Resistance  
    end
    
  end
end 

local function calcBatteryLevelmAh()  --calc Battery Percent with mah comsume
  if battLevelmAh ~= 0 then
    batteryPercentage = round((100/battLevelmAh)*(battLevelmAh-totalBatteryConsumption))  
  end
  if batteryPercentage<0 then
   batteryPercentage = 0 
  end
  if batteryPercentage>100 then 
    batteryPercentage = 100 
  end
end 
  
local function calcBatteryLevelVoltage()  

  local temp = 0 --for cellVoltage and unfildred batteryPercentage placeholder
  
  if hvLiPoDetected == 1 then --for HVlipo better estimation
    temp = cellVoltage-0.15 
  else
    temp = cellVoltage
  end --Correction for HVlipo Batterpercent Estimation

  if temp > 4.2 then
   temp = 100
  elseif temp < 3.2 then
   temp = 0
  elseif temp >= 4 then
   temp = 80*temp - 236
  elseif temp <= 3.67 then
   temp = 29.787234 * temp - 95.319149 
  elseif temp > 3.67 and temp < 4 then
   temp = 212.53*temp-765.29
  end

  if batteryPercentage ==0 then 
    batteryPercentage = round(temp) --init batteryPercentage
  else 
    batteryPercentage = round(batteryPercentage*0.98 + 0.02*temp)
  end
end

local function calcTotalBatteryConsumption()
  time[1] = time[1] + (getTime() - oldTime[1])
  if time[1] >= 20 then --200 ms
    totalBatteryConsumption  = totalBatteryConsumption + ( data.current * (time[1]/360))
    time[1] = 0
  end
  oldTime[1] = getTime() 
end

local function alarmIfMaxMah()
  if batterymAhAlarm > 0 and batterymAhAlarm < totalBatteryConsumption then 
    playFile("battcns.wav")
    batterymAhAlarm = 0
  end
end

local function alarmIfLowVoltage()
  if cellVoltage  < cellVoltageAlarm and data.battsum >0.5  then 
    time[3] = time[3] + (getTime() - oldTime[3])
    if time[3] >= 800 then --8s
      playFile("battcns.wav")
      time[3] = 0
    end
    oldTime[3] = getTime()
  end
end

local function alarmIfOverAmp() 
  currAvarg = data.current*0.01+currAvarg*0.99
  if currAvarg  > maxAverageAmpere  then 
    time[4] = time[4] + (getTime() - oldTime[4])
    if time[4] >= 250 then --2,5s
      playFile("currdrw.wav")
      time[4] = 0
    end
    oldTime[4] = getTime()
  end
end

local function calcDisplayTimer()
  time[5] = time[5] + (getTime() - oldTime[5])
  if time[5] >= 200 then --2s
    if displayTimer == 1 then 
      displayTimer = 0 
    else 
      displayTimer = 1
    end
    time[5] = 0
  end
  oldTime[5] = getTime()
end

local function calcGpsDistance()
  if gpsOk == 3 and type(data.gps) == "table" then
    if data.gps["lat"] ~= nil and data.lat == nil then
      data.lat = data.gps["lat"]
    elseif data.gps["lon"] ~= nil and data.lon == nil then
      data.lon = data.gps["lon"]
    else
      local sin = math.sin--locale are faster
      local cos = math.cos
      local z1 = (sin(data.lon - data.gps["lon"]) * cos(data.lat) )*6358364.9098634
      local z2 = (cos(data.gps["lat"]) * sin(data.lat) - sin(data.gps["lat"]) * cos(data.lat) * cos(data.lon - data.gps["lon"]) )*6358364.9098634 
      gpsHorizontalDistance = math.sqrt(z1*z1 + z2*z2)/100
    end
  end
end


--------------------------------------------------------------------------------
-- function Get new Telemetry Values 
--------------------------------------------------------------------------------
local function getNewTelemetryValues()

  local getValue = getValue --faster
  
  data.battsum      = getValue(data.battsumid)
  data.alt          = getValue(data.altid)
  data.spd          = getValue(data.spdid)
  data.current      = getValue(data.currentid)
  data.flightmodeNr = getValue(data.flightmodeId)
  data.rssi         = getValue(data.rssiId)
  data.gpssatcount  = getValue(data.gpssatsid)
  data.gps          = getValue(data.gpsid)
  data.heading      = getValue(data.headingid)
end

--------------------------------------------------------------------------------
-- main draw Loop
--------------------------------------------------------------------------------
local function draw()   

  --localize optimization
  local drawText = lcd.drawText 
  local getLastPos = lcd.getLastPos
  local MIDSIZE = MIDSIZE
  local SMLSIZE = SMLSIZE 

  -- ###############################################################
  -- Battery level Drawing
  -- ###############################################################
  local myPxHeight = math.floor(batteryPercentage * 0.37) --draw level
  local myPxY = 50 - myPxHeight

  lcd.drawPixmap(1, 3, "/SCRIPTS/BMP/battery.bmp")

  lcd.drawFilledRectangle(6, myPxY, 21, myPxHeight, FILL_WHITE )

  -- local myPxHeight = math.floor(batteryPercentage * 0.37) --draw level
  -- local myPxY = 13 + 37 - myPxHeight
  -- lcd.drawPixmap(1, 3, "/SCRIPTS/BMP/battery.bmp")
  -- lcd.drawFilledRectangle(5, myPxY, 24, myPxHeight, FILL_WHITE )

  local i = 38
  while (i > 0) do 
    lcd.drawLine(6, 12 + i, 26, 12 +i, SOLID, GREY_DEFAULT)
    i= i-2
  end

--  if ( calcBattResistance ==1 and  goodItems<25) or resCalcError > 10  then--check if we have good samples from Battery Resistance Compensattion
--    drawText(3,1, "~", SMLSIZE)
--  end

  if batteryPercentage < 10 or batteryPercentage >= 100 then
    drawText(12,0, round(batteryPercentage).."%",INVERS + SMLSIZE + BLINK)
  else
    drawText(11,0, round(batteryPercentage).."%" ,SMLSIZE)
  end

  if (hvLiPoDetected == 1 and data.battsum >= 10) then
    lcd.drawNumber(0,57, data.battsum*10,PREC1+ LEFT )
  else
    lcd.drawNumber(0,57, data.battsum*100,PREC2 + LEFT )
  end

  if hvLiPoDetected == 1 then
    drawText(getLastPos(), 57,"H", BLINK, 0) 
  end
  drawText(getLastPos(), 57, " V ", 0)
  drawText(getLastPos(), 58, batType.."S" , SMLSIZE)


  -- ###############################################################
  -- Display RSSI data
  -- ###############################################################
  if data.rssi > 38 then
    rxPercent = round(rxPercent*0.5+0.5*(((math.log(data.rssi-28, 10)-1)/(math.log(72, 10)-1))*100))
  else
    rxPercent = 0
  end

  lcd.drawPixmap(164, 8, "/SCRIPTS/BMP/RSSI"..math.ceil(rxPercent*0.1)..".bmp") --Round rxPercent to the next higer 10 Percent number and search&draw pixmap

  drawText(184, 57, rxPercent, 0) 
  drawText(getLastPos(), 58, "% RX", SMLSIZE)

  -- ###############################################################
  -- Vertical Speed Drawing
  -- ###############################################################
  drawText(34, 44, "vSpeed: ",SMLSIZE)

  if settings['imperial'] ~= 0 then
    drawText(getLastPos(), 40, round(vSpeed*3.28,1) , MIDSIZE) 
    drawText(getLastPos(), 44, " fs", 0)
  else
    drawText(getLastPos(), 40, round(vSpeed,1) , MIDSIZE) 
    drawText(getLastPos(), 44, " m/s", 0)
  end

  -- ###############################################################
  -- Speed Drawing
  -- ###############################################################
  drawText(38,29, "Speed: ",SMLSIZE,0)

  if settings['imperial'] ~= 0 then
    drawText(getLastPos(), 25, round(data.spd*1.149), MIDSIZE)
    drawText(getLastPos(), 29, " mph", SMLSIZE)
  else
    drawText(getLastPos(), 25, round(data.spd*1.851), MIDSIZE)
    drawText(getLastPos(), 29, " km/h", SMLSIZE)
  end


  -- ###############################################################
  -- Distance above rssi  Drawing
  -- ###############################################################
  if headingOrDist == 1 or (displayTimer ==1 and headingOrDist == 2)  then
    if settings['imperial'] ~= 0 then
      drawText(169,0, "Dist: "..(round(gpsHorizontalDistance)).." f",SMLSIZE)
    else
      drawText(169,0, "Dist: "..(round(gpsHorizontalDistance)).." m",SMLSIZE)
    end
  -- ###############################################################
  -- Heading  above rssi Drawing
  -- ###############################################################
  elseif headingOrDist == 0 or (displayTimer == 0 and headingOrDist == 2) then
    local HdgOrt = ""

    if data.heading <0 or data.heading >360 then HdgOrt = "Error"  
    elseif data.heading <  22.5  then HdgOrt = "N"
    elseif data.heading <  67.5  then HdgOrt = "NO"
    elseif data.heading <  112.5 then HdgOrt = "O"
    elseif data.heading <  157.5 then HdgOrt = "OS"
    elseif data.heading <  202.5 then HdgOrt = "S"
    elseif data.heading <  247.5 then HdgOrt = "SW"
    elseif data.heading <  292.5 then HdgOrt = "W"
    elseif data.heading <  337.5 then HdgOrt = "WN"
    elseif data.heading <= 360.0 then HdgOrt = "N"
    end

    drawText(178,0, HdgOrt.." "..data.heading, SMLSIZE)
    drawText(getLastPos(), -2, 'o', SMLSIZE)  
  end

  -- ###############################################################
  -- Timer Drawing 
  -- ###############################################################
  local timer = model.getTimer(0)
  -- drawText(160, 6, "Time: ",SMLSIZE)
  lcd.drawTimer(178, 8, timer.value, SMLSIZE)

  -- ###############################################################
  -- Altitude Drawing
  -- ###############################################################
  drawText(114,44, "Alt: ",SMLSIZE,0)
  local temp
  if settings['imperial'] ~= 0 then
    temp = data.alt*3.28 
  else
    temp = data.alt
  end

  if temp >= 10 or temp<-0.1 then
    drawText(getLastPos(), 40, round(temp), MIDSIZE)
  elseif temp<= 0.0 and temp>= -0.1 then
    drawText(getLastPos(), 40, 0, MIDSIZE)
  else 
    drawText(getLastPos(), 40, round(temp,1), MIDSIZE)
  end

  if settings['imperial']~= 0 then
    drawText(getLastPos(), 44, ' f', 0) 
  else
    drawText(getLastPos(), 44, ' m', 0)
  end

  -- ###############################################################
  -- CurrentTotal Drawn Consumption Drawing
  -- ###############################################################
  drawText(46, 58, "Used: "..(round(totalBatteryConsumption))..' mAh',SMLSIZE)

  -- ###############################################################
  -- efficiency calculation and drawing
  -- ############################################################### 
  if data.spd > 10 then --draw wh per km
    if settings['imperial'] == 0 then
      efficiency = efficiency*0.8+(0.2*(data.current*data.battsum/data.spd))--spdint can not be 0 because the previus if
      drawText(98, 58,"  Effic: "..round(efficiency,1)..' Wh/km', SMLSIZE)
    else
      efficiency = efficiency*0.8+(0.2*(data.current*data.battsum/(data.spd*0.621371)))
      drawText(98, 58,"  Effic: "..round(efficiency,1)..' Wh/mi', SMLSIZE) 
    end
  else --draw wh per h
   efficiency = efficiency*0.8+0.2*(data.current*data.battsum)
   drawText(104, 58, " Power: "..(round(efficiency,1))..' W', SMLSIZE)
  end

  -- ###############################################################
  -- Current Drawing
  -- ###############################################################
  drawText(113, 29, "Cur: ",SMLSIZE)

  if data.current >= 100 then  
    drawText(getLastPos(), 25, round(data.current),MIDSIZE)
  else 
    drawText(getLastPos(), 25, round(data.current,1),MIDSIZE)
  end

  drawText(getLastPos(), 29, ' A', 0)

  -- ###############################################################
  -- Flightmodes Drawing for copter todo for plane,Folow
  -- ###############################################################
  if data.flightmodeNr < 0 or data.flightmodeNr > 30 then
    data.flightmodeNr = 12    
  elseif data.flightmodeId == -1 or (rxPercent ==0 and data.flightmodeNr == 0)then
    data.flightmodeNr = 30
  end
    
  drawText(68, 1, FlightModeName[data.flightmodeNr], MIDSIZE)
    
  if data.flightmodeNr ~= lastflightModeNumber and sayFlightMode == 1 then
    playFile("/SCRIPTS/WAV/AVFM"..data.flightmodeNr.."A.wav")
    lastflightModeNumber = data.flightmodeNr
  end

  -- ###############################################################
  -- Flightmode Image
  -- ###############################################################
  if data.flightmodeNr == 6 or data.flightmodeNr == 9 or data.flightmodeNr == 28 or data.flightmodeNr == 29 then
    lcd.drawPixmap(50, 2, "/SCRIPTS/BMP/H.bmp")  
  elseif (data.flightmodeNr >= 0 and data.flightmodeNr <= 2) or (data.flightmodeNr >= 18 and data.flightmodeNr <= 23) then
    lcd.drawPixmap(50, 2, "/SCRIPTS/BMP/stab.bmp")
  elseif data.flightmodeNr~= -1 or data.flightmodeNr~= 12 then
    lcd.drawPixmap(50, 2, "/SCRIPTS/BMP/gps.bmp")
  end

  -- ###############################################################
  -- GPS Fix
  -- ###############################################################
  local gpsFix =  (data.gpssatcount%10)
  local satCount =   (data.gpssatcount -  (data.gpssatcount%10))*0.1

  if data.gpssatsid ==-1 then 
    drawText(68, 15, "Check Telemetry Tem2", SMLSIZE)
  elseif gpsFix >= 4 then
    drawText(70,15, "3D D.GPS, "..satCount..' Sats', SMLSIZE)
    if gpsOk ==1 and satCount>6 then
      gpsOk = 3
      playFile("gps.wav") 
      playFile("good.wav") 
    end
  elseif gpsFix == 3 then
    drawText(70,15, "3D Fix, "..satCount..' Sats', SMLSIZE)
    if gpsOk ==1 and satCount>6 then
      gpsOk = 3
      playFile("gps.wav") 
      playFile("good.wav") 
    end
  elseif gpsFix == 2 then
    drawText(70,15, "2D Fix, "..satCount..' Sats', BLINK+SMLSIZE)
  else 
    drawText(70,15, "No Fix, "..satCount.." Sats", BLINK+SMLSIZE) 
    if gpsOk == 3 then
      gpsOk = 1
      playFile("gps.wav") 
      playFile("bad.wav")
    end
  end
end

--------------------------------------------------------------------------------
-- BACKGROUND loop FUNCTION
--------------------------------------------------------------------------------
local function doBackgroundWork()
  getNewTelemetryValues()
  
--  data.current = getValue(MIXSRC_Rud)/7 
--  data.battsum = getValue(MIXSRC_Thr)/60

  calcBatterycellVoltageageAndType() 
  calcTotalBatteryConsumption()

  if maxAverageAmpere > 0 then alarmIfOverAmp()    end
  if batterymAhAlarm > 0  then alarmIfMaxMah()     end
  if cellVoltageAlarm>0      then alarmIfLowVoltage() end
end

local function background()
  arrayItem   = 0--Delete Resistance Array because it may old Values in the Background
  resCalcError = 0
  doBackgroundWork()
end


--------------------------------------------------------------------------------
-- RUN loop FUNCTION
--------------------------------------------------------------------------------
local function run(event)
  if firstTime == 0 then
    playFile("/SCRIPTS/WAV/welcome.wav") 
  end
  if firstTime<60 then
    lcd.drawPixmap(0, 0, "/SCRIPTS/BMP/LuaPiloL.bmp")
    lcd.drawPixmap(106, 0, "/SCRIPTS/BMP/LuaPiloR.bmp")
    firstTime = firstTime+1
    return 0
  end
  
  if event == 64  then --if menu key pressed then reset all Variables.  
    playFile("/SCRIPTS/WAV/reset.wav")
    killEvents(64)
    resetVar()
  end
  
  doBackgroundWork()
  
  if headingOrDist == 1 or headingOrDist == 2 then calcGpsDistance() end
  if calcBattResistance ==1                   then calcBatteryResistance() end
  if battLevelmAh>0                           then 
    calcBatteryLevelmAh() 
  else 
    calcBatteryLevelVoltage() 
  end
  if batteryPercentSpeechEnabled ==1          then speekBatteryPercentage()     end
  
  calcDisplayTimer()
  calcVSpeed() 
  lcd.clear()
  draw()
end

return {run = run,  background = background}