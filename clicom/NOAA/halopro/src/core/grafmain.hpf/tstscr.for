$STORAGE:2
      PROGRAM TSTSCR
      CHARACTER*40 STRING
      CHARACTER INCHAR*2
      INTEGER*2 IDUM(16)
C      
      IDFONT  = 9
      STRASP  = 1.
      TXTHTND = .65
      ICLR    = 5
      XPOS    = .01
      YPOS    = .1
C
      OPEN(999,FILE='BUGTXT.PRT')
      CALL BGNHALO(0,0,IDUM)
C
      CALL SETVIE(0.,0.,0.999,0.999,-1,-1)
      CALL SETWOR(0.,0.,1.,1.)
      CALL INQASP(RETASP)
      WRITE(999,*) 'TSTSCR--RETASP=',RETASP
      STRING = '^XXX^'
      IASPFLG=0
      ADJASP=0
      CALL DFHSTWIN(IDFONT,ICLR,TXTHTND,IASPFLG,STRASP,ADJASP)
C      
      CALL INQSTS(STRING,HGHT,WID,OFF)
C      
      CALL INQVIE(XNDUL,YNDUL,XNDLR,YNDLR)
      CALL INQWOR(XWLL,YWLL,XWUR,YWUR)
      CALL MAPNTD(XNDUL,YNDUL,IXDUL,IYDUL)
      CALL MAPNTD(XNDLR,YNDLR,IXDLR,IYDLR)
      XRATIO = (IXDLR-IXDUL+1)/(XWUR-XWLL)
      IWID = WID * XRATIO
C      
      WRITE(999,*)'IXDLR,IXDUL,IYDLR,IYDUL=',IXDLR,IXDUL,IYDLR,IYDUL
      WRITE(999,*)'XWLL,YWLL,XWUR,YWUR=',XWLL,YWLL,XWUR,YWUR
      WRITE(999,*)'IWID,XRATIO',IWID,XRATIO
      WRITE(999,*)'HGHT,WIDSTR,OFFSET=',HGHT,WID,OFF
C
      CALL DEFWIN(HGHT,WID,OFF)      
      CALL DFWINASP(STRING,IDFONT,ICLR,TXTHTND,ADJASP,WINASP)
C      
C      
      XPOS    = .01
      YPOS    = .01
      CALL MOVTCA(XPOS,YPOS)
      CALL DELTCU( )
      CALL STEXT(STRING)
      READ(*,'(A)') INCHAR
C
  100 CONTINUE
      CALL FINHALO
      WRITE(*,*)'NORMAL STOP '
      STOP ' '
C 
  900 CONTINUE
      CALL FINHALO
      WRITE(*,*)'ERROR STOP '
      STOP 1
      END
***************************************************************************
      SUBROUTINE DFHSTWIN(IDFONT,ICLR,TXTHTND,IASPFLG,TXTASP,ADJASP)
C
C       ** OBJECTIVE:  DEFINE HALO ATTRIBUTES FOR STROKE TEXT THAT
C                      WILL BE USED IN A WINDOW
C
C       **INPUT:            
C            IDFONT.....ID NUMBER OF STROKE TEXT FONT
C            ICLR.......TEXT COLOR NUMBER
C            IASPFLG....FLAG TO INDICATE THE ASPECT RATIO TO USE WHEN
C                       DEFINING THE STROKE TEXT
C                       0=CALCULATE ADJASP FROM TXTASP
C                       1=USE THE VALUE OF ARGRMENT ADJASP
C            TXTHTND....HEIGHT OF TEXT IN NORMALIZED DEVICE COORDINATE UNITS
C            TXTASP.....TEXT ASPECT RATIO FOR CURRENT COORDINATE SYSTEM
C                       
C       **OUTPUT:
C
      COMMON/DEVHNDL/IHNDLSCR,IHNDLVRI,SCRNASP,VRIASP,DEVASP
C      
      PARAMETER (MXFONT=9)
      CHARACTER*3 STFONT(MXFONT)
      CHARACTER*26 FONTFIL
      INTEGER*2 IXPIX,IYPIX
      DATA FONTFIL /'^P:\HALO\FONTS\AHD000.FNT^'/
      DATA STFONT /'104','102','106','107','201','203','206',
     +             '405','406'/
