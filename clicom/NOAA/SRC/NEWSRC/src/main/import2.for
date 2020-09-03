$STORAGE:2            
$DEBUG
      PROGRAM IMPORT2

************************************************************************
*     THIS IS A "SKELETON" PROGRAM THAT LOADS DATA FROM AN EXISTING
*     DIGITAL DATA FILE INTO THE KEY-ENTRY/QC FILES.  THE DATA CAN THEN
*     BE RUN THROUGH NORMAL CLICOM QUALITY CONTROL.  THE "INC" FILES BELOW
*     SHOULD BE IN THE \SRC\MAIN DIRECTORY OF THE DISKETTE WHICH HOLDS
*     THE SOURCE FILE FOR CLICOM PROGRAMS.
*
*     THE PROGRAM ASSUMES THAT YOUR DATA ARE RECORDED BY OBSERVATION - 
*     THAT IS, MANY DIFFERENT ELEMENTS FOR A SINGLE TIME IN EACH RECORD
*
*     THIS PROGRAM REQUIRES MODIFICATION IN ORDER TO MEET SPECIFIC USER
*     REQUIREMENTS.  THE AREAS OF THE PROGRAM THAT WILL MOST LIKELY 
*     NEED REVISION ARE INDICATED BY COMMENTS THAT ARE OFFSET BY A LINE
*     OF ASTERISKS.
************************************************************************
$INCLUDE:'VAL1.INC'
$INCLUDE:'INDEX.INC'

      CHARACTER*1 RTNCODE,REPLY,INFLG(MAXELEM)
      CHARACTER*2 AMONTH,ADAY,AHOUR,RTNFLAG,HOURLBL(24),INUMELEM
      CHARACTER*3 RECTYPE,TBLRECTYP(7),ADSID
      CHARACTER*4 AYEAR
      CHARACTER*5 OUTCNT(2)
      CHARACTER*6 TYPEFRMT
      CHARACTER*8 AFIELD(7),OLDSTN,NEWSTN,INSTN,ERRSRC
      CHARACTER*20 CTRLFIL,INPUTFIL
      CHARACTER*21 IDKEY,LASTID
      CHARACTER*64 HELPFILE
      CHARACTER*80 RDFRMT,MSG,CHKFILE

      INTEGER*4 I4VALUE
      INTEGER*2 INYR,INMONTH,INDAY,INHOUR,TBLNUMLIN(7),RECCOUNT,DSETID
     +         ,NRECCOUNT,LOYR,HIYR,LOMO,HIMO
      INTEGER*2 IHRLBL(24),CTRLINE,IMPLINE
C     
C       .. PARAMETER MAXELEM DEFINED IN VAL1.INC
      INTEGER*2 INELEM(MAXELEM),ELMCOL(MAXELEM)
      REAL*4 MISVAL(MAXELEM), INVAL(MAXELEM)

      LOGICAL FILEFLAG

      DATA RECCOUNT/0/,NRECCOUNT/0/,OUTCNT/' ','\'/,LASTID/' '/
      DATA AFIELD /7*' '/
      DATA AMONTH/' '/
      DATA TBLRECTYP  /'MLY','10D','DLY','SYN','HLY','15M','U-A'/
     +    ,TBLNUMLIN /12,36,31,8,24,96,100/
      DATA HELPFILE/'P:\HELP\IMPORT1A.HLP'/
     
      OUTCNT(2) = CHAR(0)
      TYPEFRMT = 'EXPOBS'
      CTRLINE = 0
      IMPLINE = 0 
C
C     *** DISPLAY MESSAGES IF THE PROGRAM RUN OUTSIDE THE CLICOM SYSTEM
C
      CHKFILE='P:\DATA\MESSAGES.FTN'
      INQUIRE(FILE=CHKFILE,EXIST=FILEFLAG)
      IF (.NOT.FILEFLAG) THEN
         CALL CLS
         CALL BEEP
         CALL LOCATE(16,0,IERR)
         CALL POSLIN(IR,IC)
         MSG = '           This program must run within CLICOM by'
     +         //' selecting choice #3'
         IR = IR + 1
         CALL SCRNMSGI(MSG,IR,14)
         MSG = '           from the "Climate data key-entry and'
     +         //' quality control" menu (3).'
         IR = IR + 1
         CALL SCRNMSGI(MSG,IR,14)
         MSG = ' '  
         IR = IR + 2
         CALL SCRNMSGI(MSG,IR,14)
         STOP ' '
      END IF            
