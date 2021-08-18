#! /bin/bash
LCD=/dev/`whichlcd`
DIR=/sys/class/hd44780/`whichlcd`

        

printf "\x1bc\x1b[1;1H" >> ${LCD}
printf "\x00\x01\x02\x03\x04\x05\x06\x07" >> ${LCD}
printf "\x1b[2;2H" >> ${LCD}
printf "\x00\x01\x02\x03\x04\x05\x06\x07" >> ${LCD}
printf "\x1b[3;3H" >> ${LCD}
printf "\x00\x01\x02\x03\x04\x05\x06\x07" >> ${LCD}
printf "\x1b[4;4H" >> ${LCD}
printf "\x00\x01\x02\x03\x04\x05\x06\x07" >> ${LCD}
