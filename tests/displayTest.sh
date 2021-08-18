#! /bin/bash
LCD=/dev/`whichlcd`
DIR=/sys/class/hd44780/`whichlcd`

function ok {
    read -p "$*" flag
    case $flag in 
        [Yy]* ) 
                echo ok
                ;;
        [Nn]* ) exit 1;
                ;;
    esac
}
read -p "press enter to start" flag
printf "\x1b[1;0H12345678901234567890" >> ${LCD}
printf "\x1b[2;0H23456789012345678901" >> ${LCD}
printf "\x1b[3;0H34567890123456789012" >> ${LCD}
printf "\x1b[4;0H45678901234567890123" >> ${LCD}
ok Numeric pattern ok? 

printf "\x13" >> ${LCD}
ok Backlight off? 

printf "\x11" >> ${LCD}
ok Backlight on? 

printf "\x1b[HHello" >> ${LCD}
ok Hello @ home?

printf "\x1b[1;10HTEN" >> ${LCD}
ok TEN @ 1,10

printf "\x1b[2;5HFIVE" >> ${LCD}
ok FIVE @ 2,5

printf "\x1b[3;3HTHREE" >> ${LCD}
ok THREE @ 3,3

printf "\x1b[4;13HYEO" >> ${LCD}
ok YEO @ 4,13

#printf "\x1bc" >> ${LCD}
#ok Screan cleared


printf "\x1b[1;0H12345678901234567890" >> ${LCD}
printf "\x1b[2;0H23456789012345678901" >> ${LCD}
printf "\x1b[3;0H34567890123456789012" >> ${LCD}
printf "\x1b[4;0H45678901234567890123" >> ${LCD}

printf "\x1b[3;10H\x1b[J" >> ${LCD}
ok cleared 3,10 to end

printf "\x1b[1;0H12345678901234567890" >> ${LCD}
printf "\x1b[2;0H23456789012345678901" >> ${LCD}
printf "\x1b[3;0H34567890123456789012" >> ${LCD}
printf "\x1b[4;0H45678901234567890123" >> ${LCD}

printf "\x1b[3;10H\x1b[0J" >> ${LCD}
ok cleared 3,10 to end

printf "\x1b[1;0H12345678901234567890" >> ${LCD}
printf "\x1b[2;0H23456789012345678901" >> ${LCD}
printf "\x1b[3;0H34567890123456789012" >> ${LCD}
printf "\x1b[4;0H45678901234567890123" >> ${LCD}

printf "\x1b[3;10H\x1b[1J" >> ${LCD}
ok cleared 3,10 to beginning

printf "\x1b[1;0H12345678901234567890" >> ${LCD}
printf "\x1b[2;0H23456789012345678901" >> ${LCD}
printf "\x1b[3;0H34567890123456789012" >> ${LCD}
printf "\x1b[4;0H45678901234567890123" >> ${LCD}

printf "\x1b[3;10H\x1b[2Jx" >> ${LCD}
ok cleared screen

printf "\x1b[2;10HHere\x1b[2;10H\x1b[1AThere" >> ${LCD}
ok There above here


printf "\x1b[2;10H\x1b[1BEverywhere" >> ${LCD}
ok Everywhere below here


printf "\x1b[J\x1b[2;5Hi" >> ${LCD}
ok i
printf "\x1b[2;6H\x1b[2DH" >> ${LCD}
ok Hi
printf "\x1b[2;5H\x1b[1C!" >> ${LCD}
ok Hi!

printf "\x1b[1;0H12345678901234567890" >> ${LCD}
printf "\x1b[2;0H23456789012345678901" >> ${LCD}
printf "\x1b[3;0H34567890123456789012" >> ${LCD}
printf "\x1b[4;0H45678901234567890123" >> ${LCD}


printf "\x1b[1;10H\x1b[K" >> ${LCD}
ok clear first line 10 to end

printf "\x1b[2;10H\x1b[0K" >> ${LCD}
ok clear second line 10 to end

printf "\x1b[3;10H\x1b[1K" >> ${LCD}
ok clear third line start to 10

printf "\x1b[4;10H\x1b[2K" >> ${LCD}
ok clear fourth line

printf "\x1b[H\x1b[0JHello\nThere" >> ${LCD}
ok Hello There on start of lines 1 and 2

printf "\x1b[H\x1b[JHello\rThere" >> ${LCD}
ok Hello overwrites There on start of line 1 

#printf "\x1bc" >> ${LCD}
#ok Reinitialized the screen

echo 0 >> ${DIR}/backlight
ok backlight off

echo 1 >> ${DIR}/backlight
ok backlight on

cat ${DIR}/backlight
ok 20x4 geometry

echo 0 >> ${DIR}/cursor_blink
ok cursor_blink off

echo 1 >> ${DIR}/cursor_blink
ok cursor_blink on

echo 1 >> ${DIR}/cursor_display
ok cursor_display on

echo 0 >> ${DIR}/cursor_display
ok cursor_display off

echo HTL0HHHE >> ${DIR}/char0
printf "\x00" >> ${LCD}


echo VVVVVVVV >> ${DIR}/char0
printf "\x1b[1;1H\x1b[K" >> ${LCD}
printf "\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00" >> ${LCD}
printf "\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00" >> ${LCD}
printf "\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00" >> ${LCD}
printf "\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00" >> ${LCD}

ok All black


echo 00000000 >> ${DIR}/char0
ok All clear

echo EHH0EHH4 >> ${DIR}/char0
echo 0EHLHE00 >> ${DIR}/char1
echo 000AHVHA >> ${DIR}/char2
echo E44AHVHA >> ${DIR}/char3
echo SGS4T552 >> ${DIR}/char4
echo 44444444 >> ${DIR}/char5
echo 4EV44444 >> ${DIR}/char6
echo 44444VE4 >> ${DIR}/char7
        

printf "\x1bc\x1b[1;1H" >> ${LCD}
printf "\x00\x01\x02\x03\x04\x05\x06\x07" >> ${LCD}
printf "\x1b[2;2H" >> ${LCD}
printf "\x00\x01\x02\x03\x04\x05\x06\x07" >> ${LCD}
printf "\x1b[3;3H" >> ${LCD}
printf "\x00\x01\x02\x03\x04\x05\x06\x07" >> ${LCD}
printf "\x1b[4;4H" >> ${LCD}
printf "\x00\x01\x02\x03\x04\x05\x06\x07" >> ${LCD}

ok Special chars


