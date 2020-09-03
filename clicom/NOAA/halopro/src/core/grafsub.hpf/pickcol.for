$STORAGE:2
      SUBROUTINE PICKCOL(INDEX,XNPOS,YNPOS,ICNTRL,NUMCOLOR
     +                  ,PALETTE,PALDEF,IPICK)
C------------------------------------------------------------------------------
C     PICK THE DESIRED COLOR FROM A DISPLAY OF THE COLORS AVAILABLE IN THIS
C     PALETTE. 
C
C     INPUT ARGUMENTS:
C
C     XNPOS,YNPOS  REAL       LOWER LEFT CORNER (NORMALIZED DEVICE COORDS) OF 
C                             COLOR BAR MENU 
C     ICNTRL       INT2       WINDOW CONTROL
C                             0 = NORMAL OPERATION.  WINDOW IS OPENED AT 
C                                 BEGINNING AND CLOSED AT END OF ROUTINE.
C                             1 = WINDOW IS OPENED BUT IS NOT CLOSED
C                             2 = CLOSE WINDOW LEFT OPEN FROM PREVIOUS CALL 
C                                 WITH ICNTRL = 1
C     NUMCOLOR     INT2       NUMBER OF COLORS USER IS ALLOWED TO SELECT 
C     PALETTE      INT2       CURRENT PALETTE NUMBER
C     PALDEF       INT2 ARRAY CURRENT DEFINITION OF ALL 12 POSSIBLE PALETTES
C     IPICK        INT2       PALETTE AND COLOR SELECTION CONTROL
C                             1 = PALETTE SELECTION ONLY 
C                             2 = COLOR SELECTION IN CURRENT PALETTE ONLY 
C                             3 = SAME AS 2, BUT LIMITED TO CHANGEABLE COLORS 
C
C     OUTPUT ARGUMENTS:
C
C     INDEX        INT2       COLOR INDEX VALUE SELECTED. 0 THRU NUMCOLOR - 1,
C                             OR -1 IF NONE SELECTED
C------------------------------------------------------------------------------
      REAL HEIGHT,WIDTH,FACTOR,CURSSTEP,MOUSSTEP
      INTEGER*2 PREVINDEX,PALDEF(16,12),PALETTE
      CHARACTER*6 PALTXT
      CHARACTER*2 INCHAR
      CHARACTER*1 RTNCODE
C
C   SET UP WINDOW FOR DISPLAY OF COLOR BOXES.  POP IT UP AT THE 
C   NORMALIZED DEVICE COORDS PASSED AND HAVE IT TAKE AN AREA OF
C   10% OF X AND 25% OF Y FOR EACH COLOR CHOICE (40% FOR 16 COLORS). 
C
      RTNCODE = '0'
      IPAL = PALETTE
      IF (ICNTRL.EQ.2) THEN
         GO TO 150
      ENDIF
      CALL INQHCU(XOLD,YOLD,IDUMMY)
      XWIN2 = XNPOS + .1
      YWIN1 = YNPOS - ((NUMCOLOR+1)*.025)
      CALL GRAFWIN(1,XNPOS,YWIN1,XWIN2,YNPOS)
C
C   FIND CURRENT WORLD COORDS.  SET VERTICAL SENSITIVITY VALUES FOR THE MOUSE
C   AND CURSOR.  A MOVEMENT BY THE MOUSE OR CURSOR GREATER THAN THESE VALUES
C   TRIGGERS A USER CHANGE THAT HAS TO BE PROCESSED. NOTE: CURSOR MOVEMENT IS 
C   ALWAYS 1/200TH OF THE WORLD WHILE MOUSE MOVEMENT IS VARIABLE.
C
      CALL INQWOR(XLOW,YLOW,XHIGH,YHIGH)
      CURSSTEP = (YHIGH - YLOW) / 1000.
      MOUSSTEP = (YHIGH - YLOW) / 50.
      YCENTER = (YHIGH - YLOW) / 2.0
C
      YPREV = YCENTER
      XPREV = XHIGH / 2.
      PREVINDEX = INDEX
      IPAL = PALETTE
