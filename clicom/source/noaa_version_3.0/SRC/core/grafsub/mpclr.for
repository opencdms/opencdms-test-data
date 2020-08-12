$STORAGE:2
      SUBROUTINE MPCLR(XWIN,YWIN,PALETTE,PALDEF,MPCODE)
C      
      REAL *4   XWIN(*),YWIN(*)
      INTEGER*2 PALETTE,PALDEF(16,*),MPCODE(5)
C      
      INTEGER*2 WINSTAT,HELPLEVEL
      CHARACTER*2 INCHAR
C
      DATA XFRAC/.8/, YFRAC/.8/
      DATA KLRBOX/0/
C
C       ** INITIAL MENU NUMBER AND HELP FILE VARIABLES
C 
      MENUNUM = 38
      HELPLEVEL=38
C
C       ** DRAW MENU FOR MAP DETAIL CATEGORIES
C          AND GET CHOICE; SCREEN IS NOT SAVED
C
      WINSTAT = 2
      CALL GRAFMNU(WINSTAT,MENUNUM,XWIN(1),YWIN(1),HELPLEVEL,INCHAR)
C
C       ** GET COORDINATES OF MENU WINDOW; CALCULATE COORDINATES OF BOX
C          COLUMN THAT IS DRAWN TO RIGHT OF MENU.  OPEN WINDOW FOR BOX.
      CALL XYWNDO(XWINLF,YWINTP,XWINRT,YWINBT)
      XBXLF = XWINRT + .01
      YBXTP = YWINTP
      XBXRT = XBXLF + .05
      YBXBT = YWINBT
      ICNTRL = 1
      CALL WNDOBOX(ICNTRL,XBXLF,YBXTP,XBXRT,YBXBT)      
C
C       .. SET DOT TEXT SIZE 
      CALL INQDRA(MAXX,MAXY)
      IF (MAXY.GT.350) THEN
         CALL SETTEX(2,1,0,0)
      ELSE
         CALL SETTEX(1,1,0,0)
      END IF
C
C
C       ** DRAW A COLORED BOX NEXT TO EACH SELECTED MAP DETAIL CATEGORY
C          BOXES ARE DRAWN INSIDE BOX COLUMN.
C      
      CALL INQTSI('^X^',HEIGHT,CWIDTH)
      CALL INQWOR(XLOW,YLOW,XHIGH,YHIGH)
      DXWIN = XHIGH-XLOW
      XBAR1 = XLOW + .5*(1-XFRAC)*DXWIN
      XBAR2 = XBAR1 + XFRAC*DXWIN
      DO 10 I=1,5
         IF (MPCODE(I).EQ.-1) GO TO 10
            YBAR1 = YHIGH - (I+1)*HEIGHT
            YBAR2 = YBAR1 + YFRAC*HEIGHT
            CALL SETCOLOR(MPCODE(I))
            CALL BAR(XBAR1,YBAR1,XBAR2,YBAR2)
            CALL SETCOLOR(KLRBOX)
            CALL BOX(XBAR1,YBAR1,XBAR2,YBAR2)
   10 CONTINUE
C
C       ** CLOSE WINDOW VIEWPORT FOR BOX COLUMN DRAWN NEXT TO MENU      
C          SET MENU STATUS TO GET A CHOICE ONLY 
      ICNTRL = -1
      CALL WNDOBOX(ICNTRL,XBXLF,YBXTP,XBXRT,YBXBT)      
      WINSTAT=3
C      
      IPASS=1
   20 CONTINUE
      IF (INCHAR.EQ.'ES') GO TO 100
         IF (IPASS.EQ.1) THEN
            IPASS=2
            GO TO 50
         ENDIF 
         READ(INCHAR,'(I1)') NMPC
         IF (MPCODE(NMPC).GT.-1) THEN
C
C             ** DISPLAY PALETTE COLORS AND GET COLOR CHOICE FOR
C                SLEECTED MAP DETAIL CATEGORY         
            ICNTRL=0
            NBRPICK=16
            IPAL=PALETTE
            IPICK=2
            ICLR=MPCODE(NMPC)
            CALL PICKCOL(ICLR,XWIN(2),YWIN(2),ICNTRL,NBRPICK,IPAL,
     +                   PALDEF,IPICK)
            IF (ICLR.NE.-1) MPCODE(NMPC)=MAX0(ICLR,0)
C
C             ** OPEN WINDOW VIEWPORT FOR BOX COLUMN DRAWN NEXT TO MENU      
            ICNTRL = 2
            CALL WNDOBOX(ICNTRL,XBXLF,YBXTP,XBXRT,YBXBT)      
C        
C             ** REDRAW COLOR BOX TO DISPLAY MODIFIED COLOR
C    
            YBAR1 = YHIGH - (NMPC+1)*HEIGHT
            YBAR2 = YBAR1 + YFRAC*HEIGHT
            CALL SETCOLOR(MPCODE(NMPC))
            CALL BAR(XBAR1,YBAR1,XBAR2,YBAR2)
            CALL SETCOLOR(KLRBOX)
            CALL BOX(XBAR1,YBAR1,XBAR2,YBAR2)
C
C       ** CLOSE WINDOW VIEWPORT FOR BOX COLUMN DRAWN NEXT TO MENU      
C            
            ICNTRL = -1
            CALL WNDOBOX(ICNTRL,XBXLF,YBXTP,XBXRT,YBXBT)      
         ENDIF
   50    CONTINUE         
C 
C          .. GET NEXT MENU CHOICE         
         CALL GRAFMNU(WINSTAT,MENUNUM,XWIN(1),YWIN(1),HELPLEVEL,INCHAR)
      GO TO 20
C      
  100 CONTINUE
      ICNTRL = -2
      CALL WNDOBOX(ICNTRL,XBXLF,YBXTP,XBXRT,YBXBT)      
      WINSTAT=0
      CALL GRAFMNU(WINSTAT,MENUNUM,XWIN(1),YWIN(1),HELPLEVEL,INCHAR)
C
      RETURN
      END      
      