$STORAGE:2
      SUBROUTINE GRDMAN(XWIN,YWIN,PALETTE,PALDEF,
     +                  GRDCLR,GRDTHK,GRDTYP)
C
      REAL*4     XWIN(*),YWIN(*)
      INTEGER *2 PALETTE,PALDEF(16,*),GRDCLR,GRDTHK,GRDTYP
C
      INTEGER*2 WINSTAT,HELPLVL        
      CHARACTER *2 INCHAR
C      
C       ** INITIAL WINDOW CONTROL VARIABLES;  WINSTAT IS SET TO DRAW MENU,
C          AND GET CHOICE; SCREEN IS NOT SAVED
C
      WINSTAT = 2
C
C       ** LOOP TO DISPLAY AND PROCESS MENU CHOICES
C      
   70 CONTINUE
      MENUNUM = 31
      HELPLVL = 31
      CALL GRAFMNU(WINSTAT,MENUNUM,XWIN(1),YWIN(1),HELPLVL,INCHAR)
      IF (INCHAR.EQ.'ES') THEN
C
C          .. ESC SAVES CURRENT DEFINITION AND EXITS
         GO TO 100
      ELSE IF (INCHAR.EQ.'1 ') THEN
C
C          .. CHOOSE TIC/GRID OPTION
         WINSTAT=4
         MENUNUM = 32
         HELPLVL = 32
         IF (GRDTYP.LT.0) THEN
            INCHAR = '1 '
         ELSE IF (GRDTYP.GT.0) THEN
            INCHAR = '2 '
         ELSE
            INCHAR = '3 '
         ENDIF         
         CALL GRAFMNU(WINSTAT,MENUNUM,XWIN(2),YWIN(2),HELPLVL,INCHAR)
         IF (INCHAR.EQ.'1 ') THEN
C             .. TIC         
            GRDTYP = -MAX0(ABS(GRDTYP),1)
         ELSE IF (INCHAR.EQ.'2 ') THEN
C             .. GRID         
            GRDTYP = MAX0(ABS(GRDTYP),1)
         ELSE IF (INCHAR.EQ.'3 ') THEN
C             .. NO TIC OR GRID         
            GRDTYP = 0
         ENDIF
         WINSTAT=0
         CALL GRAFMNU(WINSTAT,MENUNUM,XWIN(2),YWIN(2),HELPLVL,INCHAR)
      ELSE
         IF (GRDTYP.EQ.0) THEN 
C           ..  CHOICE OF COLOR,STYLE,THICKNESS NOT ALLOWED WHEN NO TIC/GRID
C               OPTION IS SPECIFIED  
            MSGN1=546
            MSGN2=202
            XWINM=.1
            YWINM=.95
            CALL GRAFNOTE(XWINM,YWINM,MSGN1,MSGN2,' ',0,INCHAR)
         ELSE IF (INCHAR.EQ.'2 ') THEN
C
C          .. CHOOSE GRID/TIC COLOR      
            ICNTRL=0
            NBRPICK=16
            IPAL=PALETTE
            IPICK=2
            ICLR=GRDCLR
            CALL PICKCOL(ICLR,XWIN(2),YWIN(2),ICNTRL,NBRPICK,IPAL,
     +                   PALDEF,IPICK)
            IF (ICLR.NE.-1) GRDCLR=ICLR
         ELSE IF (INCHAR.EQ.'3 ') THEN
C
C             .. CHOOSE GRID/TIC LINE PATTERN     
            ICNTRL=2
            ITYP=ABS(GRDTYP)
            CALL LNATRIB(ICNTRL,XWIN(2),YWIN(2),ITYP) 
            GRDTYP = ISIGN(ITYP,GRDTYP)
         ELSE 
C
C             .. CHOOSE GRID/TIC THICKNESS
            ICNTRL=1
            CALL LNATRIB(ICNTRL,XWIN(2),YWIN(2),GRDTHK) 
         ENDIF
      ENDIF
C
C       ** RETURN TO GET ANOTHER MENU CHOICE; MENU WILL NOT BE REDRAWN
C      
      WINSTAT = 3
      GO TO 70     
C
C       ** END OF THIS MENU; REMOVE MENU FROM SCREEN
C      
  100 CONTINUE
      WINSTAT = 0
      CALL GRAFMNU(WINSTAT,MENUNUM,XWIN(1),YWIN(1),HELPLVL,INCHAR)
      RETURN
      END
            