C
C   DISPLAY COLOR BOXES
C
      WIDTH = XHIGH - XLOW
      HEIGHT = YHIGH - YLOW
      BWIDTH = (WIDTH / 3.) * .95
      BHEIGHT = (HEIGHT / FLOAT(NUMCOLOR+1)) * .95
      LOWCOL = 17 - (NUMCOLOR + 1) + 1
      DO 100 I = LOWCOL,16
         CALL SETCOL(I-1)
         YPOS = YNPOS+(HEIGHT*.96) - (I-LOWCOL+2)*BHEIGHT
         CALL BAR(XNPOS+BWIDTH,YPOS,XNPOS+2.5*BWIDTH,YPOS+BHEIGHT)
100   CONTINUE
C
C   DETERMINE OLD DOT TEXT SIZE AND COLORS, SET NEW SIZE, COLOR AND INITIALIZE
C   POINTER. SET LOWER LIMIT OF POINTER SO IT DOES NOT CHANGE 1ST 4 COLORS
C
      IF (IPICK .EQ. 3) THEN
         LOWCOL = 5
      ENDIF
      IF (INDEX.LT.LOWCOL-1) THEN
         INDEX = LOWCOL-1
         PREVINDEX = INDEX
      ELSE IF (INDEX.GT.15) THEN
         INDEX = 15
         PREVINDEX = INDEX
      ENDIF
C       .. HEIGHT AND WIDTH ARE GIVEN IN DEVICE COORDINATES        
      CALL INQTEX(IHEIGHT,IWIDTH,IFG,IBG,IPATH,IMODE)
      CALL INQXOR(IXOR)
      CALL SETXOR(1)
      CALL SETTEX(1,1,0,0)
      CALL SETTCL(3,0)
      YPOS = YNPOS+(HEIGHT*.97) - (LOWCOL-1)*BHEIGHT
      YPOS = YPOS - (INDEX-LOWCOL+3)*BHEIGHT
      XPOS = XNPOS+(0.1*WIDTH)
      CALL MOVTCA(XPOS,YPOS)
      CALL DELTCU
      CALL BTEXT('&&')
C-----------
      WRITE(UNIT=PALTXT,FMT='(2H^#,I2,1H^)') IPAL
      YPOS = YNPOS+(HEIGHT*.97) - BHEIGHT
      CALL MOVTCA(XPOS,YPOS)
      CALL DELTCU
      CALL BTEXT(PALTXT)
C
C   SET LOCATOR POSITION AND READ IT BACK TO ACCOUNT FOR ROUND OFF 
C
110   CONTINUE
         YPOS = YNPOS+(HEIGHT*.97) - BHEIGHT
         XPOS = XNPOS+(0.1*WIDTH)
         CALL MOVTCA(XPOS,YPOS)
         CALL DELTCU
         CALL BTEXT(PALTXT)
         WRITE(UNIT=PALTXT,FMT='(2H^#,I2,1H^)') IPAL
         CALL MOVTCA(XPOS,YPOS)
         CALL DELTCU
         CALL BTEXT(PALTXT)
         CALL ORGLOC(XPREV,YPREV)
C         CALL RDLOC(XPREV,YPREV,INCHAR,RTNCODE)
         XPOSP = XPREV
         YPOSP = YPREV
         XPOS1 = XPREV
C
C   READ MOUSE/CURSOR POSITION AND TAKE ACTION REQUIRED
C
120   CONTINUE
         CALL RDLOC(XPOSP,YPOSP,INCHAR,RTNCODE)
         CALL DELHCU( )
         IF (INCHAR.EQ.'RE') THEN
            RTNCODE = '0'
            GO TO 140
         ELSE IF(INCHAR.EQ.'4F'.OR.INCHAR.EQ.'ES') THEN
            RTNCODE = '1'
            GO TO 140
         ENDIF         
         IF (RTNCODE.EQ.'1') THEN
            IF (IPICK .EQ. 1) THEN
               FACTOR = MOUSSTEP * 5.
            ELSE
               FACTOR = MOUSSTEP
            ENDIF               
         ELSE
            IF (INCHAR.EQ.'YY') THEN
               XPOSP = XPREV 
               YPOSP = YPREV 
               CALL ORGLOC(XPREV,YPREV)
               GO TO 120
            ENDIF
            FACTOR = CURSSTEP
         ENDIF
