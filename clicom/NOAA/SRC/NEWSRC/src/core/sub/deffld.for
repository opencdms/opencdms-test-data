$STORAGE:2

      SUBROUTINE DEFFLD(ENDCOL,FLDFGC,FLDBGC)
C
C   ROUTINE TO DEFINE A FIELD ON A DATA ENTRY FORM 
C
      CHARACTER*80 BLANK
      CHARACTER*10 HLDCHR
      CHARACTER*2  INCHAR,RTNFLAG,FLDCHR(7)
      CHARACTER*35 PRMFILE
      CHARACTER*1  RTNCODE,TXTCHR(5)
      CHARACTER*5  YNCHR(5)
      CHARACTER*72 MESSAGE,FLDTEXT(22)
      INTEGER*2    ENDCOL,DELFLD,FLDNUM,FLDFGC,FLDBGC
      LOGICAL      NEWFLD,MODIFY,DEFLT
C
$INCLUDE: 'FRMFLD.INC'
C
      DATA BLANK /'                     '/
C
      PRMFILE = 'P:\DATA\DEFFLD.PRM'
      DO 2 K = 1,22
         FLDTEXT(K) = BLANK
  2   CONTINUE
C
C     *** READ THE TEXT FOR ALL FIELDS FROM PARAMETER FILE
C
  5   CONTINUE
      OPEN (58,FILE=PRMFILE,STATUS='OLD',FORM='FORMATTED',IOSTAT=IOCHK)
      IF (IOCHK.NE.0) THEN
         CALL OPENMSG(PRMFILE,'       DEFFLD      ',IOCHK)
         GO TO 5
      END IF
      DO 7 I = 1,22
         READ(58,*,ERR=800) FLDTEXT(I)
  7   CONTINUE
      READ(58,*,ERR=800) (TXTCHR(K),K=1,5)
      READ(58,*,ERR=800) (FLDCHR(J),J=1,7)
      READ(58,*,ERR=800) (YNCHR(L),L=1,5)
      CLOSE(58)
      CLOSE(58)
C
      CALL POSLIN(IROW,ICOL)
      CALL ACTPAG(1,IERR)
      FLDNUM = 0
      DELFLD = 0
      DO 10 I = 1,NUMFLD
         IF (FLENGTH(I).GT.0) THEN
            IF (IROW.EQ.FLDROW(I).AND.ICOL.GE.FLDCOL(I).AND.ICOL.LE.
     +            FLDCOL(I)+FLENGTH(I)-1) THEN
               FLDNUM = I
               GO TO 12
            END IF
         ELSE IF (DELFLD.EQ.0) THEN
            DELFLD = I
         END IF
   10 CONTINUE
   12 CONTINUE
      IF (FLDNUM.GT.0) THEN
         NEWFLD = .FALSE. 
         MODIFY = .FALSE.
         IROW = FLDROW(FLDNUM)
         ICOL = FLDCOL(FLDNUM)
         WRITE(MESSAGE,'(A6,I2)')YNCHR(5),FLDNUM
      ELSE
         MODIFY = .TRUE.
         IF (DELFLD.EQ.0) THEN
            NEWFLD = .TRUE.
            NUMFLD = NUMFLD + 1
            FLDNUM = NUMFLD
         ELSE
            NEWFLD = .FALSE.
            FLDNUM = DELFLD
         END IF
C
C     *** INITIALIZE VALUES IF IT'S A NEW FIELD
C
         NCHR1 = LNG(YNCHR(5))
         CALL UPRCS1(YNCHR(5),NCHR1)
         FLDTYPE(FLDNUM) = ' '
         FLENGTH(FLDNUM) = 0
         LKFILE(FLDNUM) = '  '
         LKFLEN(FLDNUM) = 0
         LKFRECFLD(FLDNUM) = 0
         LKFPOS(FLDNUM) = 0
         HIGHLIM(FLDNUM) = '        '
         LOWLIM(FLDNUM) = '      '
         DEFAULT(FLDNUM) = '     '
         RANGE(FLDNUM) = .FALSE.
         LOOKUP(FLDNUM) = .FALSE.
         NOENTRY (FLDNUM) = .FALSE.
         FLDROW(FLDNUM) = IROW
         FLDCOL(FLDNUM) = ICOL
         WRITE(MESSAGE,'(A15,I2)') FLDTEXT(1),FLDNUM
      END IF
   40 CONTINUE
      CALL CLS
      CALL LOCATE(1,1,IERR)
      LNGTH = LNG(MESSAGE)
      CALL WRTSTR(MESSAGE,LNGTH,12,0)
      CALL LOCATE(2,1,IERR)
