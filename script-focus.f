\ script for taking autofocus images

11 value autofocus.points			\ prefer an odd number
20 value autofocus.increment
s" 000000000000" $value autofocus.UUID
s" " $value autofocus.str1
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

: focus-bracket ( -- )
\ obtain some images for autofocus

    \ set the save filepath
    ACTION-OF write-FITSfilepath -> autofocus.saveXT
	ASSIGN autofocus.write-FITSfilepath TO-DO write-FITSfilepath
    UUID $-> autofocus.UUID	
   
    30 subframe \ 30% square subframe for speed        
	focuser.default.position autofocus.points 2 / 1+ autofocus.increment * + 	( f_high)
	focuser.default.position autofocus.points 2 / autofocus.increment * - 		( f_low)
	do
	 i focus-at -cr
	  exposeFITS -cr
	  autofocus.increment +loop
	focuser.default.position focus-at
	fullframe
	
	\ restore the save filepath
    autofocus.saveXT TO-DO write-FITSfilepath
;

: autofocus ( --)
\ autofocus at the current position
    focus-bracket
    s" invoke ASTAP..." .>
    FITSfolder astap.findfocus 0= if
        s" ATAP found focus.  Refocusing at..." .>
        focus-at drop
    else
        s" Failed to autofocus" .> cr
    then
;



