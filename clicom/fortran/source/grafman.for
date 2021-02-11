$STORAGE:2
      PROGRAM GRAFMAN
C
C       ** OBJECTIVE:  THE GRAPH MANAGER COMBINES THE GRAPH DEFINITION IN THE
C                      GDF FILE WITH THE DATA IN THE API FILE AND DISPLAYS THE
C                      RESULTANT GRAPH.  IT ALLOWS USERS TO TAILOR THE GRAPHS
C                      TO THEIR REQUIREMENTS.  USERS MODIFY THE GRAPHS BY
C                      SPECIFYING VALUES IN FORMS AND MANIPULATING GRAPHS
C                      DIRECTLY ON THE SCREEN.
C
$INCLUDE: 'GRFPARM.INC'
$INCLUDE: 'GRAFVAR.INC'
$INCLUDE: 'DATAVAL.INC'
$INCLUDE: 'CURRPLT.INC'
C
      INTEGER*2 HELPLVL,DATAOPT,NTTL,NOKD,LENMSG
      PARAMETER(NOKD=2)
      CHARACTER INCHAR*2, RTNCODE*1, RTNFLG*2
      CHARACTER*2 EXITOPT,OKOPT(NOKD)
      CHARACTER*1 TTLSAV(2)
      CHARACTER*28 GRAFNAME
      CHARACTER*14 MSGTXT
      CHARACTER*2 YESUP,YESLO
      LOGICAL PLTONSCR,FIRSTCALL
      DATA FIRSTCALL/.TRUE./
      DATA NTTL/1/
C       .. VALID OPTION FLAGS IN FILE DATACOM.CON
C          GO=RETURN FROM OPTMAN  ZZ=INITIAL CALL AFTER GRAFINIT      
      DATA OKOPT/'GO','ZZ'/
C       .. OPTION FLAG WRITTEN TO DATACOM.CON WHEN EXITING TO GRAFINIT
      DATA EXITOPT/'ZZ'/      
C
      IF (FIRSTCALL) THEN
         FIRSTCALL=.FALSE.
         CALL GETYN(1,2,YESUP,YESLO)
      ENDIF   
C
C       **  Open and read GRAPHICS.GDF file and store the values in the
C           GRAFVAR common block.
C
      CALL RDGRAF('GRAPHICS',ITYPE,NELEM,RTNCODE)
C
C       ** INITIAL GRAPHICS
C
      IF (RTNCODE.EQ.'0') THEN
C          .. NORMAL RETURN FROM RDGRAF -- DEFINE PALETTES
         CALL BGNHALO(1,PALETTE,PALDEF)
      ELSE
C          .. ERROR RETURN FROM RDGRAF -- USE DEFAULT PALETTES
         CALL BGNHALO(0,PALETTE,PALDEF)
         GO TO 900
      ENDIF      
C
C       ** OPEN AND READ DATACOM.CON FILE AND STORE CONSTANTS IN THE
C          DATAVAL COMMON BLOCK; CLOSE FILE
      CALL RDDCON(0,OKOPT,NOKD,INCHAR,RTNCODE)
      IF (RTNCODE.EQ.'2') THEN
C          .. ERROR IN OPENING FILE      
         GO TO 905        
      ENDIF
      MXDATROW = NROWDIM
C
C       ** Open the GRAPHICS.API file as unit 17 and read the CURRENT DATASET
C          into memory.
C
      DATAOPT=0
      CALL GETDSET(ITYPSET,DATAOPT,2,NTTL,TTLSAV,INCSET,RTNCODE)
      IF (RTNCODE.NE.'0') GO TO 900
C
C   IF FIRST ENTRY INTO GRAFMAN DISPLAY THE GRAPH AS CURRENTLY DEFINED
C
      PLTONSCR=.FALSE.
      IF (IDPLT.EQ.0) THEN
C          .. FIRST ENTRY INTO GRAFMAN -- BEGIN NEW FRAME      
         IGOPT=2
         CALL DRAWGRF(IGOPT,RTNCODE)
         PLTONSCR = RTNCODE.EQ.'0'
      ENDIF  
C
C  Display the main menu 
C
C    1.RE_PLOT  2.NXT_PLOT  3.POS DATA  4.OUTPUT  5.COLORS  6.LABELS  
C    7.LINES    8.SIZE      9.DATA MGR    F1-Help   Esc-Exit
C
   20 CONTINUE
      HELPLVL=2
      XWIN=.1
      YWIN=.8
      CALL GRAFMNU(1,2,XWIN,YWIN,HELPLVL,INCHAR)
