\ integrate the camera, focuser, filter-wheel and the mount to create a user lexionary for astroimaging

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

: intitialize

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
	
	\ obtain the size of the camera sensor and allocate an image buffer with descriptor, and forth-maps
	camera_pixels ( width height) -> sensor.height -> sensor.width	
	
	\ allocate the ForthXISF image structure
	sensor.width sensor.height 1 allocate-image ( img) -> image		
	map ( forth-map) image FITS_map !
	map ( forth-map) image XISF_map !	
	
;

: expose
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


