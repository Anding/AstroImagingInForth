\ script for taking autofocus images

21 value autofocus.points			\ prefer an odd number
10 value autofocus.increment
s" 000000000000" $value autofocus.UUID
0  value autofocus.saveXT

: autofocus.write-FITSfilepath { map buf -- }									\ VFX locals
\ map is a completed FITSKEY map that will interrogated to create the filename
\ buf may point to IMAGE_DESCRIPTOR..FILEPATH_BUFFER to complete the XISF structure
\ 
	\ directory
	s" e:\images\" buf write-buffer drop
	s" NIGHTOF" map >string buf write-buffer drop 
	s" \Focus\" buf write-buffer drop 
	autofocus.UUID drop 24 + 12 buf write-buffer drop 
	'\' buf echo-buffer drop	
	buf buffer-punctuate-filepath
	
	\ filename in format F2000-000000000000.fits
	'F' buf echo-buffer drop
	s" FOCUSPOS" map >string buf write-buffer drop 
	'-' buf echo-buffer drop
	s" UUID" map >string drop 24 + 12 buf write-buffer drop
	s" .fits" buf write-buffer drop
;

: focus-bracket ( Alt Az -- )
\ obtain some images for autofocus

    \ set the save filepath
    ACTION-OF write-FITSfilepath -> model.saveXT
	ASSIGN autofocus.write-FITSfilepath TO-DO write-FITSfilepath
    UUID $-> model.UUID	
        
	focuser.default.position autofocus.points 2 / 1+ autofocus.increment * + 	( f_high)
	focuser.default.position autofocus.points 2 / autofocus.increment * - 		( f_low)
	do
	 cr s" focus at " .> i (.) .> 
	 i focus-at 
	 cr exposeFITS
	autofocus.increment +loop
	focuser.default.position dup ->focuser_position 
	cr s" return focus to " .>
;