C
C     CHANGE PALETTE IF THAT IS REQUESTED 
C
         IF (IPICK.EQ.1) THEN
            IF (XPOSP.GT.XPOS1+FACTOR) THEN
               IPAL = IPAL + 1
               CALL SETGPAL(IPAL,PALDEF)
               GO TO 110
            ELSE IF (XPOSP.LT.XPOS1-FACTOR) THEN
               IPAL = IPAL - 1
               CALL SETGPAL(IPAL,PALDEF)
               GO TO 110
            ENDIF
         ENDIF
C
C     DETERMINE COLOR SELECTION 
C
         IF (IPICK .NE. 1) THEN
            IF (YPOSP.NE.YPREV) THEN
               IF (YPOSP.GT.YPREV+FACTOR) THEN
                  INDEX = INDEX - 1
                  YPOSP = YPREV 
                  CALL ORGLOC(XPREV,YPREV)
               ELSE IF (YPOSP.LT.YPREV-FACTOR) THEN
                  INDEX = INDEX + 1
                  YPOSP = YPREV 
                  CALL ORGLOC(XPREV,YPREV)
               ENDIF
               IF (INDEX.GT.15) THEN
                  INDEX = 15
               ELSE IF (INDEX.LT.LOWCOL-1) THEN
                  INDEX = LOWCOL - 1
               ENDIF
            ENDIF
C
C      MOVE POINTER IF COLOR HAS CHANGED
C         
            IF (INDEX.NE.PREVINDEX) THEN
               XPOS = XNPOS+(0.1*WIDTH)
               YPOS = YNPOS+(HEIGHT*.97) - (LOWCOL-1)*BHEIGHT
               YPOS = YPOS - (PREVINDEX-LOWCOL+3)*BHEIGHT
               CALL MOVTCA(XPOS,YPOS)
               CALL DELTCU
               CALL BTEXT('&&')
               YPOS = YNPOS+(HEIGHT*.97) - (LOWCOL-1)*BHEIGHT
               YPOS = YPOS - (INDEX-LOWCOL+3)*BHEIGHT
               CALL MOVTCA(XPOS,YPOS)
               CALL DELTCU
               CALL BTEXT('&&')
               PREVINDEX = INDEX
            ENDIF
         ENDIF
         GO TO 120
C
C   SET COLOR TO SELECTION (-1 IF NONE) AND PALETTE NUMBER TO ONE WANTED
C   COLOR INDEX VALUES BEGIN AT 0 SO VALUES RANGE FROM 0 TO 15 FOR 16 COLORS,
C   ETC. PALETTE NUMBER (VARIABLE IPAL) IS NOT CHANGE WHEN IPICK=2 OR 3
C
140   CONTINUE
      IF (RTNCODE.EQ.'1') THEN
         INDEX = -1
         CALL SETGPAL(PALETTE,PALDEF)
      ELSE
         IF (IPICK .EQ. 1) THEN
            INDEX = -1
         ENDIF
         PALETTE = IPAL
      ENDIF
C
C   RESTORE THE WINDOW, SET THE COLOR TO THE ONE WANTED AND EXIT.
C
150   CONTINUE
      CALL SETXOR(0)
      IF (ICNTRL.NE.1) THEN
         CALL GRAFWIN(0,XNPOS,YWIN1,XWIN2,YNPOS)
         CALL ORGLOC(XOLD,YOLD)
      ENDIF
      CALL SETXOR(IXOR)
C       .. CONVERT HEIGHT AHD WIDTH FROM DEVICE COORDINATES TO MULTIPLES
C          OF THE SIZE OF THE DOT TEXT CELL
      IHEIGHT = IHEIGHT/8
      IWIDTH  = IHEIGHT/8  
      CALL SETTEX(IHEIGHT,IWIDTH,IPATH,IMODE)
      CALL SETTCL(IFG,IBG)
      RETURN
      END
