$STORAGE:2
C
      SUBROUTINE LINEQC(RECTYPE,IELEM,ILINE,LINQCD,POSFLD,STRTELEM
     +     ,EDALL,NEWREC,HOURLBL,RTNCODE)
C
C  THIS ROUTINE CALLS THE APPROPRIATE VALIDATION ROUTINES.  ALL
C  ROUTINES ARE CALLED FOR EVERY ELEMENT IN THE CURRENT LINE.
C
$INCLUDE: 'VAL1.INC'
$INCLUDE: 'ELEMCHKS.INC'
$INCLUDE: 'GENMOIST.INC'
C
      CHARACTER*1 RTNCODE,LINQCD(MAXLINE),NEWREC
      CHARACTER*1 FLAGHOLD(MAXELEM,MAXCHK,2)
      CHARACTER*2 HOURLBL(24)
      CHARACTER*3 RECTYPE
C
      INTEGER*2 IELEM,ILINE,ICOL,POSFLD,STRTELEM,IROW
      REAL*8 VALUE
      LOGICAL EDALL,DATFND
C
      RTNCODE = '0'
      POSFLD = 0
      ICOL = IELEM
C
C  INITIALIZE FLAGARRAY AND THE TEMPORARY FLAG FIELD
C
      DO 40 ICOL = 1,NUMELEM
         IF (FLAGARRAY(ICOL,ILINE,1).LT.'A'
     +      .OR.FLAGARRAY(ICOL,ILINE,1).GT.'G')THEN
            IF (FLAGARRAY(ICOL,ILINE,1).LT.'a'
     +      .OR.FLAGARRAY(ICOL,ILINE,1).GT.'g')THEN
               FLAGARRAY(ICOL,ILINE,1) = 'A'
               FLAGARRAY(ICOL,ILINE,2) = 'A'
            END IF
         END IF
         DO 25 J = 1,MAXCHK
            FLAGHOLD(ICOL,J,1) = 'A'
            FLAGHOLD(ICOL,J,2) = 'A'
   25    CONTINUE
   40 CONTINUE
C
C  CALL THE QC ROUTINES TO PERFORM ALL CHECKS REQUESTED FOR THIS ELEMENT
C
      DATFND = .FALSE.
      DO 80 ICOL = 1,NUMELEM
         IF (GENTBL(ICOL).EQ.'Y')THEN
            CALL GENVARS(ICOL,ILINE,FLAGHOLD)
         END IF
         IF (VALARRAY(ICOL,ILINE).EQ.'      ')THEN
            GO TO 80
         END IF
         DATFND = .TRUE.
         READ(VALARRAY(ICOL,ILINE),'(F5.0,1X)',ERR=220) VALUE
         VALUE = VALUE * TBLCONV(ICOL)
         CALL FLAGCHK(ILINE,ICOL,VALUE,FLAGHOLD,RECTYPE,RTNCODE)
         IF (RTNCODE.NE.'0') THEN
            GO TO 80
         END IF            
         DO 50 ICHK = 1,MAXCHK
            IF (CHKTYP(ICOL,ICHK).EQ.0) THEN
               GO TO 80
            END IF
            IF (CHKTYP(ICOL,ICHK).EQ.01) THEN
               CALL GLBLIM(ICOL,ICHK,VALUE,FLAGHOLD)
            ELSE IF (CHKTYP(ICOL,ICHK).EQ.04) THEN
               CALL ELMREL(ILINE,ICOL,ICHK,0,VALUE,FLAGHOLD)
            ELSE IF (CHKTYP(ICOL,ICHK).EQ.05.AND.ILINE.GT.1) THEN
               CALL ELMREL(ILINE,ICOL,ICHK,1,VALUE,FLAGHOLD)
            ELSE IF (CHKTYP(ICOL,ICHK).EQ.03) THEN
               CALL GLBREL(ILINE,ICOL,ICHK,VALUE,FLAGHOLD)
            ELSE IF (CHKTYP(ICOL,ICHK).EQ.06.AND.ILINE.GT.1) THEN
               CALL GLBCHG(ILINE,ICOL,ICHK,VALUE,FLAGHOLD)
            ELSE IF (CHKTYP(ICOL,ICHK).EQ.51) THEN
               CALL STNLIM(ICOL,VALUE,FLAGHOLD)
            ELSE IF (CHKTYP(ICOL,ICHK).EQ.52) THEN
               CALL STNSD(ICOL,VALUE,FLAGHOLD)
            ELSE IF (CHKTYP(ICOL,ICHK).EQ.53.AND.ILINE.GT.1) THEN
               CALL STNCHG(ILINE,ICOL,ICHK,VALUE,FLAGHOLD)
            END IF
