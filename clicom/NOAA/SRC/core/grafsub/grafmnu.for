$STORAGE:2
      SUBROUTINE GRAFMNU(WINSTAT,MENUNUM,XWIN,YWIN,HELPLVL,OUTCHAR)
C
C       ** OBJECTIVE:  SUBROUTINE TO WRITE AND READ A GRAPHICS MENU
C                      AS DEFINED IN THE GRAPHICS MENU DEFINITION FILE.
C                      (THAT FILE, P:\FORM\GRAFMENU.DEF CONTAINS 2 LINES FOR
C                      F1 AND ESC KEY DEFINITIONS AND THEN 1 LINE PER MENU.
C                      MAXIMUM LENGTH OF ANY CHOICE IS 16 CHARS FOR A MENU 
C                      WHICH SAVES THE BACKGROUND PLOT OR 32 CHARS FOR A MENU
C                      WHICH OVERWRITES THE BACKGROUND.
C       **INPUT:
C            WINSTAT....0=REMOVE MENU, DO NOT RESTORE SCREEN
C                       1=DRAW MENU, GET CHOICE, REMOVE MENU, RESTORE SCREEN
C                         INITIAL CURSOR POSITION IS AT CHOICE 1
C                       2=DRAW MENU, DO NOT SAVE SCREEN, GET CHOICE
C                         INITIAL CURSOR POSITION IS AT CHOICE 1
C                       3=GET CHOICE -- MENU IS ALREADY ON SCREEN
C                         INITIAL CURSOR POSITION IS AT CHOICE OF LAST ENTRY
C                       4=DRAW MENU, DO NOT SAVE SCREEN, GET CHOICE
C                         INITIAL CURSOR POSITION IS AT CHOICE=OUTCHAR
C                       5=DRAW MENU, GET CHOICE, REMOVE MENU, RESTORE SCREEN
C                         INITIAL CURSOR POSITION IS AT CHOICE=OUTCHAR
C            MENUNUM....THE NUMBER OF THE MENU TO BE DISPLAYED 
C            XWIN,YWIN..LOWER LEFT WINDOW CORNER IN NORMALIZED DEVICE COORDS
C            HELPLVL....THE GRAPHICS HELP LEVEL NUMBER FOR THIS MENU
C            OUTCHAR....INITIAL CURSOR POSITION; USED ONLY IF WINSTAT=4 OR 5
C       ** OUTPUT:
C            OUTCHAR....THE CHARACTER*2 CHOICE RESULT
C                       CHOICE NUMBERS ARE LEFT JUSTIFIED
C
      CHARACTER*2 OUTCHAR
      INTEGER*2   WINSTAT,MENUNUM,HELPLVL
      REAL*4      XWIN,YWIN
C
C       ** LOCAL COMMON TO SAVE SPACE IN D-GROUP
      PARAMETER (MAXCHAR=22,MAXCHOICE=9,MAXITEM=MAXCHOICE+1)
      INTEGER*2     NUMCHOICE
      CHARACTER*(MAXCHAR)  CHOICE(MAXITEM)
      CHARACTER*1   RTNCODE
      COMMON /MNUSAV/ NUMCHOICE,
     +                CHOICE,RTNCODE 
C
C       ** READ MENU CHOICES FROM FILE
C
      IF (WINSTAT.EQ.1 .OR. WINSTAT.EQ.5 .OR. 
     +    WINSTAT.EQ.2 .OR. WINSTAT.EQ.4) THEN 
         CALL RDMENU(MENUNUM,MAXITEM,CHOICE,NUMCHOICE,RTNCODE)
      ENDIF
C
C       ** DISPLAY MENU AND GET USER CHOICE 
C
      CALL ARGMENU(WINSTAT,CHOICE,NUMCHOICE,XWIN,YWIN,HELPLVL,OUTCHAR)      
C      
      RETURN
      END
      SUBROUTINE RDMENU(MENUNUM,MAXITEM,CHOICE,NUMCHOICE,RTNCODE)
C
C       ** OBJECTIVE:  READ MENU FROM FILE, PLACE CHOICE VALUES IN ARRAY,
C                      COUNT THE NUMBER OF CHOICES     
C       
C       ** INPUT:  
C             MENUNUM.....THE NUMBER OF THE MENU TO READ
C             MAXITEM.....MAXIMUM NUMBER OF VALUES THAT CAN BE ENTERED IN THE
C                         CHOICE ARRAY; FIRST ENTRY IS MENU TITLE
C       ** OUTPUT:
C             CHOICE......ARRAY OF MENU CHOICES; FIRST ENTRY IS MENU TITLE
C             NUMCHOICE...ACTUAL NUMBER OF MENU CHOICES
C             RTNCODE.....RETURN CODE FROM PARSE1
C      
      INTEGER*2 MENUNUM,MAXITEM,NUMCHOICE
      CHARACTER *(*) CHOICE(MAXITEM)
      CHARACTER *1 RTNCODE
      CHARACTER *2 INCHAR
C      
      CHARACTER*180 INREC
C      
      OPEN (13,FILE='P:\FORM\GRAFMENU.DEF',STATUS='OLD')
C
C       ** POSITION FILE TO THE SPECIFIED MENU
C
      DO 10 I=1,3
         READ(13,500) 
   10 CONTINUE      
      DO 20 I = 1,MENUNUM-1
         READ(13,510) 
20    CONTINUE
      READ(13,510,END=900) INREC
      CLOSE(13)
C
C       ** READ THE MENU AND PLACE MENU CHOICES IN ARRAY
C
      LNGTH = LEN(CHOICE(1))
      CALL PARSE1(INREC,180,MAXITEM,LNGTH,CHOICE(1),RTNCODE)
C
C       ** COUNT THE NUMBER OF CHOICES IN THE MENU -- FIRST LINE IS THE
C          MENU TITLE AND IS NOT COUNTED AS A CHOICE
C
      DO 30 J = 2,MAXITEM
         IF (CHOICE(J).EQ.' ') GO TO 35
   30 CONTINUE  
      J = MAXITEM+1          
   35 CONTINUE
      NUMCHOICE = J-2   
C
      RETURN
C
C       ** ERROR PROCESSING
C
  900 CONTINUE
C          .. PREMATURE END OF FILE
         NUMCHOICE=0
         XWIN=.1
         YWIN=.95
         MSGN1=382
         MSGN2=202
         CALL GRAFNOTE(XWIN,YWIN,MSGN1,MSGN2,'GRAFMENU.DEF',12,INCHAR)
         CLOSE(13)
         RETURN
C
C       ** FORMAT STMTS
C
  500 FORMAT(A12)
  510 FORMAT(4X,A180)
      END
      SUBROUTINE ARGMENU(WINSTAT,CHOICE,NUMCHOICE,XWIN,YWIN,
     +                   HELPLVL,OUTCHAR)
C*************************************************************************
C  ** DEBUG  CORRECTIONS TO DAVE'S ORIGINAL VERSION
C     1) 8-4-89  AFTER OPENING VIEWPORT TO ENTIRE SCREEN THE WORLD COORDINATES
C                ARE SET TO A RANGE OF 0-1. RATHER THAN THE OLD WORLD COORD
C                CALL TO MOVHCA(XOLD,YOLD) IS REMOVED.  THESE CHANGES ARE IN
C                CODE JUST PRIOR TO LOOP 110.  
C     2) 14-DEC  PULL OUT SELECTION BAR AND PUT IN SUBR PIKITEM
C     3) 20-DEC  ARRAY OF ITEMS RATHER THAN MENU NUMBER TO BE DISPLAYED
C*************************************************************************
C
C   SUBROUTINE TO WRITE A GRAPHICS MENU USING A CHARACTER ARRAY WHICH CONTAINS
C   THE CHOICES TO DISPLAY. ALSO ADD 2 LINES FOR F1 AND ESC KEY DEFINITIONS.
C   MAXIMUM LENGTH OF ANY CHOICE IS 16 CHARS FOR A MENU WHICH SAVES THE 
C   BACKGROUND PLOT OR 32 CHARS FOR A MENU WHICH OVERWRITES THE BACKGROUND.
C
C       **INPUT:
C            WINSTAT....0=REMOVE MENU, DO NOT RESTORE SCREEN
C                       1=DRAW MENU, GET CHOICE, REMOVE MENU, RESTORE SCREEN
C                         INITIAL CURSOR POSITION IS AT CHOICE 1
C                       2=DRAW MENU, DO NOT SAVE SCREEN, GET CHOICE
C                         INITIAL CURSOR POSITION IS AT CHOICE 1
C                       3=GET CHOICE -- MENU IS ALREADY ON SCREEN
C                         INITIAL CURSOR POSITION IS AT CHOICE OF LAST ENTRY
C                       4=DRAW MENU, DO NOT SAVE SCREEN, GET CHOICE
C                         INITIAL CURSOR POSITION IS AT CHOICE=OUTCHAR
C                       5=DRAW MENU, GET CHOICE, REMOVE MENU, RESTORE SCREEN
C                         INITIAL CURSOR POSITION IS AT CHOICE=OUTCHAR
C            CHOICE ....ARRAY OF ITEMS TO BE DISPLAYED IN MENU INCLUDING HEADER
C            NUMCHOICE..THE NUMBER ITEMS IN THE MENU WITHOUT HEADER LINE
C            XWIN,YWIN..LOWER LEFT WINDOW CORNER IN NORMALIZED DEVICE COORDS
C            HELPLVL....THE GRAPHICS HELP LEVEL NUMBER FOR THIS MENU
C            OUTCHAR....INITIAL CURSOR POSITION; USED ONLY IF WINSTAT=4 OR 5
C       ** OUTPUT:
C            OUTCHAR....THE CHARACTER*2 CHOICE RESULT
C                       CHOICE NUMBERS ARE LEFT JUSTIFIED
C
      INTEGER*2     WINSTAT,NUMCHOICE,HELPLVL
      REAL*4        XWIN,YWIN
      CHARACTER*(*) CHOICE(*)
      CHARACTER*2   OUTCHAR
