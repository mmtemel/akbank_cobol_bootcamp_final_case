       IDENTIFICATION DIVISION.
       PROGRAM-ID.    FNLPRGMN
       AUTHOR.        Mert Musa TEMEL.
       ENVIRONMENT DIVISION.
       INPUT-OUTPUT SECTION.
       FILE-CONTROL.
           SELECT ACCT-REC   ASSIGN TO    ACCTREC
                             ORGANIZATION INDEXED
                             ACCESS       RANDOM
                             RECORD       ACCT-KEY
                             STATUS       ACCT-ST.
           SELECT INP-REC    ASSIGN TO    INPFILE
                             STATUS       INP-ST.
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
       FD  INP-REC    RECORDING MODE F.
       01  INP-FIELDS.
           05 INP-OPR        PIC X(01).
           05 INP-ID         PIC X(05).
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
           05 INP-ST      PIC 9(02).
              88 INP-EOF      VALUE 10.
              88 INP-SUCCESS  VALUE 00
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
           PERFORM H200-PROCESS UNTIL INP-EOF.
           PERFORM H999-PROGRAM-EXIT.
      *OPEN FILES AND CHECK STATUS
       H100-OPEN-FILES.
           OPEN INPUT ACCT-REC.
           IF (NOT ACCT-SUCCESS)
              DISPLAY 'UNABLE TO OPEN1 FILE: ' ACCT-ST
              MOVE ACCT-ST TO RETURN-CODE
              PERFORM H999-PROGRAM-EXIT
           END-IF.
           OPEN INPUT INP-REC.
           IF (NOT INP-SUCCESS)
              DISPLAY 'UNABLE TO OPEN2 FILE: ' INP-ST
              MOVE INP-ST TO RETURN-CODE
              PERFORM H999-PROGRAM-EXIT
           END-IF.
           OPEN OUTPUT PRINT-LINE.
           IF (NOT PRT-SUCCESS)
              DISPLAY 'UNABLE TO OPEN3 FILE: ' PRT-ST
              MOVE PRT-ST TO RETURN-CODE
              PERFORM H999-PROGRAM-EXIT
           END-IF.
           READ INP-REC.
           IF (NOT INP-SUCCESS)
              DISPLAY 'UNABLE TO READ4 FILE: ' INP-ST
              MOVE INP-ST TO RETURN-CODE
              PERFORM H999-PROGRAM-EXIT
           END-IF.
           COMPUTE ACCT-ID = FUNCTION NUMVAL (INP-ID).
           DISPLAY 'FIRST READ INP-ID 'ACCT-ID.
           READ ACCT-REC
              INVALID KEY MOVE 'Y' TO INVALID-KEY.
           IF INVALID-KEY NOT = 'Y'
              IF (NOT ACCT-SUCCESS)
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
              DISPLAY 'INVALID KEY' INP-ID
              INITIALIZE INVALID-KEY
           END-IF.
           READ INP-REC.
           COMPUTE ACCT-ID = FUNCTION NUMVAL (INP-ID).
           DISPLAY ACCT-ID.
           READ ACCT-REC
              INVALID KEY MOVE 'Y' TO INVALID-KEY.
       H200-END. EXIT.
      *CLOSE I/O FILES
       H300-CLOSE-FILES.
           CLOSE ACCT-REC
                 PRINT-LINE
                 INP-REC.
       H300-END. EXIT.
      *END THE PROGRAM
       H999-PROGRAM-EXIT.
           PERFORM H300-CLOSE-FILES.
           STOP RUN.
       H999-END. EXIT.
      *
