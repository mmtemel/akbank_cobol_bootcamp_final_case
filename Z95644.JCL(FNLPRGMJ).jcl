//FNLPRGMJ JOB 1,NOTIFY=&SYSUID
//***************************************************/
//* Copyright Contributors to the COBOL Programming Course
//* SPDX-License-Identifier: CC-BY-4.0
//***************************************************/
//COBRUN  EXEC IGYWCL
//COBOL.SYSIN  DD DSN=&SYSUID..CBL(FNLPRGMN),DISP=SHR
//LKED.SYSLMOD DD DSN=&SYSUID..LOAD(FNLPRGMN),DISP=SHR
//***************************************************/
// IF RC < 5 THEN
//***************************************************/
//RUN       EXEC PGM=FNLPRGMN
//STEPLIB   DD DSN=&SYSUID..LOAD,DISP=SHR
//ACCTREC   DD DSN=&SYSUID..VSAM.AA,DISP=SHR
//INPFILE   DD DSN=&SYSUID..QSAM.INF,DISP=SHR
//PRTLINE   DD DSN=&SYSUID..QSAM.OUT,
//             DISP=(NEW,CATLG,DELETE),
//             UNIT=SYSDA,
//             SPACE=(TRK,(5,5),RLSE),
//             DCB=(RECFM=FB,LRECL=38,BLKSIZE=0)
//SYSOUT    DD SYSOUT=*,OUTLIM=15000
//CEEDUMP   DD DUMMY
//SYSUDUMP  DD DUMMY
//***************************************************/
// ELSE
// ENDIF
