$STORAGE:2
      SUBROUTINE CONMAP(IOPT,STNID,VAL,I1VAL,MXDATROW,NVAL,RTNCODE)
C
C       ** OBJECTIVE:  CONTOUR DATA AND OVERLAY CONTOURS ON A MAP
C                      BACKGROUND
C
C       ** INPUT:
C             IOPT................FLAG TO CONTROL GRAPH PROGRESSION
C                                   -1=REDRAW CURRENT PLOT--REGRID DATA
C                                    0=REDRAW CURRENT PLOT--GRID OK
C                                    1=NEXT PLOT IN CURRENT FRAME  
C                                    2=NEW FRAME
C                                    4=REDRAW CURRENT SCREEN--GRID OK--PRINT
C             STNID...............STATION ID VALUES
C             VAL(1,1)............LATITUDE VALUES -- ONE SET FOR EACH FRAME
C                (1,2)............LONGITUDE VALUES -- ONE SET FOR EACH FRAME
C                (1,3)-(1,N)......VALUES TO BE CONTOURED 
C             I1VAL...............NUMBER OF DATA SETS FROM EACH STATION USED
C                                 FOR CONTOURING IN CURRENT PLOT
C             MXDATROW............NUMBER OF ROWS IN VAL ARRAY
C             NVAL................MAXIMUM NUMBER OF VALUES IN A SET
C             RTNCODE.............ERROR FLAG    '0'= NO ERROR
C                                               '1'= EXIT USING ESC OR F4
C                                               '2'= NO MORE PLOTS IN FRAME
C                                               '5'= NO DATA AVAILABLE FOR 
C                                                    CURRENT PLOT
C      
C       ** ARGUMENTS
C
      REAL*4 VAL(MXDATROW,*)
      INTEGER*2 IOPT
      CHARACTER *(*) STNID(*)
      CHARACTER *1 RTNCODE
      INTEGER*1 I1VAL(*)
C
$INCLUDE: 'GRFPARM.INC'
$INCLUDE:  'GRAFVAR.INC'
C
$INCLUDE:  'CURRPLT.INC'
C
$INCLUDE:  'MAPLAB.INC'
C
C       ** COMMONS FOR MAP AND CONTOUR
C
C      PARAMETER (NDIMSTOR=500,NDIMBOX=60)
      PARAMETER (NDIMSTOR=500,NDIMBOX=150)
      INTEGER*2 NSZSTOR,NSZBOX,ICUR
      COMMON /KWMID3/ NSZSTOR,STOR(2,NDIMSTOR)
      COMMON /KWINER/ NUMBOX,ICUR,BOX(10,NDIMBOX)               
C
      INTEGER*2 CHKUNT,KWUNIT
C
C       ** LOCAL VARIABLES
C
      LOGICAL GRIDOK,NODAT,CPYBKGND,WRSPEC,PRTFLG,RDERR
      INTEGER*2 BTVCFLG,GRDLBON,CONLBON,INDXMP,IERR
      CHARACTER*12 BKGNDNAM
      CHARACTER*35 MSGTXT
C       ** REVISION JML 7-30-93      
      CHARACTER*2 INCHAR
C       .. GRFPARM.INC REQUIRED FOR PARAMETER
      CHARACTER *(LENTXTD) TTLTXT      
C
      IF (IOPT.EQ.-1) THEN
C
C          .. OPTION -1 (REDRAW/REGRID) -- THIS OPTION IS  TREATED LIKE 
C                                 OPTION 0 (REDRAW CURRENT PLOT--GRID OK)
C                                 EXCEPT THAT THE DATA MUST BE REGRIDDED
         PRTFLG=.FALSE.
         MPOPT=0
         GRIDOK = .FALSE.
      ELSE IF (IOPT.EQ.0) THEN
C
C          .. OPTION 0 (REDRAW CURRENT PLOT--GRID OK)
         PRTFLG=.FALSE.
         MPOPT=IOPT
         GRIDOK = .TRUE.
      ELSE IF (IOPT.EQ.4) THEN
C
C          .. OPTION 4 (PRINT) -- THIS OPTION IS CURRENTLY TREATED LIKE 
C                                 OPTION 0 (REDRAW CURRENT PLOT--GRID OK)
C                                 EXCEPT THAT THE BACKGROUND IS DRAWN
         PRTFLG=.TRUE.
         MPOPT=0
         GRIDOK = .TRUE.
      ELSE
C
C          .. OPTIONS 1 (NEXT PLOT IN CURRENT FRAME), 2 (NEW FRAME)
         PRTFLG=.FALSE.
         MPOPT=IOPT
         GRIDOK = .FALSE.
      ENDIF            
C
C       ** INITIAL VARIABLES FOR CURRENT GRAPH OPTION
C
      RTNCODE = '0'
      FRAMWID = MIN0(HICOL,NUMCOL)
      IF (MPOPT.EQ.2) THEN
C          .. NEW FRAME      
         NCA = 0
         NCB = MAX0(LOWCOL-1,2)
         IDPLT = 0
      ENDIF
      IF (MPOPT.GT.0) THEN
C      
C          .. NEW FRAME OR NEXT PLOT IN CURRENT FRAME.
         IF (NCB+1 .GT. MIN0(NCB+PLTWID,FRAMWID)) GO TO 905
         NCA = NCB + 1
         NCB = MIN0(NCB+PLTWID,FRAMWID)
         IDPLT = IDPLT + 1
      ENDIF
C
C       ** INITIAL CONTOUR PLOT      
C
C       .. INITIAL VARIABLES FOR KW CONTOUR ROUTINES     
      ICUR = 1
      NUMBOX = 0
