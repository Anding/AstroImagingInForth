\ setup a particular rig at a particular observatory

\ the user file integrates the hardware (camera, focuser, filter-wheel and the mount) to create a user lexionary for interactive astroimaging
include "%idir%\User001.f"

\ define local values for this rig at this observatory
\ 2280	value focuser.default.position		( typical focus position, Takahashi focuser)
5200    value focuser.default.position		( typical focus position, 2047 focuser)
6000    value focuser.default.maxsteps		\ just within full range of travel, to protect the telescope
80      value focuser.default.backlash		\ as measured by experiment on this rig
0	    value focuser.default.reverse		\ focuser reverse depends on mounting direction
100		value camera.default.gain
0	    value camera.default.offset
light frames

\ populate expected hardware values (mainly for FITS key information)
192 168 0 15 toIPv4 -> 10Micron.IP						
20 secs -> exposure.duration
s" 160.0"		 	$-> rig.aperature_dia
s" 17000.0" 	$-> rig.aperature_area
s" 530.0"			$-> rig.focal_len
s" 3.3"				$-> rig.focal_ratio
\ s" 4.2" 			$-> focuser.stepsize ( um/step, Takahashi focuser)
s" 2.8"             $-> focuser.stepsize ( um/step, 2047 focuser)
s" Takahashi Epsilon 160ED " $-> rig.telescope
s" github.com/Anding/AstroImagingInForth" $-> rig.software
s" Anding" $-> obs.observer
	
: initialize
	\ prepare the focuser
	focuser.default.reverse  ->focuser_reverse
	focuser.default.backlash ->focuser_backlash
	focuser.default.maxsteps ->focuser_maxsteps
	focuser.default.position ->focuser_position	
	camera.default.gain ->camera_gain
	camera.default.offset ->camera_offset
	\ allocate the ForthXISF image structure depending on the camera sensor size
	camera_pixels 1 ( width height bitplanes) allocate-image ( img) -> image		
;

: finalize
		wait-wheel
		0 ->wheel_position
		wait-focuser
		focuser.default.position ->focuser_position	
		image free-image
;

\ filter wheel settings
BEGIN-ENUM
	+ENUM LUM
	+ENUM RED
	+ENUM GREEN
	+ENUM BLUE
	+ENUM H-ALPHA
	+ENUM SII
	+ENUM OIII
END-ENUM

BEGIN-ENUMS DB_FITSfilterBand
	+" LUM"
	+" RED"
	+" GREEN"
	+" BLUE"
	+" H-ALPHA"
	+" SII"
	+" OIII"
END-ENUMS

ASSIGN DB_FITSfilterBand TO-DO FITSfilterBand
	
BEGIN-ENUMS DB_FITSfilterSpec
	+" Astronomik UV-IR-BLOCK L-2"
	+" Astronomik Deep-Sky RGB"
	+" Astronomik Deep-Sky RGB"
	+" Astronomik Deep-Sky RGB"
	+" Astronomik MaxFR 6nm"
	+" Astronomik MaxFR 6nm"
	+" Astronomik MaxFR 6nm"
END-ENUMS

ASSIGN DB_FITSfilterSpec TO-DO FITSfilterSpec
	
