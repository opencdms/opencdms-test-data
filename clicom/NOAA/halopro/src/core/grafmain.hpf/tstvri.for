$STORAGE:2
      PROGRAM TSTVRI
      CHARACTER INCHAR*2
C
      CALL BGNHALO
C
   20 CONTINUE
      WRITE(*,*)'ENTER C TO CONTINUE; Q TO QUIT'
      READ(*,'(A)') INCHAR
C      
      IF (INCHAR.EQ.'C' .OR.INCHAR.EQ.'c') THEN
         CALL SETVIE(0.,0.,0.999,0.999,-1,-1)
         CALL SETWOR(0.,0.,1.,1.)
         CALL OUTTXT('^GRAPHICS TEXT ON SCREEN-- PRESS C TO CONTINUE^')
         READ(*,'(A)') INCHAR
         CALL GRFPRNT(IER)
         IF (IER.NE.0) GO TO 900
         GO TO 20
      ENDIF   
C
  100 CONTINUE
      CALL FINHALO
      WRITE(*,*)'NORMAL STOP '
      WRITE(*,*)'PRESS C'
      READ(*,'(A)') INCHAR
      STOP ' '
C 
  900 CONTINUE
      CALL FINHALO
      WRITE(*,*)'ERROR STOP '
      WRITE(*,*)'PRESS C'
      READ(*,'(A)') INCHAR
      STOP 1
      END
***************************************************************************
      SUBROUTINE BGNHALO
C-----------------------------------------------------
C   HALO GRAPHICS ENVIRONMENT VARIABLES
C
      PARAMETER        (MXPTRV=26)
      CHARACTER*30     DEVICE,PRINTR,ENVFILE,VRI
      INTEGER*2        DEVMODE,PTRVAL(0:MXPTRV),CLRFLG
      REAL*4           PTRASP
      COMMON /HALOENV/ DEVICE,PRINTR,ENVFILE,VRI,
     +                 DEVMODE,PTRVAL,CLRFLG,   PTRASP
C-----------------------------------------------------
      COMMON/DEVHNDL/IHNDLSCR,IHNDLVRI
      CHARACTER INCHAR*2
      CHARACTER*18 KRNLPATH
      DATA KRNLPATH/'&P:\HALO\KERNELS&'/
C      
      CALL SETKER(KRNLPATH)
      IHNDLSCR=0
      IHNDLVRI=0
      CALL HALOINIT
C         
      CALL SETDEV(DEVICE)
      CALL CKHALOER('SETDEV',IER)
      IF (IER.NE.0) GO TO 900
C         
      CALL INQADE(IHNDLSCR)
      CALL INITGR(DEVMODE)
      CALL CKHALOER('INITGR-SCR',IER)
      IF (IER.NE.0) GO TO 900
C      
      CALL SETIEE(1)
      CALL SETCOL(0)
      CALL CLR
C      
      CALL SETVIE(0.,0.,0.999,0.999,-1,-1)
      CALL SETWOR(0.,0.,1.,1.)
      RETURN
C
  900 CONTINUE
      CALL FINHALO
      WRITE(*,*)'STOP ON ERR '
      WRITE(*,*)'BGNHALO--PRESS C'
      READ(*,'(A)') INCHAR
      STOP 1       
      END
***************************************************************************
      SUBROUTINE FINHALO
      COMMON/DEVHNDL/IHNDLSCR,IHNDLVRI
      CALL SETADE(IHNDLSCR)
      CALL CLOSEG
      CALL SETADE(IHNDLVRI)
      CALL CLOSEG
      RETURN
      END
*****************************************************************************
      SUBROUTINE HALOINIT
C-----------------------------------------------------
C   HALO GRAPHICS ENVIRONMENT VARIABLES
C
      PARAMETER        (MXPTRV=26)
      CHARACTER*30     DEVICE,PRINTR,ENVFILE,VRI
      INTEGER*2        DEVMODE,PTRVAL(0:MXPTRV),CLRFLG
      REAL*4           PTRASP
      COMMON /HALOENV/ DEVICE,PRINTR,ENVFILE,VRI,
     +                 DEVMODE,PTRVAL,CLRFLG,   PTRASP
C-----------------------------------------------------
      DO 10 I=0,MXPTRV
         PTRVAL(I)=-1
   10 CONTINUE        
C      
      DEVICE    = '^P:\HALO\DRIVERS\AHDIBMV.DSP ^'
      PRINTR    = '^P:\HALO\DRIVERS\AHDLJTP.PRT ^'
      DEVMODE   = 3
      PTRVAL(0) = 900
      PTRVAL(1) = 900
      PTRVAL(4) = 1
      PTRVAL(6) = 2
      PTRVAL(7) = 3
      PTRVAL(8) = 1
      PTRVAL(9) = 1
      PTRVAL(10)= 1200
      PTRVAL(11)= 600
      PTRVAL(17)= 1
      CLRFLG    = 1
      PTRASP    = 1.0
      VRI = '^P:\HALO\DRIVERS\AHDVRI.DSP^'
      RETURN
      END
***************************************************************************
      SUBROUTINE GRFPRNT(IER)
C-----------------------------------------------------
C   HALO GRAPHICS ENVIRONMENT VARIABLES
C
      PARAMETER        (MXPTRV=26)
      CHARACTER*30     DEVICE,PRINTR,ENVFILE,VRI
      INTEGER*2        DEVMODE,PTRVAL(0:MXPTRV),CLRFLG
      REAL*4           PTRASP
      COMMON /HALOENV/ DEVICE,PRINTR,ENVFILE,VRI,
     +                 DEVMODE,PTRVAL,CLRFLG,   PTRASP