50       CONTINUE
80    CONTINUE
90    CONTINUE
C
C  CALL SPECIAL QC ROUTINE FOR UPPER AIR DATA
C
      IF (RECTYPE.EQ.'U-A') THEN
         LINQCD(ILINE) = 'Y'
         CALL RAOBQC(ILINE,FLAGHOLD,NEWREC)
      END IF
C
      IF (DATFND) THEN
         LINQCD(ILINE) = 'Y'
C
C     IF THIS IS A VALIDATOR ALTER THE NEW FLAGS TO REFLECT THIS 
C
         IF (PASSWD.EQ.'QC')THEN
            DO 150 LVL = 1,MAXCHK
               DO 150 ICOL = 1,NUMELEM
                  IF (FLAGHOLD(ICOL,LVL,1).LE.'Z'.AND.
     +                   FLAGHOLD(ICOL,LVL,1).GE.'A')THEN
                     JCHAR = ICHAR(FLAGHOLD(ICOL,LVL,1))
                     JCHAR = JCHAR + 32
                     FLAGHOLD(ICOL,LVL,1) = CHAR(JCHAR)
                  END IF
  150       CONTINUE
         END IF
C
C     UPDATE FLAGARRAY FROM THE JUST CREATED FLAGHOLD
C
         CALL SETFLAGS(FLAGHOLD,ILINE)
C
C     IF NOT EDIT-ALL - FIND FIRST RED FIELD AND MAKE IT THE CURRENT
C     ELEMENT 
C
         IF (.NOT.EDALL) THEN
           CALL FNDRED(IELEM,ILINE,POSFLD,RTNCODE)
         END IF
C
  200    CALL POSLIN(IROW,NCOL)
         CALL WRTLINE(RECTYPE,HOURLBL,STRTELEM,ILINE,IROW)
         CALL LOCATE (IROW,NCOL,IERR)
      END IF
      NEWREC = '0'
      RETURN
C
  220 FLAGHOLD(ICOL,1,1) = 'C'
      FLAGHOLD(ICOL,1,2) = '['
      NEWREC = '0'
      RETURN
      END
***********************************************************************
$PAGE
      SUBROUTINE FLAGCHK(ILINE,ICOL,VALUE,FLAGHOLD,RECTYPE,RTNCODE)
C
C  ROUTINE TO CHECK IF THE FLAG AND VALUE FIELDS FOR THIS ELEMENT
C  ARE CONSISTENT WITH EACH OTHER
C
$INCLUDE: 'VAL1.INC'
$INCLUDE: 'ELEMCHKS.INC'
C
      CHARACTER*1 RTNCODE,FLAGHOLD(MAXELEM,MAXCHK,2),FLG
      CHARACTER*3 RECTYPE
      INTEGER*2 ILINE,ICOL
      REAL*8 VALUE
C
      RTNCODE = '0'
      FLG = VALARRAY(ICOL,ILINE)(6:6)
C
      IF (FLG.NE.' ')THEN
         IF (RECTYPE.EQ.'U-A'.AND.FLG.EQ.'W'.AND.
     +          ICOL.EQ.1)THEN
            RETURN 
         ELSE IF (FLG.EQ.'T')THEN
            IF (VALUE.NE.0.0.OR.VALARRAY(ICOL,ILINE)(1:5).EQ.' ') THEN
               FLAGHOLD(ICOL,1,1) = 'C'
               FLAGHOLD(ICOL,1,2) = 'Q'
               RTNCODE = '1'
            END IF
         ELSE
            IF (VALARRAY(ICOL,ILINE)(1:5).EQ.'     ')THEN
               FLAGHOLD(ICOL,1,1) = 'C'
               FLAGHOLD(ICOL,1,2) = 'R'
               RTNCODE = '1'
            END IF
         END IF
      END IF
      RETURN
      END
************************************************************************
$PAGE
      SUBROUTINE GLBLIM (ICOL,ICHK,VALUE,FLAGHOLD)