C
C       ** RETRIEVE THE DATA TYPE TO BE IMPORTED
C
      CALL SETMOD(3,IERR)
      CALL LOCATE (4,8,IERR)
      CALL GETMNU('DR-DATATYPES','  ',ITYPE)
      IF (ITYPE.EQ.0)THEN
         CALL LOCATE(23,0,IERR)
         STOP ' '
      END IF
C
C       .. DEFINE LOCAL VARIABLES
      RECTYPE = TBLRECTYP(ITYPE)

************************************************************************
C       ** OPEN THE IMPORT CONTROL FILE.  THE NAME OF THE FILE IS
C          P:\DATA\IMPCTRL.xxx WHERE xxx IS THE OBS-TYPE (DLY, MLY, ETC.)   
C          AND IS DETERMINED BY THE DATA TYPE TO BE IMPORTED. 
************************************************************************

      CTRLFIL = 'P:\DATA\IMPCTRL.'//RECTYPE
      OPEN(61,FILE=CTRLFIL,STATUS='OLD',FORM='FORMATTED',ERR=9015,
     +                    IOSTAT=IOCHK)
C
C       .. DEFINE VARIABLES IN COMMON VAL1 (VAL1.INC) -- VARIABLES NUMLINE
C          AND NUMELEM ARE USED IN ROUTINE PUTDATA.  NUMELEM IS DEFINED IN
C          ROUTINE GETSET    
      NUMLINE = TBLNUMLIN(ITYPE)
C
C       ** RETRIEVE THE SELECTION CRITERIA FROM THE USER 
C          THEY ARE RETURNED IN AFIELD AND MOVED TO THE PROPER VARIABLES
C
      CALL CLS
50    CONTINUE
      CALL LOCATE (4,0,IERR)
      RTNFLAG = 'SS'
      CALL GETFRM('IMPORT1A ',HELPFILE,AFIELD,8,RTNFLAG)
      IF (RTNFLAG.EQ.'4F')THEN
         CALL LOCATE (24,0,IERR)
         STOP ' '
      END IF
      
      READ(AFIELD(1),'(A8)') OLDSTN
      READ(AFIELD(2),'(A8)') NEWSTN
      READ(AFIELD(3),'(I4)') LOYR    
      READ(AFIELD(4),'(I2)') LOMO   
      READ(AFIELD(5),'(I4)') HIYR    
      READ(AFIELD(6),'(I2)') HIMO   
      READ(AFIELD(7),'(I3)') DSETID 
C
C       ** OPEN THE SETUP FILE (THE DEFINITION OF KEY-ENTRY FORMS) 
C          AND LOAD THE ELEMENT CODES AND COLUMN HEADERS.  THE KEY
C          ENTRY FORMS MUST BE DEFINED BEFORE THIS PROGRAM IS RUN.
C          FOR HOURLY AND SYNOPTIC DATA READ HOUR LABEL VALUES FROM 
C          DATAQC.PRM.  THEN OPEN THE KEY-ENTRY/QC FILES.
C

      CALL GETSET(DSETID,ITYPE,RECTYPE,HOURLBL,RTNCODE)
      ERRSRC = 'GETSET'
      IF (RTNCODE.NE.'0') GO TO 9035
      LASTID = ' '
      CALL OPENFILES(2)

************************************************************************
C
C       ** FOR HOURLY AND SYNOPTIC DATA CONVERT HOUR LABELS FROM
C          CHARACTER TO INTEGER FORMAT
C          NOTE:  IT IS EXPECTED THAT THE HOUR VALUES FOR THE INPUT DATA
C                 AGREE WITH THE HOUR VALUES SPECIFIED IN THE DATAQC.PRM
C                 FILE.  IF THIS IS NOT TRUE, THEN CODE TO MAKE THE CONVERSION
C                 MUST BE ADDED TO THIS PROGRAM
C
************************************************************************
      IF (ITYPE.EQ.4 .OR. ITYPE.EQ.5) THEN
         DO 60 I=1,NUMLINE
            READ(HOURLBL(I),'(I2)') IHRLBL(I)
   60    CONTINUE         
      ENDIF 
