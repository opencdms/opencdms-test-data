C       *****   INQUIRE/SET CLIP DISTANCE FOR LABLES   *****
C
c
        SUBROUTINE KINQCW (XDIST,YDIST)
        INTEGER*2 IBOX
        COMMON /KSAVCW/ XSAVE,YSAVE,IBOX
        XDIST = XSAVE
        YDIST = YSAVE
        RETURN
        END
C
        SUBROUTINE KSETCW (XDIST,YDIST)
        INTEGER*2 IBOX
        COMMON /KSAVCW/ XSAVE,YSAVE,IBOX
        XSAVE = XDIST
        YSAVE = YDIST
        RETURN
        END
C
C      *****    SET BOX ON/OFF AROUND LABELS ************
C
c
C      INUM = 0  DO NOT DRAW BOX
C      INUM = 1  DRAW BOX 
c
       SUBROUTINE KSETBX(INUM) 
       INTEGER*2  IBOX,INUM
       COMMON /KSAVCW/ XSAVE,YSAVE,IBOX
       IBOX = INUM
       RETURN
       END
C
       SUBROUTINE KINQBX(INUM)
       INTEGER*2 IBOX,INUM
       COMMON /KSAVCW/ XSAVE,YSAVE,IBOX
       INUM = IBOX
       RETURN
       END
C
C
C       ***********  SET CLIPPING FOR TEXT LABELS ON/OFF *******
C
        SUBROUTINE KCLPON
        COMMON /KWSWCP/  ICOV 
        ICOV = 1
        RETURN
        END
C
C
        SUBROUTINE KCLPOF
        COMMON /KWSWCP/  ICOV 
        ICOV = 0
        RETURN
        END
C
C   These subroutine set the flag to either write to disk
c   or store in the array /KWMID3/ NUMPTS,STOR(2,NUMPTS)
C   If writing to disk, set numpts = 1 in main subroutine.
C
       SUBROUTINE KSETBF(ICHECK,IUNIT)
       INTEGER*2  ICHECK,IUNIT,IFLG,NUMUNT
       COMMON /KSAVBF/ IFLG,NUMUNT
              IFLG = ICHECK
            NUMUNT = IUNIT
C
       IF (ICHECK.EQ.1) THEN
       OPEN (IUNIT,FILE='SCRATCH.CTR',ACCESS='DIRECT',
     +       FORM='UNFORMATTED',RECL=8)
       ENDIF
C
       RETURN
       END
C
C
       SUBROUTINE KINQBF(ICHECK,IUNIT)
       INTEGER*2  ICHECK,IUNIT,IFLG,NUMUNT
       COMMON /KSAVBF/ IFLG,NUMUNT
            ICHECK =  IFLG 
            IUNIT  =  NUMUNT
       RETURN
       END
C
C      THIS SUBROUTINE SETS THE NUMBER OF POINTS IN COMMON /KWMID3/ AND
C      THE TOTAL NUMBER OF BOXES IN COMMON /KWSVLM/
C
       SUBROUTINE KINQLM(NUMPTS,NUMBOX)
       INTEGER*2  TOTPTS,TOTBOX,NUMBOX,NUMPTS
       COMMON /KWMID3/ TOTPTS,STOR(2,1)
       COMMON /KWSVLM/ TOTBOX
C
       NUMPTS = TOTPTS
       NUMBOX = TOTBOX
       RETURN
       END
C
CC       SUBROUTINE KSETLM(NUMPTS,NUMBOX,IUNT)
       SUBROUTINE KSETLM(NUMPTS,NUMBOX)
       INTEGER*2  TOTPTS,TOTBOX,NUMBOX,NUMPTS
       COMMON /KWMID3/ TOTPTS,STOR(2,1)
       COMMON /KWSVLM/ TOTBOX
CCKW11/25       COMMON /UNTBOX/  IBXUNT
C
CCKW11/25       IBXUNT = IUNT
CCKW11/25       CLOSE(IUNT)
CCKW11/25       OPEN (IUNT,FILE='SCRATCH.BOX',ACCESS='DIRECT',
CCKW11/25     .       FORM='UNFORMATTED',RECL=40)
C
       TOTPTS = NUMPTS
       TOTBOX = NUMBOX
       RETURN
       END
C
C      *****     SET DISTANCE FOR CLIPPING LONG LINES     *****
C
       SUBROUTINE KIQDST (I1,DST)
       COMMON /KDSTCK/ IJMP,DIST
       I1  = IJMP
       DST = DIST
       RETURN
       END
c
       SUBROUTINE KSTDST(I1,DST)
       COMMON /KDSTCK/ IJMP,DIST
       IJMP = I1
       DIST = DST
       RETURN
       END