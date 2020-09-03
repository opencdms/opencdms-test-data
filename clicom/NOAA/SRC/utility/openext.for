$STORAGE:2

      SUBROUTINE OPENEXT(ITYPE,NUMEXT,MEANEXTR)
C
C   ROUTINE TO OPEN THE LONG TERM MEANS/EXTREMES FILE
C   THAT CORRESPONDS TO THE ITYPE GIVEN.  THE FILE IS OPENED AS
C   UNIT 31, A DIRECT FILE WITH READ-ACCESS.  FILES OPENED BY 
C   THIS ROUTINE CAN BE READ WITH THE RDEXTR SUBROUTINE.
C
C     INPUT:
C       ITYPE.....1 = MONTHLY - FORTRAN FILE ELEM.LIM
C                 2 = 10 DAY  - DATAEASE FORM  10DAY Means/Extremes
C                 3 = DAILY   - DATAEASE FORM  Daily Means/Extremes
C     OUTPUT:
C       NUMEXT....THE NUMBER OF RECORDS IN THE EXTREMES FILE THAT HAS BEEN
C                 OPENED.
C       MEANEXTR..LOGICAL, TRUE IF FILE OPENED OK, ELSE FALSE.
C
      INTEGER*2 ITYPE
      INTEGER*4 NUMEXT
      LOGICAL MEANEXTR
      CHARACTER*24 FRMNAM,EXTFILE
C            
      IF (ITYPE.EQ.1) THEN
180      CONTINUE
         OPEN(31,FILE='P:\DATA\ELEM.LIM',STATUS='OLD',ACCESS='DIRECT'
     +       ,RECL=62,MODE='READ',IOSTAT=IOCHK)
         IF(IOCHK.NE.0) THEN
            CALL OPENMSG('P:\DATA\ELEM.LIM      ','OPENEXT     '
     +            ,IOCHK)
            GO TO 180
         END IF
      ELSE 
         IF (ITYPE.EQ.2) THEN
            FRMNAM = 'Means/Extremes (10D)'
         ELSE IF (ITYPE.EQ.3) THEN
            FRMNAM = 'Daily Means/Extremes'
         END IF
         CALL FNDFIL(FRMNAM,EXTFILE,NUMEXT)
         IF (EXTFILE.EQ.'       ') THEN
            MEANEXTR = .FALSE.
            RETURN
         END IF
190      CONTINUE
         OPEN (31,FILE=EXTFILE,STATUS='OLD',FORM='BINARY'
     +       ,RECL=51,ACCESS='DIRECT',SHARE='DENYWR',MODE='READ'
     +       ,IOSTAT=IOCHK)
         IF (IOCHK.NE.0) THEN
            CALL OPENMSG(EXTFILE,'OPENEXT     ',IOCHK)
            GO TO 190
         END IF
      END IF
      RETURN
      END
      