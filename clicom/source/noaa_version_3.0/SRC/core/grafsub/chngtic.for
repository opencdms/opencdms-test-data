$STORAGE:2
      SUBROUTINE CHNGTIC(XWIN,YWIN,TICSZ,TICTHK,VPNDLF,VPNDRT)
C------------------------------------------------------------------------------
C     ROUTINE TO CHANGE THE LENGTH OF THE TIC MARKS ON THE TIME SERIES AXES 
C     AND MAP BORDERS.
C
C     INPUT ARGUMENTS:  
C
C     XWIN,YWIN  REAL  LOWER LEFT CORNER (NORMALIZED DEVICE COORDS) OF POP-UP
C                      MENU THAT CONTROLS THE CHANGE OF THE TIC SIZE
C     VPNDLF,    REAL  VIEWPORT HORIZONTAL MINIMUM (LEFT) AND MAXIMUM (RIGHT) 
C     VPNDRT           VALUES (NORM DEV COORDS)
C     TICSZ      REAL  LENGTH OF TIC MARKS ALONG EACH AXIS (NORM WORLD COORDS)
C     TICTHK     INT2  LINE THICKNESS OF THE TIC MARKS
C
C     OUTPUT ARGUMENTS:
C
C     TICSZ      REAL  REVISED TIC MARK LENGTH
C------------------------------------------------------------------------------
C
C       ** LOCAL COMMON TO SAVE SPACE IN D-GROUP
C
      INTEGER*2     TICTHK,MAXX,MAXY,IXOR,IDUMMY,HELPLVL
      REAL          HEIGHT,WIDTH,XOLD,YOLD,X1OLD,Y1OLD,X2OLD,Y2OLD,
     +              XPOS,YPOS,XN1,YN1,XN2,YN2,XWIN1,YWIN1,XWIN2,YWIN2,
     +              XLOW,YLOW,XHIGH,YHIGH,XWORLD,YWORLD,XNDC,XNDCLN,
     +              XLEN,YLEN,XNDCHI,XBEG,YDUM,DISTNDC,TICINCR,YY
      CHARACTER*45  TESTLINE
      CHARACTER*78  MESSAGE
      CHARACTER*12  F1LINE,ESCLINE
      CHARACTER*2   INCHAR
      CHARACTER*3   DEVERS
      LOGICAL       FIRSTCALL
      COMMON /CNGTSV/ HEIGHT,WIDTH,XOLD,YOLD,X1OLD,Y1OLD,X2OLD,Y2OLD,
     +                XPOS,YPOS,XN1,YN1,XN2,YN2,XWIN1,YWIN1,XWIN2,YWIN2,
     +                XLOW,YLOW,XHIGH,YHIGH,XWORLD,YWORLD,XNDC,XNDCLN,
     +                XLEN,YLEN,XNDCHI,XBEG,YDUM,DISTNDC,TICINCR,
     +                YY,MAXX,MAXY,IXOR,IDUMMY,HELPLVL
     +                TESTLINE,MESSAGE,F1LINE,ESCLINE,INCHAR,DEVERS
      DATA    FIRSTCALL /.TRUE./
C
C   DETERMINE AND SAVE THE CURRENT VIEWPORT, COORDINATES,CROSS-HAIR
C   CURSOR LOCATION AND XOR MODE
C
      CALL INQVIE(XN1,YN1,XN2,YN2)
      CALL INQWOR(X1OLD,Y1OLD,X2OLD,Y2OLD)
      CALL INQHCU(XOLD,YOLD,IDUMMY)
      CALL INQXOR(IXOR)
C
C   SAVE VIEWPORT, WORLD COORDINATES OF ACTUAL PLOT, NOT THE WINDOW VALUES
C
      
      TESTLINE ='^XXXXXXXXXXXXXXXXXXXXXXXX^'
      CALL SETXOR(0)
C
C     FIND THE TIC MARK LINE LENGTH IN WORLD COORD AND NORM DEV COORDS
C     ALSO DETERMINE THE MAX LINE LENGTH AND INCREMENTS FOR MODIFICATION
C
       TICINCR = .002
C
C   ON 1ST CALL TO THIS ROUTINE READ THE 2 LINES FOR F1 AND ESC KEY DEFINITIONS
C
      IF (FIRSTCALL) THEN
         FIRSTCALL = .FALSE.
         CALL GETDEASE(DEVERS)
         OPEN (13,FILE='P:\FORM\GRAFMENU.DEF',STATUS='OLD')
         READ(13,500) F1LINE
  500    FORMAT(A12)
         IF (DEVERS.EQ.'4.0') THEN
