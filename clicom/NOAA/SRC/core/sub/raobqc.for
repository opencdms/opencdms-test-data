$STORAGE:2
      SUBROUTINE RAOBQC(ILINE,FLAGHOLD,NEWREC)
************************************************************************
*     QC FLAG DEFINITIONS:                                             *
*                                                                      *
*     FLAG 1                                                           *
*        ' '   NOT CHECKED                                             *
*        A     PASSED QC                                               *
*        B     SUSPECT                                                 *
*        C     ERRONEOUS                                               *
*        D     ACCEPTED BY DATA ENTRY                                  *
*        E     ACCEPTED BY VALIDATION                                  *
*                                                                      *
*     FLAG 2                                                           *
*        A     NO ERROR                                                *
*        O     BLANK NOT ALLOWED                                       *
*        S     SURFACE HEIGHT NOT ENTERED                              *
*        T     SUPERADIABATIC LAPSE RATE                               *
*        U     SUPERINVERSION                                          *
*        V     DEEP INVERSION                                          *
*        W     COMPUTED VALUE DOES NOT AGREE WITH REPORTED VALUE       *
*        X     PRESSURE OUT OF SORT                                    *
*        ]     VALUE UNREADABLE                                        *
*        d     PRESSURE OR HEIGHT REQUIRED                             *
************************************************************************

      IMPLICIT INTEGER (A-Z)

      CHARACTER*1 NEWREC

$INCLUDE:'VAL1.INC'
$INCLUDE:'RAOBQC.INC'

************************************************************************
*     THIS SUBROUTINE PERFORMS THE VALIDATION CHECKS ON UPPER AIR DATA.*
*                                                                      *
*     PRESSURE MUST BE AVAILABLE FOR EVERY ENTRY.                      *
*     WINDS ONLY LEVELS WILL HAVE A 'W' DATAFLAG IN THE PRESSURE       *
*     FIELD.                                                           *
*                                                                      *
*     ONCE TWO ADJACENT TEMPERATURE LEVELS HAVE BEEN IDENTIFIED, THE   *
*        HEIGHT OF THE TOP LEVEL IS COMPUTED.                          *
*     A LAPSE RATE CHECK IS PERFORMED AND THE COMPUTED HEIGHT  IS      *
*        COMPARED AGAINST THE REPORTED HEIGHT                          * 
************************************************************************

C **DEBUG -- REMOVE CHECK FOR PRESSURE AND HEIGHT
C
C          ** A PRESSURE OR HEIGHT MUST EXIST AT THE CURRENT LEVEL  (9-24-91)
C
C      IF (VALARRAY(1,ILINE)(1:5).EQ.BLANK .AND.
C     +    VALARRAY(2,ILINE)(1:5).EQ.BLANK)      THEN
C         IF (IELEM.GT.1) THEN
C            FLAGHOLD(1,5,1) = 'C'
C            FLAGHOLD(1,5,2) = 'd'
C            FLAGHOLD(2,5,1) = 'C'
C            FLAGHOLD(2,5,2) = 'd'
C         ENDIF   
C         RETURN
C      END IF
C **DEBUG  ADD QC BACK TO KE
C      IF (PASSWD.NE.'QC') RETURN      
C **END DEBUG
C
C  IF THIS IS A WINDS ONLY SOUNDING DO NOT DO THE PRESSURE/TEMP
C  CHECKS  - ASSUME IT IS WIND ONLY IF NO PRESSURE IS ENTERED IN LINE 1 
C  NOTE:  WNDONLY ROUTINE IS CALLED ONLY IF PRESSURE IN LINE 1 IS FLAGGED 'W'
C
      IF (VALARRAY(1,1).EQ.BLANK.AND.VALARRAY(5,1).NE.BLANK) THEN
         VALARRAY(1,1)(6:6) = 'W'
      END IF
      IF (VALARRAY(1,1)(6:6).EQ.'W')THEN
         CALL WNDONLY(ILINE,FLAGHOLD)
         RETURN
      END IF

      IF(NEWREC .EQ. '1') THEN
C          .. NEW RECORD; WRITE MESSAGE: LOADING DATA ARRAYS      
C         CALL WRTMSG(2,255,12,0,0,' ',0)
         L=1
         M=MAXLINE
      ELSE
         L=1
         M=ILINE
      END IF

C  READ THE DATA ARRAY INTO NUMERIC VARIABLES.  IDENTIFY THE WIND
C  ONLY LEVELS AS THE DATA ARE LOADED

      DO 1000 J=L,M

         IF (VALARRAY(1,J).EQ.BLANK) THEN
C             .. MISSING PRESSURE -- SET WIND FLAG ONLY IF WIND DIRECTION IS
C                ENTERED.  NOTE THAT ON THE FIRST PASS (NEWREC='1') ALL 
C                PRESSURES ARE SET TO MISSING BUT NOT FLAGGED SINCE NO
C                WIND DIRECTION HAS BEEN ENTERED AT THIS TIME.
            PRESSURE(J)=MISSING
            IF(VALARRAY(5,J).NE.BLANK) THEN
               VALARRAY(1,J) = '     W'
               DATAFLAG(1,J)='W'
            END IF
         ELSE
C             .. CONVERT CHARACTER TO REAL PRESSURE          
            READ (VALARRAY(1,J),50) PRESSURE(J),DATAFLAG(1,J)
50          FORMAT(F5.0,A1)
            PRESSURE(J) = PRESSURE(J) * TBLCONV(1)
         END IF
         IF (VALARRAY(1,J)(6:6).EQ.'W')THEN
C             .. WIND FLAG SET FOR BOTH BLANK AND GENERATED PRESSURES         
            WIND(J) = .TRUE.
         ELSE
            WIND(J) = .FALSE.
         END IF 

         IF (VALARRAY(2,J) .EQ. BLANK) THEN
            HEIGHT(J)=MISSING
            DATAFLAG(2,J)=' '
            COMPHT(J)=MISSING
         ELSE
            READ (VALARRAY(2,J),50) HEIGHT(J),DATAFLAG(2,J)
            HEIGHT(J) = HEIGHT(J) * TBLCONV(2)