C
C  ROUTINE CHECKS THIS VALUE AGAINST THE GLOBAL LIMITS FOR THIS ELEMENT
C
$INCLUDE: 'VAL1.INC'
$INCLUDE: 'ELEMCHKS.INC'
C
      CHARACTER*1 FLAGHOLD(MAXELEM,MAXCHK,2)
      INTEGER*2 ICHK,ICOL
      REAL*8 VALUE
C
      IF (VALUE.LT.CHKVL1(ICOL,ICHK)) THEN
         FLAGHOLD(ICOL,1,1) = 'C'
         FLAGHOLD(ICOL,1,2) = 'B'
      ELSE 
         IF (VALUE.GT.CHKVL2(ICOL,ICHK)) THEN
            FLAGHOLD(ICOL,1,1) = 'C'
            FLAGHOLD(ICOL,1,2) = 'C'
         END IF
      END IF
C
      RETURN
      END
***********************************************************************
$PAGE
      SUBROUTINE GLBCHG(ILINE,ICOL,ICHK,VALUE,FLAGHOLD)
C
C  THIS ROUTINE CHECKS THIS ELEMENT AGAINST THE GLOBAL MAXIMUM CHANGE
C  RATE DEFINED FOR THIS ELEMENT.
C
$INCLUDE: 'VAL1.INC'
$INCLUDE: 'ELEMCHKS.INC'
C
      CHARACTER*1 FLAGHOLD(MAXELEM,MAXCHK,2)
      INTEGER*2 ILINE,ICOL,PREVLN
      REAL*8 VALUE,PREVVAL,CHANGE
C
      PREVLN = ILINE - 1
C
      IF (VALARRAY(ICOL,PREVLN).EQ.'      ')THEN
         RETURN
      END IF
C
      READ(VALARRAY(ICOL,PREVLN),'(F5.0,1X)',ERR=230) PREVVAL
      PREVVAL = PREVVAL * TBLCONV(ICOL)
C
      CHANGE = VALUE - PREVVAL
      CHANGE = DABS(CHANGE)
C
      IF (CHANGE.GT.CHKVL2(ICOL,ICHK)) THEN
         FLAGHOLD(ICOL,4,1) = 'C'
         FLAGHOLD(ICOL,4,2) = 'I'
      ELSE
         IF (CHANGE.GT.CHKVL1(ICOL,ICHK))THEN
            FLAGHOLD(ICOL,4,1) = 'B'
            FLAGHOLD(ICOL,4,2) = 'I'
         END IF
      END IF
      RETURN
C
  230 FLAGHOLD(ICOL,4,1) = 'C'
      FLAGHOLD(ICOL,4,2) = '^'
      RETURN
      END
************************************************************************
$PAGE
      SUBROUTINE ELMREL(ILINE,ICOL,ICHK,RELTYP,VALUE,FLAGHOLD)
C
C  THIS ROUTINE CHECKS THIS ELEMENT AGAINST ANOTHER ELEMENT IN THIS
C  OR THE PREVIOUS LINE.  
C
$INCLUDE: 'VAL1.INC'
$INCLUDE: 'ELEMCHKS.INC'

      CHARACTER*1 FLAGHOLD(MAXELEM,MAXCHK,2)
      CHARACTER*6 RELVAL
      INTEGER*2 ILINE,ICOL,RELCOL,RELTYP
      REAL*8 VALUE, RELNUM
      LOGICAL ERROR
C
C  SET THE RELATED VALUE TO THE LINE AND COLUMN WANTED
C
      RELCOL = CHKELM(ICOL,ICHK)
      IF (RELCOL.LE.0) THEN 
         RETURN
      END IF
      IF (RELTYP.EQ.0) THEN
         JLINE = ILINE
      ELSE
         JLINE = ILINE - 1
      END IF
      RELVAL = VALARRAY(RELCOL,JLINE)
C
C  CHECK IF THE OTHER ELEMENT IS EMPTY - IF OTHER ELEMENT IS ON PREVIOUS 
C  LINE SKIP THE CHECK.  IF ON SAME LINE AND OTHER ELEMENT IS REQUIRED
C  SET THE ERROR FLAG 
C
      IF (RELVAL.EQ.'      '.AND.RELTYP.NE.0) THEN
         RETURN
      END IF
      IF (RELVAL.EQ.'      ') THEN
         IF (CHKRL1(ICOL,ICHK).EQ.'RE') THEN
            FLAGHOLD(ICOL,3,1) = 'C'
            FLAGHOLD(ICOL,3,2) = 'F'
            FLAGHOLD(RELCOL,3,1) = 'C'
            FLAGHOLD(RELCOL,3,2) = 'F'
         END IF
         RETURN
      END IF
