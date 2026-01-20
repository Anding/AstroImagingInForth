\ integrate the hardware (camera, focuser, filter-wheel and the mount) and extend the user lectionary for integrated hardware
NEED Forth-map
NEED ForthASI
NEED ForthEFW
NEED ForthEAF
NEED Forth10Micron
NEED ForthXISF
NEED ForthVT100

0 value image                           \ pointer to a ForthXISF image structure
0 value focuser.default.position        \ typical focus position
0 value focuser.default.maxsteps		\ just within full range of travel, to protect the telescope
0 value focuser.default.backlash        \ as measured by experiment on this rig
0 value focuser.default.reverse	        \ focuser reverse depends on mounting direction
0 value camera.default.gain
0 value camera.default.offset

: connect ( --)
\ connect all hardware and allocate necessary resources

	scan-cameras 
	0 add-camera
	0 use-camera
	camera.default.gain   ->camera_gain
	camera.default.offset ->camera_offset
	camera_pixels 1 ( width height bitplanes) allocate-image ( img) -> image	

	scan-wheels
	0 add-wheel
	0 use-wheel
	0 ->wheel_position
	
	scan-focusers
	0 add-focuser
	0 use-focuser
	focuser.default.reverse  ->focuser_reverse
	focuser.default.backlash ->focuser_backlash
	focuser.default.maxsteps ->focuser_maxsteps
	focuser.default.position ->focuser_position	
	
	add-mount	
;

: check ( --)
\ check all hardware connections	
	check-wheel
	check-focuser
	check-camera
	check-mount
;

: disconnect ( --)
\ disconnect all hardware and free accociated resources
    0 ->wheel_position wait-wheel
	0 remove-wheel
	
	focuser.default.position ->focuser_position wait-focuser
	0 remove-focuser
	
	0 remove-camera	
    image free-image
    
	remove-mount
;

: (expose) ( -- IOR)
\ internal word of expose
	start-exposure
 	\ add FITS keys
 	image FITS_MAP @ add-cameraFITS 	 		\ must begin the FITS header with add-cameraFITS	
 	image FITS_MAP @ add-observationFITS
 	image FITS_MAP @ add-rigFITS	
 	image FITS_MAP @ add-wheelFITS
 	image FITS_MAP @ add-focuserFITS	
 	image FITS_MAP @ add-mountFITS
 	\ wait for the exposure to complete
	camera_exposure 1000000 / ( secs)
	dup 1 >= if 
	    .countdown ( flag) ?dup if 
	        cr ." exposure stopped" .>E cr exit 
	    then
	else
	    camera_exposure 1000 / ms 
	then
	image IMAGE_BITMAP image image_size ( addr n) download-image 0 
;

: expose ( --)
\ take an image and save it in XISF format
    (expose) if exit then 
    image save-XISFimage					
    cr image XISF_FILEPATH_BUFFER buffer-to-string .> cr
;

: exposeFITS ( --)
\ take an image and save it in FITS format
    (expose) if exit then 
	image save-FITSimage					
	CR image FITS_FILEPATH_BUFFER buffer-to-string type
;