C **DEBUG   COMMENT NEXT LINE            
C            COMPHT(J)=HEIGHT(J)
            IF (J.GE.ILINE) COMPHT(J)=MISSING
         END IF
         IF (VALARRAY(3,J) .EQ. BLANK) THEN
            TEMP(J)=MISSING
            DATAFLAG(3,J)=' '
         ELSE
            READ (VALARRAY(3,J),50) TEMP(J),DATAFLAG(3,J)
            TEMP(J) = TEMP(J) * TBLCONV(3)
         END IF
         IF (VALARRAY(4,J) .EQ. BLANK) THEN
            DEWPTDEP(J)=MISSING
            DATAFLAG(4,J)=' '
         ELSE
            READ (VALARRAY(4,J),50) DEWPTDEP(J),DATAFLAG(4,J)
            DEWPTDEP(J) = DEWPTDEP(J) * TBLCONV(4)
         END IF

         IF (VALARRAY(5,J) .EQ. BLANK) THEN
            WINDDIR(J)=MISSING
            DATAFLAG(5,J)=' '
         ELSE
            READ (VALARRAY(5,J),50) WINDDIR(J),DATAFLAG(5,J)
            WINDDIR(J) = WINDDIR(J) * TBLCONV(5)
         END IF
         IF (VALARRAY(6,J) .EQ. BLANK) THEN
            WINDSPEED(J)=MISSING
            DATAFLAG(6,J)=' '
         ELSE
            READ (VALARRAY(6,J),50) WINDSPEED(J),DATAFLAG(6,J)
            WINDSPEED(J) = WINDSPEED(J) * TBLCONV(6)
         END IF

         IF (.NOT.WIND(J))THEN
C             .. CALCULATE VIRTUAL TEMPERATURE FOR CURRENT LINE FROM PRESSURE,
C                TEMPERATURE, AND DEW POINT DEPRESSION.  PRESSURE IS ASSUMED
C                TO BE ENTERED FOR NON-WIND DATA.  NO CALCULATION IF
C                TEMPERATURE IS MISSING.
C ** DEBUG 3 LINES
C                IT IS POSSIBLE TO HAVE A MISSING PRESSURE THAT IS NOT FLAGGED
C                WIND.  WIND FLAG IS ONLY SET IF WIND DIRECTION IS PRESENT.
C                NO CHECK IS MADE FOR THIS CONDITION?
            CALL VIRTUALT(J)
         END IF

1000  CONTINUE
C **DEBUG STMT LABEL NOT USED
C1001  CONTINUE
C **DEBUG -- LOADING ARRAYS MESSAGE CLEARED SO FAST YOU CAN'T READ IT
C      CALL CLRMSG(2)       
C      
C       ** NOW PERFORM THE VALIDATION CHECKS FOR THE CURRENT LINE         
C
C       ++ WIND ONLY DATA -- NO PRESSURE AVAILABLE, BUT WIND DIRECTION ENTERED
C
      IF (WIND(ILINE))THEN
         IF (HEIGHT(ILINE).EQ.MISSING)THEN
C             .. ERROR IF HEIGHT MISSING FROM WIND DATA -- EXIT ROUTINE NOW
            FLAGHOLD(2,5,1) = 'C'
            FLAGHOLD(2,5,2) = 'O'
            RETURN
         END IF
C          .. SKIP REMAINING CHECKS FOR WIND ONLY DATA
         GO TO 2100
      END IF
C      
C       ++ LINE 1 -- PRESSURE, HEIGHT, AND TEMPERATURE REQUIRED.  FLAG
C          MISSING VALUES  
C
      IF (ILINE .EQ. 1) THEN
         IF(PRESSURE(1) .EQ. MISSING) THEN
            FLAGHOLD(1,5,1)='C'    
            FLAGHOLD(1,5,2)='O'    
         END IF  
         IF(HEIGHT(1) .EQ. MISSING) THEN
            FLAGHOLD(2,5,1)='C'    
            FLAGHOLD(2,5,2)='O'   
         END IF  
         IF(TEMP(1) .EQ. MISSING) THEN
            FLAGHOLD(3,5,1)='C'    
            FLAGHOLD(3,5,2)='O'    
         END IF
      END IF
C      
C       ++ ALL LINES EXCEPT THE FIRST LINE          
C
      IF (ILINE.GT.1) THEN
C          .. WIND ONLY DATA ON THE PREVIOUS LINE -- CALCULATE TEMP, PRESSURE
C             NOTE THAT CURRENT LINE CANNOT BE FLAGGED WIND.  THERE MUST
C             BE A PRESSURE FOR CURRENT LINE TO CALCULATE PRESSURE FOR THE
C             PREVIOUS LINE.  
         IF (WIND(ILINE-1))THEN
            CALL FILLPRESS(ILINE,IERR)
         END IF
C
C          ** MAKE SURE PRESSURES ARE IN SORT; CHECK VALUES FROM CURRENT LINE 
C             TO FIRST LINE (REVERSE ORDER); FLAG FIRST OUT OF SORT VALUE FOUND
C
         IF (PRESSURE(ILINE).NE.MISSING)THEN
            DO 1010 J = ILINE-1,1,-1
               IF (PRESSURE(J).NE.MISSING)THEN
                  IF (PRESSURE(ILINE).GE.PRESSURE(J))THEN
                     FLAGHOLD(1,5,1) = 'C'
                     FLAGHOLD(1,5,2) = 'X'
                  END IF
                  GO TO 1015
               END IF
 1010       CONTINUE
 1015       CONTINUE
         END IF
      END IF
C
C **DEBUG -- LABEL 2050 NOT USED
C 2050   CONTINUE
      OFFSET = 0
      IF(FLAGHOLD(1,5,1) .EQ. 'C') THEN
C          .. EXIT FROM ROUTINE NOW IF PRESSURE IS MISSING OR OUT OF SORT
         RETURN
      ELSE
C          .. FILL IN CONSECUTIVE MISSING/GENERATED TEMPERATURES AT LEVELS
C             BELOW AND ABOVE THE CURRENT LEVEL.  THESE ARE NOT WIND ONLY 
C             LEVELS.  TEMPERATURE IS REQUIRED FOR THE CURRENT LEVEL. IT IS 
C             ASSUMED THAT PRESSURE IS AVAILABLE FOR ALL LOWER LEVELS.  A 
C             CHECK IS MADE FOR MISSING PRESSURES AT HIGHER LEVELS.  VIRTUAL
C             TEMPERATURE IS ALSO CALCULATED FOR THESE LEVELS.  VALUE FOR
C             OFFSET IS CALCULATED.
         CALL FILLTEMP(ILINE,OFFSET)
      END IF
C
C       ** COMPUTE HEIGHTS FROM THE FIRST MISSING LEVEL TO THE TOP OF THE 
C          SOUNDING.  OFFSET IS THE INCREMENT BETWEEN THE CURRENT LEVEL AND
C          THE LOWER BOUNDARY FOR COMPUTING HEIGHTS.
      DO 2000 I=ILINE-OFFSET,MAXLINE

         IF(VALARRAY(1,I) .EQ. BLANK) THEN
C             .. EXIT LOOP IF MISSING PRESSURE --> TOP OF SOUNDING
            GO TO 2100
         END IF