C-----------------------------------------------------
      COMMON/DEVHNDL/IHNDLSCR,IHNDLVRI
C
      LOGICAL       FIRSTCALL
      INTEGER       MATR(0:32)
      DATA MATR/33*0/
      DATA FIRSTCALL/.TRUE./
C      
      IER = 0
C         
      CALL INITGR(DEVMODE)
      CALL CKHALOER('INITGR-SCR',IER)
      IF (IER.NE.0) GO TO 250
C      CALL SETVIE(0.,0.,0.999,0.999,-1,-1)
C      CALL SETWOR(0.,0.,1.,1.)
C      CALL OUTTXT('^WAIT FOR PRINTER TO COMPLETE^')
       WRITE(*,*)'WAIT FOR PRINTER TO COMPLETE' 
C          
      IF (FIRSTCALL) THEN
         FIRSTCALL = .FALSE.
         CALL SETDEV(VRI)
         CALL CKHALOER('SETDEV',IER)
         IF (IER.NE.0) GO TO 250
C      
         CALL INQADE(IHNDLVRI)
         CALL CKHALOER('INQADE',IER)
         IF (IER.NE.0) GO TO 250
C      
         MAXX      = PTRVAL(0) - 1
         MAXY      = PTRVAL(1) - 1
         CALL SETDRA(MAXX,MAXY)
         CALL CKHALOER('SETDRA',IER)
         IF (IER.NE.0) GO TO 250
C      
         IF (PTRVAL(19) .NE. 0) THEN
            MAXC = 3
         ELSE
            MAXC = 1
         ENDIF
         CALL SETCRA(MAXC)
         CALL CKHALOER('SETCRA',IER)
         IF (IER.NE.0) GO TO 250
C      
         MATR(0)=0
         MATR(1)=2
         MATR(2)=0
         MATR(3)=0
         CALL SETMAT(MATR)
         CALL CKHALOER('SETMAT',IER)
         IF (IER.NE.0) GO TO 250
      ELSE   
         CALL SETADE(IHNDLVRI)
         CALL CKHALOER('SETADE-VRI',IER)
         IF (IER.NE.0) GO TO 250
      ENDIF   
C         
      CALL INITGR(0)
      CALL CKHALOER('INITGR-VRI',IER)
      IF (IER.NE.0) GO TO 250
C      
      CALL SETIEE(1)
      CALL SETASP(PTRASP)
      CALL SETACTPR(PRINTR,PTRVAL(0))
C      
      CALL SETVIE(0.,0.,0.999,0.999,-1,-1)
      CALL SETWOR(0.,0.,1.,1.)
      CALL OUTTXT('^GRAPHICS TEXT ON THE VRI/PRINTER^')
C         
  200 CALL GPRINT
      CALL CKHALOER('GPRINT',IER)
      IF (IER.NE.0) GO TO 250
C      
  250 CONTINUE
      CALL SETADE(IHNDLSCR)
      CALL CKHALOER('SETADE-SCR',IER)
      IF (IER.NE.0) GO TO 300
C         
      CALL INITGR(DEVMODE)
      CALL CKHALOER('INITGR-SCR',IER)
      IF (IER.NE.0) GO TO 300
C      
      CALL SETCOL(0)
      CALL SETVIE(0.,0.,0.999,0.999,-1,-1)
      CALL SETWOR(0.,0.,1.,1.)
  300 CONTINUE      
      RETURN
      END
*****************************************************************************
      SUBROUTINE SETACTPR(PRDRVR,PRATRB)
C
      CHARACTER*(*) PRDRVR
      INTEGER*2     PRATRB(0:*)      
C
      INTEGER*2    PATTR(0:63)
C   
      CALL SETPRN(PRDRVR)
      CALL CKHALOER('SETPRN',IER)
      IF (IER.NE.0) GO TO 200
C      
      DO 20 I=0,26
         PATTR(I) = PRATRB(I)
   20 CONTINUE   
C   
      DO 25 I=27,63
         PATTR(I)=-1
   25 CONTINUE      
      CALL SETPAT(PATTR)
      CALL CKHALOER('SETPAT',IER)
      IF (IER.NE.0) GO TO 200
C
  200 CONTINUE      
      RETURN
      END
*****************************************************************************
      SUBROUTINE CKHALOER(FCNNAM,IER)
      CHARACTER*(*) FCNNAM
      CHARACTER*20  MSGTXT
      CHARACTER*2   INCHAR
C
      IER = 0
      CALL INQERR(IFCN,IER)
      IF (IER.NE.0) THEN
         MSGTXT = ' '
         WRITE(MSGTXT,'(I3,I4,1X,A12)') IER,IFCN,FCNNAM
         NCH = LNG(MSGTXT)
         WRITE(*,*)'HALOERR=',MSGTXT
         WRITE(*,*)'PRESS C'
         READ(*,'(A)') INCHAR
      ENDIF   
      RETURN
      END           
*****************************************************************************
      SUBROUTINE OUTTXT(TXTVAL)
      CHARACTER*(*) TXTVAL
         CALL SETCOL(0)
         CALL CLR
         ICLR=5
         CALL SETFON('^P:\HALO\FONTS\AHD107.FNT^')
         CALL SETSTC(ICLR,ICLR)
         CALL SETSTE(.04,1.,0)            
         CALL MOVTCA(.01,.5)
         CALL STEXT(TXTVAL)
      RETURN 
      END   