************************************************************************
C       ** OPEN THE INPUT DATA FILE -- THE DEFAULT NAME OF THE FILE IS
C          P:\DATA\IMPDATA.xxx WHERE xxx IS THE OBS-TYPE (DLY, MLY, ETC.)   
C          AND IS DETERMINED BY THE DATA TYPE TO BE IMPORTED.  IF YOU 
C          WISH TO USE A DIFFERENT NAME, SET THE VARIABLE INPUTFIL TO
C          THE DESIRED NAME OF THE INPUT DATA FILE.  IF YOU WANT FORTRAN 
C          TO ASK FOR THE NAME WHEN THE OPEN STATEMENT IS EXECUTED, THEN
C          SET THE VARIABLE INPUTFIL TO ' '.
************************************************************************

      CALL  LOCATE(20,0,IERR)
      INPUTFIL='P:\DATA\IMPDATA.'//RECTYPE
      OPEN (75,FILE=INPUTFIL,STATUS='OLD',FORM='FORMATTED',ERR=9010,
     +                       IOSTAT=IOCHK)

************************************************************************
C       ** READ THE IMPORT CONTROL FILE.  THE NAME OF THE FILE IS
C          P:\DATA\IMPCTRL.xxx WHERE xxx IS THE OBS-TYPE (DLY, MLY, ETC.)   
C          AND IS DETERMINED BY THE DATA TYPE TO BE IMPORTED. 
C          THE IMPORT CONTROL FILE DESCRIBES THE ELEMENTS TO BE EXPECTED 
C          IN THE INPUT DATA FILE.  THE IMPORT CONTROL FILE SHOULD 
C          CONTAIN FOUR LINES:
C                 1. THE FIRST LINE SPECIFIES THE NUMBER OF ELEMENTS THAT
C                    WILL BE PROCESSED.
C                 2. THE SECOND LISTS THE ELEMENT CODES FOR ALL OF THE
C                    ELEMENTS TO BE CONVERTED (SEPARATED BY COMMAS). 
C                    THE ELEMENTS MUST BE LISTED IN THE SAME ORDER AS THEY 
C                    APPEAR IN THE INPUT FILE.
C                 3. THE THIRD LINE SHOULD CONTAIN THE MISSING VALUE CODE
C                    FOR EACH OF THE ELEMENTS IN THE SECOND LINE (IN THE
C                    SAME ORDER).  THESE SHOULD ALSO BE SEPARATED BY COMMAS.
C                 4. THE FOUR LINE SPECIFIES THE FORMAT USES TO READ THE INPUT
C                    DATA FILE. (IF IT IS 'EXPOBS', THE INPUT FILE ARE RECORDED
C                    BY OBSERVATION.  IF IT IS 'CUSTOM', THE FORMAT USES TO
C                    READ THE INPUT DATA FILE BY LIST DIRECTED I/O).
C                     
************************************************************************

      CTRLINE = CTRLINE + 1
      READ(61,*,ERR=9020,IOSTAT=IOCHK) NBRINELM
      IF (NBRINELM.GT.MAXELEM) GO TO 9005
      CTRLINE = CTRLINE + 1
      READ(61,*,ERR=9020,IOSTAT=IOCHK) (INELEM(I),I=1,NBRINELM)
      CTRLINE = CTRLINE + 1
      READ(61,*,ERR=9020,IOSTAT=IOCHK) (MISVAL(I),I=1,NBRINELM)
      CTRLINE = CTRLINE + 1
      READ(61,*,ERR=9020,IOSTAT=IOCHK) TYPEFRMT
      CLOSE(61) 

C
C       ** IDENTIFY THE PROPER COLUMN OF THE FORM FOR EACH ELEMENT.         
C
      DO 120 J = 1,NBRINELM
         IF (INELEM(J).EQ.0) THEN
            NBRINELM = J - 1            
            GO TO 125
         END IF
         DO 110 I = 1,MAXELEM
            K=I
            IF (INELEM(J) .EQ. TBLELEM(I)) THEN
               GO TO 115
            END IF
110      CONTINUE
            GOTO 9030
115      CONTINUE         
         ELMCOL(J) = K
