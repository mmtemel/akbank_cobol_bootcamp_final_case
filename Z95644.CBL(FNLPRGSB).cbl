       IDENTIFICATION DIVISION.
      *SUB PROGRAM
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
      *INTERNAL VARIABLES.
       WORKING-STORAGE SECTION.
       01  WS-WORK-AREA.
           05 ACCT-ST           PIC 9(02).
              88 ACCT-EOF       VALUE 10.
              88 ACCT-SUCCESS   VALUE 00
                                      97.
           05 INVALID-KEY       PIC X(01).
              88 INVL-KEY       VALUE 'Y'.
           05 ACCT-NAME-O       PIC X(15) VALUE SPACES.
           05 COUNTER-VARS.
              07 COUNTER-I      PIC 9(02) VALUE ZEROS.
              07 COUNTER-O      PIC 9(02) VALUE 1.
           05 WS-COMMENT-FILLER.
              07 WS-FL          PIC X(01) VALUE '-'.
              07 WS-OPR-P       PIC X(04).
              07 WS-RC          PIC 9(02) VALUE 00.
              07 WS-CMT         PIC X(30) VALUE SPACES.
              07 WS-OPR         PIC X(01).
                 88 VLD-OPR        VALUE  'R'
                                          'U'
                                          'W'
                                          'D'.
      *LINKAGE SECTION VARIABLES
      *RECEIVED FROM MAIN PROGRAM
       LINKAGE SECTION.
       01  LS-SUB-AREA.
           05 LS-OPR            PIC X(01).
           05 LS-ID             PIC X(05).
           05 LS-CMT            PIC X(45).
           05 LS-SUB-CALLED     PIC 9(01).
              88 SUB-CALL-NS    VALUE 00.
              88 SUB-CALL-SC    VALUE 01.
       PROCEDURE DIVISION USING LS-SUB-AREA.
      *MAIN LOOOP
       0000-MAIN.
           PERFORM H100-OPEN-FILES.
           PERFORM H200-PROCESS.
           PERFORM H999-PROGRAM-EXIT.
      *OPEN VSAM FILE AND CHECK STATUS
       H100-OPEN-FILES.
           OPEN I-O ACCT-REC.
           IF (NOT ACCT-SUCCESS)
              STRING
                  'UNABLE TO OPEN VSAM FILE RETURN CODE: ' ACCT-ST
                  DELIMITED BY SIZE INTO LS-CMT
              DISPLAY 'UNABLE TO OPEN1 FILE: ' ACCT-ST
              MOVE ACCT-ST TO RETURN-CODE
              PERFORM H999-PROGRAM-EXIT
           END-IF.
           INITIALIZE INVALID-KEY.
           COMPUTE ACCT-ID = FUNCTION NUMVAL (LS-ID).
           READ ACCT-REC
              INVALID KEY MOVE 'Y' TO INVALID-KEY.
           IF NOT INVL-KEY
              IF (NOT ACCT-SUCCESS)
                 STRING
                     'UNABLE TO OPEN VSAM AFTER READ CODE: ' ACCT-ST
                     DELIMITED BY SIZE INTO LS-CMT
                DISPLAY 'UNABLE TO READ5 FILE: ' ACCT-ST
                MOVE ACCT-ST TO RETURN-CODE
                PERFORM H999-PROGRAM-EXIT
           END-IF.
       H100-END. EXIT.
      *CHECK IF KEY AND OPERATION ARE VALID
      *IF BOTH OK, PERFORM THE OPERATION
      *IF INVALID KEY AND 'W' THEN ADD NEW RECORD
      *IF INVALID KEY THEN OUTPUT 'NO RECORD FOUND'
      *IF INVALID OPERATION THEN WRITE TO OUTPUT
       H200-PROCESS.
           MOVE LS-OPR TO WS-OPR.
           INITIALIZE LS-CMT.
           IF NOT INVL-KEY AND VLD-OPR
              PERFORM H400-OPR-PRCS
              MOVE 00                       TO WS-RC
              MOVE 'OPERATION COMPLETED'    TO WS-CMT
           ELSE
              IF INVL-KEY
                 IF WS-OPR = 'W'
                    PERFORM H450-WRITE-NEW
                    MOVE 00                       TO WS-RC
                    MOVE 'REGISTRATION ADDED'     TO WS-CMT
                 ELSE
                    PERFORM H400-OPR-PRCS
                    MOVE 23                       TO WS-RC
                    MOVE 'NO RECORDS FOUND'       TO WS-CMT
                 END-IF
              ELSE
                 PERFORM H400-OPR-PRCS
                 MOVE 01                       TO WS-RC
                 MOVE 'INVALID OPERATION'      TO WS-CMT
              END-IF
           END-IF.
           PERFORM H700-STRING-FOR-COMMENT.
       H200-END. EXIT.
      *EXECUTE THE PROCESS ACCORDING TO LETTER RECEIVED
       H400-OPR-PRCS.
           EVALUATE WS-OPR
              WHEN "R"
                 MOVE 'READ'             TO WS-OPR-P
                 DISPLAY 'READ DONE -> ' ACCT-FIELDS
              WHEN "U"
                 MOVE 'UPDT'             TO WS-OPR-P
                 INSPECT ACCT-SURNAME REPLACING ALL 'E' BY 'I'
                 INSPECT ACCT-SURNAME REPLACING ALL 'A' BY 'E'
                 PERFORM H600-SPACE-REMOVER
                 DISPLAY 'UPDT DONE -> ' ACCT-FIELDS
              WHEN "W"
                 MOVE 'WRIT'             TO WS-OPR-P
                 MOVE 'MERT MUSA'        TO ACCT-NAME
                 MOVE 'TEMEL'            TO ACCT-SURNAME
                 DISPLAY 'WRIT DONE -> ' ACCT-FIELDS
              WHEN "D"
                 MOVE 'DELT'             TO WS-OPR-P
                 DELETE ACCT-REC
                 END-DELETE
                 DISPLAY 'DELT DONE -> ' ACCT-FIELDS
              WHEN OTHER
                 MOVE 'INVD'             TO WS-OPR-P
                 DISPLAY 'INVD DONE -> ' ACCT-FIELDS
           END-EVALUATE.
           REWRITE ACCT-FIELDS
           END-REWRITE.
       H400-END. EXIT.
      *FOR ADDIND NEW RECORD
       H450-WRITE-NEW.
           MOVE 'WRIT'             TO WS-OPR-P
           MOVE 482                TO ACCT-CUR
           MOVE 'MERT MUSA'        TO ACCT-NAME
           MOVE 'TEMEL'            TO ACCT-SURNAME
           MOVE SPACES             TO ACCT-FIELDS (36:12)
           WRITE ACCT-FIELDS
           DISPLAY 'WRTN DONE -> ' ACCT-FIELDS.
       H450-END. EXIT.
      *REMOVE SPACES IN THE NAME FIELD
       H600-SPACE-REMOVER.
           PERFORM VARYING COUNTER-I FROM 1 BY 1
              UNTIL COUNTER-I > LENGTH OF  ACCT-NAME
              IF ACCT-NAME (COUNTER-I:1) = ' '
                 CONTINUE
              ELSE
                 MOVE  ACCT-NAME (COUNTER-I:1) TO
                       ACCT-NAME-O (COUNTER-O:1)
                 ADD 1 TO COUNTER-O
              END-IF
           END-PERFORM.
           MOVE ACCT-NAME-O     TO ACCT-NAME.
           MOVE 1               TO COUNTER-O.
           MOVE SPACES          TO ACCT-NAME-O.
       H-600-END. EXIT.
      *CONCATENATE COMMENT STRING THAT WILL BE SENT TO MAIN
       H700-STRING-FOR-COMMENT.
           STRING
                 WS-FL WS-OPR-P WS-FL 'RC:' WS-RC WS-FL WS-CMT
                 DELIMITED BY SIZE INTO LS-CMT.
       H700-END. EXIT.
      *END THE PROGRAM
       H999-PROGRAM-EXIT.
           CLOSE ACCT-REC.
           EXIT PROGRAM.
       H999-END. EXIT.
      *
