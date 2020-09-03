$STORAGE:2

      SUBROUTINE SORT (SRCNAM,SRCLN,DESTNAM,DESTLN,RECLEN,SRTCTL)
C
C   ROUTINE TO DO A SORT OF A FILE BY CALLING THE COSORT PROGRAM
C
C     INPUT PARAMETERS:
C
C        SRCNAM....THE FULL NAME OF THE INPUT FILE
C        SRCLN.....THE NUMBER OF CHARACTERS IN SRCNAM
C        DESTNAM...THE FULL NAME OF THE OUTPUT FILE
C        DESTLN....THE NUMBER OF CHARACTERS IN DESTNAM
C        RECLEN....THE RECORD LENGTH OF THE FILE TO BE SORTED
C        SRTCTL....CHARACTER STRING CONTAINING THE FOLLOWING
C                POSITION 1 - 1 NUMBER OF KEYS (MAX 10)
C                POSITION 3 - ? THE DESCRIPTION OF EACH KEY IN THE 
C                               FOLLOWING FORMAT       
C
C                      A,START,LENGTH,
C
C                          WHERE A = A OR D FOR ASCENDING OR DESCENDING 
C                                START = STARTING POSITION OF THIS KEY
C                                LENGTH = LENGTH OF THIS KEY 
C
C         NOTE: BEFORE THIS ROUTINE IS CALLED FOR THE FIRST TIME WITHIN
C               ANY PROGRAM, THE PROGRAM MUST CALL COLOAD.
C 
      CHARACTER*80 CHRFIL
      CHARACTER*40 FILNAM
      CHARACTER*2 MSGTXT
      CHARACTER*1 SRCNAM,DESTNAM,SRTCTL,HLDCHR
      INTEGER*2   SRCLN,DESTLN,RECLEN,ISRCNAM
C
      INTEGER*2 INFILE(20),OUTFIL(20),KEYDEF(50)
      EQUIVALENCE (CHRFIL,OUTFIL),(ISRCNAM,FILNAM)
C
      DO 30 I = 1,50
         KEYDEF(I) = 0
   30 CONTINUE
C
C   VERIFY THAT INPUT FILE TO BE SORTED EXISTS
C
   40 CONTINUE
   
      FILNAM = ' '
      FILNAM = SRCNAM(1:SRCLN)
      OPEN (62,FILE=FILNAM,STATUS='OLD',IOSTAT=IOCHK)
      IF (IOCHK.NE.0) THEN
         CALL OPENMSG(FILNAM,'SORT        ',IOCHK)
         GO TO 40
      END IF
      CLOSE(62)
C
C   DETERMINE THE NUMBER OF KEYS AND DECODE EACH
C
      IPOS = 1
      CALL RDCTRL(IKEY,SRTCTL,IPOS)
      DO 60 I = 1,IKEY
         K = (I-1)*5 + 1
         IF (SRTCTL(IPOS:IPOS).EQ.'D') THEN
            CALL MOVBYT(1,1,1,KEYDEF(K),1)
         END IF
         IPOS = IPOS + 2 
         CALL RDCTRL(ISTRT,SRTCTL,IPOS)
         KEYDEF(K+1) = ISTRT 
         CALL RDCTRL(ILEN,SRTCTL,IPOS)
         KEYDEF(K+2) = ILEN
   60 CONTINUE
C
C   CALL COSORT - 1 TO SET ENVIRONMENT (DEFAULT SCRATCH DRIVE SET = 
C                   TO INPUT DATA DRIVE)
C
      IDRV = 0
      IF (SRCNAM(2:2).EQ.':') THEN
         HLDCHR = SRCNAM(1:1)
         JCHAR = ICHAR(HLDCHR)
         IF (JCHAR.GT.90) THEN
            IDRV = JCHAR - 96
         ELSE 
            IDRV = JCHAR - 64
         END IF   
      END IF
      IDUM=0
      MESS=0
      ISW=0
      CALL COSORT(ISW,MESS,IDRV,IDUM)
C
C   CALL COSORT - 2 TO DEFINE INPUT FILE
C
      ISW=1
      MESS=1
      CALL MOVBYT(2,SRCLN,1,INFILE,1)
      CALL MOVBYT(SRCLN,ISRCNAM,1,INFILE,3)
C                       ISRCNAM == FILNAM WHICH = SRCNAM
      CALL COSORT(ISW,MESS,INFILE,RECLEN)
C
C   CALL COSORT - 3 TO DEFINE KEYS
C
      ISW=2
      CALL COSORT(ISW,IKEY,KEYDEF,IDUM)
C
C   CALL COSORT - 4 TO DEFINE OUTPUT FILE 
C
C          COSORT VERSION 4.2 DOES NOT WORK IF  OUTPUT FILE
C          NAME INCLUDES BOTH DISK AND DIRECTORY.  THUS, IF
C          BOTH ARE USED SET DEFAULT DRIVE TO OUTPUT DISK
C          LETTER AND REMOVE THE DRIVE FROM THE FILE NAME
C
      ISW=3
      MESS=1
      CALL GETDSK(IDISK)
      IF (DESTNAM(2:3).EQ.':\') THEN
         HLDCHR = DESTNAM(1:1)
         JCHAR = ICHAR(HLDCHR)
         IF (JCHAR.GT.90) THEN
            JDISK = JCHAR - 97
         ELSE 
            JDISK = JCHAR - 65
         END IF   
         DESTLN = DESTLN - 2
         CALL MOVBYT(2,DESTLN,1,OUTFIL,1)
         CHRFIL(3:3+DESTLN-1) = DESTNAM(3:3+DESTLN-1) 
         CALL SDISK(JDISK,NDRIVE)
      ELSE
         CALL MOVBYT(2,DESTLN,1,OUTFIL,1)
         CHRFIL(3:3+DESTLN-1) = DESTNAM(1:DESTLN)
      END IF
      CALL COSORT(ISW,MESS,OUTFIL,IDUM)
C
C   CALL COSORT - 5 ... DO THE SORT
C
      WRITE(*,*) 'Sorting...'
      CALL COSORT(ISW,MESS,IDUM,IDUM)
80    IF (ISW.EQ.4) THEN
         CALL SDISK(IDISK,NDRIVE)
         WRITE(MSGTXT,'(I2)') MESS
         CALL WRTMSG(3,160,12,0,0,MSGTXT,2)
         CALL WRTMSG(2,161,12,1,1,' ',0)
         STOP 2
      ELSE IF (ISW.NE.5) THEN
         GO TO 80
      END IF
      CALL SDISK(IDISK,NDRIVE)
      RETURN
      END

     
      SUBROUTINE RDCTRL(IVALUE,SRTCTL,IPOS)
C
C   ROUTINE TO READ SRTCTL UNTIL A ',' OR SPACE IS REACHED,
C      STORE THE INTEGER RESULT INTO IVALUE, AND SET IPOS TO THE
C      NEXT CHARACTER TO BE READ
C
      CHARACTER*1 SRTCTL
      CHARACTER*6 CVALUE
C
      ICHR = 0
      CVALUE = '     '
      DO 50 I = IPOS, IPOS+5
         IF (SRTCTL(I:I).EQ.','.OR.SRTCTL(I:I).EQ.' ') THEN
            GO TO 60
         ELSE
            ICHR = ICHR + 1
            CVALUE(ICHR:ICHR) = SRTCTL(I:I)
         END IF
   50 CONTINUE
      CALL WRTMSG(4,55,12,1,1,' ',0)
      STOP 2
   60 CONTINUE
      IPOS = I + 1
      READ(CVALUE,'(BN,I4)') IVALUE
      RETURN
      END
