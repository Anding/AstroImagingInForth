\ script for taking autofocus images

11 value autofocus.points			\ prefer an odd number
20 value autofocus.increment
20 secs value autofocus.exposure
s" 000000000000" $value autofocus.UUID
s" " $value autofocus.str1
0  value autofocus.save.XT
0  value autofocus.save.exposure

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

    \ set the save filepath and exposure duration
    ACTION-OF write-FITSfilepath -> autofocus.save.XT
	ASSIGN autofocus.write-FITSfilepath TO-DO write-FITSfilepath
    UUID $-> autofocus.UUID	
    camera_exposure -> autofocus.save.exposure
    autofocus.exposure duration
   
    30 subframe \ 30% square subframe for speed        
	focuser.default.position autofocus.points 2 / 1+ autofocus.increment * + 	( f_high)
	focuser.default.position autofocus.points 2 / autofocus.increment * - 		( f_low)
	do
	 i focus-at
	  exposeFITS
	  autofocus.increment +loop
	focuser.default.position focus-at
	fullframe
	
	\ restore the save filepath and duration
    autofocus.save.XT TO-DO write-FITSfilepath
    autofocus.save.exposure duration
;

: autofocus ( --)
\ autofocus at the current position
    focus-bracket
    s" invoke ASTAP..." .>
    FITSfolder astap.findfocus 0= if
        s" ATAP found focus.  Refocusing at..." .>
        focus-at drop
    else
        s" Failed to autofocus" .>
    then
;