C      
C       ** LOCAL COMMON TO SAVE SPACE IN D-GROUP
C          ALSO USED BY XYWNDO
C
      PARAMETER (MAXCHOICE=9,MAXITEM=MAXCHOICE+1)
      PARAMETER (MXMNU=6)      
      INTEGER*2  MAXX,MAXY,IXOR(MXMNU),MAXLEN,IMENU,NCHOISV(MXMNU),
     +           IWSTAT,ICURFLG 
      REAL       HEIGHT,CWIDTH,XLOW,YLOW,XHIGH,YHIGH,WIDTH,XPOS,YPOS,
     +           XN1(MXMNU),YN1(MXMNU),XN2(MXMNU),YN2(MXMNU),
     +           X1OLD(MXMNU),Y1OLD(MXMNU),X2OLD(MXMNU),Y2OLD(MXMNU),
     +           XWIN1(MXMNU),YWIN1(MXMNU),XWIN2(MXMNU),YWIN2(MXMNU),
     +           XOLD(MXMNU),YOLD(MXMNU),XHELP,YHELP
      CHARACTER*34  ITEMS(MAXITEM)
      CHARACTER*22  HOLDLINE
      CHARACTER*12  F1LINE,ESCLINE
      CHARACTER*2   SAVCHOI(MXMNU)
      CHARACTER*3   DEVERS
      COMMON /ARGSAV/   MAXX,MAXY,IXOR,MAXLEN,IMENU,NCHOISV,
     +        IWSTAT,ICURFLG, 
     +        HEIGHT,CWIDTH,XLOW,YLOW,XHIGH,YHIGH,WIDTH,XPOS,YPOS,
     +        XN1,YN1,XN2,YN2,X1OLD,Y1OLD,X2OLD,Y2OLD,
     +        XWIN1,YWIN1,XWIN2,YWIN2,XOLD,YOLD,XHELP,YHELP,
     +        ITEMS,HOLDLINE,F1LINE,ESCLINE,SAVCHOI,DEVERS
