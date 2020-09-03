$STORAGE:2
      SUBROUTINE OPENPOS(RECTYPE,DATASOURCE,SRCHSTN,SRCHDATE)
C
C   ROUTINE TO OPEN A CLIMATE DATA FILE AS FILE 25 AND DO A BINARY 
C      SEARCH OF THE FILE TO POSITION TO THE FIRST RECORD THAT MEETS
C      OR IS AFTER THE SEARCH STN AND DATE SPECIFIED.  TO ENSURE THAT
C      NO ELEMENT RECORDS ARE SKIPPED, ELEMENT CODE 000 IS INCLUDED
C      AS PART OF THE SEARCH ID. (FOR UPPER AIR RECORDS THE LEVEL NUMBER
C      IS USED IN PLACE OF THE ELEMENT CODE).  THIS ROUTINE HAS BEEN MODIFIED
C      TO WORK WITH EITHER DATAEASE VERSION 2.5 OR DATAEASE VERSION 4.0.
C
C   THIS ROUTINE IS USED IN PLACE OF OPENINPUT WHEN USED.
C
      CHARACTER*1 DATASOURCE
      CHARACTER*3 RECTYPE,TYPDEF(7) 
      CHARACTER*8 SRCHSTN,SRCHDATE
      CHARACTER*16 SRCHI2,INID2
      CHARACTER*19 SRCHID,INID
      CHARACTER*22 FILNAME
      CHARACTER*24 FRMNAM(14)
      CHARACTER*52 INREC
      INTEGER*2 RECLEN(7),LOCSTN(7),LOCDAT(7),LENDAT(7)
     +         ,LOCELM(7)
      INTEGER*4 RECNUM,ITOP,IBOT,K,NUM4,NUMREC
C
C
      DATA TYPDEF /'MLY','10D','DLY','SYN','HLY','15M','U-A'/
      DATA FRMNAM /'MONTHLY DATA','TEN DAY DATA','DAILY DATA'
     +   ,'SYNOPTIC DATA','HOURLY DATA','FIFTEEN MINUTE DATA'
     +   ,'UPPER-AIR DATA','H MLY DATA','H 10D DATA','H DLY DATA'
     +   ,'H SYN DATA','H HLY DATA','H 15M DATA','H U-A DATA'/
C
C  THE FOLLOWING VARIABLES HOLD THE FILE RECORD LENGTH, THE POSITION
C  IN THE RECORD OF THE STATION-ID, DATE, AND ELEMENT CODE, AND THE 
C  LENGTH OF THE DATE FIELD
C
      DATA RECLEN /84,210,186,67,151,529,62/
      DATA LOCSTN /10,16,15,9,13,31,9/ ,LOCDAT /21,27,26,20,24,42,17/
     +    ,LENDAT /4,4,6,8,8,8,8/, LOCELM /18,24,23,17,21,39,30/
C
C   FIND THE RELATIVE NUMBER OF THE DATATYPE WANTED TO INDEX INTO THE
C   FRMNAM ARRAY
C
      DO 20 I = 1,7
         IF (RECTYPE.EQ.TYPDEF(I)) THEN
            ITYPE = I
            GO TO 30
         END IF
20    CONTINUE
      CALL WRTMSG(3,81,12,1,1,RECTYPE,3)
      STOP 2
30    CONTINUE
      JTYPE = ITYPE
      IF (DATASOURCE.NE.'M'.AND.DATASOURCE.NE.'m'.AND.DATASOURCE.NE.
     +     'S'.AND.DATASOURCE.NE.'s') THEN
         CALL WRTMSG(3,83,12,1,1,DATASOURCE,1)
         DATASOURCE = 'S'
      END IF
      IF (DATASOURCE.EQ.'S'.OR.DATASOURCE.EQ.'s') THEN
         ITYPE = ITYPE + 7
      END IF
C  
C   FIND THE FILE NAME AND NUMBER OF RECORDS OF THE DATAEASE FORM WANTED
C
      CALL FNDFIL(FRMNAM(ITYPE),FILNAME,NUMREC)
      IF (FILNAME.EQ.'       ') THEN
         STOP 2
      END IF
C   
C   OPEN THE DATA FILE WANTED
C
200   CONTINUE
      OPEN (25,FILE=FILNAME,STATUS='OLD',FORM='BINARY',ACCESS='DIRECT'
     +   ,RECL=RECLEN(JTYPE),SHARE='DENYNONE',MODE='READ',IOSTAT=IOCHK)
      IF (IOCHK.NE.0) THEN
         CALL OPENMSG(FILNAME,'FNDREC      ',IOCHK)
         GO TO 200
      END IF
C
      NUM4 = NUMREC
C
C   INITIALIZE BINARY SEARCH CONTROL VARIABLES
C
      ITOP = NUM4 + INT4(1)
      IBOT = 0
      JSTN = LOCSTN(JTYPE)
      JDATE = LOCDAT(JTYPE)
      LNDATE = LENDAT(JTYPE)
      LDATE = JDATE + LNDATE - 1
      JELEM = LOCELM(JTYPE)
      SRCHID  = SRCHSTN(1:8)
      SRCHID(9:8+LNDATE) = SRCHDATE(1:LNDATE)
      SRCHID(17:19) = '000'
C
C   READ THE FIRST RECORD TO SEE IF A BINARY SEARCH IS NECESSARY
C
      IF (NUM4.EQ.0) THEN
         RETURN
      END IF
      READ(25,REC=1) INREC
      INID = INREC(JSTN:JSTN+7)
      INID(9:8+LNDATE) = INREC(JDATE:LDATE)
      INID(17:19) = INREC(JELEM:JELEM+2)
      IF (SRCHID.LT.INID) THEN
         REWIND (25)
         RETURN
      END IF 
C
C   BEGIN THE BINARY SEARCH LOOP
C 
  100 CONTINUE
C
C   CHECK IF THE STATION HAS BEEN FOUND. IF NOT, INCREMENT THE RECORD
C   NUMBER UP OR DOWN AS NEEDED
C
      IF (ITOP-IBOT.GT.1) THEN
         K = (ITOP+IBOT)
         K = K / INT4(2)
         READ(25,REC=K) INREC
         INID = INREC(JSTN:JSTN+7)
         INID(9:8+LNDATE) = INREC(JDATE:LDATE)
         INID(17:19) = INREC(JELEM:JELEM+2)
         IF (SRCHID.LT.INID) THEN
            ITOP = K
            GO TO 100
         ELSE IF (SRCHID.GT.INID) THEN
            IBOT = K
            GO TO 100
         END IF
      ELSE
         SRCHI2 = SRCHID(1:16)
         INID2 = INID(1:16)
         IF (SRCHI2.NE.INID2) THEN
            GO TO 300
         END IF
      END IF
C
C   PROPER STATION AND DATE HAS BEEN FOUND - FINISHED
C
      RECNUM = K - INT4(1)
      GO TO 400
C
C   GET HERE IF STATION AND DATE NOT FOUND
C
  300 CONTINUE
      IF (SRCHID.LT.INID) THEN
         RECNUM = K - INT4(1) 
      ELSE 
         RECNUM = K 
      END IF
C
C   READ THE RECORD PRIOR TO THE RECORD WANTED.  THAT WAY THE FILE
C   POINTER WILL BE SET SO THE NEXT SEQUENTIAL READ WILL READ THE 
C   RECORD WANTED.
C
400   CONTINUE
      IF (K.GT.0) THEN
         READ(25,REC=RECNUM) INREC
      ELSE
         REWIND 25
      END IF
      RETURN
      END
