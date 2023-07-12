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
      *    RECORD CONTAINS 47 CHARACTERS
      *    DATA RECORD IS ACCT-FIELDS.
       FD  ACCT-REC.
       01  ACCT-FIELDS.
           03 ACCT-KEY.
              05 ACCT-ID     PIC S9(05) COMP-3.
           03 ACCT-CUR       PIC S9(03) COMP.
           03 ACCT-NAME      PIC X(15).
           03 ACCT-SURNAME   PIC X(15).
           03 FILLER         PIC X(12) VALUE SPACES.
      *INDEX FILE
       FD  INP-REC    RECORDING MODE F.
       01  INP-FIELDS.
           05 INP-OPR        PIC X(01).
              88 VLD-OPR     VALUE  'R'
                                    'U'
                                    'W'
                                    'D'.
           05 INP-ID         PIC X(05).
      *PRINT VARS
       FD  PRINT-LINE RECORDING MODE F.
       01  PRINT-REC.
           05 PRT-ID         PIC X(05).
           05 FILLER         PIC X(01) VALUE '-'.
           05 PRT-OPR        PIC X(04).
           05 FILLER         PIC X(01) VALUE '-'.
           05 PRT-RC         PIC X(05).
           05 FILLER         PIC X(01) VALUE '-'.
           05 PRT-COMMENT    PIC X(20).
      *INTERNAL VARIABLES.
       WORKING-STORAGE SECTION.
       01  WS-WORK-AREA.
           05 ACCT-ST           PIC 9(02).
              88 ACCT-EOF       VALUE 10.
              88 ACCT-SUCCESS   VALUE 00
                                    97.
           05 INP-ST            PIC 9(02).
              88 INP-EOF        VALUE 10.
              88 INP-SUCCESS    VALUE 00
                                    97.
           05 PRT-ST            PIC 9(02).
              88 PRT-SUCCESS    VALUE 00
                                    97.
           05 INVALID-KEY       PIC X(01).
              88 INVL-KEY       VALUE 'Y'.
           05 ACCT-NAME-O       PIC X(15) VALUE SPACES.
           05 COUNTER-VARS.
              07 COUNTER-I      PIC 9(02) VALUE ZEROS.
              07 COUNTER-O      PIC 9(02) VALUE 1.
       PROCEDURE DIVISION.
      *MAIN LOOOP
       0000-MAIN.
           PERFORM H100-OPEN-FILES.
           PERFORM H200-PROCESS UNTIL INP-EOF.
           PERFORM H999-PROGRAM-EXIT.
      *OPEN FILES AND CHECK STATUS
       H100-OPEN-FILES.
           OPEN I-O ACCT-REC.
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
           READ ACCT-REC
              INVALID KEY MOVE 'Y' TO INVALID-KEY.
           IF NOT INVL-KEY
              IF (NOT ACCT-SUCCESS)
                DISPLAY 'UNABLE TO READ5 FILE: ' ACCT-ST
                MOVE ACCT-ST TO RETURN-CODE
                PERFORM H999-PROGRAM-EXIT
           END-IF.
       H100-END. EXIT.
      *PROGRAM LOGIC
       H200-PROCESS.
           INITIALIZE PRINT-REC.
           IF NOT INVL-KEY AND VLD-OPR
              PERFORM H400-OPR-PRCS
              MOVE ACCT-ID                  TO PRT-ID
              MOVE '-'                      TO PRINT-REC (6:1)
              PERFORM H500-EVAL-OPR-PRT
              MOVE '-'                      TO PRINT-REC (11:1)
              MOVE 'RC:00'                  TO PRT-RC
              MOVE '-'                      TO PRINT-REC (17:1)
              MOVE 'OPERATION COMPLETED'    TO PRT-COMMENT
           ELSE
              IF INVL-KEY
                 IF INP-OPR = 'W'
                    PERFORM H450-WRITE-NEW
                    MOVE ACCT-ID                  TO PRT-ID
                    MOVE '-'                      TO PRINT-REC (6:1)
                    PERFORM H500-EVAL-OPR-PRT
                    MOVE '-'                      TO PRINT-REC (11:1)
                    MOVE 'RC:00'                  TO PRT-RC
                    MOVE '-'                      TO PRINT-REC (17:1)
                    MOVE 'REGISTRATION ADDED'     TO PRT-COMMENT
                 ELSE
                    MOVE ACCT-ID                  TO PRT-ID
                    MOVE '-'                      TO PRINT-REC (6:1)
                    PERFORM H500-EVAL-OPR-PRT
                    MOVE '-'                      TO PRINT-REC (11:1)
                    MOVE 'RC:23'                  TO PRT-RC
                    MOVE '-'                      TO PRINT-REC (17:1)
                    MOVE 'NO RECORDS FOUND'       TO PRT-COMMENT
                 END-IF
              ELSE
                 PERFORM H400-OPR-PRCS
                 MOVE ACCT-ID                  TO PRT-ID
                 MOVE '-'                      TO PRINT-REC (6:1)
                 PERFORM H500-EVAL-OPR-PRT
                 MOVE '-'                      TO PRINT-REC (11:1)
                 MOVE 'RC:??'                  TO PRT-RC
                 MOVE '-'                      TO PRINT-REC (17:1)
                 MOVE 'INVALID OPERATION'      TO PRT-COMMENT
              END-IF
           END-IF.
           WRITE PRINT-REC
           INITIALIZE INVALID-KEY
           READ INP-REC.
           COMPUTE ACCT-ID = FUNCTION NUMVAL (INP-ID).
           READ ACCT-REC
              INVALID KEY MOVE 'Y' TO INVALID-KEY.
       H200-END. EXIT.
      *CLOSE I/O FILES
       H300-CLOSE-FILES.
           CLOSE ACCT-REC
                 PRINT-LINE
                 INP-REC.
       H300-END. EXIT.
      *EVALUATE THE OPERATION
       H400-OPR-PRCS.
           EVALUATE INP-OPR
              WHEN "R"
                 DISPLAY 'READ DONE -> ' ACCT-FIELDS
              WHEN "U"
                 INSPECT ACCT-SURNAME REPLACING ALL 'E' BY 'I'
                 INSPECT ACCT-SURNAME REPLACING ALL 'A' BY 'E'
                 PERFORM H600-SPACE-REMOVER
                 DISPLAY 'UPDT DONE -> ' ACCT-FIELDS
              WHEN "W"
                 MOVE 'MERT MUSA'        TO ACCT-NAME
                 MOVE 'TEMEL'            TO ACCT-SURNAME
                 DISPLAY 'WRIT DONE -> ' ACCT-FIELDS
              WHEN "D"
                 DELETE ACCT-REC
                 END-DELETE
                 DISPLAY 'DELT DONE -> ' ACCT-FIELDS
              WHEN OTHER
                 DISPLAY 'INVD DONE -> ' ACCT-FIELDS
           END-EVALUATE.
           REWRITE ACCT-FIELDS
           END-REWRITE.
       H400-END. EXIT.
      *WRITE NEW RECORD
       H450-WRITE-NEW.
           MOVE 482                TO ACCT-CUR
           MOVE 'MERT MUSA'        TO ACCT-NAME
           MOVE 'TEMEL'            TO ACCT-SURNAME
           MOVE SPACES             TO ACCT-FIELDS (36:12)
           WRITE ACCT-FIELDS
           DISPLAY 'WRTN DONE -> ' ACCT-FIELDS.
       H450-END. EXIT.
      *INPUT OPERATOON CHECK
       H500-EVAL-OPR-PRT.
           EVALUATE INP-OPR
              WHEN "R"
                 MOVE 'READ'             TO PRT-OPR
              WHEN "U"
                 MOVE 'UPDT'             TO PRT-OPR
              WHEN "W"
                 MOVE 'WRIT'             TO PRT-OPR
              WHEN "D"
                 MOVE 'DELT'             TO PRT-OPR
              WHEN OTHER
                 MOVE 'INVD'             TO PRT-OPR
           END-EVALUATE.
       H500-END. EXIT.
      *SPACE REMOVE
       H600-SPACE-REMOVER.
           PERFORM VARYING COUNTER-I FROM 1 BY 1
              UNTIL COUNTER-I > LENGTH OF  ACCT-NAME
              IF ACCT-NAME (COUNTER-I:1) = ' '
                 CONTINUE
              ELSE
                 MOVE  ACCT-NAME      (COUNTER-I:1) TO
                       ACCT-NAME-O    (COUNTER-O:1)
                 ADD 1 TO COUNTER-O
              END-IF
           END-PERFORM.
           MOVE ACCT-NAME-O     TO ACCT-NAME.
           MOVE 1               TO COUNTER-O.
           MOVE SPACES          TO ACCT-NAME-O.
       H-600-END. EXIT.
      *END THE PROGRAM
       H999-PROGRAM-EXIT.
           PERFORM H300-CLOSE-FILES.
           STOP RUN.
       H999-END. EXIT.
      *