C      
      IF (INCHAR.EQ.'ES') THEN
C      
C          .. EXIT GRAFMAN 
         XWIN=.1
         YWIN=.95
         MSGN1=506
         MSGN2=504
         CALL GRAFNOTE(XWIN,YWIN,MSGN1,MSGN2,' ',0,INCHAR)
         IF (INCHAR.EQ.YESUP .OR. INCHAR.EQ.YESLO) THEN
   25       CONTINUE      
            MSGN1=528
            MSGN2=247
            CALL GRAFNOTE(XWIN,YWIN,MSGN1,MSGN2,' ',0,INCHAR)
            RTNFLG=' '
            IF (INCHAR.EQ.YESUP .OR. INCHAR.EQ.YESLO) THEN
               GRAFNAME = GDFNAME     
               ITYPE = IOBSTYP
               ITEMP = 0 
               CALL WRTGRAF(GRAFNAME,ITYPE,ITEMP,RTNFLG)
            ENDIF
            IF (RTNFLG.EQ.'4F') GO TO 25
            IFPFLG=-2
            IPSFLG=0
            IDCFLG=0
            ISTP=0
            INCHAR=EXITOPT
            GO TO 100
         END IF
      ELSE IF (INCHAR.LE.'3 ') THEN   
         RTNCODE='0'
         IF (INCHAR.EQ.'1 ') THEN
C      
C             .. REDRAW CURRENT PLOT      
            IGOPT = 0
            IF (IGRAPH.EQ.2) IGOPT=-1
         ELSE IF (INCHAR.EQ.'2 ') THEN
C       
C             .. DRAW NEXT PLOT IN CURRENT DATA SET
            IF (IGRAPH.EQ.3 .OR. IGRAPH.EQ.4) THEN
C                .. SPECIAL CASE FOR SKEWT AND WINDROSE.  THESE GRAPH TYPES
C                   HAVE ONLY ONE PLOT PER FRAME.  BOTH NEXT PLOT AND NEXT
C                   FRAME GIVE THE SAME RESULTS.
               DATAOPT = 3
               CALL GETDSET(ITYPSET,DATAOPT,2,NTTL,TTLSAV,INCSET,
     +                      RTNCODE)
               IGOPT = 2
            ELSE
C                .. TIMESERIES AND MAP
               IGOPT = 1
            ENDIF
         ELSE IF (INCHAR.EQ.'3 ') THEN
C      
C             .. POSITON FILE/DATA SET.  DRAW FIRST PLOT IN DATA SET
            HELPLVL=3
            XWIN=.2
            YWIN=.9
            CALL GRAFMNU(1,3,XWIN,YWIN,HELPLVL,INCHAR)
            IF (INCHAR.NE.'ES') THEN
               IF (INCHAR.NE.'4 ') THEN
                  DATAOPT = ICHAR(INCHAR(1:1))-48
                  CALL GETDSET(ITYPSET,DATAOPT,2,NTTL,TTLSAV,
     +                         INCSET,RTNCODE)
               ENDIF
               IGOPT = 2
            ELSE
               RTNCODE='1'   
            ENDIF
         ENDIF
C
C          .. DRAW PLOT         
         IF (RTNCODE.EQ.'0') THEN
            CALL DRAWGRF(IGOPT,RTNCODE)
            PLTONSCR = RTNCODE.EQ.'0'
         ENDIF   
      ELSE IF (INCHAR.LE.'6 ') THEN      
C
C          .. REDRAW CURRENT PLOT IF NOT ALREADY ON SCREEN      
         IF(.NOT.PLTONSCR) THEN
            IGOPT=3
            CALL DRAWGRF(IGOPT,RTNCODE)
            PLTONSCR = RTNCODE.EQ.'0'
         ENDIF
         IF (.NOT.PLTONSCR) THEN
            XWIN=.1
            YWIN=.95
            MSGN1=602
            MSGN2=202
            CALL GRAFNOTE(XWIN,YWIN,MSGN1,MSGN2,' ',0,INCHAR)
         ELSE IF (INCHAR.EQ.'4 ') THEN
