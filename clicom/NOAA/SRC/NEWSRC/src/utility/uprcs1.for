$STORAGE:2

        SUBROUTINE UPRCS1(CHRS,NWDR)
C
        CHARACTER*1 CHRS(1)
        INTEGER*1 INTX
        DO 50 J=1,NWDR
          INTX=CHRS(J)
          IF(INTX.LT.97.OR.INTX.GT.122) GO TO 50
          INTX=INTX-32
          CHRS(J)=INTX
  50    CONTINUE
        RETURN
        END