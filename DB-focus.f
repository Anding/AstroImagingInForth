 include "%idir%\DB.f"

21 value autofocus.points			\ prefer an odd number
10 value autofocus.increment

NEED ForthASTAP

: focus-bracket ( Alt Az -- )
	
	focuser.default.position autofocus.points 2 / 1+ autofocus.increment * + 	( f_high)
	focuser.default.position autofocus.points 2 / autofocus.increment * - 		( f_low)
	do
	 cr ." focus to " i . 
	 i focus-to 
	 ." and expose"
	 exposeFITS
	autofocus.increment +loop
	focuser.default.position dup ->focuser_position 
	cr ." return focus to " . 
;

: User003_write-FITSfilepath_buffer { map buf -- }									\ VFX locals
\ map is a completed FITSKEY map that will interrogated to create the filename
\ buf may point to IMAGE_DESCRIPTOR..FILEPATH_BUFFER to complete the XISF structure
\ 
	\ directory
	s" e:\images\" buf write-buffer drop
	s" NIGHTOF" map >string buf write-buffer drop 
	s" \Focus\" buf write-buffer drop 
	
	buf buffer-punctuate-filepath
	
	\ filename
	'F' buf echo-buffer drop
	s" FOCUSPOS" map >string buf write-buffer drop 
	'-' buf echo-buffer drop
	s" UUID" map >string drop 24 + 12 buf write-buffer drop
	s" .fits" buf write-buffer drop
;

	ASSIGN user003_write-FITSfilepath_buffer TO-DO write-FITSfilepath_buffer