C       .. THESE VARIABLES MUST BE SET FOR THE LINE SEGMENT BUFFER AND
C          TOTAL NUMBER OF LABEL BOXES CREATED FOR THE CONTOURING
      NSZSTOR = NDIMSTOR
      NSZBOX  = NDIMBOX
      CALL KSETLM(NSZSTOR,NSZBOX)
C
C       .. SET CONTOUR BUFFER TO DISK OR MEMORY
C          CHKUNT = 0    MEMORY USE NSZSTOR
C                 = 1    USE DISK - FILE = SCRATCH.CTR
C          KWUNIT = FILE UNIT NUMBER IF CHKUNT = 1
C      
      IF (NSZSTOR.EQ.1) THEN
         CHKUNT = 1
      ELSE   
         CHKUNT = 0
      ENDIF   
      KWUNIT = 38
      CALL KSETBF(CHKUNT,KWUNIT)
C
C       .. DEFINE AXES, WORLD COORDINATES, AND MAP PROJECTION (NDECRT(4))
      CALL BGNCON(GANWLF,GANWRT,GANWBT,GANWTP,BTSCALE
     +           ,LFTSCALE(1,1),NDECRT(4))
C
      IF (PRTFLG) THEN       
C
C          .. PRINT -- BACKGROUND WILL ALWAYS BE DRAWN      
         CPYBKGND = .FALSE.         
      ELSE   
C
C          .. NO PRINT -- BACKGROUND WILL BE COPIED IF PLOT
C             SPECIFICATIONS HAVE NOT CHANGED SINCE SCREEN WAS SAVED
         BKGNDNAM = 'MAPSCRN'
         CALL CKBKGND(BKGNDNAM,CPYBKGND)
C
C          .. CONSTRUCT NAME (8 CHARACTERS) AND EXTENSION FOR BACKGROUND SCREEN
C             FILE; THIS NAME IS USED FOR BOTH READING AND WRITING BACKGROUND
C             SCREEN FILE.
         NCHR = LNG(BKGNDNAM)
         BKGNDNAM(NCHR+1:) = '.GRF'
C
C          ..  IF COPY FLAG IS ON, COPY BACKGROUND TO SCREEN; RESET COPY FLAG
C              TO OFF IF BACKGROUND SCREEN FILE CANNOT BE FOUND
         IF (CPYBKGND) THEN
            CALL RDBKGND(BKGNDNAM,RTNCODE)
            CPYBKGND = RTNCODE.EQ.'0'         
         ENDIF
      ENDIF
      RTNCODE='0'
      IF (.NOT.CPYBKGND) THEN
C  
C          .. SET WORLD COORDINATES FOR CONTOURING
         CALL RESETWOR(1)
C
C          .. DRAW MAP.  MPCODE VALUES >-1 ARE COLORS.  MPCODE POSITIONS:
C                        1=COAST  2=RIVERS  3=BOUNDARIES  4=LAKES  5=STATES
         DO 12 I=1,5
            IF (MPCODE(I).GT.-1) THEN
               CALL DEFHLN(MPCODE(I),YGRDTYP(1),YGRDTHK)
               INDXMP = I
               CALL KWLAND(LOWLON,LOWLAT,HILON,HILAT,INDXMP,IERR)
            ENDIF
C
C             .. EXIT PLOT IF ECS OR F4 ENTERED     
            CALL ESCQUIT(*900)
   12    CONTINUE                  
C
C             .. 'NO PRINT' -- SAVE BACKGROUND SCREEN TO FILE
C                SAVE PLOT SPECIFICATIONS
         IF (.NOT.PRTFLG) THEN
            WRSPEC = .TRUE.
            CALL WRBKGND(WRSPEC,BKGNDNAM)
         ENDIF
      ENDIF
C     
C       .. SET WORLD COORDINATES FOR CONTOURING
      CALL RESETWOR(1)
C      
C       .. DEFINE ATTRIBUTES FOR PLOT BORDER.  DRAW PLOT BORDER.
      LNTYP=1
      CALL DEFHLN(AXSCLR,LNTYP,AXSTHK)
      CALL KWBORD
C      
C       .. NO TIC, GRID, OR LABELS IF XGRDTYP EQUAL TO ZERO
      IF (XGRDTYP(IDPLT).EQ.0 .OR. XMAJBT.EQ.0. 
     +                        .OR. YMAJLFT(1).EQ.0.) THEN
         ITICGRD=0
      ELSE
         ITICGRD = 1
      ENDIF   
      IF (ITICGRD.EQ.1) THEN
         IF (ATXTSIZE.GT.0.) THEN
C
C             .. TIC/GRID LABELS WILL BE DRAWN  
            CALL DEFHST(AXSFONT,AXSCLR,ANG,ATXTASP,ATXTSIZE,TXTSZW)
            TXTDSW  = .5*TXTSZW
            GRDLBON = 1
         ELSE
            TXTSZW  = 0.
            TXTDSW  = 0.   
            GRDLBON = 0
         ENDIF
         IF (XGRDTYP(IDPLT).EQ.-1) THEN
C
C             .. TIC MARKS WILL BE DRAWN.  USE DEFAULT TIC SIZE      
            CALL INQWOR(XW1,YW1,XW2,YW2)
            TICSZW = TICSIZE*(XW2-XW1)
         ELSE
C
C             .. GRID LINES WILL BE DRAWN INSTEAD OF TIC MARKS      
            TICSZW = 0.
         ENDIF   
