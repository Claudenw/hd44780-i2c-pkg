# -*- coding: UTF-8 -*-
#
# Copyright Claude Warren 2019-2020
#
import subprocess
from time import sleep
import datetime
from threading import Thread
from threading import RLock
import sys
import os
import fcntl
import ctypes
import logging


class LCD:
    RawDevice = None
    DEVICE = None
    DEVICE_ROWS = 4
    DEVICE_COLUMNS = 20
    PAD_TEXT = "{:"+str(DEVICE_COLUMNS)+"}"
    lock = [ RLock(), RLock(), RLock(), RLock() ]
    
    thread = None
    clock =chr(0x12)
    off = chr(0x14)
    newLine = [ None, None, None, None ]
    line = [off, off, off, off ]
    scroll = [False,False,False,False]
    pos = [ 0, 0, 0, 0 ]
    tick = [ 0, 0, 0, 0 ]
    logger = logging.getLogger( "LCD" )
 
    ##
    ## In the code below "lineNum" is zero based and "lineNo" is 1 based
    ##
    
    # recalculate the contents of the line 
    def recalc( self, lineNum ) :
        with self.lock[lineNum] :
            if (len(self.newLine[lineNum]) <= self.DEVICE_COLUMNS ) :
               self.line[lineNum] = self.PAD_TEXT.format(self.newLine[lineNum])
               self.scroll[lineNum] = False
            else :
               self.line[lineNum] = '  '+self.newLine[lineNum]+'  |'
               self.scroll[lineNum] = True
            self.pos[lineNum] = 0
            self.newLine[lineNum] = None
        self.logger.debug( "{}: {}".format( lineNum, self.line[lineNum]) )

    def vt100(self, text):
        return bytes("\x1B["+text, 'utf-8' )
        
    def display_string(self, text, lineNum ):
        # check line position
        # trim text to length
        txt = (text[:self.DEVICE_COLUMNS]) if len(text) > self.DEVICE_COLUMNS else text
        dev = os.open( self.DEVICE, os.O_WRONLY)
        os.write( dev, self.vt100( str(lineNum+1)+";0H"+txt ) )
        os.close( dev );

    # print the line replacing self.clock with timestamp.
    def printline ( self, lineNum ) :
        if (self.line[lineNum][0] == self.off):
            return
        if (self.line[lineNum][0] == self.clock):
            txt = self.PAD_TEXT.format(datetime.datetime.now().strftime("%d-%b %H:%M:%S %Z"))
            self.display_string( txt, lineNum )
        elif self.scroll[lineNum]:  
            # scroll          
            if ( self.tick[lineNum] == 0):
                limit = len(self.line[lineNum])       
                pos = self.pos[lineNum]
                wrap= self.DEVICE_COLUMNS - (limit-pos)
                long_line = self.line[lineNum]
                if (wrap>0):
                    myLine = long_line[pos:pos+self.DEVICE_COLUMNS]+long_line[0:wrap]
                else:
                    myLine = long_line[pos:pos+self.DEVICE_COLUMNS]
                self.display_string( self.PAD_TEXT.format(myLine), lineNum )
                self.pos[lineNum] = pos + 1
                if (self.pos[lineNum] > len(long_line)):
                    self.pos[lineNum] = 0
            self.tick[lineNum] = (self.tick[lineNum] + 1) % 3 
        else:
            self.display_string( self.PAD_TEXT.format(self.line[lineNum]), lineNum )
            self.pos[lineNum] = 0

    # display all DEVICE_ROWS lines in a continuous loop
    def startDisplay( self ):
        dev = os.open( self.DEVICE, os.O_WRONLY)
        os.write( dev, self.vt100( "m"));
        os.close( dev )

        while (True):
            for x in range(self.DEVICE_ROWS):
                with self.lock[x]:
                    if (self.newLine[x] != None):
                        self.recalc( x )
                        self.printline( x )
                    elif (self.line[x][0] == self.clock or self.scroll[x]):
                        self.printline( x )
            sleep( 0.1 )

    def __init__(self, device):
        self.RawDevice = device
        LCD.DEVICE = "/dev/"+device
        if (LCD.thread == None):
            LCD.thread = Thread(target=self.startDisplay, name="LCD thread")
            try:
                LCD.thread.daemon = True
                LCD.thread.start()
            except Exception as e:
                print( e.args[0] )

    def defineChar(self, pos, value ):
        subprocess.getoutput( 'echo {} > /sys/class/hd44780/{}/char{}'.format( value, self.RawDevice, pos ))
        
    def _makeStr(self, display ):
        if isinstance( display, str ):
            return display
        if isinstance( display, int ):
            return chr(display)
        if isinstance( display, bytes ) :
            return display.decode("utf-8")
        return "{}".format(display)

    def setChar(self, lineNo, charPos, display ):
        disp = self._makeStr( display )
        lineNum = (lineNo-1) % 4
        with self.lock[lineNum]:
            if (self.newLine[lineNum] != None):
                self.recalc( lineNum )
            workLine = self.line[lineNum]
            if workLine[0] == self.off or workLine[0] == self.clock:
                workLine=""
            limit = charPos+len(disp)-1
            if limit > len( workLine ):
                str_pad = " " * (limit-len(workLine))
                workLine = workLine+str_pad
            rest = charPos+len(disp)-1
            limit = len(workLine)
            if charPos>0:
                self.setLine( lineNo, workLine[0:charPos-1]+disp+workLine[rest:] )
            else:
                self.setLine( lineNo, disp+workLine[rest:] )

    def setLine(self, lineNo, display):
        lineNum = (lineNo-1) % 4
        if display == self.off or display == self.clock:
            self.newLine[lineNum] = display
        else :
            with self.lock[lineNum]:
                self.newLine[lineNum] = self._makeStr( display )

    def setTime(self, lineNo ):
        self.setLine( lineNo, self.clock )

    def unsetTime(self, lineNo ):
        self.setLine( lineNo, "" )

    def setUnused(self, lineNo ):
        self.setLine( lineNo, self.off )
        
    def clear(self):
        for x in range(self.DEVICE_ROWS):
            with self.lock[x]:
                self.newLine[x] = None
                self.line[x] = self.off
        dev = os.open( self.DEVICE, os.O_WRONLY)
        os.write( dev, self.vt100( "2J" ) )
        os.close( dev );
        
    def setBacklight(self, state ):
        dev = os.open( self.DEVICE, os.O_WRONLY)
        if state:
            os.write( dev, b'\x13')
        else:
            os.write( dev, b'\x11')
        os.close( dev )

    def reset(self):
        dev = os.open( self.DEVICE, os.O_WRONLY)
        os.write( dev, b'\x1b[2J')
        os.close( dev );
        for x in range(self.DEVICE_ROWS):
            with self.lock[x]:
                self.printline( x )
        
    def strobe(self, count=1):
        dev = os.open( self.DEVICE, os.O_WRONLY)
        for i in range( 0, count):
            os.write( dev, b'\x11')
            sleep(.1)
            os.write( dev,b'\x13')
            sleep(.1)
        os.close( dev );

    def createChar(self, charNum, encoding ):
        # check line position
        # trim text to length
        dev = os.open( self.DEVICE, os.O_WRONLY)
        print( bytes("\x10"+str(charNum)+encoding, 'utf-8' ) )
        os.write( dev, bytes("\x10"+str(charNum)+encoding, 'utf-8' ) )
        os.close( dev );