C             .. DATAEASE 4.X -- DISPLAY 'ESC'         
            READ(13,500) 
            READ(13,500) ESCLINE
         ELSE
C             .. DATAEASE 2.5 -- DISPLAY 'F4'      
            READ(13,500) ESCLINE
            READ(13,500) 
         ENDIF
         CLOSE(13)
         MESSAGE = F1LINE
         F1LINE = '^ '//MESSAGE
         F1LINE(12:12) = '^'
         MESSAGE = ESCLINE
         ESCLINE = '^ '//MESSAGE
         ESCLINE(12:12) = '^'
         HELPLVL=94
      ENDIF
C
C   SET THE HALO DOT TEXT SIZE FOR THE HELP WINDOW
C
      CALL INQDRA(MAXX,MAXY)
      IF (MAXY.GT.350) THEN
         CALL SETTEX(2,1,0,1)
      ELSE
         CALL SETTEX(1,1,0,1)
      END IF
C
C  DETERMINE HOW MUCH SPACE IS REQUIRED FOR THIS MENU IN THE CURRENT
C  WORLD COORD SYSTEM AND DEFINE WINDOW BIG ENOUGH TO HOLD IT.
C  ADD 2% OF SCREEN TO WINDOW SIZE TO ACCOUNT FOR WINDOW BORDER AND SHADOWS.
C
C       .. IN ORDER TO OPEN THE VIEWPORT TO THE ENTIRE SCREEN, A MAX VALUE
C          EQUAL TO .999 MUST BE USED.  A VALUE OF 1.0 IS A SPECIAL SIGNAL FOR
C          HALO TO 'TURN OFF' THE VIEWPORT WHICH DOES NOT RESET ASPECT RATIOS
      CALL SETVIE(0.,0.,0.999,0.999,-1,-1)
      CALL SETWOR(X1OLD,Y1OLD,X2OLD,Y2OLD)
      CALL MOVHCA(XOLD,YOLD)
      CALL INQTSI(TESTLINE,HEIGHT,WIDTH)
      XWORLD = WIDTH + X1OLD 
      YWORLD = HEIGHT*6. + Y1OLD
      CALL MAPWTN(XWORLD,YWORLD,XWIN2,YWIN1)
      XWIN2 = XWIN2 + .02
      YWIN2 = 1.03 - YWIN1 
C
C   OPEN THE TEXT WINDOW - FIND TEXT HEIGHT IN WINDOW COORDS
C
      XWIN1 = XWIN
      XWIN2 = XWIN1 + XWIN2
      YWIN1 = YWIN - YWIN2
      YWIN2 = YWIN
      CALL GRAFWIN(1,XWIN1,YWIN1,XWIN2,YWIN2)
      XWORLD = (XWIN2-XWIN1) / (VPNDRT-VPNDLF)
      CALL SETWOR(0.0,YWIN1,XWORLD,YWIN2)
C
C ----BY SETTING THE WORLD COORDS TO THE SAME AS THE NDC IN THE CALL TO 
C ----GRAFWIN, THE NORM WOR COORDS AND THE NDC ARE THE SAME IN THE X DIRECTION
C ----SIMPLIFIES THE DETERMINATION OF THE TIC LENGTH WHICH IS NWC
C
C     DISPLAY THE MENU TITLE IN THE WINDOW 
C
      CALL INQTSI(TESTLINE,HEIGHT,WIDTH)
      CALL INQWOR(XLOW,YLOW,XHIGH,YHIGH)
      CALL SETCOL(3)
      CALL CLR
      CALL SETTCL(1,3)
      MESSAGE = '   '
      CALL GETMSG(537,MESSAGE)
      CALL DELIMSTR(MESSAGE,TESTLINE)
      XPOS = XLOW
      YPOS = YHIGH - HEIGHT
      CALL MOVTCA(XPOS,YPOS)
      CALL TEXT(TESTLINE)
      CALL GETMSG(999,TESTLINE)
C
C   DISPLAY THE F1 AND ESC KEY DEFINITIONS, THEN DRAW A VERTICAL LINE 
C   PERPINDICULAR TO THE TIC MARK LINE    
C
      YPOS = YHIGH - (5*HEIGHT)
      CALL MOVTCA(XPOS,YPOS)
      CALL SETTCL(1,3)
      CALL TEXT(F1LINE)
      YPOS = YHIGH - (6*HEIGHT)
      CALL MOVTCA(XPOS,YPOS)
      CALL DELTCU
      CALL TEXT(ESCLINE)
      CALL DELTCU 