C      
C       .. DEFINE ATTRIBUTES, DRAW, AND LABEL TIC MARKS (OR GRID)     
C
         BTVCFLG = 1
         LNTYPCUR=ABS(XGRDTYP(IDPLT))
         LNTHKCUR = XGRDTHK
         CALL DEFHLN(XGRDCLR,LNTYPCUR,LNTHKCUR)
C
         CALL KWGRID(BTSCALE(1),LFTSCALE(1,1),BTSCALE(2),LFTSCALE(2,1),
     +               XMAJBT,YMAJLFT(1),XMINBT,YMINLFT(1),    
     +               TICSZW,TXTDSW,TXTSZW,GRDLBON,BTVCFLG)
      ENDIF
C
C       .. SET WORLD COORDINATES FOR LAT/LONG
      CALL RESETWOR(2)
C
C       .. DRAW PLOT TITLE AND SUBTITLE LINES
      IF (GRTITLE.EQ.' ') THEN
         TTLTXT = DATATITLE
      ELSE
         TTLTXT = GRTITLE
      ENDIF      
      NLTITL = 1
      CALL PLTTITL(TTLTXT,NLTITL,TLLOC,TLFONT,TLSIZE,TLASP,TLCLR)
      IF (GRSUBTITLE.EQ.' ') THEN
         IF (PLTWID.EQ.1) THEN
            DATASUB = COLHDR(NCA)
         ELSE
            DATASUB=COLHDR(NCA)
            DO 20 NC=NCA+1,NCB
               ICH=LNG(DATASUB)+1
               DATASUB(ICH:)=', '//COLHDR(NC)
   20       CONTINUE
         ENDIF
         TTLTXT=DATASUB
      ELSE       
         TTLTXT = GRSUBTITLE
      ENDIF      
      NLTITL = 2
      CALL PLTTITL(TTLTXT,NLTITL,STLLOC,STLFONT
     +            ,STLSIZE,STLASP,STLCLR)  
C
C       .. DRAW BOTTOM MARGIN TEXT
      IF (BOTTXT.NE.' ') THEN
         ISIDE=3 
         CALL PLTXMGN(BOTTXT,ISIDE,BTXTLOC
     +               ,BTXTFONT,BTXTSIZE,BTXTASP,BTXTCLR)
      ENDIF
C
C       .. DRAW LEFT MARGIN TEXT
      IF (LFTTXT(1).NE.' ') THEN
         ISIDE = 4
         CALL PLTYMGN(LFTTXT(1),ISIDE,LTXTLOC
     +               ,LTXTFONT,LTXTSIZE,LTXTASP,LTXTCLR)
      ENDIF  
C
C       .. EXIT PLOT IF ECS OR F4 ENTERED     
      CALL ESCQUIT(*900)
C
C       ** DETERMINE IF ROUTINE KONTOUR SHOULD REGRID DATA      
C
      IF (GRIDOK .AND. NCA.EQ.NCB) THEN
C          .. FLAG IS SET TO REPLOT AND ONE SET OF DATA IS CONTOURED
C             DO NOT REGRID DATA IF PLOT WIDTH = 1
         IPASSB = 2
      ELSE
C          .. REGRID DATA; INITIAL ARRAY FOR TABULATING NUMBER OF GOOD DATA
C             POINTS AT STATIONS
         IPASSB = 1
         DO 25 I=1,NVAL
            I1VAL(I)=0.      
   25    CONTINUE
      ENDIF   
C
C       ** REPEAT FOR EACH ELEMENT IN CURRENT PLOT
C      
      CALL KCLPON      
      NODAT=.TRUE.
      DO 100 NC=NCA,NCB
         IPASS=IPASSB
C      
C          .. SET WORLD COORDINATES FOR CONTOURING
         CALL RESETWOR(1)
C
C          .. DEFINE ATTRIBUTES FOR CONTOUR LABELS    
         IF (RTXTSIZE.GT.0) THEN
            CONLBON = 1
            BTVCFLG = 1
            ANG=0.
            CALL DEFHST(RTXTFONT,COL1CLR(NC-2),ANG,
     +                  RTXTASP,RTXTSIZE,CLBHTW)
         ELSE
            CONLBON = 0
         ENDIF   
C         
         LNTYPCUR = COLTYPE(NC-2)
         LNTHKCUR = COLTHK(NC-2)
         CALL DEFHLN(COL1CLR(NC-2),LNTYPCUR,LNTHKCUR)
         IF (IPASS.EQ.1) THEN
            CONMN  = -99999.
            CONMX  =  99999.    
         ENDIF      
         IF (CONINCR(NC-2).EQ.0.) THEN
C
C             .. USER SPECIFIED CONTOUR LEVELS
            CTRVAL = 1.
            NLEV   = 1
            DO 30 I=1,NCONLEV
               CONMN = CONLEV(I)
               CONMX = CONMN
               CALL KONTOUR(VAL(1,1),VAL(1,2),VAL(1,NC),I1VAL,NVAL,
     +            IPASS,NLEV,CTRVAL,CONMN,CONMX,
     +            CONLBON,NDECRT(1),BTVCFLG,CLBHTW,NCONPTS,RDERR,KONERR)
               IPASS=2
   30       CONTINUE
         ELSE IF (CONINCR(NC-2).LT.0.) THEN
C
C             .. USER SPECIFIED NUMBER OF CONTOUR LEVELS.  MIN/MAX CONTOUR
C                LEVELS AND CONTOUR INCREMENT DETERMINED FROM DATA
            CTRVAL = -99999.
            NLEV = NINT(ABS(CONINCR(NC-2)))
            CALL KONTOUR(VAL(1,1),VAL(1,2),VAL(1,NC),I1VAL,NVAL,
     +           IPASS,NLEV,CTRVAL,CONMN,CONMX,
     +           CONLBON,NDECRT(1),BTVCFLG,CLBHTW,NCONPTS,RDERR,KONERR)
         ELSE
