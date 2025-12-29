\ integrate the hardware (camera, focuser, filter-wheel and the mount) to create a user lexionary for interactive astroimaging

NEED SHARED
NEED Forth-map
NEED ForthASI
NEED ForthEFW
NEED ForthEAF
NEED Forth10Micron
NEED ForthXISF

0 SHARED value sensor.width			\ camera pixesl	
0 SHARED value sensor.height			\ camera pixels
0 SHARED value image						\ pointer to a ForthXISF image structure

0 SHARED value exposure.duration		\ exposure duration in micro seconds
0 SHARED value focuser.default		\ typical optimum focus position


: connect ( --)
\ connect all hardware	

	\ activate the camera
	scan-cameras 
	0 add-camera
	0 use-camera
	camera_pixels ( width height) -> sensor.height -> sensor.width		
	
	\ activate the filter wheel
	scan-wheels
	0 add-wheel
	0 use-wheel
	
	\ activate the focuser
	scan-focusers
	0 add-focuser
	0 use-focuser
	
	\ connect to the mount
	add-mount	
	
;

: check ( --)
\ check all hardware connections	
;

: disconnect ( --)
\ disocnnect all hardware

	0 ->wheel_position	
	0 remove-wheel	
\  focuser.default ->focuser_position
	0 remove-focuser
	0 remove-camera	
	remove-mount
;

: expose ( --)
\ take an image
	exposure.duration ->camera_exposure
	start-exposure
	\ add mandatory XISF fields
 	image XISF_MAP @ add-observationXISF	
 	image XISF_MAP @ add-cameraXISF	 	
 	\ add FITS keys
 	image FITS_MAP @ add-observationFITS
 	image FITS_MAP @ add-cameraFITS 	
 	image FITS_MAP @ add-rigFITS	
 	image FITS_MAP @ add-wheelFITS
 	image FITS_MAP @ add-focuserFITS	
 	image FITS_MAP @ add-mountFITS
 	\ wait for the exposure to complete
	camera_exposure 1000 / 100 + ms	
	image IMAGE_BITMAP image image_size ( addr n) download-image
	image save-image						\ 
;

: duration ( us --)
\ set the exposure duration
	-> exposure.duration
;

: frames	( n --) 	\ see ForthXISF\properties_obs.f
\ set the bias, dark, flat, light frame type
	-> obs.type
;

: focus-to ( pos --)
	->focuser_position 
;

: focus-by ( delta --)
	focuser_position + 
	->focuser_position
;

: focus? ( -- pos)
	focuser_position cr . cr
;	

: filter ( pos --)
	->wheel_position
;

: filter? ( --)
	wheel_position FITSfilterBand cr type cr
;

: goto ( RA Dec --)
\ slew the mount to an equatorial coordinate
	->mount_equatorial ( RA DEC --)
;

: goto? ( --)
\ obtain the mount position in equatorial coordinates
	mount_equatorial swap CR ~~~. ~~~. CR
;

: object ( caddr u --)
	$-> obs.object
;

