$STORAGE:2

      SUBROUTINE DATATYPE (STRTCOL,ICNTRL,RECTYPE,NUMVAL,RTNCODE)
C
C   SUBROUTINE SOLICITS THE TYPE OF DATA TO BE PROCESSED.
C       THE ROUTINE ASKS THE USER FOR THE INFORMATION AND READS IT FROM
C       THE TERMINAL. 
C
C     PASSED VARIABLES
C         INPUT:
C            STRTCOL....STARTING COLUMN FOR THE MENU
C            ICNTRL.....CONTROL VARIABLES DETERMINES CHOICES AVAILABLE
C                        1 = MLY THRU U-A
C                        2 = DLY THRU U-A
C                        3 = DLY THRU 15M
C                        4 = MLY THRU 15M
C         OUTPUT:
C            RECTYPE...CODED DATA TYPE (MLY,DLY,ETC.)
C            NUMVAL....NUMBER OF DATA VALUES FOR SELECTED DATA TYPE
C            RTNCODE...STATUS CODE (0 = OK, 1 = EXIT SELECTED)
C
      PARAMETER (MAXCHOICE = 7)
C
      INTEGER*2 STRTCOL
      CHARACTER*3 RECTYPE,TYPEDEF(MAXCHOICE)                 
      INTEGER*2 NUMVAL, VALNUM(MAXCHOICE)                      
      CHARACTER*1 RTNCODE
      DATA TYPEDEF/'MLY','10D','DLY','SYN','HLY','15M','U-A'/
     +    ,VALNUM/12,36,31,8,24,96,1/
C
      CALL POSLIN(IROW,ICOL)
      CALL LOCATE(IROW,STRTCOL,IERR)
      IF (ICNTRL.EQ.1) THEN
         CALL GETMNU('DR-DATATYPES','  ',ICHOICE)
         ITYPE = ICHOICE
      ELSE IF (ICNTRL.EQ.2) THEN
         CALL GETMNU('DATATYPES2  ','  ',ICHOICE)
         ITYPE = ICHOICE + 2
      ELSE IF (ICNTRL.EQ.3) THEN
         CALL GETMNU('DATATYPES3  ','  ',ICHOICE)
         ITYPE = ICHOICE + 2
      ELSE IF (ICNTRL.EQ.4) THEN
         CALL GETMNU('DATATYPES4  ','  ',ICHOICE)
         ITYPE = ICHOICE 
      END IF
         IF (ICHOICE.EQ.0)  THEN
            RTNCODE = '1'
         ELSE
            RECTYPE = TYPEDEF(ITYPE)
            NUMVAL = VALNUM(ITYPE)
            RTNCODE = '0'
      END IF
C
      RETURN
      END