C
C       ** CONVERT CHARACTER HEIGHT FROM NORMALIZED DEVICE TO
C          WORLD COORDINATES        
C
C **DEBUG
      WRITE(999,*)'BEGIN DFHSTWIN'
      WRITE(999,*)'IASPFLG,TXTASP,ADJASP=',IASPFLG,TXTASP,ADJASP
C **END DEBUG      
      CALL INQVIE(XNDUL,YNDUL,XNDLR,YNDLR)
      CALL INQWOR(XWLL,YWLL,XWUR,YWUR)
C **DEBUG
      WRITE(999,*)'XNDUL,YNDUL,XNDLR,YNDLR=',XNDUL,YNDUL,XNDLR,YNDLR
      WRITE(999,*)'XWLL,YWLL,XWUR,YWUR=',XWLL,YWLL,XWUR,YWUR
C **END DEBUG      
C
C       .. CALCULATE HEIGHT IN WORLD COORDINATES
C
      CALL MAPNTW(XNDUL,YNDUL,XWUL,YWUL)
      CALL MAPNTW(XNDUL,YNDUL+TXTHTND,XWUL,YW)
      YHTW = YWUL-YW
C      
C       .. CALCULATE HEIGHT IN DEVICE COORDINATES (PIXELS)
      CALL MAPNTD(XNDUL,YNDUL,IXD,IYDUL)
      CALL MAPNTD(XNDUL,YNDUL+TXTHTND,IXD,IYD)
      IYHTD = (IYD-IYDUL)
C**DEBUG
      CALL INQASP(DASPINQ)
      CALL INQDRA(IXPIX,IYPIX)
C
      IF (IASPFLG.EQ.0) THEN
         CALL MAPNTD(XNDUL,YNDUL,IXDUL,IYDUL)
         CALL MAPNTD(XNDLR,YNDLR,IXDLR,IYDLR)
         WRITE(999,*)'IXDLR,IXDUL,IYDLR,IYDUL=',IXDLR,IXDUL,IYDLR,IYDUL
         CURPXFAC = REAL(IXDLR-IXDUL+1)/REAL(IYDLR-IYDUL+1)
         VGAPXFAC = (((XNDLR-XNDUL)*639)+1)/(((YNDLR-YNDUL)*479)+1)
         PXFAC = CURPXFAC/VGAPXFAC

         ASPFAC = PXFAC
         ADJASP = TXTASP*ASPFAC
         WRITE(999,*)'CURPXFAC,VGAPXFAC=',CURPXFAC,VGAPXFAC
         WRITE(999,*)'ASPFAC,IXPIX,IYPIX=',ASPFAC,IXPIX,IYPIX
      ENDIF   
C
        WRITE(999,*)'IXD,IYDUL,IYD,IYHTD=',IXD,IYDUL,IYD,IYHTD
        WRITE(999,*)'THTND,YWUL,YW=',TXTHTND,YWUL,YW
        WRITE(999,*)'DASPINQ,DEVASP=',DASPINQ,DEVASP
        WRITE(999,*)'TXTASP,ADJASP,YHTW=',TXTASP,ADJASP,YHTW
C      
C       ** DEFINE STROKE TEXT ATTRIBUTES
C
      FONTFIL(19:21) = STFONT(IDFONT)
      IPATH = 0
      CALL SETLNW(1)
      CALL SETLNS(1)
      CALL SETHAT(1)
      CALL SETFON(FONTFIL)
      CALL SETSTC(ICLR,ICLR)
      CALL SETDEG(1)
      CALL SETSTE(YHTW,ADJASP,IPATH)            
C
      WRITE(999,*)'END DFHSTWIN'
      RETURN
      END       
**************************************************************************
      SUBROUTINE DEFWIN(HGHT,WID,OFF)
      REAL*4 HGHT, WID, OFF
      DATA XWNBG,YWNBG/.05,.2/
C
      XW = WID
C      YW = HGHT+.2*OFF
      YW = HGHT
C      
      CALL INQVIE(XNDUL1,YNDUL1,XNDLR1,YNDLR1)
      CALL INQWOR(XWLL,YWLL,XWUR,YWUR)
