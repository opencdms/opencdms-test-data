$STORAGE:2
      SUBROUTINE GTCONLEV(NTOTLEV,CONLEV,NCONLEV)
C       **INPUT/OUTPUT:
C            NTOTLEV....NUMBER OF CONTOUR LEVELS THAT ARE AVAILABLE
C            CONLEV.....CONTOUR LEVEL VALUES
C            NCONLEV....NUMBER OF CONTOUR LEVELS THAT ARE USED FOR CONTOURING
C
C
      INTEGER*2 NTOTLEV,NCONLEV
      REAL*4    CONLEV(*)      
C
$INCLUDE:'GRFPARM.INC'
C
      CHARACTER*9  FIELD(20)
      CHARACTER*64 HELPFILE
      CHARACTER*8  FRMNAM
      CHARACTER*2  RTNFLAG
C
      DATA FRMNAM /'CNTRLEVL'/      
      DATA HELPFILE/'P:\HELP\GTCONLEV.HLP'/
C      
      DO 10 I=1,20
         FIELD(I)=' '
   10 CONTINUE   
      DO 12 I=1,NTOTLEV
         WRITE(FIELD(I),500) CONLEV(I)
   12 CONTINUE   
C
C       .. DISPLAY THE CONTOUR LEVEL FORM AND SOLICIT USER INPUT
C
   15 CALL LOCATE(1,0,IERR)
      CALL GETFRM(FRMNAM,HELPFILE,FIELD,9,RTNFLAG)
      IF (RTNFLAG.EQ.'4F') GO TO 100
      IF (RTNFLAG.EQ.'2F') THEN
         DO 20 I=1,MXCONLEV
            IF (FIELD(I).EQ.' ') GO TO 21
   20    CONTINUE   
         I=MXCONLEV+1
   21    CONTINUE            
         NTOTLEV=I-1
         DO 30 I=1,NTOTLEV
            READ(FIELD(I),500) CONLEV(I)
   30    CONTINUE   
         DO 35 I=NTOTLEV+1,MXCONLEV
            CONLEV(I)=0.
   35    CONTINUE   
         NCONLEV = MIN0(NCONLEV,NTOTLEV)
      ELSE
         GO TO 15   
      ENDIF
C
  100 RETURN
C
C       ** FORMAT STMTS
C
  500 FORMAT(F9.3)
C
      END        