120   CONTINUE
125   CONTINUE

C
C       ** WRITE THE RUNNING TOTAL LINE                                     
C

      CALL CLRMSG(1)
      CALL LOCATE(24,0,IERR)
      CALL WRTSTR('Records read -        Records processed - ',42,14,0)

C
C       ** INITIALIZE THE WORK ARRAYS.  NOTE THAT NUMLINE AND NUMELEM ARE
C          LISTED IN COMMON VAL1 (VAL1.INC)
C

      DO 900 J=1,NUMLINE
         DO 900 K=1,NUMELEM
         VALARRAY(K,J) = ' '
         FLAGARRAY(K,J,1) = ' '
         FLAGARRAY(K,J,2) = ' '
900   CONTINUE
C
C       .. FLAG IS SET FOR AUTOMATIC QUALITY CONTROL FOR ALL DATA TYPES EXCEPT
C          UPPER-AIR.  FOR UPPER-AIR DATA YOU MUST PRESS F10 AFTER YOU 
C          SELECT VALIDATION.  FOR OTHER DATA TYPES QUALITY CONTROL OCCURS
C          AUTOMATICALLY AFTER YOU SELECT VALIDATION.
      IF (ITYPE.NE.7) FLAGARRAY(1,1,1) = '?'

C
C       ** NOW READ THE DATA, FORMAT IDKEY AND SELECT PROPER RECORDS.      
C          --- THIS IS THE MAIN LOOP IN THE PROGRAM ---
C

      LINENUM = 0
1000  CONTINUE
C
C       ** INITIALIZE ALL VALUES TO MISSING
C
      DO 1050 I2 = 1,NBRINELM
         INVAL(I2) = MISVAL(I2)
1050  CONTINUE               

************************************************************************
C       ** READ A DATA RECORD - THIS LINE MUST BE MODIFIED TO READ DATA 
C          IN YOUR FORMAT.  AS DELIVERED IT USES A * FORMAT (LIST 
C          DIRECTED I/O).  THE FOLLOWING RULES APPLY TO LIST DIRECTED I/O:
C          DATA VALUES MUST BE SEPARATED BY COMMAS OR BLANKS, CHARACTER
C          VALUES (FOR EXAMPLE, INSTN) MUST BE ENCLOSED IN APOSTROPHES.
C          IMPORT1 ASSUMES THE DATA ARE STORED BY OBSERVATION 
C          WITH THE ELEMENTS IN THE ORDER THAT YOU SPECIFIED IN THE IMPORT 
C          CONTROL FILE ABOVE.  YOU MAY CHOOSE TO USE A FORMAT STATEMENT
C          IF ONE IS REQUIRED FOR YOUR DATA.  IF YOUR INPUT DATA DOES NOT
C          AGREE IN TYPE WITH THE EXPECTED INPUT VARIABLES, YOU MUST CREATE
C          ADDITIONAL INPUT VARIABLES OR AN ARRAY TO RECEIVE YOUR DATA.
************************************************************************
C
C     DETERMINE THE FORMAT USES TO READ THE INPUT DATA FILE.  IF TYPEFRMT
C     IS 'EXPOBS', THE INPUT DATA FILE ARE RECORDED BY OBSERVATION. (i.e, WITH
C     STATION-ID, THE DATE/TIME GROUP AND THE ELEMENTS DATA LISTED ON ONE LINE
C     FOR EACH STATION).  IF TYPEFRMT IS 'CUSTOM', THE FORMAT USES TO READ
C     INPUT DATA FILE AS A LIST DIRECT I/O FORMAT.
C
*******************************************************************************

      IF (TYPEFRMT.EQ.'CUSTOM'.OR.TYPEFRMT.EQ.'Custom') THEN
C
C     **** THE FORMAT USES TO READ THE INPUT DATA FILE BY LIST DIRECT I/O
C          NOTE: THE STATION-ID MUST BE ENCLOSED IN APOSTROPHES AND DATA
C                VALUES MUST BE SEPARATED BY COMMAS OR BLANKS.
C
         IMPLINE = IMPLINE + 1
         READ(75,*,END=4000,ERR=9025,IOSTAT=IOCHK) INSTN,INYR,INMONTH,
     +                          INDAY,INHOUR,(INVAL(I1),I1=1,NBRINELM)
      ELSE