C
C     *** GET THE FIELD TYPE
C
      LNGTH = LNG(FLDTEXT(2))
      CALL WRTSTR(FLDTEXT(2),LNGTH,14,0)
   50 CONTINUE
      IF (FLDTYPE(FLDNUM).EQ.TXTCHR(2)) THEN
         FLDTYPE(FLDNUM) = TXTCHR(3)
      END IF
      CALL LOCATE(2,66,IERR)
      CALL WRTSTR(FLDTYPE(FLDNUM),1,15,1)
      CALL LOCATE(2,66,IERR)
      IF (MODIFY) THEN 
         CALL GETCHAR(0,INCHAR)
         IF (INCHAR.EQ.'4F') THEN
            GO TO 500
C
C     *** IF "C" IS ENTERED - COPY THE DEFINITION OF ANOTHER FIELD
C
         ELSE IF (INCHAR.EQ.FLDCHR(1)) THEN
            LNGTH = LNG(FLDTEXT(3))
            CALL WRTSTR(FLDTEXT(3),LNGTH,15,1)
  60        CONTINUE
            CALL LOCATE(4,1,IERR)
            INCHAR = '  '
            LNGTH = LNG(FLDTEXT(4))
            CALL WRTSTR(FLDTEXT(4),LNGTH,14,0)
            CALL GETSTR(3,INCHAR,2,15,1,RTNFLAG)
            IF (RTNFLAG.EQ.'4F'.OR.INCHAR.EQ.'  ') THEN
               GO TO 500
            END IF
            READ(INCHAR,'(BN,I2)',ERR=75) INFLD
            IF (INFLD.GT.NUMFLD.OR.INFLD.EQ.FLDNUM) THEN
               CALL WRTMSG(1,131,12,1,0,' ',0)
               GO TO 60
            ELSE
               CALL DITTOFLD(FLDNUM,INFLD,IROW,ICOL,ENDCOL,RTNCODE)
               IF (RTNCODE.EQ.'0') THEN
                  MODIFY = .FALSE.
                  WRITE(MESSAGE,'(A15,I2)') FLDTEXT(1),FLDNUM
                  GO TO 40
               ELSE
                  GO TO 500
               END IF
            END IF
C
C     *** OTHERWISE - GET THE DEFINITION FOR THIS FIELD TYPE
C
         ELSE IF (INCHAR.NE.'RE') THEN
            IF (INCHAR(2:2).EQ.' ') THEN
               FLDTYPE(FLDNUM) = INCHAR(1:1)
            ELSE
               CALL BEEP
               GO TO 50
            END IF
         END IF
      END IF   
      IF (FLDTYPE(FLDNUM).EQ.FLDCHR(2)) THEN
         LNGTH = LNG(FLDTEXT(5))
         CALL WRTSTR(FLDTEXT(5),LNGTH,15,1)
      ELSE IF (FLDTYPE(FLDNUM).EQ.FLDCHR(3)) THEN
         LNGTH = LNG(FLDTEXT(6))
         CALL WRTSTR(FLDTEXT(6),LNGTH,15,1)
      ELSE IF (FLDTYPE(FLDNUM).EQ.FLDCHR(4)) THEN
         LNGTH = LNG(FLDTEXT(7))
         CALL WRTSTR(FLDTEXT(7),LNGTH,15,1)
      ELSE IF (FLDTYPE(FLDNUM).EQ.FLDCHR(5)) THEN
         LNGTH = LNG(FLDTEXT(8))
         CALL WRTSTR(FLDTEXT(8),LNGTH,15,1)
      ELSE
         CALL BEEP
         GO TO 50
      END IF 
