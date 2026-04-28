@echo off
echo =============================================
echo  ElectroCare - Product Image Installer
echo =============================================
echo.

set SRC=C:\Users\LENOVO\.gemini\antigravity\brain\e71d28a4-ef43-4a79-aeab-9076867916bd
set DST=c:\Users\LENOVO\electrical_shop_app\assets\images

echo Copying product images to assets folder...
echo.

copy /Y "%SRC%\led_bulb_1777393356816.png" "%DST%\led_bulb.png"
echo [1/8] Philips LED Bulb 9W .............. OK

copy /Y "%SRC%\switch_plate_1777393378241.png" "%DST%\switch_plate.png"
echo [2/8] Anchor Roma Switch Plate ......... OK

copy /Y "%SRC%\copper_wire_1777393401937.png" "%DST%\copper_wire.png"
echo [3/8] Finolex FR Cable ................. OK

copy /Y "%SRC%\mcb_breaker_1777393430249.png" "%DST%\mcb_breaker.png"
echo [4/8] Havells Crabtree MCB 32A ......... OK

copy /Y "%SRC%\syska_spotlight_1777393445557.png" "%DST%\syska_spotlight.png"
echo [5/8] Syska PAR LED Spotlight 7W ....... OK

copy /Y "%SRC%\socket_outlet_1777393462091.png" "%DST%\socket_outlet.png"
echo [6/8] Panasonic 5A Socket .............. OK

copy /Y "%SRC%\surge_protector_1777393478938.png" "%DST%\surge_protector.png"
echo [7/8] Havells DIGISURGE Surge Guard .... OK

copy /Y "%SRC%\rccb_breaker_1777393500713.png" "%DST%\rccb_breaker.png"
echo [8/8] Legrand RCCB 40A 30mA ............ OK

echo.
echo =============================================
echo  All 8 product images installed!
echo =============================================
echo.
pause
