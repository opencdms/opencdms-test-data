$STORAGE:2
      SUBROUTINE SETZOOM(MOVFLG,ZOOMED,REPLTSKT)
C------------------------------------------------------------------------------
C     ROUTINE TO DISPLAY THE ZOOM FUNCTION KEY ON THE SKEW-T PLOT AND PROCESS
C     THE USER'S RESPONSE.
C
C     INPUT ARGUMENTS:
C     
C     MOVFLG    LOGICAL  FLAG THAT DETERMINES WHETHER THE SCREEN BEHIND F8
C                        KEY WILL BE SAVED.  USED TO SAVE SPACE WHEN ROUTINE
C                        IS CALLED FROM DATAQC   
C
C     INPUT AND OUTPUT ARGUMENTS:
C
C     ZOOMED    LOGICAL  VARIABLE THAT ENABLES THE SKEWT ROUTINE TO DETERMINE
C                        WHETHER OR NOT TO USE ZOOMED VERSION OF SKEW-T PLOT
C     REPLTSKT  LOGICAL  VARIABLE THAT ENABLES GRAPHICS MANAGER PGM TO DETER-
C                        MINE WHETHER THE SKEW-T PLOT MUST BE REDRAWN BECAUSE
C                        THE ZOOM FUNCTION KEY WAS PRESSED
C------------------------------------------------------------------------------
$INCLUDE: 'SAVBUF.INC'
      CHARACTER*1  RTFG
      CHARACTER*2  INCHAR
      CHARACTER*8  ZOOMSG
      CHARACTER*78 MSG
      LOGICAL MOVFLG,ZOOMED,REPLTSKT
C
C ---  GET CURRENT BACKGROUND COLOR.  SET WORLD COORDS AND DOT TEXT ATTRIBUTES
C
      CALL INQBKN(KLRBKGN)      
      CALL GETMSG(486,MSG)
      CALL GETMSG(999,MSG)
      CALL DELIMSTR(MSG,ZOOMSG)
      CALL INQVIE(XN3,YN3,XN4,YN4)
C       .. IN ORDER TO OPEN THE VIEWPORT TO THE ENTIRE SCREEN, A MAX VALUE
C          EQUAL TO .999 MUST BE USED.  A VALUE OF 1.0 IS A SPECIAL SIGNAL FOR
C          HALO TO 'TURN OFF' THE VIEWPORT WHICH DOES NOT RESET ASPECT RATIOS
      CALL SETVIE(0.0,0.0,0.999,0.999,-1,-1)
      CALL SETWOR(0.,0.,24.,80.)
C
C       ** SET DOT TEXT SIZE 
C
      CALL INQDRA(MAXX,MAXY)
      IF (MAXY.GT.350) THEN
         CALL SETTEX(2,1,0,1)
      ELSE
         CALL SETTEX(1,1,0,1)
      END IF
      CALL MOVTCA(0.,0.)
      CALL SETTCL(3,0)
C
C ---  SAVE THE PLOT BEHIND THE F8 ZOOM MESSAGE FIRST
C
      MSG = '^F8' // ZOOMSG(2:)
      CALL INQTSI(MSG,HG,WD)
      HG = HG + 0.2
      WD = WD + 0.2
      IF (MOVFLG) CALL MOVEFR(0.0,HG,WD,0.0,BUFFER)
C
C ---  DRAW AN F8 ZOOM KEY AND CHECK TO SEE IF IT IS PRESSED
C
      CALL BTEXT('^F8^')
      CALL SETTCL(1,2)
      CALL BTEXT(ZOOMSG)
      RTFG = '1'
   50 CALL RDLOC(XP,YP,INCHAR,RTFG)
      IF (RTFG.EQ.'1'.AND.(INCHAR.NE.'RE'.AND.INCHAR.NE.'4F')) THEN
         GO TO 50
      ENDIF 
      IF (MOVFLG) CALL MOVETO(0.0,HG,BUFFER,1)
      CALL SETVIE(XN3,YN3,XN4,YN4,-1,-1)
C
      IF (INCHAR.EQ.'8F') THEN
         IF (ZOOMED) THEN
            ZOOMED = .FALSE.
         ELSE
            ZOOMED = .TRUE.
         ENDIF
         REPLTSKT = .TRUE.
      ELSE
         REPLTSKT = .FALSE.
      END IF
C
      RETURN
      END      