C      
C             .. SEND CURRENT SCREEN TO OUTPUT DEVICE
            CALL OUTMAN(PLTONSCR) 
         ELSE IF (INCHAR.EQ.'5 ') THEN
C      
C             .. CHOOSE COLOR PALETTE AND ADJUST PALETTE COLORS      
            CALL CLRMAN(PALETTE,PALDEF)
         ELSE IF (INCHAR.EQ.'6 ') THEN
C      
C             .. CHOOSE LABEL TYPE AND MODIFY SIZE, FONT, COLOR, LOCATION      
            CALL LBLMAN(I1VAL)
         ENDIF   
      ELSE IF (INCHAR.EQ.'7 ') THEN
C      
C          .. MODIFY COLOR, WIDTH, STYLE OF AXES, GRID, MAP LINES, DATA LINES
         IFPFLG=-1
         IPSFLG=1
         IDCFLG=1
         ISTP=1
         GO TO 100
      ELSE IF (INCHAR.EQ.'8 ') THEN
C      
C          .. ADJUST VIEWPORT, PLOT AREA, AND BACKGROUND COLOR       
         IFPFLG=-1
         IPSFLG=1
         IDCFLG=1
         ISTP=1
         GO TO 100
      ELSE IF (INCHAR.EQ.'9 ') THEN
C      
C          .. MODIFY REMAINING OPTIONS IN GRAFVAR COMMON
         IFPFLG=-1
         IPSFLG=1
         IDCFLG=1
         ISTP=1
         GO TO 100
      END IF
      GO TO 20
C
  100 CONTINUE
      ITYPE = IOBSTYP
      ITEMP = 1
      CALL WRTGRAF(GDFNAME,ITYPE,ITEMP,RTNFLG)
      CALL WRFILPOS(IFPFLG,IGRAPH,NUMCOL,IDUM)
C       .. OPTION FLAG WRITTEN TO DATACOM.CON IS THE CURRENT MENU CHOICE VALUE
C          (7=LINES  8=SIZE/BKGND  9=DATA) OR 'ZZ' IF EXITING TO GRAFINIT
      CALL WRTDCON(IPSFLG,IDCFLG,INCHAR,RTNCODE)
      IF (RTNCODE.NE.'0') GO TO 910        
      CALL FINHALO
      IF (ISTP.EQ.0) THEN
C          .. EXIT GRAPHICS; RETURN TO GRAFINIT.EXE      
         OPEN (UNIT=62,FILE='O:\DATA\SQUX',ACCESS='DIRECT',
     +         FORM='BINARY',RECL=512,STATUS='OLD',IOSTAT=IOCHK)
         IF (IOCHK.EQ.0) THEN
            CLOSE(62,STATUS='DELETE')
         ENDIF   
         CALL LOCATE(23,0,IERR)
         STOP 1
      ELSE
C          .. EXIT TO RUN OPTMAN.EXE THEN RETURN TO GRAFMAN      
         CALL LOCATE(23,0,IERR)
         STOP ' '
      ENDIF      
C
C       ** FATAL ERROR      
C
  900 CONTINUE
C          .. ERROR READING FILE: GRAPHICS.GDF  
         MSGN1=191
         MSGTXT='  GRAPHICS.GDF'
         LENMSG=14
         GO TO 990
  905 CONTINUE
C          .. ERROR READING FILE: DATACOM.CON  
         MSGN1=191
         MSGTXT='  DATACOM.CON'
         LENMSG=13
         GO TO 990
  910 CONTINUE
C          .. ERROR WRITING FILE: DATACOM.CON  
         MSGN1=192
         MSGTXT='  DATACOM.CON'
         LENMSG=13
         GO TO 990
  915 CONTINUE
C          .. ERROR READING FILE: GRAPHICS.API  
         MSGN1=191
         MSGTXT='  GRAPHICS.API'
         LENMSG=14
         GO TO 990
  990 CONTINUE         
         MSGN2=202
         XWIN=.1
         YWIN=.95
         CALL GRAFNOTE(XWIN,YWIN,MSGN1,MSGN2,MSGTXT,LENMSG,INCHAR)
         CALL WRFILPOS(-2,IGRAPH,NUMCOL,IDUM)
         INCHAR = EXITOPT
         CALL WRTDCON(0,0,INCHAR,RTNCODE)
         IF (RTNCODE.NE.'0') THEN
            MSGN1=192
            MSGTXT='  DATACOM.CON'
            LENMSG=13
            CALL GRAFNOTE(XWIN,YWIN,MSGN1,MSGN2,MSGTXT,LENMSG,INCHAR)
         ENDIF            
         CALL FINHALO
         OPEN (UNIT=62,FILE='O:\DATA\SQUX',ACCESS='DIRECT',
     +         FORM='BINARY',RECL=512,STATUS='OLD',IOSTAT=IOCHK)
         IF (IOCHK.EQ.0) THEN
            CLOSE(62,STATUS='DELETE')
         ENDIF   
         CALL LOCATE(23,0,IERR)
         STOP 1
      END
      SUBROUTINE DRAWGRF(IGOPT,RTNCODE)
