$STORAGE:2
C     PROGRAM PATHLEN
C-----------------------------------------------------------------------------
C     DEFINE THE INTERFACE TO THE ROUTINE CMDLIN2
C-----------------------------------------------------------------------------
      INTERFACE TO SUBROUTINE CMDLIN2(ADDRES,LENGTH,RESULT)
      INTEGER*4 ADDRES[VALUE],LENGTH[VALUE]
      CHARACTER*1 RESULT
      END
C
      PROGRAM PATHLEN
C------------------------------------------------------------------------------
C     READ THE DOS ENVIRONMENT AREA AND SEARCH FOR THE PATH.  DETERMINE IF THE 
C     LENGTH OF THE CURRENT PATH PLUS ANY CLICOM APPENDAGES WILL EXCEED THE
C     DOS MAXIMUM COMMAND LENGTH OF 128 BYTES. CURRENT PATH LIMITED TO 100 OR
C     FEWER BYTES DURING INSTALLATION CHECK OR 115 BYTES WHEN RUNNING CLICOM.
C
C     RETURN CODES: 0 = OK; 1 = TOO LONG PATH; 
C------------------------------------------------------------------------------
      CHARACTER*100 STRBUF(5),ENVSTR
      CHARACTER*64  RESULT
      CHARACTER*1   NULL
      INTEGER*4     PSP,PSPNCHR,OFFSET
      INTEGER*2     MAXPATH
      LOGICAL       BADPATH
      EQUIVALENCE   (STRBUF,ENVSTR)
C
C   LOCATE SEGMENTED ADDRESS OF THE BEGINNING OF THIS PROGRAM
C
      OFFSET = #00100000
      PSP = LOCFAR(PATHLEN)
C
C   COMPUTE THE BEGINNING OF THE PROGRAM SEGMENT PREFIX (PSP)
C   LOCATE POSITION OF COMMAND PARAMTERS WITHIN THE PSP
C   PASS THE ADDRESS OF THE COMMAND PARAMTERS TO CMDLIN2 WHICH DECODES
C   THE COMMAND AND RETURNS IT AS RESULT.
C
      PSP = (PSP - MOD(PSP,#10000)) - OFFSET 
      PSPNCHR = PSP + #80
      PSP = PSP + #81
      CALL CMDLIN2(PSP,PSPNCHR,RESULT)
      IF (RESULT(1:7).EQ.'INSTALL') THEN
         MAXPATH = 75
      ELSE
         MAXPATH = 115
      ENDIF
C
C   GET THE ENVIRONMENT AREA - RETURNED AS A SINGLE STRING
C
      NULL   = CHAR(0)
      CALL GETENV(ENVSTR)
      I = 0
      BADPATH = .FALSE.
C
C   SEARCH THE ENVIRONMENT STRING FOR THE PATH
C
   40 CONTINUE
      I = I + 1
C
C   CHECK FOR END OF ENVIRONMENT STRING
C
      IF (ENVSTR(I:I) .EQ. NULL) THEN
         GO TO 100
      ENDIF
C
C   CHECK TO SEE IF THIS IS THE STRING WANTED
C
      IF (ENVSTR(I:I+4) .EQ. 'PATH=') THEN
         LENPATH = 0
         I = I + 5
         DO 60 K = I,999
            IF (ENVSTR(K:K) .NE. NULL) THEN
               LENPATH = LENPATH + 1
            ELSE
               IF (LENPATH .GT. MAXPATH) THEN
                  BADPATH = .TRUE.
               ENDIF
               GO TO 100
            ENDIF
   60    CONTINUE                   
      ENDIF
C
C   FIND THE END OF THIS STRING (HENCE THE BEGINING OF THE NEXT)
C
      DO 80 J = I,999
         IF (ENVSTR(J:J) .EQ. NULL) THEN
            I = J
            GO TO 40
         ENDIF
   80 CONTINUE
  100 CONTINUE
C
  160 IF (BADPATH) THEN
         STOP 1
      ENDIF
      STOP ' '
      END
