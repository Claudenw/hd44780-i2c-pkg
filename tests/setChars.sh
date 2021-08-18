#! /bin/bash
LCD=/dev/`whichlcd`
DIR=/sys/class/hd44780/`whichlcd`

echo EHH0EHH4 >> ${DIR}/char0
echo 0EHLHE00 >> ${DIR}/char1
echo 000AHVHA >> ${DIR}/char2
echo E44AHVHA >> ${DIR}/char3
echo SGS4T552 >> ${DIR}/char4
echo 44444444 >> ${DIR}/char5
echo 4EV44444 >> ${DIR}/char6
echo 44444VE4 >> ${DIR}/char7
