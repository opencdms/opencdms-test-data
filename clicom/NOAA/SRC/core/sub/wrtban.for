$STORAGE:2
C
      SUBROUTINE WRTBAN(IDKEY,RECTYPE,RTNCODE)
C
C  THIS ROUTINE REWRITES THE CURRENT BANNER ON LINE ONE OF THE
C  SCREEN.
C
      CHARACTER*1 RTNCODE
      CHARACTER*2 RTNFLAG
      CHARACTER*3 RECTYPE
      CHARACTER*8 FIELD(6)
      CHARACTER*21 IDKEY
C
      RTNCODE = '0'
C
      READ (IDKEY,'(A8,A3,A4,3A2)')(FIELD(I),I=1,6)
C
      CALL LOCATE(0,0,IERR)
      RTNFLAG = 'BN'
      IF (RECTYPE.EQ.'U-A')THEN
         CALL GETFRM('WRTBAN6F','  ',FIELD,8,RTNFLAG) 
      ELSE IF (RECTYPE.EQ.'HLY'.OR.RECTYPE.EQ.'SYN'
     +       .OR.RECTYPE.EQ.'15M') THEN
         CALL GETFRM('WRTBAN5F','  ',FIELD,8,RTNFLAG) 
      ELSE IF (RECTYPE.EQ.'DLY') THEN
         CALL GETFRM('WRTBAN4F','  ',FIELD,8,RTNFLAG) 
      ELSE 
         CALL GETFRM('WRTBAN3F','  ',FIELD,8,RTNFLAG) 
      END IF
C
      IF (RTNFLAG.NE.' ') THEN
         RTNCODE = '1'
      END IF
      RETURN
      END
C