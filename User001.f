\ integrate the hardware (camera, focuser, filter-wheel and the mount) to create a user lexionary for interactive astroimaging

NEED Forth-map
NEED ForthASI
NEED ForthEFW
NEED ForthEAF
NEED Forth10Micron
NEED ForthXISF

0 value image							\ pointer to a ForthXISF image structure
20 Secs value exposure.duration	\ exposure duration in micro seconds

: connect ( --)
\ connect all hardware	
	\ activate the camera
	scan-cameras 
	0 add-camera
	0 use-camera

	
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
	check-wheel
	check-focuser
	check-camera
	check-mount
;

: disconnect ( --)
\ disconnect all hardware

	0 remove-wheel	
	0 remove-focuser
	0 remove-camera	
	remove-mount
;

: expose ( --)
\ take an image
	exposure.duration ->camera_exposure
	start-exposure
 	\ add FITS keys
 	image FITS_MAP @ add-cameraFITS 	 		\ must begin the FITS header with add-cameraFITS	
 	image FITS_MAP @ add-observationFITS	\ call observationFITS before observationXISF to set the UUID
 	image FITS_MAP @ add-rigFITS	
 	image FITS_MAP @ add-wheelFITS
 	image FITS_MAP @ add-focuserFITS	
 	image FITS_MAP @ add-mountFITS
	\ add mandatory XISF fields
 	image XISF_MAP @ add-observationXISF	
 	image XISF_MAP @ add-cameraXISF	  	
 	\ wait for the exposure to complete
	camera_exposure 1000 / 100 + ms	
	image IMAGE_BITMAP image image_size ( addr n) download-image
	image save-XISFimage					
	CR image XISF_FILEPATH_BUFFER buffer-to-string type
;

: exposeFITS ( --)
\ take an image
	exposure.duration ->camera_exposure
	start-exposure
 	\ add FITS keys
 	image FITS_MAP @ add-cameraFITS 	 		\ must begin the FITS header with add-cameraFITS	
 	image FITS_MAP @ add-observationFITS	\ call observationFITS before observationXISF to set the UUID
 	image FITS_MAP @ add-rigFITS	
 	image FITS_MAP @ add-wheelFITS
 	image FITS_MAP @ add-focuserFITS	
 	image FITS_MAP @ add-mountFITS
	
 	\ wait for the exposure to complete
	camera_exposure 1000 / 100 + ms	
	image IMAGE_BITMAP image image_size ( addr n) download-image
	image save-FITSimage					
	CR image FITS_FILEPATH_BUFFER buffer-to-string type
;

: duration ( us --)
\ set the exposure duration
	-> exposure.duration
;

: duration? ( -- us)
	exposure.duration cr . cr
;

: frames	( n --) 	\ see ForthXISF\properties_obs.f
\ set the bias, dark, flat, light frame type
	-> obs.type
;

: frames? ( --)
	obs.type observationType
;

: focus-to ( pos --)
	wait-focuser
	->focuser_position 
	wait-focuser
;

: focus-by ( delta --)
	wait-focuser
	focuser_position + 
	->focuser_position
	wait-focuser
;

: focus? ( -- pos)
	focuser_position cr . cr
;	

: filter ( pos --)
	->wheel_position
	wait-wheel
;

: filter? ( --)
	wheel_position FITSfilterBand cr type cr
;

: unpark ( --)
	10u.unpark
	10u.StartTracking
;

: park
	10u.park
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

