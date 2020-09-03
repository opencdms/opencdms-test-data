$STORAGE:2
      SUBROUTINE EDIT (ITYPE,RECTYPE,IDKEY,IELEM,ILINE,OLDDDS)
C
C  THIS ROUTINE ALLOWS ENTRY AND/OR VALIDATION OF DATA,  A
C  BANNER LINE IS  DISPLAYED ON LINE ONE OF THE SCREEN AND THE
C  USER ENTERS STATION, DATE, TIME INFORMATION OF THE DATA TO
C  BE ENTERED/VALIDATED.  ANY ALREADY ENTERED DATA FOR THIS
C  STATION/DATE/TIME IS LOADED AND INTERACTIVE DATA ENTRY OR
C  VALIDATION IS INITIATED
C
$INCLUDE:'VAL1.INC'
$INCLUDE:'INDEX.INC'
$INCLUDE:'ELEMCHKS.INC'
C
      CHARACTER*21 IDKEY
      CHARACTER*10 BLANK
      CHARACTER*6 INVAL,HLDFLD
      CHARACTER*3  RECTYPE
      CHARACTER*2  RTNFLAG,HOURLBL(24)
      CHARACTER*1 RTNCODE,HLDFLAG,LINQCD(MAXLINE)
     +           ,SMALLA,BIGA,NEWREC,VALCHG
C
      INTEGER*2 STRTELEM,STRTLINE,POSFLD,SCRMOD,OLDDDS
     +          ,HLDLINE,HLDELEM,LNCNT,NUMDAY(12)
C
      LOGICAL  EDALL,EDALLSV,UAQCFLG,FRSTCL,QCLINE(MAXLINE)
C
      DATA SMALLA,BIGA,BLANK /'a','A','          '/
     +    ,FRSTCL /.TRUE./
     +    ,NUMDAY /31,28,31,30,31,30,31,31,30,31,30,31/
C
C  ON FIRST CALL TO THIS ROUTINE DETERMINE IF COLOR OR B&W MODE
C
      IF (FRSTCL) THEN
         FRSTCL = .FALSE.
         CALL SETMOD(3,IERR)
         CALL STATUS(SCRMOD,ICLTYP,IPAGE)
      END IF
C
C  DO THE INITIAL INITIALIZATION OF THE DATA ARRAYS
C
      DO 4 I= 1,MAXELEM
         DO 4 J=1,MAXLINE
            VALARRAY(I,J) = BLANK
            FLAGARRAY(I,J,1) = BLANK
            FLAGARRAY(I,J,2) = BLANK
    4 CONTINUE 
C
      DO 6 I = 1,MAXLINE
         QCLINE(I) = .FALSE.
         LINQCD(I) = BLANK
    6 CONTINUE
C
C       .. IF IDKEY EQUALS NON-BLANK SET ICNTRL = 1 TO INDICATE THAT THIS 
C          ROUTINE IS CALLED FROM AREAQC
C
      IF (IDKEY.EQ.BLANK) THEN
         ICNTRL = 0
      ELSE 
         ICNTRL = 1
      END IF
      ILNSAV = 0
      IELSAV = 0
      UAQCFLG = .FALSE.
      RTNCODE = '0'
C
C-------- MAIN LOOP - PERFORM THIS ONCE PER FORM --------
C
   10 CONTINUE
      CALL CLS
      CALL LOCATE (1,0,IERR)
C
      NEWREC = '1'
      EDALL = .FALSE.
C
C  CALL BANNER TO GET NEEDED ID AND TIME PARAMETERS, NAME THE
C  DATA AND INDEX FILES, AND READ THE SETUP FILE
C
      CALL BANNER(ICNTRL,ITYPE,RECTYPE,IDKEY,OLDDDS,HOURLBL,RTNCODE)
      IF (RTNCODE.EQ.'1')THEN
         RETURN
      END IF
      CALL CLRMSG(4)
      CALL CLRMSG(3)
