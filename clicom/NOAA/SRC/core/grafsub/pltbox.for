$STORAGE:2
      SUBROUTINE PLTBOX(LNCLR,LNTHK)
C
$INCLUDE:  'PLTSPEC.INC'
C
C       ** DRAW BOX AROUND PLOT AREA
C
      LNTYP=1
      CALL DEFHLN(LNCLR,LNTYP,LNTHK)   
      CALL BOX(XMIN,YMIN,XMAX,YMAX)     
C
      RETURN
      END      