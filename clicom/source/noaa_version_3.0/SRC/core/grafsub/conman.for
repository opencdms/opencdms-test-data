$STORAGE:2
      SUBROUTINE CONMAN(XWIN,YWIN,CONLEV,NTOTLEV,CONINCR,NCONLEV)
C
C       ** INPUT:
C             XWIN......
C             YWIN......
C             CONLEV....
C             NTOTLEV...      
C       ** OUTPUT:
C             CONINCR...
C             NCONLEV...
C
$INCLUDE: 'GRFPARM.INC'
C
      REAL*4     XWIN(*),YWIN(*),CONINCR,CONLEV(*)
      INTEGER *2 NCONLEV,NTOTLEV
C
      INTEGER*2 WINSTAT,HELPLVL        
      CHARACTER*9 MSGTXT
      CHARACTER*2 INCHAR
      REAL*4     XWNLFSV(3),YWNERR
      PARAMETER (MAXCHAR=22,MAXCHOICE=9,MAXITEM=MAXCHOICE+1)
      CHARACTER *(MAXCHAR) CHOICE(MAXITEM,3)
      PARAMETER (NCHRI=8)
      CHARACTER*(NCHRI) CHRINCR
      CHARACTER*6   CHRFMT
      INTEGER*2 NUMCHOICE(3)
      LOGICAL XWINPOS
      DATA YWNERR/.99/
C      
C       ** INITIAL WINDOW CONTROL VARIABLES;  WINSTAT IS SET TO DRAW MENU,
C          AND GET CHOICE; SCREEN IS NOT SAVED
C
      XWNLFSV(1)=XWIN(2)
      XWINPOS=.TRUE.
      WINSTAT = 4
C
C       .. GET STARTING CURSOR POSITION
      IF (CONINCR.EQ.0) THEN
C          .. USER SPECIFIED CONTOUR INTERVALS
         INCHAR='1 '
         DSPLYINC = 0.
         NBRDSPLY = 0
      ELSE IF (CONINCR.LT.0) THEN
C          .. USER SPECIFIED NUMBER OF CONTOUR INTERVALS      
         INCHAR='2 '
         DSPLYINC = 0.
         NBRDSPLY = NINT(ABS(CONINCR))
      ELSE
C          .. USER SPECIFIED CONTOUR INCREMENT      
         INCHAR='3 '
         DSPLYINC = CONINCR
         NBRDSPLY = 0
      ENDIF
C
C       ** LOOP TO DISPLAY AND PROCESS MENU CHOICES
C      
   20 CONTINUE
      MENUNUM = 40
      HELPLVL = 40
      CALL GRAFMNU(WINSTAT,MENUNUM,XWIN(1),YWIN(1),HELPLVL,INCHAR)
      IF (INCHAR.EQ.'ES') THEN
C
C          ** ESC EXITS CURRENT MENU
C
         GO TO 100
      ELSE IF (INCHAR.EQ.'1 ') THEN
C
C          ** USER SPECIFIED CONTOUR LEVELS 
C
C          .. RESET OLD VALUES IF NO VALUES SET FOR NCONLEV
               NCLSAV = NCONLEV
               CINSAV = CONINCR 
C
C          .. COMPOSE MENUS CONTAINING USER SPECIFIED VALUES FOR
C             CONTOUR LEVELS; MAXIMUM OF THREE MENUS CAN BE USED
C             LAST ENTRY IN ALL BUT THE FINAL MENU IS USED TO DISPLAY
C             MORE CONTOUR LEVELS
         IF (NTOTLEV.LE.0) THEN
            MSGN1=513
            MSGN2=202
            CALL GRAFNOTE(XWINLF,YWNERR,MSGN1,MSGN2,' ',0,INCHAR)
         ELSE
            MENUNUM = 41
            HELPLVL = 41
            CALL RDMENU(MENUNUM,MAXITEM,CHOICE(1,1),NUMCHOICE(1),
     +                  RTNCODE)
C         
            DO 24 I=1,MAXCHOICE-1
               CHOICE(I+1,1)=' '
   24       CONTINUE      
            DO 25 KMNU=2,3
               DO 25 I=1,MAXITEM
                  CHOICE(I,KMNU)=CHOICE(I,1)
   25       CONTINUE     
C
            NXTRA=NTOTLEV
            KLEV=0
            KMNU=0
   30       CONTINUE
            KMNU=KMNU+1
            NENTRY=MIN0(MAXCHOICE-1,NXTRA)
            DO 35 I=1,NENTRY
               KLEV=KLEV+1
               WRITE(CHOICE(I+1,KMNU),500) CONLEV(KLEV)
   35       CONTINUE
            NUMCHOICE(KMNU)=NENTRY+1
            NXTRA=NXTRA-NENTRY
            IF (NXTRA.GT.0) GO TO 30
            MAXMNU=KMNU
            NUMCHOICE(KMNU)=NUMCHOICE(KMNU)-1
C
C             .. DISPLAY MENUS CONTAINING CONTOUR LEVELS; GET RESPONSE
            NCONLEV=0
            WINSTAT=2         
            KMNU=1
   40       CONTINUE      
            CALL ARGMENU(WINSTAT,CHOICE(1,KMNU),NUMCHOICE(KMNU),
     +                   XWNLFSV(KMNU),YWIN(2),HELPLVL,INCHAR)
            IF (INCHAR.EQ.'ES') THEN
