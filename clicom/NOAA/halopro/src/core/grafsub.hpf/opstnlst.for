$STORAGE:2
      SUBROUTINE OPSTNLST(STNSTAT,I2WRK,MXRSTNG,I2WRKD,MAXLST,
     +                    LSTNAM,SELNAM)
C
      INTEGER*2    MXRSTNG,I2WRKD,I2WRK(I2WRKD)
      INTEGER*1    STNSTAT(MXRSTNG)
      CHARACTER*8  LSTNAM,SELNAM      
C
      LOGICAL PRTLST,CHKDEL
      CHARACTER*1  RTNCODE
      CHARACTER*64 HELPFILE
      CHARACTER*80 MSGTXT
      CHARACTER*8  SAVNAM      
C
      DATA HELPFILE /'P:\HELP\OPSTNLST.HLP'/
C
      CALL GETMSG(580,MSGTXT)
      CALL GETMSG(999,MSGTXT)
      LMSG = LNG(MSGTXT)
C
      CALL POSLIN(IROW,ICOL)
   10 CONTINUE
      MSGTXT(LMSG+3:) = LSTNAM(1:8)
      LGTH = LMSG+10
      CALL LOCATE(21,ICOL,IER)
      CALL WRTSTR(MSGTXT,LGTH,14,0)
      CALL LOCATE(IROW,ICOL,IERR)    
      CALL GETMNU('LOOKSTN-OPT ',HELPFILE,IOPT)
      CALL CLRMSG(2)
      CALL CLRMSG(3)
      IF (IOPT.EQ.0) THEN
         GO TO 100
      ELSE
         IF ((LSTNAM.EQ.' ' .OR. LSTNAM.EQ.'STNGEOG') .AND.
     +        IOPT.NE.1) THEN
            IF (LSTNAM.EQ.'STNGEOG') THEN
               CALL WRTMSG(3,581,12,1,0,' ',0)
            ELSE
               CALL WRTMSG(3,598,12,1,0,' ',0)
            ENDIF
         ELSE IF (IOPT.EQ.1 .OR. IOPT.EQ.2) THEN
            DO 20 I=1,MXRSTNG
               STNSTAT(I) = 0
   20       CONTINUE
            IF (IOPT.EQ.1) THEN
               SAVNAM=LSTNAM
               LSTNAM=' '
               NSELECT=0
            ELSE   
               CALL GTOLDLST(STNSTAT,MXRSTNG,LSTNAM,NSTNLST)
               NSELECT=NSTNLST
            ENDIF   
            CALL DFSTNLST(NSELECT,STNSTAT,I2WRK,MXRSTNG,I2WRKD,MAXLST,
     +                    RTNCODE)
            CALL LOCATE(IROW+10,ICOL,IERR)
            IF (RTNCODE.EQ.'0') CALL WRSTNLST(STNSTAT,MXRSTNG,LSTNAM)
            IF (LSTNAM.EQ.' ') LSTNAM=SAVNAM
         ELSE IF (IOPT.EQ.3) THEN   
            CHKDEL = SELNAM.EQ.LSTNAM
            CALL DLSTNLST(LSTNAM)
            IF (CHKDEL) SELNAM=LSTNAM
         ELSE IF (IOPT.EQ.4) THEN
            PRTLST=.FALSE.
            CALL VWSTNLST(LSTNAM,I2WRK,I2WRKD,MXRSTNG,PRTLST)
         ELSE IF (IOPT.EQ.5) THEN         
            PRTLST=.TRUE.
            CALL VWSTNLST(LSTNAM,I2WRK,I2WRKD,MXRSTNG,PRTLST)
         ENDIF
      ENDIF
      GO TO 10
C
  100 CONTINUE
      DO 105 I=1,4
         CALL CLRMSG(I)
  105 CONTINUE    
      RETURN
      END         
      