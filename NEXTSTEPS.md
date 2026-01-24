## Next Steps for Astroimaging in Forth

- Opimize expose route to exclude mount fits for exposures of less than 10 seconds, and to exclude any ms delay

- Live testing, improve script reporting with ForthVT100

- Develop script-focus to utilize subframes, integrate with ForthASTAP

- Develop script-model to handle model building through 10micron control words

- Develop further scripts

- Example: auto-flats

- Example : a dedicated astro-focus package with a list of suitable focus stars

-   Re-use skyregion code to find the nearest focus star

-   Take subframes around the focus star for speed

-   Adjust focus times to reduce saturation

-   Ask Han for some saturation information in the analysis output files
