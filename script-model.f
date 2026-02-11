\ script for taking model points

20 Secs value model.default.exposure
20 Secs value model.save.exposure	
s" 000000000000" $value model.UUID
s" " $value model.str1
0 value model.save.XT

: model-point ( Alt Az -- )
\ slew to Alt Az and continue tracking
\ expose an image
\ plate solve
\  2dup swap s" Model point at Alt " $-> model.str1 <.ALT> $+> model.str1 s"  Az " $+> model.str1 <.AZ> $+> model.str1  model.str1 .>
	gotoAltAz
	exposeFITS cr
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
	s" ALT_" buf write-buffer drop 
	s" OBJCTALT" map >string BL csplit buf write-buffer drop 2drop
	s" -AZ_" buf write-buffer drop 
	s" OBJCTAZ"  map >string BL csplit buf write-buffer drop 2drop
	s" .fits" buf write-buffer drop
;

defer modelPoints 
    
: def_modelPoints ( --)
\ obtain 14 model points
    
    75 00 00 Alt 080 00 00 Az model-point
    70 00 00 Alt 100 00 00 Az model-point
    65 00 00 Alt 120 00 00 Az model-point
    60 00 00 Alt 140 00 00 Az model-point
    55 00 00 Alt 160 00 00 Az model-point
    50 00 00 Alt 180 00 00 Az model-point
    80 00 00 Alt 180 00 00 Az model-point
    75 00 00 Alt 200 00 00 Az model-point
    70 00 00 Alt 220 00 00 Az model-point
    65 00 00 Alt 240 00 00 Az model-point
    60 00 00 Alt 260 00 00 Az model-point
    55 00 00 Alt 280 00 00 Az model-point
    50 00 00 Alt 300 00 00 Az model-point
;

assign def_modelPoints to-do modelPoints 

: make-model 
    cr
    \ set the save filepath and exposure duration
    ACTION-OF write-FITSfilepath -> model.save.XT
	ASSIGN model.write-FITSfilepath TO-DO write-FITSfilepath
    UUID $-> model.UUID
    camera_exposure -> model.save.exposure
    model.default.exposure duration    
    
    s" Backup and delete current model" .> cr
    s" backup" save-alignment-model
    park
    delete-alignment-model
    modelPoints  
    
    \ restore the save filepath and exposure duration
    model.save.XT TO-DO write-FITSfilepath
    model.save.exposure	duration
    park

    \ create the model
    s" Plate solving" .> cr
    FITSfolder ASTAP.solveFolder
    FITSfolder astap.folder-to-ALPT
    0= if 
        new-alignment-model 
        0= if 
            .alignment 
            exit
        then 
    then
    s" Failed to create new model.  Reload from backup" .>E
    s" backup" load-alignment-model
;