C
C     *** GET AND CHECK THE FIELD LENGTH
C
      CALL LOCATE(4,1,IERR)
      LNGTH = LNG(FLDTEXT(9))
      CALL WRTSTR(FLDTEXT(9),LNGTH+1,14,0)
      IF (FLENGTH(FLDNUM).EQ.0) THEN
          INCHAR = '  '
      ELSE IF (FLENGTH(FLDNUM).LT.10) THEN
          WRITE(INCHAR,'(I1)') FLENGTH(FLDNUM)
      ELSE 
         WRITE(INCHAR,'(I2)') FLENGTH(FLDNUM)
      END IF
      CALL WRTSTR(INCHAR,2,15,1)
   70 CONTINUE
      CALL LOCATE(4,16,IERR)
      IF (MODIFY) THEN
         CALL GETSTR(0,INCHAR,2,15,1,RTNFLAG)
         IF (RTNFLAG.EQ.'4F') THEN
            GO TO 500
         END IF
      END IF
      IF (INCHAR.NE.'RE') THEN
         READ(INCHAR,'(BN,I2)',ERR=75) ILEN
      ELSE
         ILEN = FLENGTH(FLDNUM)
      END IF
      IF (ILEN.GT.0) THEN
         IF (ILEN+ICOL-1.GT.ENDCOL) THEN
            CALL WRTMSG(1,132,12,1,0,' ',0)
            GO TO 70
         ELSE
            GO TO 90
         END IF
      END IF
   75 CONTINUE
      CALL BEEP
      GO TO 70
   90 CONTINUE
      IF ((FLDTYPE(FLDNUM).EQ.TXTCHR(3).OR.FLDTYPE(FLDNUM).EQ.
      +     TXTCHR(4)).AND.ILEN.GT.10) THEN
         CALL WRTMSG(1,133,12,1,0,' ',0) 
         GO TO 70
      END IF 
      FLENGTH(FLDNUM) = ILEN
      CALL WRTFNC(4)
C
C     *** ASK IF LOWERCASE LETTERS SHOULD BE ALLOWED
C
      IROW2 = 4
      IF (FLDTYPE(FLDNUM).EQ.TXTCHR(5)) THEN 
         IROW2 = IROW2 + 1     
         CALL LOCATE(IROW2,1,IERR)
         LNGTH = LNG(FLDTEXT(10))
         CALL WRTSTR(FLDTEXT(10),LNGTH,14,0)
         CALL CHKYN(IROW2,42,MODIFY,LOWCASE(FLDNUM),INCHAR,FLDCHR,YNCHR))
         IF (INCHAR.EQ.'4F') THEN
            GO TO 500
         ELSE IF (INCHAR.EQ.'2F') THEN
            GO TO 480
         ELSE IF (INCHAR.EQ.'8F') THEN
            GO TO 40
         END IF
      END IF
C
C     *** GET THE FIELD LIMITS
C
      IROW2 = IROW2 + 2
      CALL LOCATE(IROW2,1,IERR)
      LNGTH = LNG(FLDTEXT(11))
      CALL WRTSTR(FLDTEXT(11),LNGTH,14,0)
  100 CONTINUE
      CALL CHKYN(IROW2,33,MODIFY,RANGE(FLDNUM),INCHAR,FLDCHR,YNCHR))
      IF (INCHAR.EQ.'4F') THEN
         GO TO 500
      ELSE IF (INCHAR.EQ.'2F') THEN
         GO TO 480
      ELSE IF (INCHAR.EQ.'8F') THEN
         GO TO 40
      END IF
      IF (RANGE(FLDNUM)) THEN  
         IROW2 = IROW2 + 1
         CALL LOCATE(IROW2,1,IERR)  
         LNGTH = LNG(FLDTEXT(12))
         CALL WRTSTR(FLDTEXT(12),LNGTH+2,14,0)
         CALL WRTSTR(LOWLIM(FLDNUM),66,15,1)
         CALL LOCATE(IROW2,13,IERR)
         IF (MODIFY) THEN
            CALL GETSTR(0,LOWLIM(FLDNUM),66,15,1,RTNFLAG)
         END IF
         IF (LOWLIM(FLDNUM)(1:5).EQ.YNCHR(5)) THEN
             READ(LOWLIM(FLDNUM),'(BN,6X,I2)',ERR=105) IFLD
             IF (IFLD.NE.FLDNUM.AND.IFLD.LT.NUMFLD) THEN
                IF (FLDTYPE(FLDNUM).EQ.FLDTYPE(IFLD)) THEN
                   GO TO 107
                ELSE
                   IROW2 = IROW2 - 1
                   CALL WRTMSG(1,134,12,1,0,' ',0)
                   MODIFY = .TRUE.
                   GO TO 100
                END IF
             END IF
  105        CONTINUE
             CALL WRTMSG(1,135,12,1,0,' ',0)
             IROW2 = IROW2 - 1
             GO TO 100
  107        CONTINUE
         END IF    
         IROW2 = IROW2 + 1
         CALL LOCATE(IROW2,1,IERR)  
         LNGTH = LNG(FLDTEXT(13))
         CALL WRTSTR(FLDTEXT(13),LNGTH+1,14,0)
         CALL WRTSTR(HIGHLIM(FLDNUM),66,15,1)
         CALL LOCATE(IROW2,13,IERR)
         IF (MODIFY) THEN
            CALL GETSTR(0,HIGHLIM(FLDNUM),66,15,1,RTNFLAG)
         END IF
         IF (HIGHLIM(FLDNUM)(1:5).EQ.YNCHR(5)) THEN
             READ(HIGHLIM(FLDNUM),'(BN,6X,I2)',ERR=115) IFLD
             IF (IFLD.NE.FLDNUM.AND.IFLD.LT.NUMFLD) THEN
                IF (FLDTYPE(FLDNUM).EQ.FLDTYPE(IFLD)) THEN
                   GO TO 117
                ELSE
                   CALL WRTMSG(1,134,12,1,0,' ',0)
                   IROW2 = IROW2 - 2
                   MODIFY = .TRUE.
                   GO TO 100
                END IF
             END IF
  115        CONTINUE
             CALL WRTMSG(1,135,12,1,0,' ',0)
             IROW2 = IROW2 - 2
             GO TO 100
  117        CONTINUE
         END IF    
      END IF
