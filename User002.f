

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
	\ camera_exposure 1000 / 100 + ms	
	image IMAGE_BITMAP image image_size ( addr n) download-image
	image save-FITSimage					
	CR image FITS_FILEPATH_BUFFER buffer-to-string type
;