IF EXIST FLOUT.PRT DEL FLOUT.PRT
IF EXIST LIBOUT.PRT DEL LIBOUT.PRT
FOR %%A IN (*.FOR) DO FL /FPi /Od /c %%A >>FLOUT.PRT
FOR %%B IN (*.OBJ) DO LIB C:\CLICOM\LIB\KWLIB -+%%B; >>LIBOUT.PRT