C
C          .. I IS THE THE LEVEL OF THE HEIGHT THAT WILL BE CALCULATED; 
C             OFFSET INDICATES HOW FAR (NUMBER OF ROWS) THE CALCULATED HEIGHT 
C             IS BELOW THE CURRENT LEVEL; WITH EACH ITERATION OF THE LOOP THE
C             LEVEL OF THE CALCULATED HEIGHT GETS CLOSER TO THE CURRENT LEVEL;
C             OFFSET MUST BE DECREMENTED WITH EACH ITERATION OF THE LOOP TO
C             INDICATE THIS FACT.
C
         CALL CALCHEIGHT(I,FLAGHOLD,OFFSET)
         OFFSET=OFFSET-1
2000  CONTINUE
2100  CONTINUE

      IF (WIND(ILINE))THEN
C          .. SKIP ERROR CHECK FOR TEMPERATURE IF DATA IS WIND ONLY      
         GO TO 3000
      END IF
      IF(FLAGHOLD(2,6,1) .EQ. 'C') THEN
C          .. EXIT ROUTINE NOW IF HEIGHT IS ALREADY FLAGGED WITH AN ERROR
         RETURN
      ELSE
C          .. FLAG THE FOLLOWING TEMPERATURE ERRORS:  SUPERADIABATIC LAPSE 
C             RATE, SUPERINVERSION, DEEP INVERSION
         CALL LAPSERATE(ILINE,FLAGHOLD)
      END IF

************************************************************************
*     WRITE THE VALUES AND FLAGS BACK TO THE INPUT ARRAY               *
************************************************************************
 3000 CONTINUE

      IF (WIND(ILINE).AND.PRESSURE(ILINE).LT.1)THEN
         VALARRAY(1,ILINE) = '     W'
      ELSE IF (PRESSURE(ILINE) .EQ. MISSING) THEN
         VALARRAY(1,ILINE)=BLANK
      ELSE
C         INTVAL = NINT(PRESSURE(ILINE)*10.)
         CALL IROUND4(PRESSURE(ILINE)/TBLCONV(1),INTVAL)
         WRITE(VALARRAY(1,ILINE),3010) INTVAL,DATAFLAG(1,ILINE)
3010  FORMAT(I5,A1)
      END IF
      IF(HEIGHT(ILINE) .EQ. MISSING) THEN
         VALARRAY(2,ILINE)=BLANK
      ELSE
C         INTVAL = NINT(HEIGHT(ILINE))
         CALL IROUND4(HEIGHT(ILINE)/TBLCONV(2),INTVAL)
         WRITE(VALARRAY(2,ILINE),3010) INTVAL,DATAFLAG(2,ILINE)
      END IF
      IF(TEMP(ILINE) .EQ. MISSING) THEN
         VALARRAY(3,ILINE)=BLANK
      ELSE
C         INTVAL = NINT(TEMP(ILINE)*10.)
         CALL IROUND4(TEMP(ILINE)/TBLCONV(3),INTVAL)
         WRITE(VALARRAY(3,ILINE),3010) INTVAL,DATAFLAG(3,ILINE)
      END IF
      IF(DEWPTDEP(ILINE) .EQ. MISSING) THEN
         VALARRAY(4,ILINE)=BLANK
      ELSE
C         INTVAL = NINT(DEWPTDEP(ILINE)*10.)
         CALL IROUND4(DEWPTDEP(ILINE)/TBLCONV(4),INTVAL)
         WRITE(VALARRAY(4,ILINE),3010) INTVAL,DATAFLAG(4,ILINE)
      END IF
      IF(WINDDIR(ILINE) .EQ. MISSING) THEN
         VALARRAY(5,ILINE)=BLANK
      ELSE
C         INTVAL = NINT(WINDDIR(ILINE))
         CALL IROUND4(WINDDIR(ILINE)/TBLCONV(5),INTVAL)
         WRITE(VALARRAY(5,ILINE),3010) INTVAL,DATAFLAG(5,ILINE)
      END IF
      IF(WINDSPEED(ILINE) .EQ. MISSING) THEN
         VALARRAY(6,ILINE)=BLANK
      ELSE
C         INTVAL = NINT(WINDSPEED(ILINE))
         CALL IROUND4(WINDSPEED(ILINE)/TBLCONV(6),INTVAL)
         WRITE(VALARRAY(6,ILINE),3010) INTVAL,DATAFLAG(6,ILINE)
      END IF

      RETURN
      END
************************************************************************
$PAGE
      SUBROUTINE VIRTUALT (ILINE)
C
C       ** OBJECTIVE:  PERFORM THE COMPUTATION OF VIRTUAL TEMPERATURE.
C                      REQUIRED INPUT VALUES ARE:  PRESSURE, TEMPERATURE,
C                      AND DEWPOINT DEPRESSION.  PRESSURE IS ASSUMED TO BE
C                      PRESENT.  NO CALCULATION IS MADE IF TEMPERATURE IS
C                      MISSING.  RELATIVE HUMIDITY IS SET TO .5 IF DEW
C                      POINT DEPRESSION IS MISSING.  ALL VALUES USED AND
C                      CALCULATED ARE FOR THE CURRENT LINE ONLY.
C                       
***********************************************************************

      IMPLICIT INTEGER*2 (A-Z)
      REAL*4 RTEMP,DEWPT,VAPORPRESS


$INCLUDE:'VAL1.INC'
$INCLUDE:'RAOBQC.INC'

***********************************************************************
*     FIRST COMPUTE RELATIVE HUMIDITY                                 *
***********************************************************************

      PRESS1=PRESSURE(ILINE)
      IF(TEMP(ILINE) .EQ. MISSING) THEN
         RETURN
      ELSE
         RTEMP=TEMP(ILINE)
      END IF

      IF (DEWPTDEP(ILINE) .EQ. MISSING) THEN
         RH = .50
      ELSE
         DEWPT=(TEMP(ILINE)-DEWPTDEP(ILINE))
         RH = ((112.0 - .1*RTEMP+DEWPT)/
     +         (112+.9*RTEMP))**8
      END IF

*  NEXT COMPUTE VAPOR PRESSURE                                     *

      VAPORPRESS = RH *(6.11*(10.0**(7.5*RTEMP/
     +                 (237.3+RTEMP))))

*  NEXT COMPUTE MIXING RATIO                                       *

      MIXRATIO = (.62197*VAPORPRESS)/(PRESS1-VAPORPRESS)

*  FINALLY, COMPUTE VIRTUAL TEMPERATURE                           *

      VIRTEMP(ILINE) = (RTEMP+273.15)*(1.0+(.61*MIXRATIO))
      RETURN
      END
************************************************************************
$PAGE
      SUBROUTINE FILLTEMP(ILINE,OFFSET)