C
C             .. USER SPECIFIED CONTOUR INCREMENT.  MIN/MAX CONTOUR
C                LEVELS DETERMINED FROM DATA
            CTRVAL = CONINCR(NC-2)
            CALL KONTOUR(VAL(1,1),VAL(1,2),VAL(1,NC),I1VAL,NVAL,
     +           IPASS,NCONLEV,CTRVAL,CONMN,CONMX,
     +           CONLBON,NDECRT(1),BTVCFLG,CLBHTW,NCONPTS,RDERR,KONERR)
         ENDIF 
         IF (RDERR) THEN
            XWIN=.1
            YWIN=.95
            MSGN1=191
            MSGN2=202
            MSGTXT = '  O:\CONCTRL.PRM'
            CALL GRAFNOTE(XWIN,YWIN,MSGN1,MSGN2,MSGTXT,16,INCHAR)
         ENDIF
C         
C ** REVISION ** (JML 07-30-93)
C    ADD KONERR TO CALLS TO KONTOUR; ADD ERROR MESSAGE    
         IF (KONERR.GT.0) THEN
            XWIN=.1
            YWIN=.95
            MSGN1=508
            MSGN2=202
            WRITE(MSGTXT,'(A,1X,I2)')'System error in KWWEVR.  ERROR=',
     +                                KONERR
            CALL GRAFNOTE(XWIN,YWIN,MSGN1,MSGN2,MSGTXT,34,INCHAR)
         ENDIF
         NODAT = NODAT .AND. NCONPTS.LE.1
C
C          .. EXIT PLOT IF ESC OR F4 ENTERED     
         CALL ESCQUIT(*900)
  100 CONTINUE
C
C       .. SET WORLD COORDINATES FOR LAT/LONG
      CALL RESETWOR(2)
C      
      IF (NODAT) GO TO 910
C
C          .. PLOT MARKER AT STATION LOCATION
C             COLAXIS----MARKER TYPE   0=NO MARKER   1=CHARACTER MARKER
C                                      2=STATION ID  3=NBR GOOD DATA POINTS
C             NDECRT(3)--MARKER FONT
C             YMAJRT(1)--MARKER SIZE
C             YMAJRT(2)--MARKER ASPECT RATIO
C             COL2CLR----MARKER COLOR
C             NDECRT(1)--NUMBER OF DECIMAL PLACES IN DATA TEXT; EQUAL TO
C                        THE NUMBER OF DECIMAL PLACES IN CONTOUR LABEL
      CALL CHRPLT(VAL(1,2),VAL(1,1),VAL(1,NCA),I1VAL,STNID,NVAL,
     +            COLAXIS(IDPLT),NDECRT(3),YMAJRT(1),YMAJRT(2),
     +            COL2CLR(IDPLT),NDECRT(1))
C
C       ** DRAW FREE TEXT -- LOCATION MUST BE SPECIFIED
C
      NLTITL = 3
      CALL PLTTITL(FTXT,NLTITL,FTXTLOC,FTXTFONT,FTXTSIZE,FTXTASP,
     +             FTXTCLR)
C
C       ** DRAW LEGEND
C
      LGBRDR='Y'
      LGALIGN=0
      I=0
      DO 105 NC=NCA,NCB
         I=I+1      
         LGLINBAR(I)='L'
         LGITMWID(I)=FLOAT(COLTHK(NC-2))
         LGCOLR(I)=COL1CLR(NC-2)
         LGTEXT(I)=COLHDR(NC)
         LGSTYL(I)=COLTYPE(NC-2)
  105 CONTINUE      
      LGNTRY=I
C
C          ..CALCULATE LEGEND LOCATION AND SAVE POSITION
      IF (LEGLOC(1).EQ.-99999.) THEN  
         XCW = BTSCALE(1) + .75*(BTSCALE(2)-BTSCALE(1))
         YCW = LFTSCALE(1,1) + .90*(LFTSCALE(2,1)-LFTSCALE(1,1))
         CALL W2NW(XCW,YCW,LEGLOC(1),LEGLOC(2))
      ENDIF   
C   
      CALL DRWLGND(LEGEND,LGBRDR,LGNTRY,LGLINBAR,LGSTYL,LGITMWID,
     +             LGCOLR,LGTEXT,LEGCLR,LEGFONT,
     +             LEGSIZE,LEGLOC,LEGASP,LGALIGN)
C      
      RETURN
C
C       ** ERROR PROCESSING
C
  900 CONTINUE
C       .. PREMATURE EXIT USING ESC OR F4  
      RTNCODE = '1'
      GO TO 990
  905 CONTINUE  
C       .. ERROR:  NO MORE PLOTS IN THIS FRAME
      RTNCODE='2'
      GO TO 990
  910 CONTINUE  
C       .. ERROR:  NO DATA AVAILABLE FOR CURRENT PLOT
      RTNCODE='5'
  990 RETURN
C  
      END
C
C
C
      SUBROUTINE BGNCON(GANWLF,GANWRT,GANWBT,GANWTP,XSCALE,YSCALE,
     +                  IMAPPRJ)
