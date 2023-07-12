//QSAMBB JOB ' ',CLASS=A,MSGLEVEL=(1,1),MSGCLASS=X,NOTIFY=&SYSUID
//DELET100 EXEC PGM=IDCAMS
//SYSPRINT DD SYSOUT=*
//SYSIN    DD *
  DELETE Z95644.QSAM.FF NONVSAM
  IF LASTCC LE 08 THEN SET MAXCC = 00
//SORT0200 EXEC PGM=SORT
//SYSOUT   DD SYSOUT=*
//SORTIN   DD *
00005851Y U N U S      TEYMUR
00002294B U R A K      KOZLUCA
00009297Y A S I N      SENSOY
00004194F U R K A N    TUNCER
00007184M U H A M M E DYAZICI
00008197O S M A N      OZCAN
00006840D E N I Z      KARHAN
00001978M E R T M U S ATEMEL
00003949M E H M E T    AYDIN
//SORTOUT  DD DSN=Z95644.QSAM.FF,
//            DISP=(NEW,CATLG,DELETE),
//            SPACE=(TRK,(5,5),RLSE),
//            DCB=(RECFM=FB,LRECL=47)
//SYSIN    DD *
  SORT FIELDS=(1,8,CH,A)
  OUTREC FIELDS=(1,50)
//*
//DELET300 EXEC PGM=IEFBR14
//FILE01    DD DSN=&SYSUID..QSAM.BB,
//             DISP=(MOD,DELETE,DELETE),SPACE=(TRK,0)
//SORT0400 EXEC PGM=SORT
//SYSOUT   DD SYSOUT=*
//SORTIN   DD DSN=Z95644.QSAM.FF,DISP=SHR
//SORTOUT  DD DSN=Z95644.QSAM.BB,
//            DISP=(NEW,CATLG,DELETE),
//            SPACE=(TRK,(5,5),RLSE),
//            DCB=(RECFM=FB,LRECL=47)
//SYSIN DD *
  SORT FIELDS=COPY
    OUTREC FIELDS=(1,5,ZD,TO=PD,LENGTH=3,
                   6,3,ZD,TO=BI,LENGTH=2,
                   9,30)