C
C     *** GET THE DEFAULT FIELD VALUE
C
      IROW2 = IROW2 + 2
      CALL LOCATE(IROW2,1,IERR)
      LNGTH = LNG(FLDTEXT(14))
      CALL WRTSTR(FLDTEXT(14),LNGTH,14,0)
      IF (DEFAULT(FLDNUM).EQ.'            ') THEN
         DEFLT = .FALSE.
      ELSE 
         DEFLT = .TRUE.
      END IF
      CALL CHKYN(IROW2,33,MODIFY,DEFLT,INCHAR,FLDCHR,YNCHR)
      IF (INCHAR.EQ.'4F') THEN
         GO TO 500
      ELSE IF (INCHAR.EQ.'2F') THEN
         GO TO 480
      ELSE IF (INCHAR.EQ.'8F') THEN
         GO TO 40
      END IF
      IF (DEFLT) THEN
         IROW2 = IROW2 + 1
         CALL LOCATE(IROW2,1,IERR)  
         LNGTH = LNG(FLDTEXT(15))
         CALL WRTSTR(FLDTEXT(15),LNGTH+1,14,0)
         CALL WRTSTR(DEFAULT(FLDNUM),66,15,1)
         CALL LOCATE(IROW2,10,IERR)
         IF (MODIFY) THEN
            CALL GETSTR(0,DEFAULT(FLDNUM),66,15,1,RTNFLAG)
         END IF
      ELSE
         DEFAULT(FLDNUM) = '           '
      END IF
C
C     *** GET LOOKUP-FILE INFORMATION
C
      IF (NUMFLD.LT.2) THEN
         GO TO 300
      END IF
      IROW2 = IROW2 + 2
      CALL LOCATE(IROW2,1,IERR)
      LNGTH = LNG(FLDTEXT(16))
      CALL WRTSTR(FLDTEXT(16),LNGTH,14,0)
      CALL CHKYN(IROW2,39,MODIFY,LOOKUP(FLDNUM),INCHAR,FLDCHR,YNCHR)
      IF (INCHAR.EQ.'4F') THEN
         GO TO 500
      ELSE IF (INCHAR.EQ.'2F') THEN
         GO TO 480
      ELSE IF (INCHAR.EQ.'8F') THEN
         GO TO 40
      END IF
      IF (LOOKUP(FLDNUM)) THEN
C
C     *** GET LOOKUP FILE NAME
C
         IROW2 = IROW2 + 1
         CALL LOCATE(IROW2,1,IERR)  
         LNGTH = LNG(FLDTEXT(17))
         CALL WRTSTR(FLDTEXT(17),LNGTH+1,14,0)
         CALL WRTSTR(LKFILE(FLDNUM),22,15,1)
         CALL LOCATE(IROW2,39,IERR)
         IF (MODIFY) THEN
            CALL GETSTR(0,LKFILE(FLDNUM),22,15,1,RTNFLAG)
         END IF
         IROW2 = IROW2 + 1