C
C       ** OBJECTIVE:  SET UP WORLD COORDINATE SYSTEMS FOR CONTOURING
C                      AND LAT/LONG      
C
C       ** INPUT:
C             GANWLF........X-COORDINATE OF LEFT EDGE OF PLOT AREA
C             GANWRT........X-COORDINATE OF RIGHT EDGE OF PLOT AREA
C             GANWBT........Y-COORDINATE OF BOTTOM EDGE OF PLOT AREA
C             GANWTP........Y-COORDINATE OF TOP EDGE OF PLOT AREA
C             XSCALE(1).....MINIMUM LONGITUDE VALUE OF X
C                   (2).....MAXIMUM LONGITUDE VALUE OF X
C             YSCALE(1).....MINIMUM LATITUDE VALUE OF Y
C                   (2).....MAXIMUM LATITUDE VALUE OF Y
C             IMAPPRJ.......FLAG TO INDICATE TYPE OF MAP PROJECTION
C                           0=MILLER  1=SCREEN
C
C       ** NOTE:  GRAPH AXIS(GA) COORDINATES ARE GIVEN IN NORMALIZED WORLD
C                 COORDINATES.  THE VALUES FOR THE VIEWPORT CAN RANGE
C                 BETWEEN 0 AND 1.  THE PLOT AREA IS A PORTION OF THE
C                 VIEWPORT. 
C
$INCLUDE: 'MAPLAB.INC'
C
      REAL*4  XSCALE(2),YSCALE(2)
C
C       .. SET UP CONTOURING WORLD COORDINATE SYSTEM
C
C **DEBUG  CTRLON SHOULD BE ALLOWED TO VARY
      CTRLON = 0.0
C
      CALL KSETUP(IMAPPRJ,GANWLF,GANWRT,GANWBT,GANWTP,
     +     XPLTSZ,YPLTSZ,XPLTCEN,YPLTCEN,XKWMX,YKWMX)
C
      CALL KWAREA(XPLTSZ,YPLTSZ,XPLTCEN,YPLTCEN,
     +            XSCALE(1),YSCALE(1),XSCALE(2),YSCALE(2),CTRLON)
C
C       .. SAVE CONTOURING WORLD COORDINATE SYSTEM      
C
      CALL RESETWOR(-1)
C
C       .. GET LIMITS OF PLOT AREA.  INITIAL LAT/LONG WORLD
C          COORDINATE SYSTEM      
C
      CALL KWINQL(XKW1,YKW1,XKW2,YKW2)
      XNW1 = XKW1/XKWMX
      XNW2 = XKW2/XKWMX
      YNW1 = YKW1/YKWMX
      YNW2 = YKW2/YKWMX
C
      XORIGIN=XSCALE(1)
      YORIGIN=YSCALE(1)            
      CALL BGNPLT(XNW1,XNW2,YNW1,YNW2,XSCALE,YSCALE,XORIGIN,YORIGIN)
C
C       .. SAVE LAT/LONG WORLD COORDINATE SYSTEM      
      CALL RESETWOR(-2)
C
      RETURN
      END      
C
C
C
      SUBROUTINE RESETWOR(ISETFLG)
C
C       ** OBJECTIVE:  SAVE THE CURRENT WORLD COORDINATE SYSTEM.  SET THE
C                      WORLD COORDINATE SYSTEM TO THE SPECIFIED VALUE.      
C       ** INPUT:
C              ISETFLG....ABSOLUTE VALUE INDICATES THE ID OF THE WORLD
C                         COORDINATE SYSTEM (WCS)
C                            <0=SAVE THE CURRENT WCS USING THE SPECIFIED ID
C                            >0=SET THE SPECIFIED WCS 
C
      COMMON /SAVWOR/ XW1SV(2),YW1SV(2),XW2SV(2),YW2SV(2)      
C            
      IF (ISETFLG.LT.0) THEN
C
C          .. SAVE THE CURRENT WORLD COORDINATE SYSTEM       
         ID=IABS(ISETFLG)
         CALL INQWOR(XW1SV(ID),YW1SV(ID),XW2SV(ID),YW2SV(ID))
      ELSE IF (ISETFLG.LE.2 .AND. ISETFLG.NE.0) THEN
C
C          .. SET THE SPECIFIED WORLD COORDINATE SYSTEM      
         ID=ISETFLG
         CALL SETWOR(XW1SV(ID),YW1SV(ID),XW2SV(ID),YW2SV(ID))
      ENDIF
C
      RETURN
      END  
C
C
C    
      SUBROUTINE KONTOUR(YLAT,XLON,DATVAL,I1KNTDAT,NUMPTS,IPASS,NCONLEV,
     +              CTRVAL,CONMN,CONMX,
     +              CONLBON,NCONDEC,BTVCFLG,CLBHTW,NCONPTS,RDERR,KONERR)
C
C       ** OBJECTIVE:  CONTOUR DATA AT THE GIVEN LAT/LONG POSITIONS
C
C ** REVISION ** (JML 07-30-93)
C    ADD KONERR TO CALLING ARGUMENTS   
C
C       ** INPUT:    
C              YLAT.......LATITUDE VALUES
C              XLON.......LONGITUDE VALUES
C              DATVAL.....DATA VALUES
C              I1KNTDAT...NUMBER OF GOOD DATA POINTS AT EACH STATION
C              NUMPTS.....NUMBER OF INPUT DATA VALUES
C              IPASS......NUMBER OF CALLS TO THIS ROUTINE WITH CURRENT DATA
C              NCONLEV....NUMBER OF CONTOUR LEVELS FOR CURRENT CALL
C              CTRVAL.....INCREMENT BETWEEN CONTOUR LEVELS
C              CONMN......MINIMUM VALUE TO BE CONTOURED
C              CONMX......MAXIMUM VALUE TO BE CONTOURED
C              CONLBON....
C              NCONDEC....
C              BTVCFLG....
C              CLBHTW.....CONTOUR LABEL HEIGHT IN WORLD COORDINATES
C
C       ** OUTPUT:
C              NCONPTS....NUMBER OF POINTS ACTUALLY CONTOURED
C              RDERR......
C
      REAL*4 YLAT(*),XLON(*),DATVAL(*)
      INTEGER*1 I1KNTDAT(NUMPTS)
