# Akbank Cobol Bootcamp Final Case

## Creating Necessary Files and Launching

1. Submit job **INPFILE0** to create **QSAM.INPFILE** input file.
2. Submit job **SORTEJ02** then submit job **DELDEF01** to create **VSAM.AA** file.
3. Submit job **FNLPRGMJ** to launch the main program and subprogram that process the VSAM file according to the input file's instructions and writes the output to the **QSAM.OUTLINE** output file.

## Main Program

The main COBOL program is named '**FNLPRGMN**'. It reads records from the INP-REC file, passes the data to a sub-program called '**FNLPRGSB**', and writes the results to the PRINT-LINE file. Please refer to the code for more details and specific implementation.

### Author

- Mert Musa TEMEL

### Files
The program operates on the following files:

#### INP-REC

- File Name: INPFILE
- Recording Mode: F
- Status: INP-ST

#### PRINT-LINE

- File Name: PRTLINE
- Recording Mode: F
- Status: PRT-ST

### Data Structure

- The program uses the following data structure:

#### INP-REC

```
FD  INP-REC    RECORDING MODE F.
01  INP-FIELDS.
   05 INP-OPR           PIC X(01).
   05 INP-ID            PIC X(05).
```

#### PRINT-LINE

```
FD  PRINT-LINE RECORDING MODE F.
01  PRINT-REC.
   05 PRT-ID            PIC X(05).
   05 PRT-CMT           PIC X(45).
```

### Procedure

The program follows the following procedure:

1. Open the necessary files and check the status.
2. Enter the main loop and perform the processing until the end of the INP-REC file is reached.
3. Exit the program.

### Program Logic

The program consists of the following logic:

#### 0000-MAIN

- Perform the necessary setup and enter the main loop.
- Exit the program when the loop is completed.

#### H100-OPEN-FILES

- Open the INP-REC and PRINT-LINE files.
- Check the status of each file and exit the program if any of them fail to open.
- Read the first record from INP-REC.

#### H200-PROCESS

- Initialize the PRINT-REC.
- Move data from INP-REC to the working storage area.
- Call the sub-program 'FNLPRGSB' using the working storage area.
- Move data received from the sub-program to PRINT-REC and write it.
- Read the next record from INP-REC.

#### H300-CLOSE-FILES

- Close the PRINT-LINE and INP-REC files.

#### H999-PROGRAM-EXIT

- Perform the necessary cleanup by closing the files.
- Stop the execution of the program.

## Sub Program

The COBOL sub-program named FNLPRGSB performs operations on a VSAM file based on the operation received from the main program. It supports operations like read, update, write, and delete. Please refer to the code for more details and specific implementation.

### Author

- Mert Musa TEMEL

### File

- The sub-program operates on the following file:

#### ACCT-REC

- File Name: ACCTREC
- Organization: Indexed
- Access: Random
- Record: ACCT-KEY
- Status: ACCT-ST

### Data Structure

The sub-program uses the following data structure:

#### ACCT-REC

- File Description: VSAM File
- Record Length: 47 characters

```
FD  ACCT-REC.
01  ACCT-FIELDS.
   03 ACCT-KEY.
      05 ACCT-ID     PIC S9(05) COMP-3.
   03 ACCT-CUR       PIC S9(03) COMP.
   03 ACCT-NAME      PIC X(15).
   03 ACCT-SURNAME   PIC X(15).
   03 FILLER         PIC X(12) VALUE SPACES.
```

### Procedure

The sub-program follows the following procedure:

1. Open the VSAM file and check the status.
2. Check if the key and operation received from the main program are valid.
3. Perform the operation accordingly.
4. Concatenate the comment string for output to the main program.
5. Exit the sub-program.

### Program Logic

The sub-program consists of the following logic:

#### H100-OPEN-FILES
- Open the ACCT-REC file.
- Check the status of the file and exit the sub-program if it fails to open.
- Initialize the INVALID-KEY flag.
- Read the record from ACCT-REC.
- If there is an invalid key, set the INVALID-KEY flag.
- If there is no invalid key, check the status of the file after the read operation and exit the sub-program if it fails to read.

#### H200-PROCESS

- Move the operation received from the main program to the working storage area.
- Initialize the comment field received from the main program.
- If there is no invalid key and the operation is valid, perform the operation accordingly.
- If there is an invalid key, check the operation:
  - If the operation is 'W' (Write), add a new record.
  - If the operation is invalid, output 'NO RECORDS FOUND'.
- If the operation is invalid, output 'INVALID OPERATION'.
- Concatenate the comment string for output to the main program.

#### H400-OPR-PRCS

- Execute the process according to the operation received:
  - If the operation is 'R' (Read), display the record.
  - If the operation is 'U' (Update), replace 'E' with 'I' and 'A' with 'E' in the surname field.
  - If the operation is 'W' (Write), update the name and surname fields.
  - If the operation is 'D' (Delete), delete the record.
  - If the operation is invalid, output 'INVALID OPERATION'.
- Rewrite the record after the operation.

#### H450-WRITE-NEW

- Write a new record with predefined values.

#### H600-SPACE-REMOVER

- Remove spaces in the name field.

#### H700-STRING-FOR-COMMENT

- Concatenate the comment string for output to the main program.

#### H999-PROGRAM-EXIT

- Close the ACCT-REC file.
- Exit the sub-program.