C  
C                .. REMOVE CURRENT MENU; SET POINTER TO PREVIOUS MENU
               WINSTAT=0         
               CALL ARGMENU(WINSTAT,CHOICE(1,KMNU),NUMCHOICE(KMNU),
     +                      XWNLFSV(KMNU),YWIN(2),HELPLVL,INCHAR)
               KMNU=KMNU-1
               WINSTAT=3
            ELSE IF (INCHAR.EQ.'9 ') THEN
C
C                .. ADD ANOTHER MENU OF CONTOUR LEVELS         
               KMNU=MIN0(KMNU+1,3)
               WINSTAT=2
               IF (XWINPOS) THEN
                  CALL XYWNDO(XWINLF,YWINTP,XWINRT,YWINBT)
                  XWNLFSV(KMNU)=XWINRT+.01
                  XWINPOS=KMNU.LT.MAXMNU
               ENDIF
            ELSE
C
C                .. NUMBER OF CONTOUR LEVELS WAS CHOSEN
               READ(INCHAR,510) NCHOICE
               NCONLEV = (MAXCHOICE-1)*(KMNU-1) + NCHOICE
               CONINCR = 0.
               NBRDSPLY = 0.
               DSPLYINC = 0.
            ENDIF
            IF (NCONLEV.EQ.0 .AND. KMNU.GT.0) GO TO 40
C
C             .. RESET OLD VALUES IF NO VALUES SET FOR NCONLEV
            IF (NCONLEV.EQ.0) THEN
               NCONLEV = NCLSAV
               CONINCR = CINSAV 
            ENDIF
C
C             .. REMOVE REMAINING CONTOUR LEVEL MENUS          
            WINSTAT=0
            DO 50 I=KMNU,1,-1
               CALL ARGMENU(WINSTAT,CHOICE(1,KMNU),NUMCHOICE(KMNU),
     +                      XWNLFSV(KMNU),YWIN(2),HELPLVL,INCHAR)
   50       CONTINUE
         ENDIF
      ELSE IF (INCHAR.EQ.'2 ') THEN
C
C          ** SPECIFIED NUMBER OF LEVELS  
C
         CALL XYWNDO(XWINLF,YWINTP,XWINRT,YWINBT)
   55    CONTINUE  
         MSGN1=509
         MSGN2=510
         WRITE(MSGTXT,503) NBRDSPLY
         NCHTXT = 3
         CALL GRAFMSG(XWINRT+.01,YWINBT,MSGN1,MSGN2,MSGTXT,NCHTXT,
     +                3,2,INCHAR,NCHAR)
         IF (INCHAR.NE.'ES') THEN
            WRITE(CHRFMT,520) NCHAR
            READ(INCHAR,CHRFMT) ITEMP
            IF (ITEMP.LE.0 .OR. ITEMP.GT.MXCONLEV) THEN
               MSGN1=515
               MSGN2=202
               CALL GRAFNOTE(XWINLF,YWNERR,MSGN1,MSGN2,' ',0,INCHAR)
               GO TO 55
            ELSE
               CONINCR  = -ITEMP
               NBRDSPLY = ITEMP
               DSPLYINC  = 0.
            ENDIF   
         ENDIF   
      ELSE IF (INCHAR.EQ.'3 ') THEN
C
C          ** SPECIFIED CONTOUR INCREMENT
C
         CALL XYWNDO(XWINLF,YWINTP,XWINRT,YWINBT)
   60    CONTINUE      
         MSGN1=511
         MSGN2=512
C          .. MAX CHARACTERS ALLOWED IS 8(F8.3) ALSO MAX VALUE USED IN WRTGRAF
         WRITE(MSGTXT,501) DSPLYINC
         NCHTXT = NCHRI
         CALL GRAFMSG(XWINRT+.01,YWINBT,MSGN1,MSGN2,MSGTXT,NCHTXT,
     +                4,NCHRI,CHRINCR,NCHAR)
         IF (CHRINCR.NE.'ES') THEN
            WRITE(CHRFMT,530) NCHAR
            READ(CHRINCR,CHRFMT) TEMP
            IF(TEMP.LE.0) THEN
C                .. NEGATIVE INCREMENTS NOT ALLOWED
               MSGN1=514
               MSGN2=202
               CALL GRAFNOTE(XWINLF,YWNERR,MSGN1,MSGN2,' ',0,INCHAR)
               GO TO 60
            ELSE IF(TEMP.GT.9999.999) THEN
C                .. INCREMENT MAY NOT BE > MAX VALUE DISPLAYED USING F8.3
               MSGN1=440
               MSGN2=202
               CALL GRAFNOTE(XWINLF,YWNERR,MSGN1,MSGN2,' ',0,INCHAR)
               GO TO 60
            ELSE
               CONINCR  = TEMP
               NBRDSPLY = 0
               DSPLYINC = TEMP
            ENDIF      
         ENDIF      
          
      ENDIF
C
C       ** RETURN TO GET ANOTHER MENU CHOICE; MENU WILL NOT BE REDRAWN
C      
      WINSTAT = 3
      GO TO 20     
C
C       ** END OF THIS MENU; REMOVE MENU FROM SCREEN
C      
  100 CONTINUE
      WINSTAT = 0
      CALL GRAFMNU(WINSTAT,MENUNUM,XWIN(1),YWIN(1),HELPLVL,INCHAR)
      RETURN
C
C       ** FORMAT STMTS
C
  500 FORMAT(F9.3)
  501 FORMAT(F8.3)
  503 FORMAT(I3)
  510 FORMAT(I1,1X)
  520 FORMAT('(I',I1,')')
  530 FORMAT('(F',I1,'.0)')         
C  
      END
            