C
C       ** OBJECTIVE:  FILL IN CONSECUTIVE MISSING/GENERATED TEMPERATURES AT 
C                      LEVELS BELOW AND ABOVE THE CURRENT LEVEL.  THESE
C                      ARE NOT WIND ONLY LEVELS.  TEMPERATURE IS REQUIRED
C                      FOR THE CURRENT LEVEL.  ROUTINE IS EXITED IF 
C                      TEMPERATURE IS MISSING.  IT IS ASSUMED THAT PRESSURE
C                      IS AVAILABLE FOR ALL LOWER LEVELS.  A CHECK IS MADE
C                      FOR MISSING PRESSURES AT HIGHER LEVELS.
C                      

      IMPLICIT INTEGER (A-Z)

      REAL*4 DELTAT,DELTAP,TEMP1,TEMP2

$INCLUDE:'VAL1.INC'
$INCLUDE:'RAOBQC.INC'

      ND=0
      NU=0
C       .. TEMPERATURE IS REQUIRED AT CURRENT LEVEL      
      IF(TEMP(ILINE) .EQ. MISSING) THEN
         RETURN
      END IF
C
C       ** DETERMINE THE NUMBER OF CONSECUTIVE MISSING TEMPERATURE LEVELS 
C          BELOW THE CURRENT LEVEL (ND) -- GENERATED LEVELS COUNT AS MISSING.
C
C **DEBUG
C      DO 1000 I=ILINE-1,1,-1
      DO 1000 I=ILINE-1,2,-1

         IF(TEMP(I) .EQ. MISSING .OR.
     +      DATAFLAG(3,I) .EQ. 'G') THEN
            ND=ND+1
         ELSE
            GO TO 1100
         END IF
1000  CONTINUE
C       .. THERE MUST BE A TEMPERATURE AT THE LOW END IN ORDER TO DO THE
C          GENERATION OF TEMPERATURES BELOW THE CURRENT LEVEL
      IF (ILINE.LE.2 .OR. TEMP(1).EQ.MISSING) ND=0
1100  CONTINUE
C  
C       ** GENERATE A TEMPERATURE FOR ALL MISSING/GENERATED LEVELS BY 
C          INTERPOLATING BETWEEN THE CURRENT LEVEL AND THE NEXT LOWER LEVEL 
C          CONTAINING A TEMPERATURE VALUE.  CALCULATIONS BEGIN WITH THE 
C          LOWEST MISSING LEVEL.  ALSO CALCULATE VIRTUAL TEMPERATURE.
C
      PRESS1=PRESSURE(ILINE-(ND+1))
      PRESS2=PRESSURE(ILINE)
      TEMP1=TEMP(ILINE-(ND+1))
      TEMP2=TEMP(ILINE)
      DELTAT=(TEMP2-TEMP1)
      DELTAP=(PRESS1-PRESS2)

      DO 2000 I=ND,1,-1

         IF((ILINE-I) .LT. 1) THEN
            GO TO 2100
         END IF
         PRESS2=PRESSURE(ILINE-I)
         TEMP(ILINE-I)=TEMP1+(DELTAT*((PRESS1-PRESS2)/DELTAP))
         DATAFLAG(3,ILINE-I)='G'
C         INTVAL = NINT(TEMP(ILINE-I)*10.)
         CALL IROUND4(TEMP(ILINE-I)/TBLCONV(3),INTVAL)
         WRITE(VALARRAY(3,ILINE-I),'(I5,A1)') INTVAL,DATAFLAG(3,ILINE-I)
         CALL POSLIN(ROW,COLUMN)
         IF(ROW-I .GT. 4 .AND. ROW-I .LT.21) THEN
            CALL WRTVAL(VALARRAY(3,ILINE-I),FLAGARRAY(3,ILINE-I,1),
     +                  (ROW-I),21)
            CALL LOCATE(ROW,COLUMN,IERR)
         END IF
         CALL VIRTUALT(ILINE-I)
2000  CONTINUE
2100  CONTINUE
C
C       ** DETERMINE THE NUMBER OF CONSECUTIVE MISSING TEMPERATURE LEVELS 
C          ABOVE THE CURRENT LEVEL (NU) -- GENERATED LEVELS COUNT AS MISSING.
C          CHECK PRESSURES; NO CALCULATIONS ARE PERFORMED IF THERE ARE ANY
C          MISSING PRESSURES BETWEEN THE CURRENT LEVEL AND THE NEXT HIGHER
C          LEVEL THAT CONTAINS A TEMPERATURE.  IT IS ASSUMED THAT A MISSING
C          PRESSURE ABOVE THE CURRENT LEVEL SIGNIFIES THE END OF DATA.  TO
C          CALCULATE TEMPERATURES, ALL LEVELS MUST HAVE PRESSURES AND THE
C          UPPER BOUNDARY MUST HAVE BOTH PRESSURE AND TEMPERATURE.  
C
      DO 3000 I=ILINE+1,MAXLINE,1
         IF (PRESSURE(I) .EQ. MISSING) THEN
            NU=0
            GO TO 3100
         END IF
         IF(TEMP(I) .EQ. MISSING .OR.
     +      DATAFLAG(3,I) .EQ. 'G') THEN
            NU=NU+1
         ELSE
            GO TO 3100
         END IF
3000  CONTINUE
3100  CONTINUE

*     GENERATE A TEMPERATURE FOR ALL MISSING LEVELS.                   *
C
C       ** GENERATE A TEMPERATURE FOR ALL MISSING/GENERATED LEVELS BY 
C          INTERPOLATING BETWEEN THE CURRENT LEVEL AND THE NEXT HIGHER LEVEL 
C          CONTAINING A TEMPERATURE VALUE.  CALCULATIONS BEGIN WITH THE 
C          LOWEST MISSING LEVEL.  ALSO CALCULATE VIRTUAL TEMPERATURE.
C

      PRESS1=PRESSURE(ILINE)
      PRESS2=PRESSURE(ILINE+(NU+1))
      TEMP1=TEMP(ILINE)
      TEMP2=TEMP(ILINE+(NU+1))
      DELTAT=(TEMP2-TEMP1)
      DELTAP=(PRESS1-PRESS2)

      DO 4000 I=1,NU

         IF(PRESSURE(ILINE+I).EQ.MISSING.OR.(ILINE+I).GT.MAXLINE) THEN
C             .. EXIT IF A MISSING PRESSURE FOUND OR LINE COUNT ABOVE MAXIMUM
            GO TO 4100
         END IF
         PRESS2=PRESSURE(ILINE+I)
         TEMP(ILINE+I)=TEMP1+(DELTAT*((PRESS1-PRESS2)/DELTAP))
         DATAFLAG(3,ILINE+I)='G'