C
C       ** IF MOISTURE ELEMENTS ARE GENERATED, DETERMINE WHETHER THE CURRENT
C          STATION USES ASPIRATED/NON-ASPIRATED METHOD OF MEASURING THE
C          WET BULB TEMPERATURE
C
       CALL SETWBOBS 
C      CALL RDWBSTN(IDKEY)
C
C  FIND THE YEAR-MONTH ENTERED AND SET THE NUMBER OF LINES FOR DLY
C       
      NUMLN2 = NUMLINE
      READ(IDKEY,'(11X,I4,I2,4X)') INYEAR,INMON
      IF (MOD(INYEAR,4).EQ.0) THEN
         NUMDAY(2) = 29
      ELSE
         NUMDAY(2) = 28
      END IF
      IF (RECTYPE.EQ.'DLY') THEN
         NUMLN2 = NUMDAY(INMON)
      END IF
      MAXY = 16
      IF (MAXY.GT.NUMLN2) THEN
         MAXY = NUMLN2
      END IF
C
C   RESET THE DATA ARRAYS BEING USED 
C
      DO 20 I= 1,NUMELEM
         DO 20 J=1,NUMLINE
            VALARRAY(I,J) = BLANK
            FLAGARRAY(I,J,1) = BLANK
            FLAGARRAY(I,J,2) = BLANK
   20 CONTINUE 
C
      DO 25 I = 1,NUMLINE
         QCLINE(I) = .FALSE.
         LINQCD(I) = BLANK
   25 CONTINUE
C
C     CHECK FOR EXISTENCE OF THIS FRAME IN DATA FILE
C     AND LOAD VALARRAY,ETC  IF FOUND 
C
      CALL GETDATA(IDKEY,RTNCODE)
      IF (RTNCODE.EQ.'1')THEN
         STOP ' '
      ELSE IF (RTNCODE.EQ.'3')THEN
         RTNCODE = '0'
         GO TO 10
      END IF
C
C   CHECK FIRST FIELD FOR FLAG = '?' THAT INDICATES THIS FORM HAS NOT
C   YET BEEN QC'D. IF FLAG = '?', SET EDALL = TRUE (AS IF F10 PRESSED)
C   AND FIND END OF DATA LINES
C
      IF (FLAGARRAY(1,1,1).EQ.'?' .OR. UAQCFLG) THEN
         FLAGARRAY(1,1,1) = BLANK
         EDALL = .TRUE.
         DO 40 LNCNT = NUMLN2,1,-1
            DO 40 ICOL = 1,NUMELEM
               IF (VALARRAY(ICOL,LNCNT).NE.BLANK)THEN
                  GO TO 50
               END IF
40       CONTINUE
         LNCNT = 0
50       CONTINUE
         DO 55 J= 1,NUMLINE
            DO 55 I=1,NUMELEM
               FLAGARRAY(I,J,1) = BLANK
               FLAGARRAY(I,J,2) = BLANK
  55     CONTINUE
         IF (ICNTRL.EQ.1) THEN
C             .. ROUTINE IS CALLED FROM AREAQC; SAVE ELEMENT AND LINE POSITIONS
            ILNSAV = ILINE
            IELSAV = IELEM
         ENDIF
         IELEM  = 1
         ILINE  = 1
      END IF
C
C   IF THIS IS QC RESET RED FLAGS PREVIOUSLY REENTERED BY THE
C     DATA ENTRY PERSON TO FLAG RED FOR THE VALIDATOR AND UPDATE
C     FLAG(1) TO INDICATE THIS DATA HAS BEEN LOOKED AT BY A VALIDATOR
C
      IF (PASSWD.EQ.'QC')THEN
         DO 60 I = 1,NUMLINE
            DO 60 J = 1,NUMELEM
               IF (FLAGARRAY(J,I,1).EQ.'D')THEN
                  FLAGARRAY(J,I,1) = 'C'
               END IF
               IF (FLAGARRAY(J,I,1).LE.'Z'.AND.FLAGARRAY(J,I,1)
     +               .GE.BIGA)THEN
                  ICHAR = FLAGARRAY(J,I,1)
                  ICHAR = ICHAR + 32
                  FLAGARRAY(J,I,1) = ICHAR
               END IF
   60    CONTINUE
      END IF