C      
      CHARACTER*24 FILEIN
C
      INTEGER*4 IXYD 
      PARAMETER (IXSIZD=50,IYSIZD=IXSIZD,IXYD=IXSIZD*IYSIZD)
      COMMON /DUM1/ T(IXSIZD,IYSIZD)
      COMMON /DUM2/ W(IXSIZD,IYSIZD)
C
      INTEGER*1 ICUT
      COMMON /KWCHP2/ ICUT(IXSIZD,IYSIZD)
C
$INCLUDE:  'PLTSPEC.INC'      
C
      INTEGER*2 MAXSIZ,IXSIZ,IYSIZ,BTVCFLG,CONLBON,NCONDEC,IUNIT
      INTEGER*2 IFLG,IXCUT,IYCUT
      LOGICAL RDERR
C
      RDERR = .FALSE.
      IF (IPASS.EQ.1) THEN
         RDERR = .TRUE.
         FILEIN = 'O:\DATA\CONCTRL.PRM'
         OPEN (UNIT=10,FILE=FILEIN,ACCESS='SEQUENTIAL')
C          .. READ LINE 5 OF THE FILE         
         DO 20 I=1,4
            READ(10,*,ERR=25)
   20    CONTINUE            
         READ (10,*,ERR=25)   SMOOTH,PLTINC
C          .. READ LINE 20 OF THE FILE         
         DO 22 I=1,14
            READ(10,*,ERR=25)
   22    CONTINUE            
         READ (10,*,ERR=25)   IFLG,IXCUT,IYCUT
         RDERR=.FALSE.
   25    CONTINUE       
         CLOSE(10)
         IF (RDERR) THEN
            SMOOTH=2.0
            PLTINC=0.5
            IFLG=0
            IXCUT=0
            IYCUT=0
         ENDIF
C
         MAXSIZ = IXSIZD
         CALL RETLIM(YLAT,XLON,DATVAL,I1KNTDAT,NUMPTS,MAXSIZ,
     +               IXSIZ,IYSIZ,NCONPTS,XMNLON,YMNLAT,XMXLON,YMXLAT)
         IF (NCONPTS.GT.1) THEN
            CALL  REDATA(YLAT,XLON,DATVAL,T,W,
     +                   XMNLON,YMNLAT,XMXLON,YMXLAT,
     +                   IXSIZ,IYSIZ,NUMPTS,CONMN,CONMX)
C
C             **  BEGIN CONTOURING
C
            SAMPLE = 0.0
            CALL KWINTC(XMNLON,YMNLAT,XMXLON,YMXLAT,IXSIZ,IYSIZ,
     +                  SAMPLE,SMOOTH,PLTINC,CLBHTW,BTVCFLG)
C
            IUNIT=69
C ** REVISION ** (JML 07-30-93)
C    ADD KONERR TO CALLING ARGUMENTS TO KWWEVR
            KONERR = 0
            CALL KWWEVR(T,W,ICUT,IXSIZ,IYSIZ,IUNIT,IFLG,IXCUT,IYCUT,
     +                  KONERR)
C DEBUG      .. PLOT INTERPOLATED FIELD ON MAP         
CCC         CALL KWFIELD(T,W,ICUT,IXSIZ,IYSIZ,XMNLON,YMNLAT,XMXLON,YMXLAT)
         ENDIF
      ENDIF
C      
      IF (NCONPTS.GT.1) THEN
C            ICMN = CONMN
C            ICMX = CONMX
C            CONMN= ICMN
C            CONMX= ICMX
         IF (CTRVAL.EQ.-99999.) THEN
C **DEBUG
C            CTRVAL = AINT(10.*(CONMX-CONMN)/FLOAT(NCONLEV))/10.
            CTRVAL = (CONMX-CONMN)/FLOAT(NCONLEV)
         ENDIF
C         ICVAL = CTRVAL
C         CTRVAL= ICVAL
         CALL KWMICN(CONLBON,NCONDEC,CONMN,CONMX,CTRVAL,T,W)
      ENDIF    
C
      RETURN
      END
C
C
C
      SUBROUTINE REDATA(YLAT,XLON,DATVAL,T1,W1,
     +                  XMNDAT,YMNDAT,XMXDAT,YMXDAT,
     +                  IXSIZ,IYSIZ,NUMPTS,CONMN,CONMX)
C
      INTEGER*2 IXSIZ,IYSIZ,NUMPTS
      REAL*4 YLAT(*),XLON(*),DATVAL(*)
      REAL*4 T1(IXSIZ,IYSIZ)
C      INTEGER*2  W1(IXSIZ,IYSIZ)
      REAL*4  W1(IXSIZ,IYSIZ)
C
$INCLUDE:  'PLTSPEC.INC'      
C
      LOGICAL GETMNMX
C
      GETMNMX = CONMN.NE.CONMX      
C
      DO 25 IY = 1,IYSIZ
         DO 20 IX = 1,IXSIZ
            T1(IX,IY) = 0.0
            W1(IX,IY) = 0.0
   20    CONTINUE
   25 CONTINUE
C
      IF (GETMNMX) THEN
         CONMN  =  99999.0
         CONMX  = -99999.0
      ENDIF   
