\ setup a particular rig at a particular observatory

\ the Setup file integrates the particular hardware and provides a user lexicon
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


\ save-file file/path names
: DB_write-filepath_buffer { map buf -- }
\ prepare a filepath with filename for an XISF file	
\ map is a completed FITSKEY map that will interrogated to create the filename
\ buf may point to IMAGE_DESCRIPTOR..FILEPATH_BUFFER to complete the XISF structure
\ 
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