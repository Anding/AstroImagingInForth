## Next Steps for Astroimaging in Forth

1. Provide a facility to interrupt / abandon expsoures

2. Consider how to organize source files for different directions of abstraction

3. Rename model and focus folders with a UUID suffix after the run (use a PS1 script)

4. Add a facility to abort auto-focus or mount-run using KEY and KEY?

5. A facility to apply a general flat frame to obtain a rough-calibrated image

6. A dedicated astro-focus package with a list of suitable focus stars

6a. re-use skyregion code to find the nearest focus star

6b. Take subframes around the focus star for speed

6c. Adjust focus times to reduce saturation

6b. Ask Han for some saturation information in the analysis output files
