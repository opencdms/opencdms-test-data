$STORAGE:2

      SUBROUTINE INSSWTCH(INSERT)
C
C   ROUTINE TO TOGGLE INSERT MODE ON AND OFF AND WRITE A MESSAGE TO
C       INDICATE THE CURRENT STATUS
C
      LOGICAL INSERT
      CHARACTER*10 TEXT
C
      CALL POSLIN(IROW,ICOL)
      CALL CLTEXT(0,0,IERR)
      CALL LOCATE(23,48,IERR)
      IF (INSERT) THEN
         INSERT = .FALSE.
         TEXT = ' '
         TEXT(10:10) = CHAR(0)
         CALL CWRITE(TEXT,11,IERR)
      ELSE
         INSERT = .TRUE.
         TEXT(1:9) = '(Insert) '
         CALL CWRITE(TEXT,11,IERR)
      END IF
      CALL LOCATE(IROW,ICALL,IERR)
      RETURN
      END