C     
      LOGICAL       FIRSTCALL
      DATA    FIRSTCALL /.TRUE./
C
C   ON 1ST CALL TO THIS ROUTINE READ THE 2 LINES FOR F1 AND ESC KEY DEFINITIONS
C
      IF (FIRSTCALL) THEN
         FIRSTCALL = .FALSE.
         IMENU = 0
         CALL GETDEASE(DEVERS)
         OPEN (13,FILE='P:\FORM\GRAFMENU.DEF',STATUS='OLD')
         READ(13,500) F1LINE
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
         HOLDLINE = F1LINE
         F1LINE = '^'//HOLDLINE
         F1LINE(12:12) = '^'
         HOLDLINE = ESCLINE
         ESCLINE = '^'//HOLDLINE
         ESCLINE(12:12) = '^'
      ENDIF
C
C       ** SET DOT TEXT SIZE 
C
      CALL INQDRA(MAXX,MAXY)
      IF (MAXY.GT.350) THEN
         CALL SETTEX(2,1,0,0)
      ELSE
         CALL SETTEX(1,1,0,0)
      END IF
C
      IF (WINSTAT.EQ.5) THEN
         IWSTAT=1
         ICURFLG=1
      ELSE IF (WINSTAT.EQ.4) THEN
         IWSTAT=2
         ICURFLG=1
      ELSE
         IWSTAT=WINSTAT
         ICURFLG=0
      ENDIF      
