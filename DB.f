\ setup a particular rig at a particular observatory

NEED shared

0 SHARED value sensor.width			\ camera pixesl	
0 SHARED value sensor.height			\ camera pixels
0 SHARED value focuser.default		\ typical optimum focus position
0 SHARED value image						\ pointer to a ForthXISF image structure

\ the user file integrates the hardware (camera, focuser, filter-wheel and the mount) to create a user lexionary for interactive astroimaging
include "%idir%\User001.f"

\ 10Micron fixed IP address
192 168 0 15 toIPv4 -> 10Micron.IP				
\ for FITS keywords				
160 -> rig.aperature_dia
17000 -> rig.aperature_area
530 -> rig.focal_len
s" Takahashi Epsilon 160ED " $-> rig.telescope
s" github.com/Anding/AstroImagingInForth" $-> rig.software
s" Anding" $-> obs.observer
	
: initialize
	-1 ->focuser_reverse  	\ focuser reverse depends on mounting direction
	focuser.default ->focuser_position
	\ allocate the ForthXISF image structure depending on the camera sensor size
	sensor.width sensor.height 1 allocate-image ( img) -> image		
	map ( forth-map) image FITS_map !
	map ( forth-map) image XISF_map !	
;

\ filter wheel

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
	
