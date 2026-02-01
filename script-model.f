\ script for taking model points

20 Secs -> model.default.exposure
0 value model.save.exposure	
s" 000000000000" $value model.UUID
0 value model.save.XT

: model-point ( Alt Az -- )
\ slew to Alt Az and continue tracking
\ expose an image
\ plate solve
  2dup swap cr s" Model point at Alt " .> ~. s"  Az " .> ~.
	gotoAltAz
	cr exposeFITS
	cr FITSfilepath platesolve 
	0= if 
		swap s" Plate solve successful at RA " .> ~. s"  Dec " .> ~.
		else
		s" Plate solve failed" .>E
	then
;

: model.write-FITSfilepath { map buf -- }									
\ map is a completed FITSKEY map that will interrogated to create the filename
\ buf may point to IMAGE_DESCRIPTOR..FILEPATH_BUFFER to complete the XISF structure
\ 
	\ directory
	s" e:\images\" buf write-buffer drop
	s" NIGHTOF" map >string buf write-buffer drop 
	s" \Models\" buf write-buffer drop 
	model.UUID drop 24 + 12 buf write-buffer drop 
	'\' buf echo-buffer drop
	
	buf buffer-punctuate-filepath
	
	\ filename in format ALT_80-AZ_160.fits
	s" ALT_"
	s" OBJCTALT" map >string BL csplit buf write-buffer drop 2drop
	s" -AZ_"
	s" OBJCTAZ"  map >string BL csplit buf write-buffer drop 2drop	
	s" .fits" buf write-buffer drop
;

defer modelPoints 
    
: def_modelPoints ( --)
\ obtain some model points
    80 00 00 Alt 090 00 00 Az model-point
    75 00 00 Alt 120 00 00 Az model-point
    65 00 00 Alt 180 00 00 Az model-point
    60 00 00 Alt 240 00 00 Az model-point
    55 00 00 Alt 210 00 00 Az model-point
    50 00 00 Alt 180 00 00 Az model-point
    45 00 00 Alt 150 00 00 Az model-point
    40 00 00 Alt 120 00 00 Az model-point
;

assign def_modelPoints todo modelPoints 

: make-model 
    \ set the save filepath and exposure duration
    ACTION-OF write-FITSfilepath -> model.save.XT
	ASSIGN model.write-FITSfilepath TO-DO write-FITSfilepath
    UUID $-> model.UUI
    model.default.exposure duration    
    
    
    s" backup and delete current model" .> cr
    s" backup" save-alignment-model
    delete-alignment-model
    modelPoints  
    
    \ restore the save filepath and exposure duration
    model.save.XT TO-DO write-FITSfilepath
    model.save.exposure	duration

    \ create the model
    FITSfolder astap.folder-to-ALPT
    0= if 
        new-alignment-model 
        0= if 
            .alignment 
            exit
        then 
    then
     
    s" failed to create new model, reload from backup" .>E cr
    s" backup" load-alignment-model
;