C
      IF (IWSTAT.EQ.1 .OR. IWSTAT.EQ.2) THEN
         IMENU=IMENU+1   
         NCHOISV(IMENU) = NUMCHOICE
C
C          ** SET MAXIMUM LENGTH FOR MENU ITEMS
C
         IF (IWSTAT .EQ. 1) THEN
            MAXLEN = 16
         ELSE
            MAXLEN = 32
         ENDIF
C
C         ** DETERMINE AND SAVE THE CURRENT XOR STATUS, CROSS-HAIR CURSOR 
C            LOCATION, WORLD COORDINATES, AND VIEWPORT.
C
         CALL INQXOR(IXOR(IMENU))
         CALL INQHCU(XOLD(IMENU),YOLD(IMENU),IDUMMY)
         CALL INQWOR(X1OLD(IMENU),Y1OLD(IMENU),
     +               X2OLD(IMENU),Y2OLD(IMENU))
         CALL INQVIE(XN1(IMENU),YN1(IMENU),XN2(IMENU),YN2(IMENU))
C
C      ADD LEADING AND TRAILING HALO TEXT DELIMITTERS TO MENU CHOICES.
C
         DO 80 J=1,NUMCHOICE+1
            K = LNG(CHOICE(J))
            IF (K .GT. MAXLEN) THEN
               K = MAXLEN
            ENDIF
            IF (J.EQ.1) THEN
               ITEMS(1) = '^'//CHOICE(1)(1:K)//'^'
            ELSE
               WRITE(ITEMS(J),'(A1,I1,A2)') '^',J-1,'. '
               ITEMS(J)(5:K+5) = CHOICE(J)(1:K)//'^'
            ENDIF