C
C   INITIALIZE THE FORM LOCATION PARAMETERS
C
   70 IROW = 3
      ICOL = 5
      STRTELEM = 1
      STRTLINE = 1
      IF (ICNTRL.EQ.0) THEN
         IELEM = 1
         ILINE = 1
      END IF
      POSFLD = 0
      HLDLINE = ILINE
      HLDELEM = IELEM
      VALCHG = 'N'
C
C   IF THIS IS DATA ENTRY AND THE FIELD HAS ALREADY BEEN VALIDATED
C      SKIP THIS FIELD (AND DON'T DO QC ON THIS LINE)
C
      IF (PASSWD.EQ.'DE') THEN
         DO 80 ILINE = 1,NUMLN2
            IF(FLAGARRAY(1,ILINE,1).LT.SMALLA)THEN
               GO TO 90
            END IF
  80     CONTINUE
         CALL WRTMSG(3,40,12,1,1,BLANK,0)
         GO TO 10
      END IF
C
C     WRITE A SCREEN OF DATA 
C
   90 CONTINUE
      IF (PASSWD.EQ.'DE') THEN
         CALL WRTFNC(2)
      ELSE
         CALL WRTFNC(5)
      END IF
      CALL WRTPAGE(RECTYPE,HOURLBL,STRTELEM,STRTLINE)
C
C   BEGIN THE MAIN DATA ENTRY LOOP - DO THIS ONCE PER FIELD
C
  100 CONTINUE
C
C  CHECK FOR ILINE OR IELEM OUT OF BOUNDS AND CHECK AUTHORITY TO
C  ACCESS THE CURRENT LINE.
C
      CALL CHKPOS(NUMELEM,NUMLN2,IELEM,ILINE)
C
      IF (PASSWD.EQ.'DE'.AND.FLAGARRAY(1,ILINE,1).GE.SMALLA) THEN
         ILINE = ILINE + 1
         IF (ILINE.GT.NUMLN2) THEN
            CALL WRTMSG(3,40,12,1,1,BLANK,0)
            RTNCODE = '3'
            GO TO 10
         ELSE
            GO TO 100
         END IF
      END IF
C
      IF (HLDLINE.NE.ILINE)THEN
         HLDLINE = ILINE
         VALCHG = 'N'
      END IF
      HLDELEM = IELEM
C
C   POSITION THE CURSOR TO THE FIELD OF INTEREST - SCROLL AS NECESSARY
C
      CALL POSFIELD(STRTELEM,NUMLN2,STRTLINE,IELEM,ILINE,RECTYPE,
     +              HOURLBL,POSFLD,MAXY)
      POSFLD = 0
C
C   IF THIS IS VALIDATION OF UPPER AIR AND THIS IS FIRST LINE OF A NEW FRAME,
C   CALL LINEQC TO INITIALIZE ALL U-A VARIABLES
C
      IF (RECTYPE.EQ.'U-A' .AND. NEWREC.EQ.'1')THEN
C          .. EDALL FLAG IS TEMPORARILY SET TO PREVENT ELEMENT POINTERS FROM
C             BEING POSITIONED TO THE FIRST RED FIELD IN THE LINE (7-29-91)   
         EDALLSV = EDALL
         EDALL = .TRUE.
         CALL LINEQC(RECTYPE,IELEM,ILINE,LINQCD,POSFLD,STRTELEM,EDALL
     +        ,NEWREC,HOURLBL,RTNCODE)
         EDALL = EDALLSV
      END IF      
C       
C   IF THE USER HAS REQUESTED COMPLETE RE-EDIT OF THIS FRAME (F10 KEY)
C   CALL LINEQC HERE.  WHEN ALL LINES HAVE BEEN EDITED POSITION TO
C   THE FIRST RED FIELD.
C
      IF (EDALL)THEN
         IF (LNCNT.EQ.0) THEN
            EDALL = .FALSE.
            GO TO 105
         END IF
         CALL LINEQC(RECTYPE,IELEM,ILINE,LINQCD,POSFLD,STRTELEM,EDALL
     +        ,NEWREC,HOURLBL,RTNCODE)
         ILINE = ILINE + 1
         IF (ILINE.LE.LNCNT)THEN
            GO TO 100
         END IF
         EDALL = .FALSE.
         LNCNT = NUMLN2
         ILINE = 1
         IELEM = 1
         IF (ILNSAV.GT.0) THEN
C             .. EDIT HAS BEEN ENTERED FROM AREAQC; POSITION CURSOR AT 
C                REQUESTED LINE AND ELEMENT
            ILINE  = ILNSAV
            IELEM  = IELSAV
            ILNSAV = 0
            IELSAV = 0
            POSFLD = 1
            GO TO 100
         ELSE IF (FLAGARRAY(IELEM,ILINE,1).EQ.'C'.OR.
     +        FLAGARRAY(IELEM,ILINE,1).EQ.'c') THEN
C             .. FIELD FOR ELEM=1,LINE=1 IS ALREADY FLAGGED RED SO POSITION
C                CURSOR AT THAT FIELD      
            POSFLD = 1
            GO TO 100
         ELSE
C             .. POSITION CURSOR AT NEXT FIELD THAT IS FLAGGED RED         
            RTNFLAG = '9F'
            GO TO 200
         END IF
      END IF
 105  CONTINUE
C
C   AN ELEMENT ON THE PREVIOUS LINE CHANGED, RE-QC THIS LINE TO CHECK
C   FOR CHANGE-RATE ERRORS BEFORE PROCEEDING
C
      RTNCODE = '0'
      IF (QCLINE(ILINE)) THEN
         CALL LINEQC(RECTYPE,IELEM,ILINE,LINQCD,POSFLD,
     +               STRTELEM,EDALL,NEWREC,HOURLBL,RTNCODE)
         QCLINE(ILINE) = .FALSE.
         CALL POSFIELD(STRTELEM,NUMLN2,STRTLINE,IELEM,ILINE,RECTYPE,
     +              HOURLBL,POSFLD,MAXY)
         POSFLD = 0
      END IF
C
C    WRITE ANY ERROR MESSAGE FOR THE CURRENT FIELD ON LINE 23 
C
      CALL DSPERR(FLAGARRAY(IELEM,ILINE,2),FLAGARRAY(IELEM,ILINE,1)
     +           ,ILINE,IELEM)
C
C     SAVE THE PREVIOUS VALUE TO SEE IF IT IS CHANGED
C
      INVAL = VALARRAY(IELEM,ILINE)
      HLDFLD = INVAL
      HLDFLAG = FLAGARRAY(IELEM,ILINE,1)
      IRTN = 0
C
C **************  GET,CHECK AND STORE THE DATA INPUT ******************
C-------------------------------------------------------------------
C    IF UNDER QC AUTHORITY
C------------------------------------------------------------------
C    IF THE VALUE IS ALREADY FLAGGED AS IN ERROR - DISPLAY AND
C    ACCEPT THE ERROR ACTION CHOICES
C
      IF (PASSWD.EQ.'QC')THEN
         IF (FLAGARRAY(IELEM,ILINE,1).EQ.'c')THEN
            CALL CHKQVAL(IELEM,ILINE,HLDFLAG,IRTN,RTNFLAG)
            IF (IELEM.EQ.NUMELEM+1.AND.ILINE.EQ.NUMLN2)THEN
               IELEM = NUMELEM
            END IF
            IF (VALARRAY(IELEM,ILINE).NE.HLDFLD)THEN
               INVAL = VALARRAY(IELEM,ILINE)
               IF (VALARRAY(IELEM,ILINE).EQ.HLDFLD(1:5)//'D') THEN
                  VALCHG = 'N'
               ELSE   
                  VALCHG = 'Y'
               ENDIF
            END IF
            HLDFLD = INVAL
C
C        IF IRTN=1 VALUE HAS BEEN ACCEPTED, IF IRTN=2 ACCEPTED AS DUBIOUS
C
            IF (IRTN.EQ.1) THEN
               GO TO 100
            ELSE IF (IRTN.EQ.2)THEN
               GO TO 200
            END IF
         END IF
C
C     OTHERWISE GET THE NEW VALUE (STILL FOR QC ONLY)
C
         CALL GETVAL(INVAL,HLDFLAG,RTNFLAG)
         IF (RTNFLAG.NE.BLANK.AND.INVAL.EQ.HLDFLD)THEN
            IF (IRTN.EQ.3)THEN
C
C         REPLACE WITH ESTIMATE HAS BEEN SELECTED BUT NO VALUE
C         WAS ENTERED
C
               FLAGARRAY(IELEM,ILINE,1) = 'c'
               FLAGARRAY(IELEM,ILINE,2) = 'P'
               HLDFLAG = 'c'
               CALL POSLIN(IROW,ICOL)
               CALL WRTVAL(INVAL,HLDFLAG,IROW,ICOL-6)
               CALL LOCATE(IROW,ICOL,IERR)
               GO TO 100
            END IF
         END IF
         IF (IRTN.EQ.3)THEN
            INVAL(6:6) = 'E'
            IRTN = 0
         END IF
C
C      VALUE ENTERED IS DIFFERENT FROM ORIGINAL VALUE
C
         IF (INVAL.NE.HLDFLD.OR.VALCHG.EQ.'Y')THEN
            VALARRAY(IELEM,ILINE) = INVAL
            FLAGARRAY(IELEM,ILINE,1) = SMALLA
            FLAGARRAY(IELEM,ILINE,2) = BIGA
            VALCHG = 'Y'
         END IF
C -------------------------------------------------------------------
C   IF UNDER DATA-ENTRY AUTHORITY 
C -------------------------------------------------------------------
      ELSE
C
C    IF ALREADY IN ERROR - THE VALUE MUST BE RE-KEYED SO BLANK THE
C       FIELD AND RETURN TO ITS BEGINNING
C
         IF (HLDFLAG.EQ.'C')THEN
            CALL POSLIN(IROW,ICOL)
            INVAL = BLANK
            CALL WRTVAL(INVAL,HLDFLAG,IROW,ICOL)
            CALL LOCATE(IROW,ICOL,IERR)
         END IF
C
C     GET THE NEW VALUE (STILL FOR DE)
C
         CALL GETVAL(INVAL,HLDFLAG,RTNFLAG)
C
C        IF SAME VALUE ENTERED AGAIN AND IT IS FLAGGED, ACCEPT IT
C
         IF (HLDFLD.EQ.INVAL)THEN
            IF (FLAGARRAY(IELEM,ILINE,1).EQ.'C')THEN
               FLAGARRAY(IELEM,ILINE,1) = 'D'
               CALL WRTVAL(INVAL,FLAGARRAY(IELEM,ILINE,1),IROW,ICOL)
               RTNCODE = BLANK
               CALL FNDRED(IELEM,ILINE,POSFLD,RTNCODE)
               IF (RTNCODE.EQ.'2') THEN
                  RTNCODE = BLANK
                  GO TO 100
               END IF
            END IF
            GO TO 200
C
C        VALUE ENTERED IS DIFFERENT FROM ORIGINAL VALUE
C
         ELSE
            IF (FLAGARRAY(IELEM,ILINE,1).EQ.'C'.AND.INVAL.EQ.BLANK) THEN
               CALL WRTVAL(INVAL,BIGA,IROW,ICOL)
            END IF
            VALARRAY(IELEM,ILINE) = INVAL
            FLAGARRAY(IELEM,ILINE,1) = BIGA
            FLAGARRAY(IELEM,ILINE,2) = BIGA
            VALCHG = 'Y'
         END IF
      END IF
C ****************  DATA ENTERED AND STORED **********************
C------------------------------------------------------------------
C  CODE FOR BOTH DE AND QC AUTHORITIES RESUMES
C------------------------------------------------------------------
C
C   IF THIS ELEMENT CHANGED SET INDICATOR SO WE WILL REVALIDATE THE
C   NEXT LINE WHEN WE GET TO IT
C
      IF (VALCHG.EQ.'Y'.AND.ILINE.LT.NUMLN2) THEN
         IF (VALARRAY(IELEM,ILINE+1).NE.BLANK) THEN
            QCLINE(ILINE+1) = .TRUE.
         END IF
      END IF
C
C   PERFORM QC ON THIS LINE IF A VALUE HAS CHANGED AND UNDER QC
C    AUTHORITY OR THE LINE HAS ALREADY BEEN QC'D FOR DE 
C
      IF (LINQCD(ILINE).EQ.'Y'.OR.PASSWD.EQ.'QC')THEN
          IF (VALCHG.EQ.'Y')THEN
             CALL LINEQC(RECTYPE,IELEM,ILINE,LINQCD,POSFLD,
     +                   STRTELEM,EDALL,NEWREC,HOURLBL,RTNCODE)
             VALCHG = 'N'
          END IF
          IF (RTNCODE.EQ.'2')THEN
             GO TO 100
          END  IF
      END IF
C
C  CHECK FOR CURSOR/CARRAIGE CONTROL/SPECIAL KEY CHARACTERS
C
  200 CALL CHKKEY(RTNFLAG,IELEM,ILINE,RECTYPE,LINQCD,POSFLD,
     +            STRTELEM,STRTLINE,NUMLN2,HOURLBL,RTNCODE)
C
C  RTNCODE = '0'  =  NORMAL RETURN - NO QC REQUIRED
C
      IF (RTNCODE.EQ.'0')THEN
         GO TO 100
C
C  RTN-CODE = '1' NOT USED
C
C  RTN CODE = '2'  =  CURSOR CONTROL MOVED US TO DIFFERENT LINE
C                     IF VALUE CHANGED AND PASSWD=QC ALREADY QC'D
C                     THIS LINE BUT IF VALUE CHANGED AND DE, QC IT NOW
C
      ELSE IF (RTNCODE.EQ.'2')THEN
         IF (PASSWD.EQ.'DE'.AND.VALCHG.EQ.'Y')THEN
            CALL LINEQC(RECTYPE,IELEM,HLDLINE,LINQCD,POSFLD,
     +                  STRTELEM,EDALL,NEWREC,HOURLBL,RTNCODE)
            VALCHG = 'N'
            IF (RTNCODE.EQ.'2')THEN
               ILINE = HLDLINE
            END IF
         END IF
         GO TO 100
C
C  RTNCODE = '3'  =  GET A NEW FRAME OF DATA FROM DISC
C
      ELSE  IF (RTNCODE.EQ.'3')THEN
         IF (ICNTRL.EQ.0) THEN
            GO TO 10
         ELSE
            RETURN
         END IF           
C
C  RTNCODE = '4'  =  RE-EDIT THIS ENTIRE FRAME OF DATA - SO FIND
C                    THE NUMBER OF DATA LINES AND CLEAR FLAGS
C
      ELSE IF (RTNCODE.EQ.'4')THEN
         EDALL = .TRUE.
         DO 250 LNCNT = NUMLN2,1,-1
            DO 250 ICOL = 1,NUMELEM
               IF (VALARRAY(ICOL,LNCNT).NE.BLANK)THEN
                  GO TO 260
               END IF
  250    CONTINUE
         LNCNT = 0
  260    CONTINUE
         DO 280 J= 1,NUMLINE
            DO 280 I=1,NUMELEM
               FLAGARRAY(I,J,1) = BLANK
               FLAGARRAY(I,J,2) = BLANK
  280    CONTINUE
         IELEM  = 1
         ILINE = 1
         GO TO 100 
C
C  RTNCODE = '5'  =  PLOT THIS UPPER AIR SOUNDING AS A SKEW-T DIAGRAM
C
      ELSE IF (RTNCODE.EQ.'5')THEN
          CALL UAPLOT(IDKEY)
          CALL SETMOD(SCRMOD,IERR)
          CALL WRTBAN(IDKEY,'U-A',RTNCODE)
          GO TO 90
C
C  RTNCODE ='6'  =  DISPLAY THE LIMITS FOR THIS ELEMENT
C
      ELSE IF (RTNCODE.EQ.'6')THEN
            CALL DISLIMS(IELEM,ILINE)
            GO TO 100
C
C  RTNCODE = '7'  =  REWRITE THE SCREEN
C
      ELSE  IF (RTNCODE.EQ.'7')THEN
C ADDED NEXT LINE 12-4-91 TO HANDLE INSERTING A LINE      
         NEWREC='1'
         GO TO 90
C         
C **REVISION 8-30-93  
C  RTNCODE = '8' USER HAS ENTERED F5 TO CLEAR THE FORM FOR U-A;
C                FLAG IS SET SO ALL ARRAYS IN RAOBQC ARE CLEARED.
C
      ELSE IF (RTNCODE.EQ.'8') THEN
         NEWREC='1'
         GO TO 100      
C
C  RTNCODE = '9'  USER HAS ENTERED F2 TO SAVE THE FORM
C                 IF DATA ENTRY QC THE LINE
C                     IF ANY 'RED' FLAGS RETURN TO LINE
C                 ELSE
C                     WRITE THIS FORM OF DATA TO THE DISC WORK FILES
C                     GET A NEW FRAME OF DATA FROM DISK
C
      ELSE IF (RTNCODE.EQ.'9')THEN
         IF (PASSWD.EQ.'DE') THEN 
            DO 300 I = 1,NUMELEM
               IF (VALARRAY(I,HLDLINE).NE.BLANK)THEN
                  GO TO 310
               END IF
  300       CONTINUE
         END IF
         GO TO 320
  310    CONTINUE
         CALL LINEQC(RECTYPE,IELEM,HLDLINE,LINQCD,POSFLD,
     +               STRTELEM,EDALL,NEWREC,HOURLBL,RTNCODE)
         IF (RTNCODE.EQ.'2')THEN
            ILINE = HLDLINE
            GO TO 100
         END IF
  320    CONTINUE
C
C    BEFORE WRITING DATA CHECK FORM TOTALS FOR THOSE ELEMENTS THAT 
C    ARE REQUESTED IN THE ELEMCHK FILE
C
         CALL TOTQC(RECTYPE,HOURLBL,STRTELEM,STRTLINE,RTNCODE)
         IF (RTNCODE.NE.'0') THEN
            GO TO 100
         END IF
         CALL PUTDATA(IDKEY,0,RTNCODE)
         IF (ICNTRL.EQ.0) THEN
            GO TO 10
         ELSE
            RETURN
         END IF
C
C   RTNCODE NOT VALID
C
      ELSE
         CALL WRTMSG(3,84,12,1,0,BLANK,0)
         GO TO 100
      END IF
C
      STOP ' '
      END
C *********************************************************************      
$PAGE    
      SUBROUTINE RELMSG(IMSG,IELEM,ERRMSG)
C
C   ROUTINE TO FIND ELEMENTS RELATED TO THE CURRENT ELEMENT AND DISPLAY
C   WHAT THEY ARE
C
C   IF IMSG = 6 - RELATED ELEMENT ON THIS LINE - CHKTYP = 4
C           = 7 - RELATED ELEMENT GLOBAL LIMS THIS LINE - CHKTYP = 3 
C           = 8 - RELATED ELEMENT ON PREVIOUS LINE - CHKTYP = 5
$INCLUDE:'VAL1.INC'
$INCLUDE: 'ELEMCHKS.INC'
      INTEGER*2  MCHECK(3)
      CHARACTER*78 ERRMSG
      DATA MCHECK /4,3,5/
C
C   FIND THE END OF THE ERROR MESSAGE PASSED
C      
      IEND = 78
      DO 50 I = 78,1,-1
         IF (ERRMSG(I:I).NE.' ') THEN
            IEND = I+2
            GO TO 60
         END IF
  50  CONTINUE         
  60  CONTINUE
      IF (IEND.GT.60) THEN 
         RETURN
      END IF
      JEND = IEND
C      
C   FIND THE RELATED ELEMENTS
C
      DO 80 ICHK = 1,MAXCHK
         IF (CHKTYP(IELEM,ICHK).EQ.MCHECK(IMSG-5)) THEN
            ICOL = CHKELM(IELEM,ICHK)
            IF (ICOL.GT.0) THEN
               ERRMSG(IEND:IEND+5) = TBLEABRV(ICOL)
               IEND = IEND + 7
               IF (IEND.GT.73) THEN
                  GO TO 200
               END IF
            END IF
         END IF
  80  CONTINUE   
      IF (IMSG.NE.8) THEN
         DO 140 JELEM = 1,NUMELEM
            IF (JELEM.NE.IELEM) THEN
               DO 120 ICHK = 1,MAXCHK
                  IF (CHKTYP(JELEM,ICHK).EQ.MCHECK(IMSG-5).AND.
     +                  CHKELM(JELEM,ICHK).EQ.IELEM) THEN
                     ICOL = CHKELM(JELEM,ICHK)
                     IF (ICOL.GT.0) THEN
                        ERRMSG(IEND:IEND+5) = TBLEABRV(JELEM)
                        IEND = IEND + 7
                        IF (IEND.GT.73) THEN
                           GO TO 200
                        END IF
                     END IF
                  END IF
  120          CONTINUE   
            END IF
  140    CONTINUE          
      END IF
  200 CONTINUE      
      CALL WRTMG(2,ERRMSG,0)
      ERRMSG(JEND:78) = ' '
      RETURN
      END
************************************************************************
$PAGE      
      SUBROUTINE WRTMG(MSGLIN,MESSAGE,BEEPON)
C
C   THIS ROUTINE WRITES MESSAGE TEXT INTO THE APPROPRIATE LINE
C     OF THE MESSAGE AREA AT THE BOTTOM OF THE SCREEN - LINE 1 IS BOTTOM
C     AFTER WRITING THE MESSAGE, IT BEEPS IF WANTED
C
      PARAMETER(JMAX=77)
      INTEGER*2 MSGLIN,BEEPON
      CHARACTER*78 MESSAGE
      CHARACTER*78 OUTMSG
      LOGICAL FRSTCL
      DATA FRSTCL /.TRUE./
C
C   ON FIRST CALL TO THIS ROUTINE SET TEXT FOR COLOR OR B&W MODE
C
      IF (FRSTCL) THEN
         FRSTCL = .FALSE.
         CALL STATUS(IMODE,ICLTYP,IPAGE)
      END IF
      IF (IMODE.EQ.3) THEN
         IFG = 12
         IBG = 0
      ELSE
         IBG = 7
         IFG = 0
      END IF
C
C   DISPLAY THE MESSAGE
C
      OUTMSG = MESSAGE
      OUTMSG(78:78) = CHAR(0)
      CALL POSLIN(IROW,ICOL)
      CALL LOCATE(25-MSGLIN,0,IERR)
      CALL CLTEXT(IBG,0,IERR)
      CALL CWRITE(OUTMSG,IFG,IERR)
C
C   BEEP IF WANTED
C
      IF (BEEPON.EQ.1) THEN
         CALL BEEP
      END IF
      CALL LOCATE(IROW,ICOL,IERR)
      RETURN
      END
      