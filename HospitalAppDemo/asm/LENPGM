* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * **          
* This program read a 255 byte input string, reverses it, fills low- *          
* values with spaces and return the length of the string to the      *          
* caller.                                                            *          
* Program Input : 255 byte input string                              *          
* Program Output: Length of Input String                             *          
* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * **          
* Sample COBOL invocation :                                          *          
* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * **          
*   WORKING-STORAGE SECTION.                                         *          
*   01 WORK1.                                                        *          
*     02 STRING1 PIC X(255).                                         *          
*   01 WORK2.                                                        *          
*     02 LEN1   PIC S9(4).                                           *          
*   PROCEDURE DIVISION.                                              *          
*   PROGRAM-PARA.                                                    *          
*       MOVE 'INPUT STRING            ' TO STRING1.                  *          
*       CALL 'LENPGM' USING WORK1, WORK2                            *           
*String length will be returned in variable LEN1.                    *          
* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * **          
LENPGM   CSECT                                                                  
         STM   14,12,12(13)      HOUSEKEEPING                                   
         LR    12,15             LOAD BASE REGISTER WITH PGM ENTRY              
         USING LENPGM,12         ESTABLISH BASE REGISTER                        
         LR    11,13             LOAD OLD SAVEA TO R11                          
         LA    13,SAVE           LOAD NEW SAVEA TO R13                          
         ST    11,4(13)          BACKWARD CHAIN                                 
         ST    13,8(11)          FWD CHAIN                                      
*                                                                               
         L     R7,0(R1)          LOAD PARM ADDRESS TO R7(STRING VAR)            
         L     R8,4(R1)          LOAD PARM ADDRESS TO R8(LENGTH VAR)            
         MVC   STR1,0(R7)        MOVE INPUT STRING TO STR1                      
*                                                                               
*                                                                               
         LA    R2,STR1           ADDRESS STR1                                   
         LA    R1,STR2           ADDRESS STR2                                   
         MVCIN 0(255,1),254(2)   REVERSE INPUT STR1                             
*                                                                               
         LA    R5,STR2           LOAD STR2(REVERSED STRING)                     
         LA    R4,255            LOAD MAX VALUE                                 
         SR    R10,R10           CLEAR R10                                      
LOOP1    DS    0H                LOOP1 ROUTINE                                  
         CLI   0(R5),X'00'       CHECK FOR NULL                                 
         BE    MLOWVAL           FOUND ? BRANCH TO MLOWVAL                      
         B     AROUND1           NO ? BRANCH TO AROUND1                         
MLOWVAL  DS    0H                                                               
         MVI   0(R5),C' '        CONVERT LOW VALUES TO SPACES                   
AROUND1  DS    0H                                                               
         LA    R5,1(R5)          BUMP R5                                        
         BCT   R4,LOOP1          DECREMENT R4 AND GOTO LOOP1                    
*                                                                               
         LA    R5,STR2           ADDRESS STR2                                   
         LA    R4,255            LOAD MAX VALUE OF I/P TO R4                    
LOOP2    DS    0H                LOOP2 ROUTINE START                            
         CLI   0(R5),C' '        COMPARE STR2 FOR SPACE                         
         BNE   OUTSIDE           NOT FOUND? GET OUT OF LOOP2                    
         LA    R10,1(R10)        SPACE FOUND - BUMP SPACE COUNT R10             
         LA    R5,1(R5)          BUMP R5 - TO NEXT BYTE OF STR2                 
         BCT   R4,LOOP2          DECREMENT R4 AND GOTO LOOP2                    
OUTSIDE  DS    0H                                                               
         LR    R10,R4            LEN OF STRING IN R4 GOES TO R10                
*                                                                               
         CVD   R10,DEC1          CONVERT R10 TO PACKED                          
         UNPK  LEN1,DEC1         UNPACK IT                                      
         MVC   0(4,R8),LEN1      MOVE LENGTH TO OUTPUT AREA                     
*                                                                               
AROUND   DS    0H                                                               
         L     R13,SAVE+4                                                       
         LM    14,12,12(13)                                                     
         LA    15,0                                                             
         BR    14                                                               
*                                                                               
*  PROGRAM VARIABLES/CONSTANTS                                                  
*                                                                               
SAVE     DS    18F                                                              
STR1     DS    CL255                                                            
STR2     DS    CL255                                                            
DEC1     DS    D                                                                
LEN1     DS    CL4                                                              
         YREGS                                                                  
         END   LENPGM                                                           
