$STORAGE:2

      PROGRAM CFGPRUP
C
C   ROUTINE TO READ THE PRINTER CONFIGURATION FILE GENERATED BY
C   CLICOM VERSION 2.1 AND CONVERT IT TO WORK WITH VERSION 3.0 
C
      CHARACTER*19 MSGTXT
      CHARACTER*1  LINCHR(11),HOLD1,HOLD2
      INTEGER*2    INCODE(7,8)
C
C       ** INITIALIZE
C
      DO 20 N=1,8
         DO 20 M=1,7
            INCODE(M,N)=0
   20 CONTINUE               
C
C       ** READ THE OLD PRINTER.CFG FILE -- EACH CODE CHARACTER IS TWO
C          DECIMAL DIGITS LONG
C
   30 CONTINUE
      OPEN (7,FILE='P:\DATA\PRINTER.CFG',STATUS='OLD',SHARE='DENYWR'
     +       ,IOSTAT=IOCHK)
      IF(IOCHK.NE.0.) THEN
         CALL OPENMSG('P:\DATA\PRINTER.CFG   ','RDPRNT      ',IOCHK)
         GO TO 30
      END IF   
C
      READ(7,'(20I2)',ERR=100,END=110) ((INCODE(M,N),N=1,4),M=1,5)
      READ(7,'(11A1)',ERR=100,END=110) (LINCHR(I),I=1,11)
C
C       ** WRITE THE NEW PRINTER.CFG FILE -- EACH CODE CHARACTER IS THREE
C          DECIMAL DIGITS LONG
C
      REWIND 7
C
      HOLD1 = 'D'
      HOLD2 = 'D'
      WRITE(7,'(2A1)')HOLD1,HOLD2
      WRITE(7,'(7(8I3.3))') ((INCODE(M,N),N=1,8),M=1,7)
      WRITE(7,'(11A1)') (LINCHR(I),I=1,11)
C
      CLOSE(7)
      RETURN
C
C       ** ERROR PROCESSING -- PREMATURE END OF FILE      
  100 CONTINUE
      MSGTXT = 'P:\DATA\PRINTER.CFG'
      CALL WRTMSG (3,191,12,1,1,MSGTXT,19)
      CLOSE(7)
      RETURN
  110 CONTINUE
      MSGTXT = 'P:\DATA\PRINTER.CFG'
      CALL WRTMSG (3,199,12,1,1,MSGTXT,19)
      CLOSE(7)
      END
