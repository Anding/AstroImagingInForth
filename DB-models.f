include "%idir%\DB.f"

NEED ForthASTAP

: modelPoint ( Alt Az -- )
\ slew to Alt Az and continue tracking
\ expose an image
\ plate solve
  2dup swap cr ." Model point at Alt " ~. ."  Az " ~.
	->mount_horizon \ synchronous
	cr ." .  Slew completed. "
	exposeFITS
	cr ." Exposing.  "
	image FITS_FILEPATH_BUFFER buffer-to-string platesolve 
	0= if 
		swap ."  Plate solve successful at RA " ~. ."  Dec " ~. 
		else
		."  Plate solve failed"
	then
;

: User002_write-FITSfilepath_buffer { map buf -- }									\ VFX locals
\ map is a completed FITSKEY map that will interrogated to create the filename
\ buf may point to IMAGE_DESCRIPTOR..FILEPATH_BUFFER to complete the XISF structure
\ 
	\ directory
	s" e:\images\" buf write-buffer drop
	s" NIGHTOF" map >string buf write-buffer drop 
	s" \Model\" buf write-buffer drop 
	
	buf buffer-punctuate-filepath
	
	\ filename
	s" UUID" map >string drop 24 + 12 buf write-buffer drop
	s" .fits" buf write-buffer drop
;

	ASSIGN user002_write-FITSfilepath_buffer TO-DO write-FITSfilepath_buffer
: run-model ( --)
\ obtain some model points

80 00 00 Alt 090 00 00 Az modelPoint
75 00 00 Alt 120 00 00 Az modelPoint
65 00 00 Alt 180 00 00 Az modelPoint
60 00 00 Alt 240 00 00 Az modelPoint
55 00 00 Alt 210 00 00 Az modelPoint
50 00 00 Alt 180 00 00 Az modelPoint
45 00 00 Alt 150 00 00 Az modelPoint
40 00 00 Alt 120 00 00 Az modelPoint

;