C
      READ (RELVAL,'(F5.0,1X)',ERR=220) RELNUM
      RELNUM = RELNUM * TBLCONV(RELCOL)
C
      ERROR = .FALSE.
      IF (CHKRL1(ICOL,ICHK).EQ.'> ') THEN
         IF (VALUE.LE.RELNUM) THEN
            ERROR = .TRUE.
         END IF
      ELSE IF (CHKRL1(ICOL,ICHK).EQ.'< ') THEN
         IF (VALUE.GE.RELNUM)THEN
            ERROR = .TRUE.
         END IF
      ELSE IF (CHKRL1(ICOL,ICHK).EQ.'>=') THEN
         IF (VALUE.LT.RELNUM)THEN
            ERROR = .TRUE.
         END IF
      ELSE IF (CHKRL1(ICOL,ICHK).EQ.'<=') THEN
         IF (VALUE.GT.RELNUM)THEN
            ERROR = .TRUE.
         END IF
      END IF
C
C  SET THE APPROPRIATE ERROR FLAG TO INDICATE RELATIONSHIP TO ELEMENT
C  ON THIS OR PREVIOUS LINE
C      
      IF (ERROR) THEN
         IF (ILINE.EQ.JLINE) THEN
            FLAGHOLD(ICOL,3,1) = 'C'
            FLAGHOLD(ICOL,3,2) = 'F'
            FLAGHOLD(RELCOL,3,1) = 'C'
            FLAGHOLD(RELCOL,3,2) = 'F'
         ELSE
            FLAGHOLD(ICOL,3,1) = 'C'
            FLAGHOLD(ICOL,3,2) = 'H'
         END IF
      END IF
      RETURN
C      
  220 CONTINUE
      IF (ILINE.EQ.JLINE) THEN
         FLAGHOLD(RELCOL,3,1) = 'C'
         FLAGHOLD(RELCOL,3,2) = '['
      ELSE
         FLAGHOLD(ICOL,3,1) = 'C'
         FLAGHOLD(ICOL,3,2) = ']'
      END IF
      RETURN
      END
************************************************************************
$PAGE
      SUBROUTINE GLBREL(ILINE,ICOL,ICHK,VALUE,FLAGHOLD)
C
C  THIS ROUTINE CHECKS THIS ELEMENT AGAINST ANOTHER ELEMENT IN THIS
C  LINE AND MAKES SURE THAT THE CONDITIONS REQUESTED ARE SATISFIED  
C
$INCLUDE: 'VAL1.INC'
$INCLUDE: 'ELEMCHKS.INC'

      CHARACTER*1 FLAGHOLD(MAXELEM,MAXCHK,2)
      CHARACTER*6 RELVAL
      INTEGER*2 ILINE,ICOL,RELCOL
      REAL*8 VALUE, RELNUM
      LOGICAL ERROR
C
      RELCOL = CHKELM(ICOL,ICHK)
      RELVAL = VALARRAY(RELCOL,ILINE)
C
C  CHECK IF THE ELEMENT IN THIS COLUMN MEETS THE CRITERIA REQUESTED.
C  IF NOT, NO FURTHER CHECKS ARE REQUIRED
C
      IF (CHKRL1(ICOL,ICHK).EQ.'> ') THEN
         IF (VALUE.LE.CHKVL1(ICOL,ICHK)) THEN
            RETURN
         END IF
      ELSE IF (CHKRL1(ICOL,ICHK).EQ.'< ') THEN
         IF (VALUE.GE.CHKVL1(ICOL,ICHK)) THEN
            RETURN
         END IF
      ELSE IF (CHKRL1(ICOL,ICHK).EQ.'>=') THEN
         IF (VALUE.LT.CHKVL1(ICOL,ICHK)) THEN
            RETURN
         END IF
      ELSE IF (CHKRL1(ICOL,ICHK).EQ.'<=') THEN
         IF (VALUE.GT.CHKVL1(ICOL,ICHK)) THEN
            RETURN
         END IF
      END IF