C        
C     *** THE FORMAT USES TO READ THE INPUT DATA FILE BY OBSERVATION
C     *** DETERMINE NUMBER OF ELEMENTS IN THE INPUT DATA FILE
C
         WRITE(INUMELEM,'(I2)')NBRINELM
         IMPLINE = IMPLINE + 1
C
         IF (RECTYPE.EQ.'MLY'.OR.RECTYPE.EQ.'10D') THEN
C
C     ** FORMAT STATEMENT FOR READ MONTHLY AND 10D DATA
C
            RDFRMT='(A8,1X,I4,1X,I2,'//INUMELEM//'(1X,F8.1,1X,A1))'

            READ(75,RDFRMT,END=4000,ERR=9025,IOSTAT=IOCHK) INSTN,INYR,
     +           INMONTH,(INVAL(I1),INFLG(I1),I1=1,NBRINELM)

         ELSE IF (RECTYPE.EQ.'DLY') THEN
C
C     ** FORMAT STATEMENT FOR READ DAILY DATA
C
            RDFRMT='(A8,1X,I4,2(1X,I2),'//INUMELEM//'(1X,F8.1,1X,A1))'

            READ(75,RDFRMT,END=4000,ERR=9025,IOSTAT=IOCHK) INSTN,INYR,
     +           INMONTH,INDAY,(INVAL(I1),INFLG(I1),I1=1,NBRINELM)

         ELSE IF (RECTYPE.EQ.'HLY' .OR. RECTYPE.EQ.'SYN' .OR.
     +            RECTYPE.EQ.'15M'.OR.RECTYPE.EQ.'U-A') THEN
C
C     ** FORMAT STATEMENT FOR READ HOURLY, SYNOPTIC, 15-MINUTE, AND
C        UPPER-AIR DATA
C
            RDFRMT='(A8,1X,I4,3(1X,I2),'//INUMELEM//'(1X,F8.1,1X,A1))'

            READ(75,RDFRMT,END=4000,ERR=9025,IOSTAT=IOCHK) INSTN,INYR,
     +           INMONTH,INDAY,INHOUR,(INVAL(I1),INFLG(I1),I1=1,
     +           NBRINELM)
         END IF 
      END IF
C
      NRECCOUNT = NRECCOUNT + 1
      CALL LOCATE(24,15,IERR)
      WRITE(OUTCNT,'(I5)') NRECCOUNT
      CALL CWRITE(OUTCNT,12,IERR)

*****************************************************************************
C       ** THE IMPORT2 PROGRAM EXPECTS ACTUAL DATA VALUES INCLUDING DECIMAL
C          POINTS IF NECESSARY.  THESE VALUES ARE READ AS REAL NUMBERS AND
C          ARE CONVERTED BY THIS PROGRAM TO INTEGER VALUES THAT ARE DISPLAYED
C          ON THE KEY ENTRY FORM.  THE CONVERSION FROM REAL TO INTEGER
C          VALUES IS MADE USING THE SCALE FACTOR SPECIFIED IN THE DATAEASE
C          ELEMENT DEFINITION FORM.  THE ACTUAL PRECISION OF THE INPUT
C          VALUE IS NOT TAKEN INTO CONSIDERATION.  THE INPUT UNITS ARE
C          EXPECTED TO BE THE SAME AS THOSE SPECIFIED IN THE DATAEASE 
C          ELEMENT DEFINITION FORM.  IF, FOR EXAMPLE, THE INPUT UNITS ARE
C          INCHES AND THE UNITS DEFINED IN DATAEASE ARE CENTIMETERS, THE
C          USER IS RESPONSIBLE FOR ADDING CODE TO MAKE ANY NECESSARY
C          CONVERSIONS AND LOADING THE CONVERTED DATA INTO ARRAY INVAL.  
C          THE POSITION OF EACH ELEMENT IN THE ARRAY INVAL MUST AGREE WITH 
C          THE POSITIONS INDICATED IN THE SECOND RECORD OF THE IMPORT CONTROL 
C          FILE.
*****************************************************************************