C
C     *** GET LOOKUP FILE RECORD LENGTH
C
         CALL LOCATE(IROW2,1,IERR)  
         LNGTH = LNG(FLDTEXT(18))
         CALL WRTSTR(FLDTEXT(18),LNGTH+1,14,0)
         IF (LKFLEN(FLDNUM).EQ.0) THEN
            HLDCHR = '  '
         ELSE
            WRITE(HLDCHR,'(I3)') LKFLEN(FLDNUM)
         END IF
         CALL WRTSTR(HLDCHR,3,15,1)
  165    CONTINUE
         CALL LOCATE(IROW2,21,IERR)
         IF (MODIFY) THEN
            CALL GETSTR(0,HLDCHR,3,15,1,RTNFLAG)
            IF (RTNFLAG.EQ.'4F') THEN
               GO TO 500
            ELSE IF (RTNFLAG.EQ.'8F') THEN
               GO TO 40
            END IF
         END IF
         READ(HLDCHR,'(BN,I3)',ERR=170) LKFLEN(FLDNUM)
         GO TO 175
  170    CONTINUE
         CALL WRTMSG(1,69,12,1,0,' ',0)
         GO TO 165
  175    CONTINUE
         IROW2 = IROW2 + 1
C
C     *** GET LOOKUP FIELD NUMBER
C
         CALL LOCATE(IROW2,1,0)
         LNGTH = LNG(FLDTEXT(19))
         CALL WRTSTR(FLDTEXT(19),LNGTH+1,14,0)
         IF (LKFRECFLD(FLDNUM).EQ.0) THEN
            HLDCHR = '  '
         ELSE
            WRITE(HLDCHR,'(I2)') LKFRECFLD(FLDNUM)
         END IF
         CALL WRTSTR(HLDCHR,2,15,1)
  185    CONTINUE
         CALL LOCATE(IROW2,22,IERR)
         IF (MODIFY) THEN
            CALL GETSTR(0,HLDCHR,2,15,1,RTNFLAG)
            IF (RTNFLAG.EQ.'4F') THEN
               GO TO 500
            ELSE IF (RTNFLAG.EQ.'8F') THEN
               GO TO 40
            END IF
         END IF
         READ(HLDCHR,'(BN,I2)',ERR=190) LKFRECFLD(FLDNUM)
         IFLD = LKFRECFLD(FLDNUM)
         IF (IFLD.NE.FLDNUM.AND.IFLD.LE.NUMFLD.AND.
     +        FLDTYPE(IFLD).EQ.TXTCHR(3).AND.FLENGTH(IFLD).GT.0) THEN
            GO TO 195
         END IF
  190    CONTINUE
         CALL WRTMSG(1,69,12,1,0,' ',0)
         MODIFY = .TRUE.
         GO TO 185
  195    CONTINUE
         IROW2 = IROW2 + 1
C
C     *** GET LOOKUP FILE RECORD POSITION TO BE USED
C
         CALL LOCATE(IROW2,1,IERR)  
         LNGTH = LNG(FLDTEXT(20))
         CALL WRTSTR(FLDTEXT(20),LNGTH+1,14,0)
         IF (LKFPOS(FLDNUM).EQ.0) THEN
            HLDCHR = '  '
         ELSE
            WRITE(HLDCHR,'(I3)') LKFPOS(FLDNUM)
         END IF
         CALL WRTSTR(HLDCHR,3,15,1)
  200    CONTINUE
         CALL LOCATE(IROW2,27,IERR)
         IF (MODIFY) THEN
            CALL GETSTR(0,HLDCHR,3,15,1,RTNFLAG)
            IF (RTNFLAG.EQ.'4F') THEN
               GO TO 500
            ELSE IF (RTNFLAG.EQ.'8F') THEN
               GO TO 40
            END IF
         END IF
         READ(HLDCHR,'(BN,I3)',ERR=210) LKFPOS(FLDNUM)
         GO TO 220
  210    CONTINUE
         CALL WRTMSG(1,69,12,1,0,' ',0)
         GO TO 200
  220    CONTINUE
      END IF