C
      TESTLINE = '^X^'   
      CALL INQTSI(TESTLINE,HEIGHT,WIDTH)
C---- MOVE BEGINING SPOT OF TIC MARK LINE TO THE RIGHT THE WIDTH OF THE LINE
      CALL MAPWTD(XLOW,YLOW,KPIX,IDUMMY)
      KPIX = KPIX + (TICTHK + 1) / 2
      CALL MAPDTW(KPIX,IDUMMY,XRDC,YDUM)
      XRDC = ABS(XRDC - XLOW)
      XPOS = XLOW + WIDTH + XRDC   ! X VALUE OF THE MIDDLE OF THE VERTICAL BAR
      CALL SETLNW(TICTHK)
      CALL SETCOL(2)
      YPOS = YHIGH - (1.5*HEIGHT)
      CALL MOVABS(XPOS,YPOS)
      YPOS = YPOS - (2*HEIGHT)
      CALL LNABS(XPOS,YPOS)
      XBEG = XPOS + XRDC   ! RGT EDGE OF BAR TO PREVENT A NOTCH IN THE BAR
      YPOS = YPOS + HEIGHT
      CALL MOVABS(XBEG,YPOS)
C
C     DRAW THE TIC MARK LINE IN THE WINDOW WITH THE SAME LENGTH AS ON THE PLOT.
C     USE NORMALIZED DEVICE COORDS AND MAP THESE VALUES INTO THE CURRENT WORLD 
C     COORDINATES FOR USE BY THE LINE DRAWING ROUTINES
C
      XHIGH = XPOS + (50.0 * TICINCR)
      XPOS = XBEG + TICSZ
      IF (TICSZ .GT. 0.0) THEN
         CALL LNABS(XPOS,YPOS)
      ENDIF
C
C     GET A KEYBOARD RESPONSE AND PROCESS IT
C
 200  CONTINUE
      CALL GETCHAR(1,INCHAR)
      IF      (INCHAR .EQ. 'LA') THEN
C ------      LEFT ARROW, DECREASE THE LENGTH OF THE TIC LINE
              IF (XPOS-TICINCR .GE. XBEG) THEN
                 CALL SETCOL(3)
                 CALL LNREL(-TICINCR,0.0)
                 CALL SETCOL(2)
                 XPOS = XPOS - TICINCR
              ELSE
                 CALL SETCOL(3)
                 CALL LNREL(-(XPOS-XBEG),0.0)
                 CALL SETCOL(2)
                 XPOS = XBEG
                 CALL BEEP
              ENDIF
      ELSE IF (INCHAR .EQ. 'RA') THEN
C ------      RIGHT ARROW, INCREASE THE LENGTH OF THE TIC LINE
              IF (XPOS+TICINCR .LT. XHIGH) THEN
                 CALL LNREL(TICINCR,0.0)
                 XPOS = XPOS + TICINCR
              ELSE
                 CALL BEEP
              ENDIF
      ELSE IF (INCHAR .EQ. 'RE' .OR. INCHAR .EQ. '2F') THEN
C ------      SAVE NEW TIC SIZE
              TICSZ = XPOS - XBEG
              GO TO 900   
      ELSE IF (INCHAR.EQ.'4F'.OR.INCHAR.EQ.'ES') THEN
              GO TO 900
      ELSE IF (INCHAR.EQ.'1F') THEN
C ------      F1 PRESSED - CALL HELP
              CALL GRAFHELP(HELPLVL,0.4,0.7)
              CALL SETCOL(2)
              CALL SETHAT(1)
              CALL MOVABS(XPOS,YPOS)
      ELSE   
           CALL BEEP
      ENDIF
      GO TO 200  
C
C   CLOSE THE WINDOW AND RESTORE THE PLOT VIEWPORT AND WORLD COORDINATES
C
  900 CONTINUE
      CALL SETLNW(1)
      CALL GRAFWIN(0,XWIN1,YWIN1,XWIN2,YWIN2)
      CALL SETVIE(XN1,YN1,XN2,YN2,-1,-1)
      CALL SETWOR(X1OLD,Y1OLD,X2OLD,Y2OLD)
      CALL MOVHCA(XOLD,YOLD)
      CALL SETXOR(IXOR)
      RETURN
      END