C
C       ** CHECK IF THE RECORD READ IS WITHIN THE RANGE OF DATA THE USER 
C          HAS SPECIFIED
C
      IF (INSTN.LT.OLDSTN) THEN
         GO TO 1000
      ELSE IF (INSTN.GT.OLDSTN) THEN
         GO TO 4000
      ELSE IF (INYR.LT.LOYR) THEN   
         GO TO 1000
      ELSE IF (INYR.GT.HIYR .AND. INSTN.EQ.OLDSTN) THEN   
         GO TO 4000
      END IF

      IF (RECTYPE.NE.'MLY' .AND. RECTYPE.NE.'10D') THEN
         IF (INYR.EQ.LOYR .AND. INMONTH.LT.LOMO) THEN   
            GO TO 1000
         ELSE IF (INYR.EQ.HIYR .AND. INMONTH.GT.HIMO) THEN   
            GO TO 4000
         END IF
      END IF
C
C       ** FILL IN THE IDKEY - THE FIELD WHICH WILL IDENTIFY THIS RECORD 
C          IN THE KEY-ENTRY/QC FILE.
C
      WRITE(ADSID,'(I3.3)') DSETID
      WRITE(AYEAR,'(I4.4)') INYR
      IF (RECTYPE.EQ.'MLY' .OR. RECTYPE.EQ.'10D') THEN
C          .. MONTHLY AND 10-DAY DATA      
         AMONTH = ' '
         ADAY = ' '
         AHOUR = ' '
      ELSE IF (RECTYPE.EQ.'DLY') THEN
C          .. DAILY DATA      
         WRITE(AMONTH,'(I2.2)') INMONTH
         ADAY = ' '
         AHOUR = ' '
      ELSE IF (RECTYPE.EQ.'HLY' .OR. RECTYPE.EQ.'SYN' .OR.
     +         RECTYPE.EQ.'15M') THEN
C          .. HOURLY, SYNOPTIC, AND 15-MINUTE DATA     
         WRITE(AMONTH,'(I2.2)') INMONTH
         WRITE(ADAY,'(I2.2)') INDAY
         AHOUR = ' '
      ELSE
C          .. UPPER AIR DATA
         WRITE(AMONTH,'(I2.2)') INMONTH
         WRITE(ADAY,'(I2.2)') INDAY
         WRITE(AHOUR,'(I2.2)') INHOUR
      END IF

      WRITE(IDKEY,'(A8,A3,A4,3A2,)') NEWSTN,ADSID,AYEAR,
     +                               AMONTH,ADAY,AHOUR

C
C       ** IF IDKEY OF THIS RECORD IS DIFFERENT FROM THE PREVIOUS RECORD THEN
C          IT GOES INTO A NEW KEY-ENTRY/QC FORM.  WRITE OUT THE DATA THAT WE
C          HAVE BEEN ACCUMULATING INTO THE LAST FORM AND START A NEW ONE. 
C    
C       .. WRITE OUT THE DATA WE HAVE BEEN ACCUMULATING
C
      IF (IDKEY.NE.LASTID.AND.LASTID.NE.' ') THEN
         CALL BINDATA(LASTID,RTNCODE)
C
C          ** IF RTNCODE = 2 THEN ID NOT FOUND SO IT'S NEW (OK).
C             IF RTNCODE = 0 THEN THE PROGRAM HAS ENCOUNTERED A DUPLICATE ID
C             ASK THE USER TO CONTINUE OR QUIT.  ANY OTHER RTNCODE INDICATES
C             AN ERROR.
C
         IF (RTNCODE.NE.'2') THEN
            IF (RTNCODE.EQ.'0') THEN
               CALL WRTMSG(5,305,12,1,0,' ',0)
               CALL LOCATE(22,5,IERR)
               CALL OKREPLY(REPLY,RTNCODE)
               IF (REPLY.EQ.'N') THEN
                  CALL WRTMSG(3,365,14,1,1,' ',0)
                  CALL LOCATE(23,0,IERR)
                  STOP ' '
               ELSE
                  CALL CLRMSG(5)
                  CALL CLRMSG(3)
               END IF
            ELSE
               CALL WRTMSG(5,51,12,1,1,RTNCODE,1)
               CALL WRTMSG(3,365,14,1,1,' ',0)
               CALL LOCATE(23,0,IERR)
               STOP ' '
            END IF
         END IF
         CALL PUTDATA(LASTID,2,RTNCODE)
