045 value Az_lo
315 value Az_hi
040 value Alt_lo
085 value Alt_hi
005 value Exp_lo
180 value Exp_hi

: randomAltAz ( -- Alt Az)
\ return a random Alt Az in finite fraction format from the range
    Alt_hi Alt_lo - 1+ choose Alt_lo + 0 0 Alt
    Az_hi  Az_lo  - 1+ choose Az_lo  + 0 0 Az
;

: randomExp ( -- Exp)
\ return a random exposure time in the range
    Exp_hi Exp_lo - 1+ choose Exp_lo + 
;

: randomBool ( -- flag)
\ return a random boolean
    2 choose ( 0 or 1) 1- ( -1 or 0)
;

: random-sky
    begin
        randomAltAz gotoAltAz
        randomExp Secs duration
        randomBool
        if expose else exposeFITS then
    again
;

: random_modelPoints ( --)
  27 0 do
    randomAltAz model-point
  loop
;