80       CONTINUE
C
C  DETERMINE HOW MUCH SPACE IS REQUIRED FOR THIS MENU IN THE CURRENT
C  WORLD COORD SYSTEM AND DEFINE THE WINDOW BIG ENOUGH TO HOLD IT.
C  ADD 2% OF SCREEN TO WINDOW SIZE TO ACCOUNT FOR WINDOW BORDER AND SHADOWS.
C
C          .. IN ORDER TO OPEN THE VIEWPORT TO THE ENTIRE SCREEN, A MAX VALUE
C             EQUAL TO .999 MUST BE USED.  A VALUE OF 1.0 IS A SPECIAL SIGNAL 
C             FOR HALO TO 'TURN OFF' THE VIEWPORT WHICH DOES NOT RESET ASPECT 
C             RATIOS
         CALL SETVIE(0.,0.,0.999,0.999,-1,-1)
         CALL SETWOR(0.,0.,1.,1.)
         WIDTH = 0.
         DO 110 J = 1,NUMCHOICE+1
            CALL INQTSI(ITEMS(J),HEIGHT,CWIDTH)
            IF (CWIDTH.GT.WIDTH) THEN
               WIDTH = CWIDTH
            END IF
110      CONTINUE
         XPOS = WIDTH 
         YPOS = HEIGHT*(NUMCHOICE+3)
         CALL MAPWTN(XPOS,YPOS,XWN,YWN)
         XWN = XWN + .02
         YWN = 1.02 - YWN 
C
C   SET UP WINDOW FOR DISPLAY OF THE MENU. ALSO DETERMINE WHERE HELP
C   WINDOW SHOULD BE LOCATED IF IT IS REQUESTED.
C
         XWIN1(IMENU) = XWIN
         XWIN2(IMENU) = XWN + XWIN1(IMENU)
         YWIN1(IMENU) = YWIN - YWN 
         YWIN2(IMENU) = YWIN
         CALL GRAFWIN(IWSTAT,XWIN1(IMENU),YWIN1(IMENU),
     +                        XWIN2(IMENU),YWIN2(IMENU))
         CALL INQWOR(XLOW,YLOW,XHIGH,YHIGH)
         CALL INQTSI(ITEMS(1),HEIGHT,CWIDTH)
         XPOS = (XHIGH + XLOW) / 2.0 - (CWIDTH / 2.0)
         CALL SETTCL(1,3)
C      
C   DISPLAY THE MENU TEXT (TITLE IS CENTERED, OTHER TEXT LEFT JUSTIFIED)
C
         DO 180 I = 1,NUMCHOICE+1
            YPOS = YHIGH - I*HEIGHT
            CALL MOVTCA(XPOS,YPOS)
            CALL DELTCU( )
            CALL TEXT(ITEMS(I))
            IF (I.EQ.1) THEN
               CALL SETTCL(0,3)
               XPOS = XLOW 
            END IF
180      CONTINUE
C
C   DISPLAY THE F1 AND ESC KEY DEFINITIONS. FIND ITEM NUMBER OF SELECTED CHOICE
C
         YPOS = YHIGH - (NUMCHOICE+2)*HEIGHT
         CALL MOVTCA(XPOS,YPOS)
         CALL SETTCL(1,3)
         CALL TEXT(F1LINE)
         YPOS = YHIGH - (NUMCHOICE+3)*HEIGHT
         CALL MOVTCA(XPOS,YPOS)
         CALL DELTCU
         CALL TEXT(ESCLINE)
      ENDIF   
C         
      IF (IWSTAT.GT.0) THEN
         IF (IWSTAT.EQ.3) THEN
            CALL INQTSI(ITEMS(1),HEIGHT,CWIDTH)
            OUTCHAR = SAVCHOI(IMENU)
            NUMCHOICE = -NCHOISV(IMENU)
         ELSE IF (ICURFLG.EQ.0) THEN
            OUTCHAR = ' '
         ENDIF      
         IF (XWIN1(IMENU).LT.0.40) THEN
            XHELP = XWIN1(IMENU) + .15
         ELSE
            XHELP = XWIN1(IMENU) - .45
         END IF
         IF (YWIN1(IMENU).LT.0.5) THEN
            YHELP =  YWIN1(IMENU) + .50 
         ELSE
            YHELP = YWIN2(IMENU) - .10
         END IF
         CALL PIKITEM(HEIGHT,NUMCHOICE,HELPLVL,XHELP,YHELP,OUTCHAR)
         SAVCHOI(IMENU) = OUTCHAR
      ENDIF   
