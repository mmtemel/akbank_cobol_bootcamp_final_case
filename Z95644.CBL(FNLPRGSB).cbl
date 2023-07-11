       IDENTIFICATION DIVISION.
       PROGRAM-ID.    FNLPRGSB
       AUTHOR.        Mert Musa TEMEL.
       ENVIRONMENT DIVISION.
       INPUT-OUTPUT SECTION.
       FILE-CONTROL.
           SELECT ACCT-REC   ASSIGN TO    ACCTREC
                             ORGANIZATION INDEXED
                             ACCESS       RANDOM
                             RECORD       ACCT-KEY
                             STATUS       ACCT-ST.
           SELECT IDX-REC    ASSIGN TO    IDXREC
                             STATUS       IDX-ST.
           SELECT PRINT-LINE ASSIGN TO    PRTLINE
                             STATUS       PRT-ST.
       DATA DIVISION.
       FILE SECTION.
      *VSAM FILE
       FD  ACCT-REC.
      *    RECORD CONTAINS 50 CHARACTERS
      *    DATA RECORD IS ACCT-FIELDS.
       01  ACCT-FIELDS.
           03 ACCT-KEY.
              05 ACCT-ID     PIC S9(05) COMP-3.
              05 ACCT-CUR    PIC S9(03) COMP.
           03 ACCT-NAME      PIC X(15).
           03 ACCT-SURNAME   PIC X(15).
           03 FILLER         PIC X(12) VALUE SPACES.
      *INDEX FILE
       FD  IDX-REC    RECORDING MODE F.
       01  IDX-FIELDS.
           05 IDX-ID         PIC X(05).
           05 IDX-CUR        PIC X(03).
      *PRINT VARS
       FD  PRINT-LINE RECORDING MODE F.
       01  PRINT-REC.
           05 PRT-ID         PIC X(05).
           05 PRT-CUR        PIC X(03).
           05 PRT-NAME       PIC X(15).
           05 PRT-SURNAME    PIC X(15).
      *INTERNAL VARIABLES.
       WORKING-STORAGE SECTION.
       01  WS-WORK-AREA.
           05 ACCT-ST     PIC 9(02).
              88 ACCT-EOF     VALUE 10.
              88 ACCT-SUCCESS VALUE 00
                                    97.
           05 IDX-ST      PIC 9(02).
              88 IDX-EOF      VALUE 10.
              88 IDX-SUCCESS  VALUE 00
                                    97.
           05 PRT-ST      PIC 9(02).
              88 PRT-SUCCESS  VALUE 00
                                    97.
           05 INVALID-KEY PIC X(01).
              88 INVL-KEY     VALUE 'Y'.
       PROCEDURE DIVISION.
      *MAIN LOOOP
       0000-MAIN.
           PERFORM H100-OPEN-FILES.
           PERFORM H200-PROCESS UNTIL IDX-EOF.
           PERFORM H999-PROGRAM-EXIT.
      *OPEN FILES AND CHECK STATUS
       H100-OPEN-FILES.
           OPEN INPUT ACCT-REC.
           IF (ACCT-ST NOT = 0) AND (ACCT-ST NOT = 97)
              DISPLAY 'UNABLE TO OPEN1 FILE: ' ACCT-ST
              MOVE ACCT-ST TO RETURN-CODE
              PERFORM H999-PROGRAM-EXIT
           END-IF.
           OPEN INPUT IDX-REC.
           IF (IDX-ST NOT = 0) AND (IDX-ST NOT = 97)
              DISPLAY 'UNABLE TO OPEN2 FILE: ' IDX-ST
              MOVE IDX-ST TO RETURN-CODE
              PERFORM H999-PROGRAM-EXIT
           END-IF.
           OPEN OUTPUT PRINT-LINE.
           IF (PRT-ST NOT = 0) AND (ACCT-ST NOT = 97)
              DISPLAY 'UNABLE TO OPEN3 FILE: ' PRT-ST
              MOVE PRT-ST TO RETURN-CODE
              PERFORM H999-PROGRAM-EXIT
           END-IF.
           READ IDX-REC.
           IF (IDX-ST NOT = 0) AND (IDX-ST NOT = 97)
              DISPLAY 'UNABLE TO READ4 FILE: ' IDX-ST
              MOVE IDX-ST TO RETURN-CODE
              PERFORM H999-PROGRAM-EXIT
           END-IF.
      *    MOVE IDX-ID TO ACCT-ID.
           COMPUTE ACCT-ID = FUNCTION NUMVAL (IDX-ID).
           COMPUTE ACCT-CUR = FUNCTION NUMVAL (IDX-CUR).
           READ ACCT-REC
              INVALID KEY MOVE 'Y' TO INVALID-KEY.
           IF INVALID-KEY NOT = 'Y'
              IF (ACCT-ST NOT = 0) AND (ACCT-ST NOT = 97)
                DISPLAY 'UNABLE TO READ5 FILE: ' ACCT-ST
                MOVE ACCT-ST TO RETURN-CODE
                PERFORM H999-PROGRAM-EXIT
           END-IF.
       H100-END. EXIT.
      *PROGRAM LOGIC
       H200-PROCESS.
           INITIALIZE PRINT-REC.
           IF INVALID-KEY NOT = 'Y'
              MOVE ACCT-ID TO PRT-ID
              MOVE ACCT-CUR TO PRT-CUR
              MOVE ACCT-NAME TO PRT-NAME
              MOVE ACCT-SURNAME TO PRT-SURNAME
              WRITE PRINT-REC
           ELSE
              DISPLAY 'INVALID KEY' IDX-ID
              INITIALIZE INVALID-KEY
           END-IF.
           READ IDX-REC.
      *    MOVE IDX-ID TO ACCT-ID.
           COMPUTE ACCT-ID = FUNCTION NUMVAL (IDX-ID).
           COMPUTE ACCT-CUR = FUNCTION NUMVAL (IDX-CUR).
           READ ACCT-REC
              INVALID KEY MOVE 'Y' TO INVALID-KEY.
       H200-END. EXIT.
      *CLOSE I/O FILES
       H300-CLOSE-FILES.
           CLOSE ACCT-REC
                 PRINT-LINE
                 IDX-REC.
       H300-END. EXIT.
      *END THE PROGRAM
       H999-PROGRAM-EXIT.
           PERFORM H300-CLOSE-FILES.
           STOP RUN.
       H999-END. EXIT.
      *