C
C     *** FIND OUT IF PREVENT DATA ENTRY IN THIS FIELD
C
  300 CONTINUE
      IROW2 = IROW2 + 2
      CALL LOCATE(IROW2,1,IERR)
      LNGTH = LNG(FLDTEXT(21))
      CALL WRTSTR(FLDTEXT(21),LNGTH,14,0)
      CALL CHKYN(IROW2,29,MODIFY,NOENTRY(FLDNUM),INCHAR,FLDCHR,YNCHR)
      IF (INCHAR.EQ.'4F') THEN
         GO TO 500
      ELSE IF (INCHAR.EQ.'2F') THEN
         GO TO 480
      ELSE IF (INCHAR.EQ.'8F') THEN
         GO TO 40
      END IF
C
C     *** VERIFY THE INFORMATION ENTERED
C
  380 CONTINUE
      CALL CLRMSG(1)
      CALL LOCATE(22,10,IERR)
      LNGTH = LNG(FLDTEXT(22))
      CALL WRTSTR(FLDTEXT(22),LNGTH+1,15,3)
  400 CONTINUE
      CALL GETCHAR(0,INCHAR)
      IF (INCHAR.EQ.'2F') THEN
         GO TO 480
      ELSE IF (INCHAR.EQ.'4F') THEN
         GO TO 500
      ELSE IF (INCHAR.EQ.'7F') THEN
         CALL ACTPAG(0,IERR)
         CALL LOCATE(IROW,ICOL,IERR)
         CALL WRTSTR(BLANK,FLENGTH(FLDNUM),14,0)
         FLENGTH(FLDNUM) = 0
         RETURN
      ELSE IF (INCHAR.EQ.'8F') THEN
         MODIFY = .TRUE.
         GO TO 40
      ELSE
         CALL BEEP
         GO TO 400
      END IF
C
C     *** WRITE THE FIELD TO THE FORM
C
  480 CONTINUE
      CALL ACTPAG(0,IERR)
      CALL LOCATE(IROW,ICOL,IERR)
      CALL WRTSTR(BLANK,FLENGTH(FLDNUM),FLDFGC,FLDBGC)
      RETURN
C
C     *** ABORT THE CURRENT FIELD
C
  500 CONTINUE
      IF (NEWFLD) THEN
         NUMFLD = NUMFLD - 1
      ELSE IF (FLDNUM.EQ.DELFLD) THEN
         FLENGTH(FLDNUM) = 0
      END IF
      CALL ACTPAG(0,IERR)
      CALL LOCATE(IROW,ICOL,IERR)
      RETURN
C
C     *** ERROR READING FILE ***
C  
  800 CONTINUE
      CALL CLS
      CALL WRTMSG(4,191,12,1,0,PRMFILE,22)
      CALL LOCATE(24,0,IERR)
      STOP 2            
      END

*******************************************************************************
$PAGE
      SUBROUTINE SAVFLD
C
C   ROUTINE TO WRITE THE FIELD DEFINITIONS TO DISK
C
$INCLUDE: 'FRMFLD.INC'
C
      INTEGER*2    IOLD,INEW,OLDFLD(MAXFLD),NEWFLD(MAXFLD),
     +             TROW(MAXFLD),TCOL(MAXFLD)
      CHARACTER*2  HLDCHR
      CHARACTER*1  REPLY,RTNCODE,SORTFLDS,YESUP,NOUP,CDUM
      CHARACTER*64 MESSAG(2)
      CHARACTER*78 MSGTXT
C
      CALL GETYN(1,1,YESUP,CDUM)
      CALL GETYN(2,1,NOUP,CDUM)
C
C   ASK THE USER IF HE WANTS THE FIELDS SORTED ON OUTPUT
C
      CALL LOCATE(23,0,IERR)
      CALL GETMSG(615,MSGTXT)
      CALL GETMSG(999,MSGTXT)
      LENTXT = LNG(MSGTXT)
      LENMAX = LEN(MESSAG(1))
      CALL PARSE1(MSGTXT,LENTXT,2,LENMAX,MESSAG,RTNCODE)
      LENTXT = LNG(MESSAG(1))
      CALL WRTSTR(MESSAG(1),LENTXT,12,0)
      CALL BEEP
      CALL LOCATE(23,40,IERR)
      CALL OKREPLY(REPLY,RTNCODE)
      IF (REPLY.EQ.'Y'.AND.RTNCODE.EQ.'0') THEN
         SORTFLDS = YESUP
      ELSE
         SORTFLDS = NOUP
      END IF