C
C       ** OBJECTIVE:  CALLS ROUTINE PCTRL WHICH DRAWS THE PLOT USING THE
C                      CURRENT VALUES IN THE GRAPH DEFINITION FILE.  PAUSES
C                      AFTER PLOT AND WAITS FOR USER RESPONSE.  PRINTS ERROR
C                      MESSAGES.
C
C       ** NOTE:       THERE ARE TWO VERSIONS OF ROUTINE PCTRL.  THE ONE
C                      USED IN GRFMN2 PLOTS MAPS.  THE VERSION USED IN
C                      GRFMN134 PLOTS TIMESERIES, SKEWT, AND WINDROSE.
C       ** INPUT:
C              IGOPT...GRAPH OPTION FLAG THAT CONTROLS SELECTION OF DATA
C                      THAT WILL BE PLOTTED AND PLOT CONTROLS
C                     -1=REDRAW CURRENT PLOT -- REGRID DATA -- PAUSE (MAP ONLY)
C                      0=REDRAW CURRENT PLOT -- PAUSE
C                      1=NEXT PLOT IN CURRENT DATA FRAME -- PAUSE
C                      2=NEW DATA FRAME -- PAUSE
C                      3=REDRAW CURRENT PLOT -- NO PAUSE
C                      4=REDRAW CURRENT SCREEN FOR PRINTING -- NO PAUSE
C       ** OUTPUT:
C            RTNCODE...ONE CHARACTER ERROR FLAG
C                      '0'=NORMAL EXIT
C                      '1'=EXIT USING ESC OR F4
C                      '2'=NO MORE PLOTS IN DATASET
C                      '3'=PCTRL2 CALLED WITH PLOT TYPE = TIMESERIES(1),
C                          SKEWT(3), OR WINDROSE(4)
C                      '4'=PCTRL134 CALLED WHEN PLOT WAS MAP
C                      '5'=NO DATA AVAILABLE FOR CURRENT PLOT
C                      '6'=FILE WROSPOKE.DEF NOT AVAILABLE TO WINDROSE 
C                      NOTE:  VALUE SET IN RTNCODE IS USED TO DETERMINE IF A
C                             PLOT IS ON THE SCREEN.  RTNCODE VALUE IS SET TO 
C                             '7' BY SKEWT ROUTINES TO INDICATED PRESSURE OR
C                             TEMPERATURE IS OUT OF SORT BUT PLOT IS STILL ON
C                             SCREEN SO RTNCODE IS RESET TO '0' AFTER ERROR 
C                             MESSAGE IS DISPLAYED.  ACTION IS SIMILAR WHEN
C                             RTNCODE IS '8'.  THIS RETURN CODE IS SET BY SKEWT
C                             ROUTINES WHEN NO LINES ARE PLOTTED, BUT THE
C                             BACKGROUND IS STILL ON THE SCREEN.
C
      INTEGER*2 IGOPT
C
$INCLUDE: 'GRFPARM.INC'
$INCLUDE: 'GRAFVAR.INC'
$INCLUDE: 'CURRPLT.INC'
C
      CHARACTER INCHAR*2, RTNCODE*1, RTFLG*1
      INTEGER*2 IOPT
      LOGICAL PAUSEFLG
C
      RTNCODE='0'      
C      
C **DEBUG -- THIS ROUTINE WILL CONTROL THE PLOTTING OF 
C **DEBUG -- MULTIPLE PLOTS PER SCREEN           
      IF (IGRAPH.EQ.3) THEN
C
C          .. SKEWT -- ALL OPTIONS      
         IOPT=IGOPT
         PAUSEFLG=.FALSE.
      ELSE   
         IF (IGOPT.EQ.3) THEN
