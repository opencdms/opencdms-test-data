$STORAGE:2
      SUBROUTINE BGNHALO(IDEF,PALETTE,PALDEF)
C
C       **INPUT:
C            IDEF......FLAG TO INDICATE MODE AND PALETTE SETTINGS
C                       0=DEVMODE, DEFAULT PALETTE
C                       1=DEVMODE, USER DEFINED PALETTES
C                      10=AQCMODE, DEFAULT PALETTE
C                      11=AQCMODE, USER DEFINED PALETTES
C            PALETTE...
C            PALDEF....      
C
      INTEGER*2 IDEF,PALETTE,PALDEF(16,*)      
$INCLUDE:'HALOENV.INC'
      INTEGER*2    FUNC,ERR
      CHARACTER*1  RTNCODE
C
C       ** iNITIALIZE THE GRAPHICS DEVICE
C
      RTNCODE = '0'
      CALL HALOINIT(RTNCODE)
      IF (RTNCODE.NE.'0') GO TO 900
      CALL SETDEV(DEVICE)
      IF (IDEF.GE.10) THEN
         CALL INITGR(AQCMODE)
      ELSE
         CALL INITGR(DEVMODE)
      ENDIF
      CALL INQERR(FUNC,ERR)
      CALL SETIEE(1)
C
C       ** INITIAL PALETTE DEFINITIONS AND CURRENT PALETTE
C
      IF (IDEF.EQ.1 .OR. IDEF.EQ.11) THEN
         CALL SETGPAL(PALETTE,PALDEF)
      ENDIF         
C      
c       ** If you are not using a IBM EGA card the mode number may have
C          to be MODIFIED.  For example: CGA 320x200 4 colors mode would
C          equal 0 
C
      CALL SETCOLOR(0)
      CALL CLR
C      
C       .. IN ORDER TO OPEN THE VIEWPORT TO THE ENTIRE SCREEN, A MAX VALUE
C          EQUAL TO .999 MUST BE USED.  A VALUE OF 1.0 IS A SPECIAL SIGNAL FOR
C          HALO TO 'TURN OFF' THE VIEWPORT WHICH DOES NOT RESET ASPECT RATIOS
      CALL SETVIE(0.,0.,0.999,0.999,-1,-1)
      CALL SETWOR(0.,0.,1.,1.)
      RETURN
C
C       ** ERROR:  UNABLE TO FIND HALO ENVIRONMENT FILE -- HALOGRF?.ENV --
C                  CANNOT INITIALIZE HALO GRAPHICS
C
  900 CONTINUE
      CALL WRTMSG(3,601,12,1,1,' ',0)
      STOP 1       
      END
      SUBROUTINE FINHALO
      CALL SETLOC(0,0)
      CALL CLOSEG
      RETURN
      END
