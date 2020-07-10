$STORAGE:2
      SUBROUTINE HALOINIT(RTNCODE)
C------------------------------------------------------------------------------
C     INITIALIZE THE HALO GRAPHICS ENVIRONMENT VARIABLES IN COMMON BLOCK
C     HALOENV WITH THE VALUES FROM A USER'S HALO ENVIRONMENT FILE.
C
C     OUTPUT ARGUMENT:
C
C     RTNCODE  CHAR  STATUS OF ATTEMPT TO INITIATE GRAPHICS. 0=OK, 1=ERROR
C------------------------------------------------------------------------------
$INCLUDE:'HALOENV.INC'
C
      CHARACTER*1  HALOID, RTNCODE
      HALOID = ' '
      CALL GETHAL (HALOID)
      IF (HALOID .EQ. ' ') THEN
         RTNCODE = '1'
      ELSE
         ENVFILE = 'P:\HALO\HALOGRF .ENV'
         ENVFILE(16:16) = HALOID
         OPEN (UNIT=44,FILE=ENVFILE,FORM='FORMATTED')
         READ(44,*) DEVICE,DEVMODE,AQCMODE,NETWORK,PRINTR,PTRVAL,
     +              PTRASP,PRNTR2,PRVAL2,PRASP2,PLOTER
         CLOSE (44)
         VRI = '^P:\HALO\HALOVDIN.DEV^'
         ACTVPTR = 0
         RTNCODE = '0'
      ENDIF
      RETURN
      END
