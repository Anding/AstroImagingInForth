\ setup a particular rig at a particular observatory

\ the user file integrates the hardware (camera, focuser, filter-wheel and the mount) to create a user lexionary for interactive astroimaging
include "%idir%\AstroImagingInForth.f"

\ define local values for this rig at this observatory
192 168 0 15 toIPv4 -> 10Micron.IP		
5200    -> focuser.default.position		\ "2047 focuser": 5200; Takahashi focuser: 2280
6000    -> focuser.default.maxsteps		\ just within full range of travel, to protect the telescope
80      -> focuser.default.backlash		\ as measured by experiment on this rig\
0       -> focuser.default.reverse		\ focuser reverse depends on mounting direction
100     -> camera.default.gain
0       -> camera.default.offset
20 Secs -> camera.default.exposure			
s" 160.0"		 	$-> rig.aperature_dia
s" 17000.0"         $-> rig.aperature_area
s" 530.0"			$-> rig.focal_len
s" 3.3"				$-> rig.focal_ratio
s" 2.8"             $-> focuser.stepsize \ "2047 focuser": 2.8 um/step; Takahashi focuser: 4.2 um/step
s" Takahashi Epsilon 160ED " $-> rig.telescope
s" github.com/Anding/AstroImagingInForth" $-> rig.software
s" Anding" $-> obs.observer
light frames
	
\ filter wheel settings
BEGIN-ENUM
	+ENUM LUM
	+ENUM RED
	+ENUM GREEN
	+ENUM BLUE
	+ENUM Ha
	+ENUM SII
	+ENUM OIII
END-ENUM

BEGIN-ENUMS DB_filterBand
	+" LUM"
	+" RED"
	+" GREEN"
	+" BLUE"
	+" H-ALPHA"
	+" SII"
	+" OIII"
END-ENUMS

ASSIGN DB_filterBand TO-DO filterBand
	
BEGIN-ENUMS DB_filterSpec
	+" Astronomik UV-IR-BLOCK L-2"
	+" Astronomik Deep-Sky Red"
	+" Astronomik Deep-Sky Green"
	+" Astronomik Deep-Sky Blue"
	+" Astronomik MaxFR 6nm H-alpha"
	+" Astronomik MaxFR 6nm SII"
	+" Astronomik MaxFR 6nm OIII"
END-ENUMS

ASSIGN DB_filterSpec TO-DO filterSpec
	