C
      XDIF = XMXDAT - XMNDAT
      YDIF = YMXDAT - YMNDAT
C
      DO 110 I=1,NUMPTS
         IF (DATVAL(I).EQ.-99999.) GO TO 110
         X1 = XLON(I)
         Y1 = YLAT(I)
         IX = ABS( ((X1-XMNDAT)/XDIF)*(IXSIZ) ) + 1 
         IY = ABS( ((Y1-YMNDAT)/YDIF)*(IYSIZ) ) + 1
         IX = AMAX1(IX,1)
         IY = AMAX1(IY,1)
         IX = AMIN1(IX,IXSIZ)
         IY = AMIN1(IY,IYSIZ)
         T1(IX,IY) = DATVAL(I)
         W1(IX,IY) = 1.0
         IF (GETMNMX) THEN
            CONMX = AMAX1(CONMX,DATVAL(I))
            CONMN = AMIN1(CONMN,DATVAL(I))
         ENDIF
  110 CONTINUE
C  
      RETURN
      END 
C
C KW 6/7/91    SUBROUTINE TO FIND MIN - LON/LAT &  MAX -LON/LAT
C              THIS WILL RETURN THE IXSIZ,IYSIZ FOR ARRAY 
C              AND MAIN/MAX VALUES
C
      SUBROUTINE RETLIM(YLAT,XLON,DATVAL,I1KNTDAT,NUMPTS,MAXSIZ,
     +                  IX,IY,NCONPTS,XMNDAT,YMNDAT,XMXDAT,YMXDAT)
C
      INTEGER*2 IX,IY,MAXSIZ,NUMPTS
      INTEGER*1 I1KNTDAT(*)
      REAL*4 YLAT(*),XLON(*),DATVAL(*)
            
C
$INCLUDE:  'PLTSPEC.INC'      
C
      IX     = MAXSIZ
      IY     = MAXSIZ
      NCONPTS = 0
      XMNDAT =  99999.0
      YMNDAT =  99999.0
      XMXDAT = -99999.0
      YMXDAT = -99999.0
C
      DO 100 I=1,NUMPTS
         IF (DATVAL(I).EQ.-99999.) GO TO 100
         I1KNTDAT(I) = I1KNTDAT(I) + 1
C
         XMNDAT = AMIN1(XLON(I),XMNDAT)
         XMXDAT = AMAX1(XLON(I),XMXDAT)
         YMNDAT = AMIN1(YLAT(I),YMNDAT)
         YMXDAT = AMAX1(YLAT(I),YMXDAT)
C
         NCONPTS = NCONPTS + 1
  100 CONTINUE
      IF (NCONPTS.LE.1) GO TO 120
      XDIF = XMXDAT - XMNDAT
      YDIF = YMXDAT - YMNDAT
      IF (XDIF.EQ.0 .OR. YDIF.EQ.0) THEN
         NCONPTS=0
         GO TO 120
      ENDIF
C
C      XDIF = XMXDAT - XMNDAT
C      YDIF = YMXDAT - YMNDAT
C
      IF (XDIF.GT.YDIF) THEN
          SCL = YDIF / XDIF
          IF (SCL.LE.0) SCL = 1
          IY  = MAX0(11,NINT(MAXSIZ*SCL))
C          IY  = MAXSIZ*SCL
      ELSE
          SCL = XDIF / YDIF
          IF (SCL.LE.0) SCL = 1
          IX  = MAX0(11,NINT(MAXSIZ*SCL))
C          IX  = MAXSIZ*SCL
      ENDIF
C
  120 CONTINUE
      RETURN
      END 
C
C
C
      SUBROUTINE CHRPLT(VALX,VALY,VALD,I1KNTDAT,STNID,NVAL,
     +                  IFLG,IDFONT,CHRHTNW,CHRASP,KLRCHR,NDECDAT)
C
C       ** OBJECTIVE:  PLOT A CHARACTER STRING AT THE GIVEN X-Y VALUES
C
C       ** INPUT:
C             VALX.......ARRAY OF X_VALUES 
C             VALY.......ARRAY OF Y_VALUES
C             VALD.......ARRAY OF DATA VALUES
C             I1KNTDAT...NUMBER OF GOOD DATA POINTS AT EACH STATION
C             STNID......ARRAY OF STATION ID'S
C             NVAL.......NUMBER OF STATIONS
C             IFLG.......FLAG INDICATING TYPE OF STATION MARKER
C                          0=NO STATION MARKER
C                          1=PLOT SAME CHARACTER MARKER AT ALL STATIONS
C                          2=PLOT STATION ID
C                          3=PLOT NUMBER OF GOOD DATA POINTS AT STATION 
C             IDFONT.....INDEX TO THE ARRAY OF AVAILABLE STROKE TEXT FONTS
C             CHRHTNW....CHARACTER HEIGHT IN NORMALIZED WORLD COORDINATES
C             CHRASP.....ASPECT RATIO FOR PLOTTING TEXT
C             KLRCHR.....CHARACTER COLOR ID NUMBER
C             NDECDAT....NUMBER OF DECIMAL PLACES FOR DATA VALUE TEXT
C
      REAL *4 VALX(*),VALY(*),VALD(*)
      INTEGER*1 I1KNTDAT(*)
      INTEGER*4 IP
      CHARACTER*(*) STNID(*)
C
$INCLUDE:  'PLTSPEC.INC'
C
$INCLUDE:  'MAPLAB.INC'
C      
      CHARACTER OUTSTR*3,MARKER*1,CHRNBR*1
      DATA MARKER/'X'/
