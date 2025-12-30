\ setup a particular rig at a particular observatory

\ the user file integrates the hardware (camera, focuser, filter-wheel and the mount) to create a user lexionary for interactive astroimaging
include "%idir%\User001.f"

\ define local values for this rig at this observatory
2340	value focuser.default.position		\ typical focus position
6000  value focuser.default.maxsteps		\ just within full range of travel, to protect the telescope
80		value focuser.default.backlash		\ as measured by experiment on this rig
0			value focuser.default.reverse			\ focuser reverse depends on mounting direction

\ populate expected hardware values (mainly for FITS key information)
192 168 0 15 toIPv4 -> 10Micron.IP						
160 -> rig.aperature_dia
17000 -> rig.aperature_area
530 -> rig.focal_len
s" 4.2 um/step" $-> focuser.stepsize
s" Takahashi Epsilon 160ED " $-> rig.telescope
s" github.com/Anding/AstroImagingInForth" $-> rig.software
s" Anding" $-> obs.observer
	
: initialize
	\ prepare the focuser
	focuser.default.reverse  ->focuser_reverse
	focuser.default.backlash ->focuser_backlash
	focuser.default.maxsteps ->focuser_maxsteps
	focuser.default.position ->focuser_position	
	\ allocate the ForthXISF image structure depending on the camera sensor size
	camera_pixels 1 ( width height bitplanes) allocate-image ( img) -> image		
	map ( forth-map) image FITS_map !
	map ( forth-map) image XISF_map !	
;

: finalize
		0 ->wheel_position
		focuser.default.position ->focuser_position	
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

\ ForthXISF save-file file/path names
: DB_write-filepath_buffer { map buf -- }

	\ directory
	s" e:\images\" buf write-buffer drop
	s" NIGHTOF" map >string buf write-buffer drop 
	'\' buf echo-buffer drop
	s" OBJECT" map >string nip 0 = if
		s" IMAGETYP" map >string buf write-buffer drop 
	else
		s" OBJECT" map >string buf write-buffer drop 
	then
	'\' buf echo-buffer drop
	
	buf buffer-punctuate-filepath
	\ filename
	s" FILTER" map >string buf write-buffer drop 
	s" -F" buf write-buffer drop
	s" FOCUSPOS" map >string buf write-buffer drop 
	'-' buf echo-buffer drop
	s" UUID" map >string drop 24 + 12 buf write-buffer drop
	s" .xisf" buf write-buffer drop
;

	ASSIGN DB_write-filepath_buffer TO-DO write-filepath_buffer
	
