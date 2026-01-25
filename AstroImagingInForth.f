\ integrate the hardware (camera, focuser, filter-wheel and the mount) and extend the user lectionary for integrated hardware
NEED ForthBase
NEED Forth-map
NEED ForthASI
NEED ForthEFW
NEED ForthEAF
NEED Forth10Micron
NEED ForthXISF
NEED ForthASTAP
NEED ForthVT100
CLS

0 value image                           \ pointer to a ForthXISF image structure
0 value focuser.default.position        \ typical focus position
0 value focuser.default.maxsteps		\ just within full range of travel, to protect the telescope
0 value focuser.default.backlash        \ as measured by experiment on this rig
0 value focuser.default.reverse	        \ focuser reverse depends on mounting direction
0 value camera.default.gain
0 value camera.default.offset
0 value camera.default.exposure
s" " $value aif.msg01

: connect ( --)
\ connect all hardware and allocate necessary resources
    cr s" connecting..." .>
	0 add-camera
	0 use-camera
	camera.default.gain   ->camera_gain
	camera.default.offset ->camera_offset
	camera.default.exposure ->camera_exposure	
	camera_pixels 1 ( width height bitplanes) allocate-image ( img) -> image	
    -cr
	0 add-wheel
	0 use-wheel
	0 ->wheel_position
    -cr	
	0 add-focuser
	0 use-focuser
	focuser.default.reverse  ->focuser_reverse
	focuser.default.backlash ->focuser_backlash
	focuser.default.maxsteps ->focuser_maxsteps
	focuser.default.position ->focuser_position	
	-cr
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
    cr s" disconnecting..." .>   
    wait-wheel 0 ->wheel_position
	0 remove-wheel
	wait-focuser focuser.default.position ->focuser_position
	0 remove-focuser
	0 remove-camera	
    image free-image
	remove-mount
;

: <expose> ( --)
\ internal word of expose
    s" starting " $-> aif.msg01 
    camera_exposure 1000 / ( duration_ms)
    dup dup 1000 >= if
        1000 / (.) $+> aif.msg01 s"  second exposure..." $+> aif.msg01
    else
        (.) $+> aif.msg01 s"  milliscecond exposure..." $+> aif.msg01
    then cr aif.msg01 .>
	start-exposure
	ticks                   ( duration_ms start)
 	image FITS_MAP @ add-cameraFITS            
 	image FITS_MAP @ add-observationFITS        
 	image FITS_MAP @ add-rigFITS   
 	image FITS_MAP @ add-wheelFITS
 	image FITS_MAP @ add-focuserFITS
 	image FITS_MAP @ add-mountFITS              
 	ticks swap - 0 max      ( duration_ms elapsed_ms)   \ beware rollover of ticks counter
	- dup                   ( remaining_ms)
	1000 >= if 
	    1000 / ( S) .countdown ( flag) ?dup if s" Exposure stopped" .>E abort then \ abort through any running script
	else
	    ms 
	then
	s" downloading image..." .>
	image IMAGE_BITMAP image image_size ( addr n) download-image
	s" saving image..." .>
;


: XISFfilepath ( -- caddr u)
\ return the XISF filename of the most recent image
    image XISF_FILEPATH_BUFFER buffer-to-string
; 

: FITSfilepath ( -- caddr u)
\ return the FITS filename of the most recent image
    image FITS_FILEPATH_BUFFER buffer-to-string
; 

: FITSfolder ( img -- caddr u)
\ return the FITS folder of the most recent image
    image FITS_FILEPATH_BUFFER buffer-folder-to-string
; 

: expose ( --)
\ take an image and save it in XISF format
    <expose>
    image save-XISFimage					
    XISFfilepath .> cr
;

: exposeFITS ( --)
\ take an image and save it in FITS format
    <expose>
	image save-FITSimage					
	FITSfilepath .> cr
;