C
C     *** REMOVE DELETED FIELDS AND SORT BY ROW AND COLUMN IF REQUESTED
C
      IOLD = 0
      INEW = 0
   50 CONTINUE
      IOLD = IOLD + 1
      IF (FLENGTH(IOLD).GT.0) THEN
         INEW = INEW + 1
         IF (INEW.EQ.1) THEN
            OLDFLD(INEW) = IOLD
            NEWFLD(IOLD) = INEW
            TROW(INEW) = FLDROW(IOLD)
            TCOL(INEW) = FLDCOL(IOLD)
         ELSE
            DO 100 I = INEW-1,1,-1
               IF (FLDROW(IOLD).GT.TROW(I).OR.(FLDROW(IOLD).EQ.
     +               TROW(I).AND.FLDCOL(IOLD).GT.TCOL(I)).OR.
     +               SORTFLDS.EQ.NOUP) THEN
                  DO 80 I2 = INEW, I+2, -1
                     OLDFLD(I2) = OLDFLD(I2-1)
                     NEWFLD(OLDFLD(I2)) = I2
                     TROW(I2) = TROW(I2-1)
                     TCOL(I2) = TCOL(I2-1)
   80             CONTINUE
                  OLDFLD(I+1) = IOLD
                  NEWFLD(IOLD) = I+1
                  TROW(I+1) = FLDROW(IOLD)
                  TCOL(I+1) = FLDCOL(IOLD)
                  GO TO 120
               END IF
  100       CONTINUE
            DO 110 I2 = INEW, 2, -1
               OLDFLD(I2) = OLDFLD(I2-1)
               NEWFLD(OLDFLD(I2)) = I2
               TROW(I2) = TROW(I2-1)
               TCOL(I2) = TCOL(I2-1)
  110       CONTINUE
            OLDFLD(1) = IOLD
            NEWFLD(IOLD) = 1
            TROW(1) = FLDROW(IOLD)
            TCOL(1) = FLDCOL(IOLD)
         END IF
      END IF
  120 CONTINUE
C
      IF (IOLD.LT.NUMFLD) THEN
         GO TO 50
      END IF
C
C     *** REPLACE ANY INTERNAL FIELD NUMBERS WITH THE NEW VALUES
C
      DO 200 I = 1,INEW
         IFLD = OLDFLD(I)
         IF (RANGE(IFLD)) THEN
            IF (LOWLIM(IFLD)(1:5).EQ.MESSAG(2)) THEN
               READ(LOWLIM(IFLD),'(BN,6X,I2)') IFLD2
               WRITE(HLDCHR,'(I2)') NEWFLD(IFLD2)
               LOWLIM(IFLD)(7:8) = HLDCHR
               IF (NEWFLD(IFLD2).GT.INEW.OR.FLDTYPE(NEWFLD(IFLD2)).NE.
     +               FLDTYPE(IFLD)) THEN
                  RANGE(IFLD) = .FALSE.
               END IF
            END IF
            IF (HIGHLIM(IFLD)(1:5).EQ.MESSAG(2)) THEN
               READ(HIGHLIM(IFLD),'(BN,6X,I2)') IFLD2
               WRITE(HLDCHR,'(I2)') NEWFLD(IFLD2)
               HIGHLIM(IFLD)(7:8) = HLDCHR
               IF (NEWFLD(IFLD2).GT.INEW.OR.FLDTYPE(NEWFLD(IFLD2)).NE.
     +               FLDTYPE(IFLD)) THEN
                  RANGE(IFLD) = .FALSE.
               END IF
            END IF
         END IF
         IF (LOOKUP(IFLD)) THEN
            LKFRECFLD(IFLD) = NEWFLD(LKFRECFLD(IFLD))
         END IF
  200 CONTINUE
C
C     *** WRITE THE FIELDS IN THE NEW ORDER
C 
      WRITE (15) INEW,(FLDTYPE(OLDFLD(I)),FLDROW(OLDFLD(I))
     +                ,FLDCOL(OLDFLD(I)),FLENGTH(OLDFLD(I))
     +                ,LOWCASE(OLDFLD(I))
     +                ,RANGE(OLDFLD(I)),LOWLIM(OLDFLD(I))
     +                ,HIGHLIM(OLDFLD(I)),DEFAULT(OLDFLD(I))
     +                ,LOOKUP(OLDFLD(I)),LKFILE(OLDFLD(I))
     +                ,LKFLEN(OLDFLD(I)),LKFRECFLD(OLDFLD(I))
     +                ,LKFPOS(OLDFLD(I)),NOENTRY(OLDFLD(I)),I=1,INEW) 
      RETURN
      END