C
      WRITE(999,*)'BEGIN DEFWIN XW,YW=',XW,YW
      WRITE(999,*)'XNDUL1,YNDUL1,XNDLR1,YNDLR1=',
     +             XNDUL1,YNDUL1,XNDLR1,YNDLR1
      WRITE(999,*)'XWLL,YWLL,XWUR,YWUR=',XWLL,YWLL,XWUR,YWUR
C      
      CALL MAPWTN(XWLL+XW,YWLL+YW,XND,YND)
      XNDUL=XWNBG
      XNDLR=XWNBG + (XND-XNDUL1)
      YNDUL=YND-YWNBG
      YNDLR=YNDLR1-YWNBG
      CALL SETVIE(XNDUL,YNDUL,XNDLR,YNDLR,1,1)
      CALL SETWOR(0.,0.,100.,100.)
      WRITE(999,*)'XWNBG,YWNBG,XND,YND=',XWNBG,YWNBG,XND,YND
      WRITE(999,*)'XNDUL,YNDUL,XNDLR,YNDLR=',XNDUL,YNDUL,XNDLR,YNDLR
      WRITE(999,*)'END DEFWIN'
C      
      RETURN
      END
**************************************************************************
      SUBROUTINE DFWINASP(STRING,IDFONT,ICLR,TXTHTND,ADJASP,WINASP)
C
C       ** OBJECTIVE:  GIVEN AN INPUT ASPECT RATIO WITH RESPECT TO A
C                      VIEWPORT OPENED TO THE ENTIRE SCREEN (0.-.999) AND
C                      A WORLD COORDINATE SYSTEM OF (0.-1.), DETERMINE THE
C                      EQUIVALENT ASPECT RATIO IN THE CURRENT COORDINATE
C                      SYSTEM.
C
       CHARACTER*(*) STRING
       COMMON/DEVHNDL/IHNDLSCR,IHNDLVRI,SCRNASP,VRIASP,DEVASP
C **DEBUG
        WRITE(999,*)'BEGIN DFWINASP'
C **END DEBUG     
C
C       ** MODIFY TEXT ASPECT RATIO FOR OUTPUT DEVICE
C
         IASPFLG = 1
         DUM=0
         CALL DFHSTWIN(IDFONT,ICLR,TXTHTND,IASPFLG,DUM,ADJASP)
         CALL INQSTS(STRING,HEIGHT,WIDSTR,OFFSET)
      CALL INQVIE(XNDUL,YNDUL,XNDLR,YNDLR)
      CALL INQWOR(XWLL,YWLL,XWUR,YWUR)
      CALL MAPNTD(XNDUL,YNDUL,IXDUL,IYDUL)
      CALL MAPNTD(XNDLR,YNDLR,IXDLR,IYDLR)
      XRATIO = (IXDLR-IXDUL+1)/(XWUR-XWLL)
      YRATIO = (IYDLR-IYDUL+1)/(YWUR-YWLL)
         IWIDSTR = WIDSTR * XRATIO
         WINASP = ADJASP *(.95*ABS(IXDLR-IXDUL)/REAL(IWIDSTR))
C **DEBUG         
         WRITE(999,*)'XNDUL,YNDUL,XNDLR,YNDLR=',XNDUL,YNDUL,XNDLR,YNDLR
         WRITE(999,*)'XWLL,YWLL,XWUR,YWUR=',XWLL,YWLL,XWUR,YWUR
         WRITE(999,*)'IXDUL,IYDUL,IXDLR,IYDLR=',IXDUL,IYDUL,IXDLR,IYDLR
         WRITE(999,*)'STRING,HEIGHT,OFFSET,XRATIO=',
     +                STRING,HEIGHT,OFFSET,XRATIO
         WRITE(999,*)'ASP,IXDUL/LR,WSTR=',
     +                WINASP,IXDUL,IXDLR,IWIDSTR
C
         CALL DFHSTWIN(IDFONT,ICLR,TXTHTND,IASPFLG,DUM,WINASP)
         CALL INQSTS(STRING,HEIGHT,WIDSTR,OFFSET)
         IWIDSTR = WIDSTR * XRATIO
         IHGHT   = HEIGHT * YRATIO
         WRITE(999,*)'HGHT,WID,IHGHT,IWID=',HEIGHT,WIDSTR,IHGHT,IWIDSTR
         WRITE(999,*)'END DFWINASP'
C     
      RETURN
      END
