$STORAGE:2
      SUBROUTINE RDFRAME(CVAL,RVAL,MXDATROW,NFRMBG,FILOPT,IGRAPH,NUMCOL,
     +                   COLHDR,FRMTITLE,FRMSUB,NFRMFN,RTNCODE)
C
C       ** INPUT:
C             CVAL.......
C             RVAL.......
C             MXDATROW...MAXIMUM NUMBER OF DATA ROWS -- ARRAY DIMENSION
C             NFRMBG.....ARRAY POSITION TO BEGIN ADDING DATA
C             FILOPT.....FLAG TO INDICATE METHOD OF PROCESSING FILE
C                        0=OPEN FILE -- DO NOT READ DATA
C                        1=REWIND FILE AND READ FIRST FRAME
C                        2=READ PREVIOUS FRAME
C                        3=READ NEXT FRAME
C                        4=READ CURRENT FRAME
C                        5=POSITION FILE TO PREVIOUS FRAME -- DO NOT READ DATA
C                        6=POSITION FILE TO NEXT FRAME -- DO NOT READ DATA
C             IGRAPH.....
C             NUMCOL.....
C       ** OUTPUT:
C             COLHDR.....
C             FRMTITLE...
C             FRMSUB.....
C             NFRMFN.....ARRAY POSITION CONTAINING LAST DATA ENTRY
C             RTNCODE....FLAG TO INDICATE ERROR STATUS
C                        '0'=NO ERROR
C                        '1'=END OF FILE
C                        '2'=POSITION FILE BEFORE START OF DATA
C                        '3'=ERROR IN READING FILE
C                        '4'=ARRAY SIZE TOO SMALL FOR DATA
C
      CHARACTER *(*) CVAL(*)
      CHARACTER *(*) FRMTITLE,FRMSUB
      CHARACTER *(*) COLHDR(*)
      REAL*4 RVAL(MXDATROW,*)
      INTEGER*2 FILOPT,NUMCOL
      CHARACTER *1 RTNCODE
C      
$INCLUDE:  'GRFPARM.INC'
C
      CHARACTER*(MXRECL) INREC,BLCRLF
      CHARACTER*1 CHRRTN,LNFEED
C      
      CHRRTN = CHAR(13)
      LNFEED = CHAR(10)
      CALL GTRECL(IGRAPH,NUMCOL,NRECL,NCOLCHR)
      MXCWRT = NRECL-2
      BLCRLF = ' '
      BLCRLF(MXCWRT+1:MXCWRT+2) = CHRRTN//LNFEED
C      
      RTNCODE = '0'
C
C
C        ** OPEN FILE; DO NOT READ DATA
C
      IF (FILOPT.EQ.0) THEN
         OPEN(17,FILE='O:\DATA\GRAPHICS.API',STATUS='OLD',
     +           FORM='BINARY',ACCESS='DIRECT',RECL=NRECL,
     +           SHARE='DENYWR',MODE='READWRITE')
         GO TO 100
      ENDIF 
C
C       **  READ FILE POSITION RECORD
C      
      READ(17,REC=1,ERR=910) INREC(1:NRECL)
      READ(INREC,505) NOWFRM
C
C          ** POSITION FILE FOR READ
C
      READ(17,REC=NOWFRM) INREC(1:NRECL)
      READ(INREC,505) LSTFRM,NXTFRM,NCURREC
      IF (FILOPT.EQ.1) THEN
C      
C          .. POSITION FILE TO BEGINNING         
         NOWFRM=2
         READ(17,REC=NOWFRM) INREC(1:NRECL)
         READ(INREC,505) LSTFRM,NXTFRM,NCURREC
      ELSE IF (FILOPT.EQ.2 .OR. FILOPT.EQ.5) THEN
C
C          .. POSITION FILE TO PREVIOUS FRAME
         IF (LSTFRM.EQ.-1) GO TO 905
         NOWFRM = LSTFRM         
         READ(17,REC=NOWFRM) INREC(1:NRECL)
         READ(INREC,505) LSTFRM,NXTFRM,NCURREC
      ELSE IF (FILOPT.EQ.3 .OR. FILOPT.EQ.6) THEN
C
C          .. READ NEXT FRAME
         NOWFRM = NXTFRM
         READ(17,REC=NOWFRM) INREC(1:NRECL)
         READ(INREC,505) LSTFRM,NXTFRM,NCURREC
         IF (NXTFRM.EQ.-1) GO TO 900   
      ENDIF   
C
C       ** ENTER CURRENT POSITION INTO FILE POSITION RECORD
C      
      INREC = BLCRLF
      WRITE(INREC(1:MXCWRT),505) NOWFRM
      WRITE(17,REC=1) INREC(1:NRECL)