C
C          ** RE-INITIALIZE THE WORK ARRAYS TO HOLD THE NEW DATA.  NOTE THAT
C             NUMLINE AND NUMELEM ARE LISTED IN COMMON VAL1 (VAL1.INC) 
C
         DO 1100 J=1,NUMLINE
            DO 1100 K=1,NUMELEM
               VALARRAY(K,J) = ' '
1100     CONTINUE
         LINENUM = 0

      END IF

      LASTID = IDKEY
         
C
C       ** LOAD DATA VALUES FROM THE CURRENT RECORD INTO VALARRAY.
C

1300  CONTINUE
      IF (ITYPE.LE.2) THEN
C          .. MONTHLY AND 10-DAY DATA      
         IROW = INMONTH
      ELSE IF (ITYPE.EQ.3) THEN
C          .. DAILY DATA      
         IROW = INDAY
      ELSE IF (ITYPE.EQ.4 .OR. ITYPE.EQ.5) THEN
C          .. HOURLY AND SYNOPTIC DATA     
         DO 1320 I=1,NUMLINE
            IF (INHOUR.EQ.IHRLBL(I)) GO TO 1321
 1320    CONTINUE           
         GO TO 9040
 1321    CONTINUE           
         IROW = I
      ELSE IF (ITYPE.EQ.6) THEN
C          .. 15-MINUTE DATA     
         IROW = INHOUR
      ELSE   
C          .. UPPER AIR DATA      
         LINENUM = LINENUM + 1
         IROW=LINENUM
      END IF
C       **REVISION 9-1-93
      IF (IROW.GT.MAXLINE) GO TO 9008      
C
      DO 3000 J1 = 1,NBRINELM
         IF (INELEM(J1).GT.0.AND.INELEM(J1).LE.999) THEN
            JCOL = ELMCOL(J1)
            IF (INVAL(J1).NE.MISVAL(J1)) THEN
               CALL IROUND4((INVAL(J1)/TBLCONV(JCOL)),I4VALUE)
               CALL CKINTGR(I4VALUE,IER)
               IF (IER.EQ.0) THEN
                  WRITE(VALARRAY(JCOL,IROW),'(I5,1X)') I4VALUE
               ELSE
                  VALARRAY(JCOL,IROW) = '      '
               ENDIF
            ELSE     
               VALARRAY(JCOL,IROW) = '      '
            END IF 
C
C             ** THE NEXT LINES ARE COMMENTED BUT GIVE AN EXAMPLE OF HOW
C                YOU MIGHT CHECK FOR SPECIAL VALUES WHICH INDICATE TRACE 
C                OF PRECIP
C
C            IF ((INELEM(J1).EQ.005.OR.INELEM(J1).EQ.007.OR.
C     +           INELEM(J1).EQ.010).AND.INVAL(J1).EQ.999.9) THEN
C               VALARRAY(JCOL,IROW) = '    0T'
C            END IF
C
            IF (TYPEFRMT.EQ.'EXPOBS'.OR.TYPEFRMT.EQ.'Expobs') THEN
               IF ((INELEM(J1).EQ.005.OR.INELEM(J1).EQ.104.OR.
     +            INELEM(J1).EQ.208.OR.INELEM(J1).EQ.210)
     +            .AND.INFLG(J1).EQ.'T') THEN
                   VALARRAY(JCOL,IROW) = '    0T'
               END IF
            END IF
         END IF
3000  CONTINUE

      RECCOUNT = RECCOUNT + 1
      CALL LOCATE(24,42,IERR)
      WRITE(OUTCNT,'(I5)') RECCOUNT
      CALL CWRITE(OUTCNT,12,IERR)
C
C       ** NOW GO BACK AND READ THE NEXT RECORD
C
      GO TO 1000