C         
C             .. REDRAW CURRENT PLOT -- NO PAUSE
            IF (IGRAPH.EQ.2) THEN
C                .. MAP
               IOPT=-1
            ELSE   
C                .. TIMESERIES,WINDROSE 
               IOPT=0
            ENDIF   
            PAUSEFLG=.FALSE.
         ELSE IF (IGOPT.EQ.4) THEN
C             .. TIMESERIES,MAP,WINDROSE -- REDRAW CURRENT SCREEN FOR PRINTING
            IOPT=IGOPT
            PAUSEFLG=.FALSE.
         ELSE
C             .. TIMESERIES,MAP,WINDROSE -- OPTIONS -1,0,1,2
            IOPT=IGOPT
            PAUSEFLG=.TRUE.
         ENDIF   
      ENDIF   
      CALL PCTRL(IOPT,RTNCODE)
C
C       ** RETURN CODE=0 INDICATES NORMAL EXIT FROM ROUTINE 
C                     =1 INDICATES ROUTINE WAS EXITED BY ESC OR F4
C
      IF (RTNCODE.EQ.'0') THEN      
         IF (PAUSEFLG) THEN
C
C             .. PROGRAM PAUSES UNTIL ANY CHARACTER FROM THE KEYBOARD OR
C                ONE OF THE MOUSE BUTTONS IS PRESSED      
            RTFLG = '1'
   50       CONTINUE
            CALL RDLOC(XP,YP,INCHAR,RTFLG)      
            IF (RTFLG.EQ.'1' .AND. (INCHAR.NE.'RE' .AND.
     +                              INCHAR.NE.'4F')) THEN
               GO TO 50
            ENDIF
         ENDIF      
      ELSE IF (RTNCODE.NE.'1' .AND. IGOPT.NE.4) THEN
C
C          ** ERROR MESSAGES ARE PRINTED ONLY IF PLOT GOES TO SCREEN AND
C             AND ROUTINE WAS NOT EXITED WITH ESC/F4
C
         RTFLG = ' ' 
         IF (RTNCODE.EQ.'2') THEN
C             .. ERROR:  NO MORE PLOTS IN FRAME      
            MSGN1=535
         ELSE IF (RTNCODE.EQ.'3') THEN
C             .. ERROR:  PCTRL2 CALLED WITH PLOT TYPE = TIMESERIES(1),
C                        SKEWT(3), OR WINDROSE(4)
            MSGN1=189
         ELSE IF (RTNCODE.EQ.'4') THEN
C             .. ERROR:  PCTRL134 CALLED WITH PLOT TYPE = MAP(2)      
            MSGN1=190
         ELSE IF (RTNCODE.EQ.'5') THEN
C             .. ERROR:  NO DATA AVAILABLE FOR CURRENT PLOT      
            MSGN1=547
         ELSE IF (RTNCODE.EQ.'6') THEN
C             .. ERROR:  FILE WROSPOKE.DEF NOT AVAILABLE TO WINDROSE 
C                        ERROR MESSAGE HANDLED IN ROUTINE WINDROSE      
            GO TO 100
         ELSE IF (RTNCODE.EQ.'7') THEN
C             .. ERROR:  PRESSURE AND/OR HEIGHT VALUES ARE OUT OF SORT
C                        SKEWT COULD NOT DRAW HEIGHT LABELS
            MSGN1=443
            RTNCODE = '0'
         ELSE IF (RTNCODE.EQ.'8') THEN
C             .. ERROR:  NO DATA TO PLOT.  EITHER VALUES ARE MISSING OR 
C                        PRESSURES ARE TOO LOW TO PLOT; A MINIMUM OF TWO 
C                        POINTS WITH PRESSURES GREATER THAN 100 ARE REQUIRED.
            MSGN1=442
            RTNCODE = '0'
         ELSE            
C             .. UNKNOWN RETURN CODE          
            MSGN1=188
            RTFLG = RTNCODE
         ENDIF
         MSGN2=202
         XWIN=.1
         YWIN=.95
         CALL GRAFNOTE(XWIN,YWIN,MSGN1,MSGN2,RTFLG,1,INCHAR)
      ELSE IF (RTNCODE.EQ.'7' .OR. RTNCODE.EQ.'8') THEN
         RTNCODE = '0'   
      ENDIF
  100 CONTINUE      
      RETURN 
      END
