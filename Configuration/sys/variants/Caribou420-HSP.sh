#!/bin/sh

# =========================================================================================================
# definition for Caribou420 Duet3Mini+ Bondtech - SE HT Thermistor - SuperPINDA
# =========================================================================================================

CARIBOU_VARIANT="Caribou420 Duet3Mini+ Bondtech - SE HT Thermistor - SuperPINDA"
CARIBOU_NAME="Caribou420-HSP"
CARIBOU_ZHEIGHTLEVELING="Z405"
CARIBOU_ZHEIGHT="Z416.50"
CARIBOU_EESTEPS=830.00
CARIBOU_FINALUNLOAD=45
CARIBOU_INITIALLOAD=40
CARIBOU_MINEXTRUDETEMP=180
CARIBOU_MINRETRACTTEMP=180

# set output for sys and macros
#

SysOutputPath=../processed
# prepare output folder
if [ ! -d "$SysOutputPath" ]; then
    mkdir -p $SysOutputPath || exit 27
else
    rm -fr $SysOutputPath || exit 27
    mkdir -p $SysOutputPath || exit 27
fi

MacrosDir=../../macros
MacroOutputPath=$MacrosDir/processed
# prepare output folder
if [ ! -d "$MacroOutputPath" ]; then
    mkdir -p $MacroOutputPath || exit 27
else
    rm -fr $MacroOutputPath || exit 27
    mkdir -p $MacroOutputPath || exit 27
fi

# =========================================================================================================
# create sys files
# =========================================================================================================