C
C   CURRENT ELEMENT MEETS THE CRITERIA REQUESTED - CHECK IF THE RELATED
C   ELEMENT MEETS THE CRITERIA REQUESTED FOR IT
C
C   CHECK IF THE OTHER ELEMENT IS EMPTY - ERROR IF THAT IS NOT ALLOWED 
C
      IF (RELVAL.EQ.'     ')THEN
         IF (CHKRL2(ICOL,ICHK).EQ.'RE') THEN
            FLAGHOLD(ICOL,7,1) = 'C'
            FLAGHOLD(ICOL,7,2) = 'F'
            FLAGHOLD(RELCOL,7,1) = 'C'
            FLAGHOLD(RELCOL,7,2) = 'F'
         END IF
         RETURN
      END IF   
C
      READ (RELVAL,'(F5.0,1X)',ERR=220) RELNUM
      RELNUM = RELNUM * TBLCONV(RELCOL)
C
C   CHECK OTHER RELATIONSHIPS FOR THE SECOND ELEMENT
C
      ERROR = .FALSE.
      IF (CHKRL2(ICOL,ICHK).EQ.'> ') THEN
         IF (RELNUM.LE.CHKVL2(ICOL,ICHK)) THEN
            ERROR = .TRUE.
         END IF
      ELSE IF (CHKRL2(ICOL,ICHK).EQ.'< ') THEN
         IF (RELNUM.GE.CHKVL2(ICOL,ICHK)) THEN
            ERROR = .TRUE.
         END IF
      ELSE IF (CHKRL2(ICOL,ICHK).EQ.'>=') THEN
         IF (RELNUM.LT.CHKVL2(ICOL,ICHK)) THEN
            ERROR = .TRUE.
         END IF
      ELSE IF (CHKRL2(ICOL,ICHK).EQ.'<=') THEN
         IF (RELNUM.GT.CHKVL2(ICOL,ICHK)) THEN
            ERROR = .TRUE.
         END IF
      END IF
C
      IF (ERROR) THEN
         FLAGHOLD(ICOL,7,1) = 'C'
         FLAGHOLD(ICOL,7,2) = 'G'
         FLAGHOLD(RELCOL,7,1) = 'C'
         FLAGHOLD(RELCOL,7,2) = 'G'
      END IF
      RETURN
C      
  220 FLAGHOLD(RELCOL,7,1) = 'C'
      FLAGHOLD(RELCOL,7,2) = '['
      RETURN
      END
************************************************************************
$PAGE
      SUBROUTINE STNLIM (ICOL,VALUE,FLAGHOLD)
C
C  THIS ROUTINE CHECKS THIS ELEMENT AGAINST THE RECORD VALUES
C  FOR THIS STATION AND MONTH
C
$INCLUDE: 'VAL1.INC'
$INCLUDE: 'ELEMCHKS.INC'
C
      CHARACTER*1 FLAGHOLD(MAXELEM,MAXCHK,2)
      INTEGER*2 ICOL
      REAL*8 VALUE
C
C  CHECK IF THIS VALUE EXCEEDS STATION RECORDS. ADD SOME TO RECORDS
C  TO ACCOUNT FOR ROUND OFF ERROR
C
      IF (VALUE.GT.(TBLMAX(ICOL)+.1*TBLCONV(ICOL)))THEN
         FLAGHOLD(ICOL,2,1) = 'C'
         FLAGHOLD(ICOL,2,2) = 'K'
      ELSE IF (VALUE.LT.(TBLMIN(ICOL)-.1*TBLCONV(ICOL)))THEN
         FLAGHOLD(ICOL,2,1) = 'C'
         FLAGHOLD(ICOL,2,2) = 'J'
      END IF
C
      RETURN
      END
***********************************************************************
$PAGE
      SUBROUTINE STNSD(ICOL,VALUE,FLAGHOLD)
C
C  THIS ROUTINE CHECKS THIS ELEMENT AGAINST STATISTICAL LIMITS 
C  USING THE MEAN AND STANDARD DEVIATION FOR THIS STN-ELEMENT-MONTH
C
$INCLUDE: 'VAL1.INC'
$INCLUDE: 'ELEMCHKS.INC'
C
      CHARACTER*1 FLAGHOLD(MAXELEM,MAXCHK,2)
      INTEGER*2 ICOL
      REAL*8 VALUE
      REAL*8 HIGHLIM,LOWLIM