C
C   RESTORE THE WINDOW AND CURSOR POSITION AND EXIT.
C
      IF (IWSTAT.LE.1) THEN
         CALL SETXOR(0)
         CALL GRAFWIN(0,XWIN1(IMENU),YWIN1(IMENU),
     +                  XWIN2(IMENU),YWIN2(IMENU))
         CALL SETVIE(XN1(IMENU),YN1(IMENU),XN2(IMENU),YN2(IMENU),-1,-1)
         CALL SETWOR(X1OLD(IMENU),Y1OLD(IMENU),
     +               X2OLD(IMENU),Y2OLD(IMENU))
         CALL SETXOR(IXOR(IMENU))
         CALL MOVHCA(XOLD(IMENU),YOLD(IMENU))
         CALL ORGLOC(XOLD(IMENU),YOLD(IMENU))
         IMENU=IMENU-1   
      ELSE   
         CALL SETXOR(IXOR(IMENU))
      ENDIF   
      RETURN
C
C       ** FORMAT STMTS
C
  500 FORMAT(A12)
      END
      SUBROUTINE XYWNDO(XWINLF,YWINTP,XWINRT,YWINBT)
C
C       ** OBJECTIVE:  GET COORDINATES OF LAST WINDOW OPENED ON SCREEN
C                      VALUES RETURNED ARE IN NORMALIZED DEVICE 
C                      COORDINATES WITH A RANGE OF 0-1
C
C       **OUTPUT:      
C            XWINLF....X-COORDINATE -- LEFT SIDE
C            YWINTP....Y-COORDINATE -- TOP
C            XWINRT....X-COORDINATE -- RIGHT SIDE
C            YWINBT....Y-COORDINATE -- BOTTOM
C      
C       ** LOCAL COMMON TO SAVE SPACE IN D-GROUP
C          ALSO USED BY ARGMENU
C
      PARAMETER (MAXCHOICE=9,MAXITEM=MAXCHOICE+1)
      PARAMETER (MXMNU=6)      
      INTEGER*2  MAXX,MAXY,IXOR(MXMNU),MAXLEN,IMENU,NCHOISV(MXMNU),
     +           IWSTAT,ICURFLG 
      REAL       HEIGHT,CWIDTH,XLOW,YLOW,XHIGH,YHIGH,WIDTH,XPOS,YPOS,
     +           XN1(MXMNU),YN1(MXMNU),XN2(MXMNU),YN2(MXMNU),
     +           X1OLD(MXMNU),Y1OLD(MXMNU),X2OLD(MXMNU),Y2OLD(MXMNU),
     +           XWIN1(MXMNU),YWIN1(MXMNU),XWIN2(MXMNU),YWIN2(MXMNU),
     +           XOLD(MXMNU),YOLD(MXMNU),XHELP,YHELP
      CHARACTER*34  ITEMS(MAXITEM)
      CHARACTER*22  HOLDLINE
      CHARACTER*12  F1LINE,ESCLINE
      CHARACTER*2   SAVCHOI(MXMNU)
      CHARACTER*3   DEVERS
      COMMON /ARGSAV/   MAXX,MAXY,IXOR,MAXLEN,IMENU,NCHOISV,
     +        IWSTAT,ICURFLG, 
     +        HEIGHT,CWIDTH,XLOW,YLOW,XHIGH,YHIGH,WIDTH,XPOS,YPOS,
     +        XN1,YN1,XN2,YN2,X1OLD,Y1OLD,X2OLD,Y2OLD,
     +        XWIN1,YWIN1,XWIN2,YWIN2,XOLD,YOLD,XHELP,YHELP,
     +        ITEMS,HOLDLINE,F1LINE,ESCLINE,SAVCHOI,DEVERS
C     
      XWINLF = XWIN1(IMENU)
      YWINTP = YWIN1(IMENU)
      XWINRT = XWIN2(IMENU)
      YWINBT = YWIN2(IMENU)
C
      RETURN      
      END
      