# copy sys files to processed folder (for SuperPINDA except deployprobe and retractprobe)
find ../* -maxdepth 0  ! \( -name "*deploy*" -o -name "*retract*" -o -name "*processed*" -o -name "*variants*" \) -exec cp  -rt $SysOutputPath {} +
cp -r ../00-Functions $SysOutputPath

#
# create bed.g
#
sed "
{s/#CARIBOU_VARIANT/$CARIBOU_VARIANT/};
{/#CARIBOU_ZPROBERESET/ c\
M558 F600 T8000 A3 S0.03                               ; for SuperPINDA
};
" < ../bed.g > $SysOutputPath/bed.g

#
# create config.g
#

# general replacements
sed "
{s/#CARIBOU_VARIANT/$CARIBOU_VARIANT/};
{s/#CARIBOU_NAME/$CARIBOU_NAME/};
{s/#CARIBOU_ZHEIGHT/$CARIBOU_ZHEIGHT/};
{s/#CARIBOU_EESTEPS/$CARIBOU_EESTEPS/};
{s/#CARIBOU_MINEXTRUDETEMP/$CARIBOU_MINEXTRUDETEMP/};
{s/#CARIBOU_MINRETRACTTEMP/$CARIBOU_MINRETRACTTEMP/};
" < ../config.g > $SysOutputPath/config.g

# replacemente SE thermistor
sed -i "
{/#CARIBOU_HOTEND_THERMISTOR/ c\
; Hotend (Mosquito or Mosquito Magnum with SE Thermistor) \\
;\\
M308 S1 P\"temp1\" Y\"thermistor\" T500000 B4723 C1.19622e-7 A\"Nozzle\"   ; SE configure sensor 0 as thermistor on pin e0temp\\
;\\
M950 H1 C\"out1\" T1                                        ; create nozzle heater output on e0heat and map it to sensor 2\\
M307 H1 B0 S1.00                                            ; disable bang-bang mode for heater  and set PWM limit\\
M143 H1 S365                                                ; set temperature limit for heater 1 to 365°C
};
" $SysOutputPath/config.g

# replacements for SuperPINDA
sed -i "
{/#CARIBOU_ZPROBE/ c\
; SuperPINDA \\
;\\
M558 P5 C\"^io1.in\" H1.5 F600 T8000 A3 S0.03             ; set z probe to SuperPINDA\\
M557 X23:235 Y5:186 S30.25:30                               ; define mesh grid
};
{/#CARIBOU_OFFSETS/ c\
G31 P1000 X23 Y5
}
" $SysOutputPath/config.g

#
# create homez and homeall
#

sed "
{s/#CARIBOU_VARIANT/$CARIBOU_VARIANT/}
{s/#CARIBOU_MEASUREPOINT/G1 X11.5 Y4.5 F6000               ; go to first probe point/};
{/#CARIBOU_ZPROBE/ c\
;
};" < ../homez.g > $SysOutputPath/homez.g

sed "
{s/#CARIBOU_VARIANT/$CARIBOU_VARIANT/};
{/#CARIBOU_ZPROBE/ c\
;
};
" < ../start.g > $SysOutputPath/start.g

#
# create trigger2.g
#

sed "
{s/#CARIBOU_MINEXTRUDETEMP/$CARIBOU_MINEXTRUDETEMP/};
{s/#CARIBOU_MINRETRACTTEMP/$CARIBOU_MINRETRACTTEMP/};
{s/#CARIBOU_INITIALLOAD/$CARIBOU_INITIALLOAD/g}
" < ../trigger2.g > $SysOutputPath/trigger2.g

# =========================================================================================================
# create macro files
# =========================================================================================================

# copy macros directory to processed folder (for BL-Touch except the Print-Surface Macros)
find $MacrosDir/* -maxdepth 0  ! \( -name "*Main*" -o -name "*Preheat*" -o -name "*processed*" -o -name "*Nozzle*" \) -exec cp -r -t  $MacroOutputPath {} \+
mkdir $MacroOutputPath/04-Maintenance
find $MacrosDir/04-Maintenance/* -maxdepth 0  ! \( -name "*First*" \) -exec cp -r -t  $MacroOutputPath/04-Maintenance {} \+
cp -r $MacrosDir/04-Maintenance/01-First_Layer_Calibration/processed $MacroOutputPath/04-Maintenance/01-First_Layer_Calibration
cp -r $MacrosDir/00-Preheat/processed $MacroOutputPath/00-Preheat

# create 00-Level-X-Axis
#
sed "
{s/#CARIBOU_VARIANT/$CARIBOU_VARIANT/};
{s/#CARIBOU_NAME/$CARIBOU_NAME/};
{s/#CARIBOU_ZHEIGHTLEVELING/$CARIBOU_ZHEIGHTLEVELING/}
{s/#CARIBOU_ZHEIGHT/$CARIBOU_ZHEIGHT/}
" < $MacrosDir/04-Maintenance/00-Self_Tests/01-Level_X-Axis > $MacroOutputPath/04-Maintenance/00-Self_Tests/01-Level_X-Axis

# create Load_Filament
#
sed "
{s/#CARIBOU_VARIANT/$CARIBOU_VARIANT/};
{s/#CARIBOU_MINEXTRUDETEMP/$CARIBOU_MINEXTRUDETEMP/};
{s/#CARIBOU_MINRETRACTTEMP/$CARIBOU_MINRETRACTTEMP/};
{s/#CARIBOU_INITIALLOAD/$CARIBOU_INITIALLOAD/g}
" < $MacrosDir/01-Filament_Handling/00-Load_Filament > $MacroOutputPath/01-Filament_Handling/00-Load_Filament

# create Unload_Filament
#
sed "
{s/#CARIBOU_VARIANT/$CARIBOU_VARIANT/};
{s/#CARIBOU_MINEXTRUDETEMP/$CARIBOU_MINEXTRUDETEMP/};
{s/#CARIBOU_MINRETRACTTEMP/$CARIBOU_MINRETRACTTEMP/};
{s/#CARIBOU_FINALUNLOAD/$CARIBOU_FINALUNLOAD/g}
" < $MacrosDir/01-Filament_Handling/01-Unload_Filament > $MacroOutputPath/01-Filament_Handling/01-Unload_Filament

# create Change_Filament
#
sed "
{s/#CARIBOU_VARIANT/$CARIBOU_VARIANT/};
{s/#CARIBOU_MINEXTRUDETEMP/$CARIBOU_MINEXTRUDETEMP/};
{s/#CARIBOU_MINRETRACTTEMP/$CARIBOU_MINRETRACTTEMP/};
{s/#CARIBOU_INITIALLOAD/$CARIBOU_INITIALLOAD/g}
{s/#CARIBOU_FINALUNLOAD/$CARIBOU_FINALUNLOAD/g}
" < $MacrosDir/01-Filament_Handling/03-Change_Filament > $MacroOutputPath/01-Filament_Handling/03-Change_Filament

# =========================================================================================================