C         INTVAL = NINT(TEMP(ILINE+I)*10.)
         CALL IROUND4(TEMP(ILINE+I)/TBLCONV(3),INTVAL)
         WRITE(VALARRAY(3,ILINE+I),'(I5,A1)') INTVAL,DATAFLAG(3,ILINE+I)
         CALL POSLIN(ROW,COLUMN)
         IF(ROW+I .GT. 4 .AND. ROW+I .LT.21) THEN
            CALL WRTVAL(VALARRAY(3,ILINE+I),FLAGARRAY(3,ILINE+I,1),
     +                  (ROW+I),21)
            CALL LOCATE(ROW,COLUMN,IERR)
         END IF
         CALL VIRTUALT(ILINE+I)
4000  CONTINUE
4100  CONTINUE
C
C       ** DEFINE THE LOWER BOUNDARY FOR COMPUTING HEIGHTS.  HEIGHTS ARE 
C          COMPUTED FROM THE FIRST MISSING LEVEL TO THE TOP OF THE SOUNDING.
C
5000  OFFSET=ND

      RETURN
      END
************************************************************************
$PAGE
      SUBROUTINE CALCHEIGHT (ILINE,FLAGHOLD,OFFSET)
***********************************************************************
*     PERFORM THE COMPUTATION OF GEOPOTENTIAL HEIGHT                  *
***********************************************************************

      IMPLICIT INTEGER*2 (A-Z)
C **DEBUG
C      INTEGER*4 ICOMPHT
      REAL*4 COMPHTLN 


$INCLUDE:'VAL1.INC'
$INCLUDE:'RAOBQC.INC'

***********************************************************************
*      COMPUTE HEIGHT                                                 *
***********************************************************************
C **DEBUG -- SHOULD THE CHECK BE .LE.0 RATHER THAN .LT.0?
C      IF (PRESSURE(ILINE).LT.0 .OR. PRESSURE(ILINE-1).LT.0) THEN
      IF (PRESSURE(ILINE).LE.0 .OR. PRESSURE(ILINE-1).LE.0) THEN
         RETURN
      END IF    
C **DEBUG
C      IF (ILINE.EQ.1) THEN
C         PRESS1=PRESSURE(ILINE)
C      ELSE   
C         PRESS1=PRESSURE(ILINE-1)
C      END IF   
C      PRESS2=PRESSURE(ILINE)
C **DEBUG 11-18-91
C      IF (ILINE .GT. 1 .AND. COMPHT(ILINE-1) .NE. MISSING) THEN
      IF (ILINE .GT. 1 .AND. HEIGHT(ILINE-1) .NE. MISSING) THEN
