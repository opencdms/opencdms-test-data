$STORAGE:2
      SUBROUTINE KWLAB  (TXTCHR,X,Y,NCHAR,ICENT,ANG,CHRHT,BTVCFLG)
C
C       ** OBJECTIVE:  DRAW TEXT AT THE SPECIFIED X,Y COORDINATES       
C                      NOTE -- ROUTINE DEFHST MUST BE CALLED PRIOR TO THIS
C                              ROUTINE TO DEFINE CHARACTER ATTRIBUTES 
C
C       ** INPUT:
C             TXTCHR......TEXT STRING
C             X...........X WORLD COORDINATE OF TEXT STRING
C             Y...........Y WORLD COORDINATE OF TEXT STRING
C             NCHAR.......NUMBER OF CHARACTERS IN STRING 
C             ICENT....... 0=X,Y IS CENTER LEFT EDGE OF STRING
C                          1=X,Y IS HORIZONTAL/VERTICAL CENTER OF STRING
C                          2=X,Y IS CENTER TOP EDGE OF STRING
C             ANG.........ANGLE (DEGREES) AT WHICH TEXT IS DRAWN 
C                         ALLOWED ANGLES:  0,90,180,270
C             CHRHT.......CHARACTER HEIGHT IN WORLD COORDINATE
C
C             BTVCFLG.......0=BIT FONT
C                           1=VECTOR FONT   
C
$INCLUDE:  'MAPLAB.INC'
      REAL*4 X,Y,ANG,CHRHT
      INTEGER*2 NCHAR,ICENT,BTVCFLG
      CHARACTER *(*) TXTCHR
      CHARACTER *80 OUTTXT
C
C
C       ** ADD HALO DELIMITERS TO STRING
C
      CALL DELIMSTR(TXTCHR(1:NCHAR),OUTTXT)  
C
C       ** GET X,Y COORDINATES OF LOWER LEFT CORNER OF STRING 
C      
      CALL GETWASP(WASP)
      CALL INQSTS(OUTTXT,HEIGHT,WIDTH,OFFSET)
      IF (ICENT.EQ.0) THEN
         FAC1=0.0
         FAC2=0.5
         HEIGHT = HEIGHT+OFFSET
      ELSE IF (ICENT.EQ.1) THEN
         FAC1=0.5
         FAC2=0.5
         HEIGHT = HEIGHT+OFFSET
      ELSE IF (ICENT.EQ.2) THEN
         FAC1=0.5
         FAC2=1.0
      ELSE
         FAC1=0.
         FAC2=0.5
         HEIGHT = HEIGHT+OFFSET
      ENDIF         
      NIANG = NINT(ANG)
      IF (NIANG.EQ.0) THEN
         XL = X-FAC1*WIDTH
         YL = Y-FAC2*HEIGHT
      ELSE IF (NIANG.EQ.90) THEN
         XL = X+FAC2*HEIGHT/WASP
         YL = Y-FAC1*WIDTH*WASP
      ELSE IF (NIANG.EQ.180) THEN
         XL = X+FAC1*WIDTH
         YL = Y+FAC2*HEIGHT
      ELSE IF (NIANG.EQ.270) THEN
         XL = X-FAC2*HEIGHT/WASP
         YL = Y+FAC1*WIDTH*WASP
      ELSE
         XL = X
         YL = Y   
      ENDIF
      XL=XPLTCEN+XL
      YL=YPLTCEN+YL
C
C       ** PLOT STRING AT SPECIFIED ANGLE
C 
      CALL SETLNW(1)
      CALL SETLNS(1)
      CALL SETSTA(ANG)
      CALL MOVTCA(XL,YL)
      CALL STEXT(OUTTXT)           
C      
C       ** RETURN SETTING TO CURRENT LINE THICKNESS AND STYLE
C
      CALL SETLNW(LNTHKCUR)
      CALL SETLNS(LNTYPCUR)
C
      RETURN      
      END      
 