C
C       ** BEFORE STOPPING, WRITE OUT THE DATA THAT HAS BEEN ACCUMULATING FOR
C          THE LAST KEY-ENTRY/QC FORM.
C
4000  CONTINUE
      IF (RECCOUNT.GT.0) THEN
         CALL BINDATA(LASTID,RTNCODE)
         IF (RTNCODE .NE.'2') THEN
            IF (RTNCODE .EQ. '0') THEN
               CALL WRTMSG(5,305,12,1,0,' ',0)
               CALL LOCATE(22,5,IERR)
               CALL OKREPLY(REPLY,RTNCODE)
               IF (REPLY .EQ. 'N') THEN
                  CALL WRTMSG(3,365,14,1,1,' ',0)
                  CALL LOCATE(23,0,IERR)
                  STOP ' '
               ELSE
                  CALL CLRMSG(5)
                  CALL CLRMSG(3)
                  NMSG = 365
               END IF
            ELSE
               CALL WRTMSG(5,51,12,1,1,RTNCODE,1)
               CALL WRTMSG(3,365,14,1,1,' ',0)
               CALL LOCATE(23,0,IERR)
               STOP ' '
            END IF
         END IF
         CALL PUTDATA(LASTID,2,RTNCODE)
         NMSG = 365
      ELSE   
         NMSG = 306
      ENDIF
      CALL CLRMSG(1)
      CALL LOCATE(15,0,IERR)
      WRITE(*,5010) RECCOUNT,NRECCOUNT - RECCOUNT
      CALL WRTMSG(3,NMSG,14,1,1,' ',0)
C
C       ** PROCESSING IS COMPLETE. 
C
      CLOSE(19)
      CLOSE(20)
C
5010  FORMAT(///,' Processing Complete',/
     +      ,2X,I5,' Records Processed',/
     +      ,2X,I5,' Records Skipped') 
      STOP ' '
C
C      ** ERROR PROCESSING
C
C       ** REVISION 9-1-93  ADD ERROR MESSAGES FOR INPUT ELEMENTS,IROW
9005  CONTINUE
         CALL LOCATE(21,0,IERR)  
         WRITE(*,*) 
     +      'Number of input elements greater than maximum   In,Max=',
     +       NBRINELM,MAXELEM        
         GO TO 9999
9008  CONTINUE
         CALL LOCATE(21,0,IERR)  
         WRITE(*,*) 
     +      'Input row greater than maximum  Row,Max,Id=',
     +       IROW,MAXLINE,IDKEY        
         GO TO 9999
9010  CONTINUE
         CALL LOCATE(20,0,IERR)
         CALL CLRMSG(1)
         WRITE(*,*) 'The input data file: '//INPUTFIL//'was not'
     +        //' found.'
         WRITE(*,*)'FORTRAN Error Message=',IOCHK
         GO TO 9999
9015  CONTINUE
         CALL LOCATE(20,0,IERR)  
         CALL CLRMSG(1)
         WRITE(*,*) 'The import control file: '//ctrlfil//'was not'
     +        //' found.'
         WRITE(*,*)'FORTRAN Error Message=',IOCHK
         GO TO 9999
9020  CONTINUE
         CALL LOCATE(20,0,IERR)  
         CALL CLRMSG(1)
         WRITE(*,*) 'Read error in import control file: '//CTRLFIL//
     +              ' at Line=',CTRLINE
         WRITE(*,*)'FORTRAN Error Message=',IOCHK
         GO TO 9999
9025  CONTINUE
         CALL LOCATE(20,0,IERR)  
         CALL CLRMSG(1)
         WRITE(*,*)'Read error in input data file: '//INPUTFIL//
     +              ' at Line=',IMPLINE
         WRITE(*,*)'FORTRAN Error Message=',IOCHK
         GOTO 9999
9030  CONTINUE
         CALL LOCATE(20,0,IERR)
         CALL CLRMSG(1)
         WRITE(*,*)'Element',INELEM(J),'   not defined for this dataset'
         GO TO 9999
9035  CONTINUE
         CALL LOCATE(20,0,IERR)  
         WRITE(*,*)'Error condition returned from routine ',ERRSRC
         GO TO 9999
9040  CONTINUE
         CALL LOCATE(20,0,IERR)  
         CALL CLRMSG(1)
         WRITE(*,*)
     +   'Input hour does not agree with values in DATAQC.PRM:  ',INHOUR
C
9999  CONTINUE
      CALL BEEP
      WRITE(*,*)'See chapter 17 in CLICOM manual for more information.'
      WRITE(*,*) 'Enter any key to continue '
      CALL GETCHAR(INCHAR,0)
      STOP ' '
      END



