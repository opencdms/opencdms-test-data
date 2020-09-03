$STORAGE:2
      SUBROUTINE GETXTIC(NTIC,TICX,TICY)
C
C       ** OBJECTIVE:  GET X AND Y COORDINATES OF MAJOR TIC MARKS ALONG
C                      THE X AXIS
C
C       ** OUTPUT:
C             NTIC............NUMBER OF TIC MARKS ALONG X-AXIS
C             TICX............ARRAY OF X-COORDINATES AT START OF TIC MARK
C             TICY............ARRAY OF Y-COORDINATES AT START OF TIC MARK
C
C       ** NOTE:  ALL VALUES ARE IN WORLD COORDINATES.  TIC MARKS ARE PLACED
C                 ALONG THE AXIS AT INTERVALS OF XMAJOR STARTING AT
C                 THE ORIGIN.  DRWXAX MUST BE CALLED PRIOR TO THIS ROUTINE.
C 
      REAL *4 TICX(*),TICY(*)
C
$INCLUDE:  'PLTSPEC.INC'
C
C       ** CALCULATE TIC LOCATIONS
C
      XLOC = XTXLOC - DXTIC
      DO 10 N=1,NXTIC
         XLOC = XLOC + DXTIC
         TICX(N) = XLOC
         TICY(N) = XTYLOC         
   10 CONTINUE
C
      NTIC=NXTIC
C      
      RETURN
      END
      SUBROUTINE GETYTIC(NTIC,TICX,TICY)
C
C       ** OBJECTIVE:  GET X AND Y COORDINATES OF MAJOR TIC MARKS ALONG
C                      THE Y-AXIS
C
C       ** OUTPUT:
C             NTIC............NUMBER OF TIC MARKS ALONG Y-AXIS
C             TICX............ARRAY OF X-COORDINATES AT START OF TIC MARK
C             TICY............ARRAY OF Y-COORDINATES AT START OF TIC MARK
C
C       ** NOTE:  ALL VALUES ARE IN WORLD COORDINATES.  TIC MARKS ARE PLACED
C                 ALONG THE AXIS AT INTERVALS OF YMAJOR STARTING AT
C                 THE ORIGIN.  DRWYAX MUST BE CALLED PRIOR TO THIS ROUTINE.
C 
      REAL *4 TICX(*),TICY(*)
C
$INCLUDE:  'PLTSPEC.INC'
C
C       ** CALCULATE TIC LOCATIONS
C
      YLOC = YTYLOC - DYTIC
      DO 10 N=1,NYTIC
         YLOC = YLOC + DYTIC
         TICX(N) = YTXLOC
         TICY(N) = YLOC         
   10 CONTINUE
C
      NTIC = NYTIC
C      
      RETURN
      END