C           .. CALCULATE HEIGHT AT THE CURRENT LINE USING THE CALCULATED 
C              HEIGHT FROM THE PREVIOUS LINE
C **DEBUG 11-18-91
C          COMPHT(ILINE) = COMPHT(ILINE-1)+(29.2713
          PRESS1=PRESSURE(ILINE-1)
          PRESS2=PRESSURE(ILINE)
          COMPHT(ILINE) = HEIGHT(ILINE-1)+(29.2713
     +                       *((VIRTEMP(ILINE)+VIRTEMP(ILINE-1))/2)
     +                       *ALOG(PRESS1/PRESS2))
C          CALL IROUND4(COMPHT(ILINE)/TBLCONV(2),INTVAL)
C          COMPHT(ILINE) = INTVAL*TBLCONV(2)
C      ELSE IF (ILINE .EQ. 1) THEN
C         COMPHT(ILINE) = HEIGHT(ILINE)
C          GO TO 100
       ELSE   
C           .. THIS IS THE FIRST LINE IN THE SOUNDING OR NO HEIGHT WAS
C              CALCULATED FOR THE PREVIOUS LINE.  SET COMPUTED HEIGHT
C              TO CURRENT ENTERED VALUE AND EXIT ROUTINE.
          COMPHT(ILINE) = HEIGHT(ILINE)
          GO TO 100
       ENDIF
C **DEBUG -- BEGIN***********************************************************
C **DEBUG         NEXT LINE COMMENTED  11-15-91 
C      IF (PASSWD .EQ. 'DE') THEN
C **DEBUG -- END  ***********************************************************
C
C       ** DATA ENTRY ONLY -- IF THE COMPUTED HEIGHT VARIES SIGNIFICANTLY FROM
C          THE REPORTED HEIGHT SET THE FLAGS.
C
C         ICOMPHT=NINT(COMPHT(ILINE))
C         CALL IROUND4(COMPHT(ILINE),ICOMPHT)
C         IF (HEIGHT(ILINE) .EQ. MISSING) THEN
         IF (HEIGHT(ILINE).EQ.MISSING .OR. 
     +       DATAFLAG(2,ILINE).EQ.'G') THEN
C             .. REPORTED HEIGHT IS MISSING; SET VALUE TO COMPUTED HEIGHT
            HEIGHT(ILINE) = COMPHT(ILINE)
            DATAFLAG(2,ILINE) = 'G'
            IF (OFFSET.EQ.0) THEN
C                .. SET FLAG ONLY FOR THE CURRENT LEVEL            
               FLAGHOLD(2,6,1)='A'
               FLAGHOLD(2,6,2)='A'
            ENDIF
            FLAGARRAY(2,ILINE,1)='A'
            FLAGARRAY(2,ILINE,2)='A'
C            INTVAL = NINT(HEIGHT(ILINE))
            CALL IROUND4(HEIGHT(ILINE)/TBLCONV(2),INTVAL)
            WRITE(VALARRAY(2,ILINE),'(I5,A1)') INTVAL,DATAFLAG(2,ILINE)
            CALL POSLIN(ROW,COLUMN)
C             .. CURSOR IS ON THE ROW FOR THE CURRENT LEVEL; OFFSET INDICATES 
C                HOW FAR (NUMBER OF ROWS) THE CALCULATED HEIGHT IS ABOVE/BELOW
C                THE CURRENT LEVEL; IF THE POSITION OF THE CALCULATED HEIGHT
C                (ROW-OFFSET) IS ON THE SCREEN WRITE THE REVISED VALUE TO 
C                THE SCREEN
            IF((ROW-OFFSET) .GT. 4 .AND. (ROW-OFFSET) .LT.21) THEN
               CALL WRTVAL(VALARRAY(2,ILINE),'A',(ROW-OFFSET),14)
               CALL LOCATE(ROW,COLUMN,IERR)
            END IF
C **DEBUG -- THE ERROR LIMITS ARE HARD SET.  PROBABLY DOES NOT MATTER IF
C **DEBUG -- LIMITS ARE HARD SET BECAUSE UPPER AIR UNITS ARE STANDARD NO
C **DEBUG -- MATTER WHERE YOU ARE?  SHOULD YOU USE A SET FRACTION 
C **DEBUG -- INSTEAD?  ALSO WHAT IS THE PURPOSE OF THE CHECK AT TWO LIMITS?
C **DEBUG -- (EX: HT+20 VS HT+10) ALL YOU NEED IS THE LOWER CHECK?
c **DEBUG -- POSSIBLE SOLUTION:  5000 -> 500MB   HEIGHT IS MORE ACCURATE AT
C **DEBUG -- LOWER LEVELS (HI PRESS) SO A SMALLER RANGE IS ALLOWED BEFORE
C **DEBUG -- FLAGGING HEIGHT.  THE TWO CHECKS AT EACH PRESSURE RANGE MAY BE
C **DEBUG -- BECAUSE ONE SHOULD BE CYAN AND THE OTHER FOR A RED FLAG.
C **DEBUG PRESSURE CORRECTION 5000 -> 500   10-21-91
C **DEBUG FLAG CORRECTION -- ADD RED FLAG   10-21-91
C         ELSE IF(PRESSURE(ILINE) .GE. 5000) THEN
         ELSE IF(PRESSURE(ILINE) .GE. 500.0) THEN
C             .. PRESSURE IN LOWER ATMOSPHERE 
C                SET COMPUTED HEIGHT TO REPORTED HEIGHT
C **DEBUG COMMENT NEXT LINE 11-18-91
C            COMPHT(ILINE) = HEIGHT(ILINE)
            IF (OFFSET.EQ.0) THEN
C                .. FOR CURRENT LEVEL ONLY -- SET FLAGS IF REPORTED HEIGHT  
C                   DIFFERS SIGNIFICANTLY FROM COMPUTED HEIGHT
               COMPHTLN = COMPHT(ILINE)
               IF(HEIGHT(ILINE) .GT. COMPHTLN+20.0 .OR.
     +            HEIGHT(ILINE) .LT. COMPHTLN-20.0) THEN
C                  FLAGHOLD(2,6,1)='B'
                  FLAGHOLD(2,6,1)='C'
                  FLAGHOLD(2,6,2)='W'
               ELSE IF(HEIGHT(ILINE) .GT. COMPHTLN+10 .OR.
     +                 HEIGHT(ILINE) .LT. COMPHTLN-10) THEN
                  FLAGHOLD(2,6,1)='B'
                  FLAGHOLD(2,6,2)='W'
               END IF
            END IF
         ELSE 
C             .. PRESSURE IN UPPER ATMOSPHERE 
C                SET COMPUTED HEIGHT TO REPORTED HEIGHT
C **DEBUG COMMENT NEXT LINE 11-18-91
C            COMPHT(ILINE) = HEIGHT(ILINE)
            IF (OFFSET.EQ.0) THEN
C                .. FOR CURRENT LEVEL ONLY -- SET FLAGS IF REPORTED HEIGHT  
C                   DIFFERS SIGNIFICANTLY FROM COMPUTED HEIGHT
               COMPHTLN = COMPHT(ILINE)
               IF(HEIGHT(ILINE) .GT. COMPHTLN+30 .OR.
     +            HEIGHT(ILINE) .LT. COMPHTLN-30) THEN
C                  FLAGHOLD(2,6,1)='B'
                  FLAGHOLD(2,6,1)='C'
                  FLAGHOLD(2,6,2)='W'
               ELSE IF(HEIGHT(ILINE) .GT. COMPHTLN+20 .OR.
     +                 HEIGHT(ILINE) .LT. COMPHTLN-20) THEN
                  FLAGHOLD(2,6,1)='B'
                  FLAGHOLD(2,6,2)='W'
               END IF
            END IF
         END IF
C **DEBUG -- BEGIN***********************************************************
C **DEBUG    11-15-91
C **DEBUG    REMOVE CODE THAT SETS HEIGHT TO COMPUTED HEIGHT FOR VALIDATION
C **DEBUG    VALIDATION WILL BE HANDLED THE SAME AS KEY ENTRY FOR HEIGHTS
C      ELSE
C
C          ** VALIDATION ONLY -- SET HEIGHT TO COMPUTED HEIGHT; REMOVE ALL
C                                FLAGS ON HEIGHT SET IN KEY ENTRY
C
C **DEBUG -- WHY IS THE COMPUTED HEIGHT ROUNDED TO THE NEAREST INTEGER?
C **DEBUG -- IS THIS BECAUSE THE SCALE FACTOR WAS HARD SET TO 1.0?  DOES
C **DEBUG -- ANYONE USE A SCALE OF .1?  PROBABLY DOES NOT MAKE ANY DIFFERENCE
C **DEBUG -- IF THIS IS HARD SET?  
C      
C         HEIGHT(ILINE)=NINT(COMPHT(ILINE))
C **DEBUG ROUND COMPUTED HEIGHT TO CORRECT NUMBER OF SIGFIG BEFORE SETTING
C **DEBUG HEIGHT TO COMPUTED HEIGHT
C         CALL IROUND4(COMPHT(ILINE)/TBLCONV(2),INTVAL)
C         HEIGHT(ILINE) = INTVAL*TBLCONV(2)
C         IF (OFFSET.EQ.0) THEN
C             .. SET FLAG ONLY FOR THE CURRENT LEVEL            
C            FLAGHOLD(2,6,1)='A'
C            FLAGHOLD(2,6,2)='A'
C         ENDIF
C         FLAGARRAY(2,ILINE,1)='A'
C         FLAGARRAY(2,ILINE,2)='A'
C         INTVAL = NINT(HEIGHT(ILINE))
C         CALL IROUND4(HEIGHT(ILINE)/TBLCONV(2),INTVAL)
C         WRITE(VALARRAY(2,ILINE),'(I5,A1)') INTVAL,DATAFLAG(2,ILINE)
C         CALL POSLIN(ROW,COLUMN)
C         IF((ROW-OFFSET) .GT. 4 .AND. (ROW-OFFSET) .LT.21) THEN
C            CALL WRTVAL(VALARRAY(2,ILINE),'A',(ROW-OFFSET),14)
C            CALL LOCATE(ROW,COLUMN,IERR)
C         END IF
C      END IF
C **DEBUG -- END*************************************************************
  100 CONTINUE
      RETURN
      END
************************************************************************
$PAGE
      SUBROUTINE LAPSERATE(ILINE,FLAGHOLD) 

      IMPLICIT INTEGER*2 (A-Z)

      REAL*4 LAPSRAT

$INCLUDE:'VAL1.INC'
$INCLUDE:'RAOBQC.INC'

************************************************************************
*     IF THE TEMPERATURE DOES NOT EXIST AT THIS LEVEL, RETURN.         *
*     OTHERWISE, LOCATE THE NEXT LOWER LEVEL WITH A TEMPERATURE.       *
*     AND COMPUTE THE LAPSERATE AND ADIABATIC TEMPERATURE              *
************************************************************************

      IF (TEMP(ILINE) .EQ. MISSING .OR. 
     +    COMPHT(ILINE) .EQ. MISSING .OR.
     +    ILINE .EQ. 1) THEN
         RETURN
      END IF
 
      IF(COMPHT(ILINE-I) .EQ. MISSING) THEN
         FLAGHOLD(2,6,1)='C'
         FLAGHOLD(2,6,2)='S'
         RETURN
      END IF

      LAPSRAT= (TEMP(ILINE)-TEMP(ILINE-1)) 
     +        /(COMPHT(ILINE)-COMPHT(ILINE-1))

*     IDENTIFY SUPERINVERSIONS                                        *

      IF(LAPSRAT .GE. 0.02) THEN
         FLAGHOLD(3,6,1)='C'
         FLAGHOLD(3,6,2) ='U'
      END IF      

*     IDENTIFY DEEP INVERSIONS                                        *

      IF(LAPSRAT .GT.0.0) THEN
         BASEINV=ILINE
         DO 2000 I=ILINE-1,1,-1
            IF(TEMP(I) .LE. TEMP(ILINE)) THEN
               BASEINV=I
            ELSE
               GO TO 3000
            END IF
2000     CONTINUE
3000     CONTINUE
      ELSE
         GO TO 4000
      END IF

      IF ((PRESSURE(BASEINV)-PRESSURE(ILINE)) .GT. 20.0 .AND.
     +       PRESSURE(ILINE) .GE. 200.0) THEN
         FLAGHOLD(3,6,1)='B'
         FLAGHOLD(3,6,2) = 'V'
      END IF

*     IDENTIFY SUPERADIABATIC LAYERS                                  *

4000  IF (LAPSRAT .LT. -0.0097) THEN
         FLAGHOLD(3,6,1)='C'
         FLAGHOLD(3,6,2) = 'T'
      END IF

      RETURN
      END
$PAGE
C  *********************************************************************
      SUBROUTINE FILLPRESS(ILINE,IERR)
C
C       ** OBJECTIVE:  FILL IN PRESSURES FOR WIND LEVELS AT LOWER LEVELS
C
      IMPLICIT INTEGER (A-Z)
      REAL*4 HGT1,HGT2,DELTAH,VTEMP1,VTEMP2,DELTAT,B
C
$INCLUDE: 'VAL1.INC'
$INCLUDE: 'RAOBQC.INC'
C
C       ** TEMPERATURE AND PRESSURE AT THE CURRENT LEVEL ARE REQUIRED 
C          FOR CALCULATION
C
      IF(PRESSURE(ILINE).EQ.MISSING .OR. TEMP(ILINE).EQ.MISSING) THEN
         RETURN
      END IF
C
C       ** A LOWER BOUND FOR TEMPERATURE AND PRESSURE IS REQUIRED 
C          FOR CALCULATION
C
      IF (ILINE.LE.2) RETURN
C      
C       ** INITIAL VARIABLES
C
      ND=0
      NP=0
      NT=0
C
C       ** DETERMINE THE NUMBER OF CONSECUTIVE MISSING PRESSURE (WIND) LEVELS 
C          BELOW THE CURRENT LEVEL.  CHECK STOPS WITH THE FIRST LEVEL THAT
C          
C          ND EQUALS THE NUMBER OF LEVELS FLAGGED AS MISSING.
C          NP EQUALS THE NUMBER OF FLAGGED LEVELS FOR WHICH PRESSURE HAS 
C          ALREADY BEEN GENERATED.
C
C **DEBUG
C      DO 100 I=ILINE-1,1,-1
      DO 100 I=ILINE-1,2,-1
         IF (DATAFLAG(1,I) .EQ. 'W') THEN
            ND=ND+1
            IF (PRESSURE(I).GT.0.1)THEN
               NP = NP+1
            END IF
         ELSE
            GO TO 110
         END IF
  100 CONTINUE
C       .. A LOWER PRESSURE IS REQUIRED TO GENERATE MISSING PRESSURES AT
C          LEVELS BELOW THE CURRENT LEVEL
      IF (PRESSURE(1).LE.0) THEN
         ND=0
         NP=0
      ENDIF    
  110 CONTINUE
C
C       ** IF EACH OF THE WIND LEVELS ALREADY HAVE GENERATED PRESSURES
C          THEN RETURN
C
      IF (ND.EQ.NP)THEN
         RETURN
      END IF 
C **DEBUG 11-18-91   VARIABLE NOT USED IN THIS ROUTINE      
C      NU=0
C
C
C       ** DETERMINE THE NUMBER OF CONSECUTIVE MISSING TEMPERATURE LEVELS 
C          IMMEDIATELY BELOW THE CURRENT LEVEL (NT) -- GENERATED LEVELS 
C          COUNT AS MISSING.    
C
C **DEBUG
C      DO 1000 I=ILINE-1,1,-1
      DO 1000 I=ILINE-1,2,-1

         IF(TEMP(I) .EQ. MISSING .OR.
     +      DATAFLAG(3,I) .EQ. 'G') THEN
            NT=NT+1
         ELSE
            GO TO 1100
         END IF
1000  CONTINUE
C       .. A LOWER TEMPERATURE IS REQUIRED FOR THE GENERATION OF TEMPERATURES
C          AND PRESSURES BELOW THE CURRENT LEVEL
      IF (TEMP(1) .EQ. MISSING) THEN
         NT=0
         ND=0
      ENDIF
1100  CONTINUE
C
C       ** GENERATE A TEMPERATURE FOR ALL MISSING LEVELS BY INTERPOLATING
C          BETWEEN THE CURRENT LEVEL AND THE NEXT LOWER LEVEL CONTAINING
C          A TEMPERATURE VALUE.  CALCULATIONS BEGIN WITH THE LOWEST MISSING
C          LEVEL.
C
      HGT1=HEIGHT(ILINE-(NT+1))
      HGT2=HEIGHT(ILINE)
      VTEMP1=TEMP(ILINE-(NT+1))
      VTEMP2=TEMP(ILINE)
      DELTAT=(VTEMP2-VTEMP1)
      DELTAH=(HGT2-HGT1)

      DO 1500 I=NT,1,-1

         IF((ILINE-I) .LT. 1) THEN
            GO TO 1600
         END IF
         HGT2=HEIGHT(ILINE-I)
         TEMP(ILINE-I)=VTEMP1+(DELTAT*((HGT2-HGT1)/DELTAH))
         DATAFLAG(3,ILINE-I)='G'
C         INTVAL = NINT(TEMP(ILINE-I)*10.)
         CALL IROUND4(TEMP(ILINE-I)/TBLCONV(3),INTVAL)
         WRITE(VALARRAY(3,ILINE-I),'(I5,A1)') INTVAL,DATAFLAG(3,ILINE-I)
         CALL POSLIN(ROW,COLUMN)
         IF(ROW-I .GT. 4 .AND. ROW-I .LT.21) THEN
            CALL WRTVAL(VALARRAY(3,ILINE-I),FLAGARRAY(3,ILINE-I,1),
     +                  (ROW-I),21)
            CALL LOCATE(ROW,COLUMN,IERR)
         END IF
1500  CONTINUE
1600  CONTINUE
C
C       ** GENERATE A PRESSURE FOR THE CONSECUTIVE WIND ONLY LEVELS THAT
C          ARE MISSING PRESSURE BY INTERPOLATING BETWEEN THE CURRENT LEVEL AND
C          THE NEXT LOWER UNFLAGGED LEVEL.  WIND ONLY LEVELS THAT CONTAIN 
C          PRESSURE ARE SKIPPED.  CALCULATIONS BEGIN WITH THE LOWEST FLAGGED
C          LEVEL.
C
      PRESS1=PRESSURE(ILINE-(ND+1))
      HGT1=HEIGHT(ILINE-(ND+1))
      VTEMP1 = TEMP(ILINE-(ND+1))
      VTEMP1 = VTEMP1+273.15

      DO 2000 I=ND,1,-1

         IF (PRESSURE(ILINE-I).GT.1)THEN
            GO TO 2000
         END IF

         IF((ILINE-I) .LT. 1) THEN
            GO TO 2100
         END IF

         VTEMP2 = TEMP(ILINE-I)
         VTEMP2 = VTEMP2+273.15
         HGT2 = HEIGHT(ILINE-I)

         B = (2*(HGT2-HGT1))/(29.2713*(VTEMP2+VTEMP1))
         PRESS2 = PRESS1*EXP(-B)
         PRESSURE(ILINE-I) = PRESS2

C         INTVAL = NINT(PRESSURE(ILINE-I)*10.)
         CALL IROUND4(PRESSURE(ILINE-I)/TBLCONV(1),INTVAL)
         WRITE(VALARRAY(1,ILINE-I),'(I5,A1)') INTVAL,DATAFLAG(1,ILINE-I)
         CALL POSLIN(ROW,COLUMN)
         IF(ROW-I .GT. 4 .AND. ROW-I .LT.21) THEN
            CALL WRTVAL(VALARRAY(1,ILINE-I),FLAGARRAY(1,ILINE-I,1),
     +                  (ROW-I),7)
            CALL LOCATE(ROW,COLUMN,IERR)
         END IF
2000  CONTINUE
2100  CONTINUE

      RETURN
      END

$PAGE
C  ********************************************************************
      SUBROUTINE WNDONLY(ILINE,FLAGHOLD)
C
C       ** OBJECTIVE:  DO THE FOLLOWING TASKS FOR LINES 1 TO CURRENT LINE.
C                      FLAG MISSING PRESSURES AS WIND ONLY DATA (W) IF A
C                      WIND DIRECTION IS ENTERED.  IT IS ASSUMED THAT IF
C                      WIND DIRECTION IS ENTERED, SO IS WIND SPEED.  CONVERT
C                      CHARACTER VALUES IN VALARRAY TO REAL VALUES FOR
C                      PRESSURE, HEIGHT, WIND DIRECTION, AND WIND SPEED.
C                      FLAG OUT OF SORT PRESSURES AND HEIGHTS.
C
      IMPLICIT INTEGER*2 (A-Z)

$INCLUDE: 'VAL1.INC'
$INCLUDE: 'RAOBQC.INC'

      DO 100 J = 1,ILINE
         IF (VALARRAY(1,J)(1:5).EQ.BLANK) THEN
            PRESSURE(J)=MISSING
            IF (VALARRAY(5,J).NE.BLANK) THEN
               VALARRAY(1,J)(6:6) = 'W'
               DATAFLAG(1,J)='W'
            END IF
         ELSE
            READ (VALARRAY(1,J),50) PRESSURE(J),DATAFLAG(1,J)
            PRESSURE(J) = PRESSURE(J) * TBLCONV(1)
         END IF

         IF (VALARRAY(2,J) .EQ. BLANK) THEN
            HEIGHT(J)=MISSING
            DATAFLAG(2,J)=' '
         ELSE
            READ (VALARRAY(2,J),50) HEIGHT(J),DATAFLAG(2,J)
            HEIGHT(J) = HEIGHT(J) * TBLCONV(2)
         END IF

         IF (VALARRAY(5,J) .EQ. BLANK) THEN
            WINDDIR(J)=MISSING
            DATAFLAG(5,J)=' '
         ELSE
            READ (VALARRAY(5,J),50) WINDDIR(J),DATAFLAG(5,J)
            WINDDIR(J) = WINDDIR(J) * TBLCONV(5)
         END IF

         IF (VALARRAY(6,J) .EQ. BLANK) THEN
            WINDSPEED(J)=MISSING
            DATAFLAG(6,J)=' '
         ELSE
            READ (VALARRAY(6,J),50) WINDSPEED(J),DATAFLAG(6,J)
            WINDSPEED(J) = WINDSPEED(J) * TBLCONV(6)
         END IF
  100 CONTINUE
C
C       ** MAKE SURE PRESSURES AND HEIGHTS ARE IN SORT; CHECK VALUES FROM
C          CURRENT LINE TO FIRST LINE (REVERSE ORDER); FLAG FIRST OUT OF
C          SORT VALUE FOUND
C
      IF (PRESSURE(ILINE).NE.MISSING)THEN
         DO 200 J = ILINE-1,1,-1
            IF (PRESSURE(J).NE.MISSING)THEN
               IF (PRESSURE(ILINE).GE.PRESSURE(J))THEN
                  FLAGHOLD(1,5,1) = 'C'
                  FLAGHOLD(1,5,2) = 'X'
               END IF
               GO TO 210
            END IF
  200    CONTINUE
  210    CONTINUE
      END IF
      IF (HEIGHT(ILINE).NE.MISSING)THEN
         DO 300 J = ILINE-1,1,-1
C **DEBUG IS THIS AN ERROR? SHOULD EQ --> NE?  WHAT ABOUT MISSING HEIGHTS?  
C **DEBUG  CHANGE EQ --> NE  10-21-91
C            IF (HEIGHT(J).EQ.MISSING)THEN
            IF (HEIGHT(J).NE.MISSING)THEN
               IF (HEIGHT(J).GE.HEIGHT(ILINE))THEN
                  FLAGHOLD(2,5,1) = 'C'
                  FLAGHOLD(2,5,2) = 'X'
               END IF
               GO TO 310
            END IF
  300    CONTINUE
  310    CONTINUE
      END IF
C
      RETURN
C
C       ** FORMAT STMTS
C
   50 FORMAT (F5.0,A1)
C      
      END