C
C       .. CALCULATE FINAL ARRAY POSITION FOR DATA
      NFRMFN = NFRMBG + (NCURREC-3) - 1
C
C       .. DO NOT READ DATA FOR FILOPT=5/6      
      IF (FILOPT.EQ.5 .OR. FILOPT.EQ.6) GO TO 100
C         
      READ(17,REC=NOWFRM+1,ERR=910) INREC(1:NRECL)
      READ(INREC,500) FRMTITLE
      READ(17,ERR=910) INREC(1:NRECL)
      READ(INREC,500) FRMSUB
      READ(17,ERR=910) INREC(1:NRECL)
      READ(INREC,510) (COLHDR(I)(1:NCOLCHR),I=1,NUMCOL)
C
C       ** CHECK TO BE SURE THERE IS ROOM FOR FRAME IN ARRAY
C
      IF (NFRMFN.GT.MXDATROW) GO TO 915
C
C       ** READ ONE FRAME OF DATA
C
      DO 26 I=NFRMBG,NFRMFN
         READ(17,ERR=910) INREC(1:NRECL)
         READ(INREC,515) IROW,CVAL(I),(RVAL(I,J),J=1,NUMCOL)
   26 CONTINUE  
C   
  100 RETURN
C
C       ** ERROR PROCESSING      
C
C          .. END OF FILE 
  900 CONTINUE
         RTNCODE = '1'
         GO TO 990
C
C       .. ATTEMPT TO POSITION BEFORE BEGINNING OF FILE  
  905 CONTINUE
         RTNCODE = '2'
         GO TO 990
C
C       .. ERROR IN READING FILE
  910 CONTINUE
         RTNCODE = '3'
         GO TO 990
C
C       .. ARRAY SIZE TOO SMALL FOR DATA
  915 CONTINUE
         RTNCODE = '4'
  990 CONTINUE       
      RETURN  
C
C       ** FORMAT STMTS
C
  500 FORMAT(A)
  505 FORMAT(I5,1X,I5,1X,I5)
  510 FORMAT(16X,36(1X,A:))
  515 FORMAT(I3,1X,A12,36(1X,F9.2:))
  520 FORMAT(I3)
C
      END        
*****************************************************************************
      SUBROUTINE RDFILPOS(IGRAPH,NUMCOL,NOWFRM)
C
C       ** OBJECTIVE:   READ FILE POSITION RECORD
C
C       ** INPUT:
C             IGRAPH
C             NUMCOL 
C       ** OUTPUT:
C             NOWFRM....POSITION OF CURRENT FRAME IN FILE
C 
$INCLUDE:  'GRFPARM.INC'
      CHARACTER*(MXRECL) INREC
C      
      CALL GTRECL(IGRAPH,NUMCOL,NRECL,NCOLCHR)
      READ(17,REC=1) INREC(1:NRECL)
      READ(INREC,505) NOWFRM
      RETURN
C
C       ** FORMAT STMTS
C
  505 FORMAT(I5,1X,I5,1X,I5)
      END
*****************************************************************************
      SUBROUTINE WRFILPOS(FILOPT,IGRAPH,NUMCOL,NOWFRM)
C      
C       ** INPUT:
C             FILOPT.....FLAG TO INDICATE METHOD OF PROCESSING FILE
C                        -1=CLOSE FILE WITH POSITION AT CURRENT FRAME
C                        -2=SET FILE POSITION TO FIRST FRAME; CLOSE FILE 
C                        -3=SET FILE POSITION TO SPECIFIED FRAME (NOWFRM)
C             NOWFRM.....
C
      INTEGER*2 FILOPT,NOWFRM
C        
$INCLUDE:  'GRFPARM.INC'
      CHARACTER*(MXRECL) INREC,BLCRLF
      CHARACTER*1 CHRRTN,LNFEED
C      
      CHRRTN = CHAR(13)
      LNFEED = CHAR(10)
      CALL GTRECL(IGRAPH,NUMCOL,NRECL,NCOLCHR)
      MXCWRT = NRECL-2
      BLCRLF = ' '
      BLCRLF(MXCWRT+1:MXCWRT+2) = CHRRTN//LNFEED
C      
      IF (FILOPT.NE.-1) THEN
C
C          .. WRITE FILE POSITION RECORD 
         IF (FILOPT.EQ.-2) THEN
            NOWFRM=2
         ENDIF
         INREC=BLCRLF
         WRITE(INREC(1:MXCWRT),505) NOWFRM
         WRITE(17,REC=1) INREC(1:NRECL)
      ENDIF
      IF (FILOPT.NE.-3) THEN
C
C          .. CLOSE FILE
         CLOSE(17)   
      ENDIF   
      RETURN
C
C       ** FORMAT STMTS
C
  500 FORMAT(A)
  505 FORMAT(I5,1X,I5,1X,I5)
      END