*******************************************************************************
$PAGE
      SUBROUTINE CHKYN(IROW,ICOL,MODIFY,OUTPUT,INCHAR,YNCHR,YESNO)
C
C     ROUTINE TO CHECK FOR A Y/N RESPONSE AND SET THE OUTPUT VARIABLE
C     TO TRUE IF YES AND FALSE IF NO
C
C     IF FUNCTION KEYS F2, F4, OR F8 ARE ENTERED IT RETURNS THEM
C
      LOGICAL OUTPUT,MODIFY
      CHARACTER*2 INCHAR,YNCHR(7)
      CHARACTER*5 YESNO(5)
C
  100 CONTINUE
      CALL LOCATE(IROW,ICOL,IERR)
      IF (OUTPUT) THEN   
         CALL WRTSTR(YESNO(2),5,14,0)
         INCHAR = YNCHR(6) 
      ELSE
         CALL WRTSTR(YESNO(4),5,14,0)
         INCHAR = YNCHR(7)
      END IF
      CALL LOCATE(IROW,ICOL,IERR)
      IF (MODIFY) THEN 
         CALL GETCHAR(0,INCHAR)
         IF (INCHAR.EQ.'4F'.OR.INCHAR.EQ.'2F'.OR.INCHAR.EQ.'8F') THEN
            RETURN
         ELSE IF (INCHAR.EQ.YNCHR(7)) THEN
            OUTPUT = .FALSE.
         ELSE IF (INCHAR.EQ.YNCHR(6)) THEN
            OUTPUT = .TRUE.
         ELSE IF (INCHAR.NE.'RE') THEN
            CALL BEEP
            GO TO 100
         END IF
      END IF
      IF (OUTPUT) THEN
         CALL WRTSTR(YESNO(1),5,15,1)
      ELSE
         CALL WRTSTR(YESNO(3),5,15,1)
      END IF
C
      RETURN
      END

*******************************************************************************
$PAGE
      SUBROUTINE DITTOFLD(FLDNUM,INFLD,IROW,ICOL,ENDCOL,RTNCODE)
C
C     ROUTINE TO COPY THE FIELD DEFINITION OF FIELD INFLD TO FIELD
C     NUMFLD
C
      CHARACTER*1 RTNCODE
      CHARACTER*2 INCHAR
      INTEGER*2   INFLD,ENDCOL,FLDNUM
C
$INCLUDE: 'FRMFLD.INC'
C
      RTNCODE = '0'
C
C     CHECK IF THERE IS ROOM FOR THE SPECIFIED FIELD AT THE CURRENT
C     CURSOR POSITION
C
      IF (FLENGTH(INFLD)+ICOL-1.GT.ENDCOL) THEN
         CALL WRTMSG(1,132,12,1,0,' ',0)
         RTNCODE = '1'
         CALL WRTMSG(20,202,14,0,0,' ',0)
         CALL GETCHAR(0,INCHAR)
         RETURN
      END IF
C 
C     COPY THE FIELD DEFINTIION FOR THE FIELD SPECIFIED
C
      FLDROW(FLDNUM) = IROW
      FLDCOL(FLDNUM) = ICOL
      FLDTYPE(FLDNUM) = FLDTYPE(INFLD)
      LOWCASE(FLDNUM) = LOWCASE(INFLD)
      RANGE(FLDNUM) = RANGE(INFLD)
      FLENGTH(FLDNUM) = FLENGTH(INFLD) 
      HIGHLIM(FLDNUM) = HIGHLIM(INFLD) 
      LOWLIM(FLDNUM) = LOWLIM(INFLD) 
      DEFAULT(FLDNUM) = DEFAULT(INFLD) 
      LOOKUP(FLDNUM) = LOOKUP(INFLD) 
      LKFILE(FLDNUM) = LKFILE(INFLD) 
      LKFLEN(FLDNUM) = LKFLEN(INFLD) 
      LKFRECFLD(FLDNUM) = LKFRECFLD(INFLD) 
      LKFPOS(FLDNUM) = LKFPOS(INFLD) 
      NOENTRY(FLDNUM) = NOENTRY(INFLD)
      RETURN
      END