C  
C       ** TEXT AT DATA POINTS IS PLOTTED IN WORLD COORDINATES FOR CONTOURING
C          CHARACTER ATTRIBUTES MUST BE DEFINED UNDER THIS COORDINATE SYSTEM
C
         CALL RESETWOR(1)
C
C       ** DEFINE CHARACTER ATTRIBUTES
C
      LNTYP=1
      LNTHK=1
      CALL DEFHLN(KLRCHR,LNTYP,LNTHK)
      ANG = 0.
      CALL DEFHST(IDFONT,KLRCHR,ANG,CHRASP,CHRHTNW,CHRHTW)
      CALL SETSTA(ANG)
      IF (IFLG.EQ.0) THEN
C
C          .. DO NOT PLOT STATION MARKERS
         GO TO 100
      ELSE IF (IFLG.EQ.1) THEN    
C
C          .. PLOT ONE MARKER AT ALL THE POINTS      
         DO 20 N=1,NVAL
            IF (I1KNTDAT(N).EQ.0) GO TO 20
            IF ((VALX(N).GE.XMIN .AND. VALX(N).LE.XMAX).AND.
     +          (VALY(N).GE.YMIN .AND. VALY(N).LE.YMAX)) THEN
               CALL DRWTXTKW(VALX(N),VALY(N),MARKER)
            ENDIF
   20    CONTINUE
      ELSE IF (IFLG.EQ.2) THEN
C
C          .. PLOT STATION ID AT EACH POINT         
         DO 30 N=1,NVAL
            IF (I1KNTDAT(N).EQ.0) GO TO 30
            IF ((VALX(N).GE.XMIN .AND. VALX(N).LE.XMAX).AND.
     +          (VALY(N).GE.YMIN .AND. VALY(N).LE.YMAX)) THEN
               CALL DRWTXTKW(VALX(N),VALY(N),STNID(N))
            ENDIF   
   30    CONTINUE
      ELSE IF (IFLG.EQ.3) THEN
C
C          .. PLOT DATA VALUES AT EACH POINT      
         DO 35 N=1,NVAL
            IF (VALD(N).EQ.-99999.) GO TO 35
            IF ((VALX(N).GE.XMIN .AND. VALX(N).LE.XMAX).AND.
     +          (VALY(N).GE.YMIN .AND. VALY(N).LE.YMAX)) THEN
               CALL KWTXTNM(VALX(N),VALY(N),VALD(N),NDECDAT)
            ENDIF
   35    CONTINUE
      ELSE
C
C          .. PLOT NUMBER OF DATA POINTS AT EACH STATION
         CALL GETWASP(WASP)
         DO 40 N=1,NVAL
            IF (I1KNTDAT(N).EQ.0) GO TO 40
            IF ((VALX(N).GE.XMIN .AND. VALX(N).LE.XMAX).AND.
     +          (VALY(N).GE.YMIN .AND. VALY(N).LE.YMAX)) THEN
C                .. DRAW NUMBER STRING 
               WRITE(CHRNBR,'(I1)') I1KNTDAT(N)
               CALL DRWTXTKW(VALX(N),VALY(N),CHRNBR)
C                .. CONVERT LAT/LON VALUES TO CONTOURING COORDINATES
               XX      = VALX(N)
               YY      = VALY(N)
               IP      = -3                 
               CALL KWTRAN (XX,YY,IP) 
               CALL SCLCON(XX,YY,XKW,YKW)
               XKW = XPLTCEN+XKW
               YKW = YPLTCEN+YKW
C                .. DRAW CIRCLE AROUND NUMBER               
               CALL DELIMSTR(CHRNBR,OUTSTR)
               CALL INQSTS(OUTSTR,HEIGHT,WIDTH,OFFSET)
               RAD = 1.1*(.5*AMAX1(HEIGHT/WASP,WIDTH))
               CALL MOVABS(XKW,YKW)
               CALL CIR(RAD)
            ENDIF   
   40    CONTINUE
      ENDIF
C
  100 CONTINUE
C          .. SET WORLD COORDINATES FOR LAT/LONG
      CALL RESETWOR(2)
      RETURN
      END   
      SUBROUTINE DRWTXTKW(X1,Y1,STR)
C
C       ** OBJECTIVE:  CENTER AND PLOT THE INPUT STRING AT THE SPECIFIED
C                      X,Y COORDINATES.  STRING POSITION IS GIVEN IN LAT
C                      LONG COORDINATES AND WILL BE PLOTTED IN THE WORLD
C                      COORDINATE SYSTEM USED FOR CONTOURING. 
      CHARACTER*(*)STR
      INTEGER*2 ICNTR,BTVCFLG
      INTEGER*4 IP
C
C       ** CONVERT LAT/LON VALUES TO CONTOURING COORDINATES
C
      XX      = X1
      YY      = Y1
      IP      = -3                 
      CALL KWTRAN (XX,YY,IP) 
      CALL SCLCON(XX,YY,XBCK,YBCK)
C
C       ** PLOT STRING -- STRING WILL BE CENTERED AT THE SPECIFIED POSITION
C                         CHRHT IS A DUMMY VALUE; CHARACTER ATTRIBUTES MUST
C                         BE SET BEFORE THIS ROUTINE IS CALLED.
C
      NCHAR   = LNG(STR)
      ICNTR   = 1
      ANG     = 0.
      CHRHT   = 0.
      BTVCFLG = 1
      CALL KWLAB (STR,XBCK,YBCK,NCHAR,ICNTR,ANG,CHRHT,BTVCFLG)
C
      RETURN
      END 
