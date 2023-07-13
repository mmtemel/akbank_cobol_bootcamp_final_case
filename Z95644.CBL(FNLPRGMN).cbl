       IDENTIFICATION DIVISION.
      *MAIN PROGRAM
       PROGRAM-ID.    FNLPRGWN
       AUTHOR.        Mert Musa TEMEL.
       ENVIRONMENT DIVISION.
       INPUT-OUTPUT SECTION.
       FILE-CONTROL.
           SELECT INP-REC    ASSIGN TO    INPFILE
                             STATUS       INP-ST.
           SELECT PRINT-LINE ASSIGN TO    PRTLINE
                             STATUS       PRT-ST.
       DATA DIVISION.
       FILE SECTION.
      *INDEX FILE
       FD  INP-REC    RECORDING MODE F.
       01  INP-FIELDS.
           05 INP-OPR           PIC X(01).
           05 INP-ID            PIC X(05).
      *PRINT VARS
       FD  PRINT-LINE RECORDING MODE F.
       01  PRINT-REC.
           05 PRT-CMT           PIC X(50).
      *INTERNAL VARIABLES.
       WORKING-STORAGE SECTION.
       01  WS-WORK-AREA.
           05 INP-ST            PIC 9(02).
              88 INP-EOF        VALUE 10.
              88 INP-SUCCESS    VALUE 00
                                      97.
           05 PRT-ST            PIC 9(02).
              88 PRT-SUCCESS    VALUE 00
                                      97.
       01  WS-SUB-AREA.
           05 WS-OPR            PIC X(01).
           05 WS-ID             PIC X(04).
           05 WS-CMT            PIC X(50).
       PROCEDURE DIVISION.
      *MAIN LOOOP
       0000-MAIN.
           PERFORM H100-OPEN-FILES.
           PERFORM H200-PROCESS UNTIL INP-EOF.
           PERFORM H999-PROGRAM-EXIT.
      *OPEN FILES AND CHECK STATUS (IN AND OUT)
       H100-OPEN-FILES.
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
       H100-END. EXIT.
      *PROGRAM LOGIC
       H200-PROCESS.
           INITIALIZE PRINT-REC.
           MOVE INP-OPR      TO    WS-OPR
           MOVE INP-ID       TO    WS-ID
           MOVE SPACES       TO    WS-CMT
           CALL 'FNLPRGSB' USING WS-SUB-AREA
           MOVE WS-CMT       TO    PRT-CMT
           WRITE PRINT-REC.
       H200-END. EXIT.
      *CLOSE I/O FILES
       H300-CLOSE-FILES.
           CLOSE PRINT-LINE
                 INP-REC.
       H300-END. EXIT.
      *END THE PROGRAM
       H999-PROGRAM-EXIT.
           PERFORM H300-CLOSE-FILES.
           STOP RUN.
       H999-END. EXIT.
      *