C
C     CHECK IF THIS VALUE EXCEEDS UPPER LIMITS AND DETERMINE SEVERITY.
C
      IF (TBLSTDDEV(ICOL).EQ.99999.0)THEN
         RETURN
      END IF
      HIGHLIM = HIGHPCT * TBLSTDDEV(ICOL) + TBLMEAN(ICOL)
      IF (VALUE.GT.HIGHLIM)THEN
         FLAGHOLD(ICOL,5,1) = 'C'
         FLAGHOLD(ICOL,5,2) = 'M'
      ELSE
         HIGHLIM = LOWPCT * TBLSTDDEV(ICOL) + TBLMEAN(ICOL)
         IF (VALUE.GT.HIGHLIM)THEN
            FLAGHOLD(ICOL,5,1) = 'B'
            FLAGHOLD(ICOL,5,2) = 'M'
C
C     REPEAT ABOVE PROCEEDURE FOR LOW LIMITS
C
         ELSE
            LOWLIM = TBLMEAN(ICOL) - HIGHPCT * TBLSTDDEV(ICOL)
            IF (VALUE.LT.LOWLIM)THEN
               FLAGHOLD(ICOL,5,1) = 'C'
               FLAGHOLD(ICOL,5,2) = 'L'
            ELSE
               LOWLIM = TBLMEAN(ICOL) - LOWPCT * TBLSTDDEV(ICOL)
               IF (VALUE.LT.LOWLIM)THEN
                  FLAGHOLD(ICOL,5,1) = 'B'
                  FLAGHOLD(ICOL,5,2) = 'L'
               END IF
            END IF
         END IF
      END IF   
      RETURN
      END
***********************************************************************
$PAGE
      SUBROUTINE STNCHG(ILINE,ICOL,ICHK,VALUE,FLAGHOLD)
C
C  THIS ROUTINE CHECKS THIS ELEMENT AGAINST THE MAXIMUM CHANGE RATE
C  DEFINED FOR THIS STN-ELEMENT-MONTH.
C
$INCLUDE: 'VAL1.INC'
$INCLUDE: 'ELEMCHKS.INC'
C
      CHARACTER*1 FLAGHOLD(MAXELEM,MAXCHK,2)
      INTEGER*2 ILINE,ICOL,PREVLN
      REAL*8 VALUE,PREVVAL,CHANGE,MXCR
C
      PREVLN = ILINE - 1
C
      IF (VALARRAY(ICOL,PREVLN).EQ.'      ')THEN
         RETURN
      END IF
C
      READ(VALARRAY(ICOL,PREVLN),'(F5.0,1X)',ERR=230) PREVVAL
      PREVVAL = PREVVAL * TBLCONV(ICOL)
C
      CHANGE = VALUE - PREVVAL
      CHANGE = DABS(CHANGE)
C
      MXCR = TBLMXCR(ICOL) * CHKVL2(ICOL,ICHK)
      IF (CHANGE.GT.MXCR)THEN
         FLAGHOLD(ICOL,6,1) = 'C'
         FLAGHOLD(ICOL,6,2) = 'N'
      ELSE
         MXCR = TBLMXCR(ICOL) * CHKVL1(ICOL,ICHK)
         IF (CHANGE.GT.MXCR)THEN
            FLAGHOLD(ICOL,6,1) = 'B'
            FLAGHOLD(ICOL,6,2) = 'N'
         END IF
      END IF
      RETURN
C
  230 FLAGHOLD(ICOL,6,1) = 'C'
      FLAGHOLD(ICOL,6,2) = '^'
      RETURN
      END
***********************************************************************
      SUBROUTINE FNDRED(IELEM,ILINE,POSFLD,RTNCODE)
C
$INCLUDE: 'VAL1.INC'
C
      CHARACTER*1 RTNCODE
      INTEGER*2 IELEM,ILINE,POSFLD
C
C   ROUTINE TO FIND THE FIRST RED ERROR IN THE CURRENT LINE
C
      DO 180 ICOL = 1,NUMELEM
         IF (FLAGARRAY(ICOL,ILINE,1).EQ.'C'.OR.
     +       FLAGARRAY(ICOL,ILINE,1).EQ.'c')THEN
            IELEM = ICOL
            POSFLD = 1
            RTNCODE = '2'
            RETURN
         END IF
  180 CONTINUE
      RETURN
      END