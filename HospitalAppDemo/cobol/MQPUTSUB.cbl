       IDENTIFICATION DIVISION.                                                 
      *------------------------                                                 
       PROGRAM-ID. MQPUTSUB.                                                    
      ***************************************************************           
      *  NAME    : MQPUTSUB                                                     
      *  PURPOSE : MQPUTSUB IS A SUBPROGRAM WHOSE MAIN FUNCTION IS              
      *            TO PUT A MESSAGE TO A QUEUE.                                 
      * -------------------------------------------------------------           
      *   DATE      DESCRIPTION                                                 
      * ----------  ---------------------------------------------------         
      * 01JUN2010   V 1.0 - INITIAL CREATION                                    
      ***************************************************************           
      *                                                                         
       ENVIRONMENT DIVISION.                                                    
      *---------------------                                                    
       CONFIGURATION SECTION.                                                   
      *----------------------                                                   
       SOURCE-COMPUTER.   IBM.                                                  
       OBJECT-COMPUTER.   IBM.                                                  
      *                                                                         
       INPUT-OUTPUT SECTION.                                                    
      *---------------------                                                    
       FILE-CONTROL.                                                            
           SELECT USRPARM ASSIGN TO USRPARM.                                    
      *                                                                         
       DATA DIVISION.                                                           
      *--------------                                                           
      *                                                                         
       FILE SECTION.                                                            
      *-------------                                                            
       FD  USRPARM                                                              
           RECORDING MODE F.                                                    
       01  USRPARM-RECORD              PIC X(0080).                             
      *                                                                         
       WORKING-STORAGE SECTION.                                                 
      *------------------------                                                 
      *                                                                         
      *    Constants                                                            
      *                                                                         
       01  WC-PROGRAM-NAME             PIC X(00008) VALUE 'MQPUTSUB'.           
       01  WC-PROGRAM-VERSION          PIC X(00004) VALUE 'V1.0'.               
       01  WC-DISPLAY-PREFIX           PIC X(00002) VALUE '* '.                 
       01  WC-DELIMITER                PIC X(00001) VALUE '='.                  
       01  WC-SERIOUS-ERROR            PIC 9(00002) VALUE 8.                    
       01  WC-USRPARMS.                                                         
           05  WC-QMGR                 PIC X(00004) VALUE 'QMGR'.               
           05  WC-QUEUE                PIC X(00005) VALUE 'QUEUE'.              
           05  WC-DEBUG                PIC X(00005) VALUE 'DEBUG'.              
       01  WC-CA-ACTIONS.                                                       
           05  WC-CONNECT-ACTION       PIC X(00004) VALUE 'CONN'.               
           05  WC-PUT1-ACTION          PIC X(00004) VALUE 'PUT1'.               
           05  WC-DISCONNECT-ACTION    PIC X(00004) VALUE 'DISC'.               
       01  WC-CA-DEBUG-MODES.                                                   
           05  WC-NO-DEBUG             PIC X(00001) VALUE '0'.                  
           05  WC-MINIMAL-DEBUG        PIC X(00001) VALUE '1'.                  
       01  WC-MQ-ACTIONS.                                                       
           05  WC-CONNECT-TEXT         PIC X(00008) VALUE 'MQCONN  '.           
           05  WC-PUT1-TEXT            PIC X(00008) VALUE 'MQPUT1  '.           
           05  WC-DISCONNECT-TEXT      PIC X(00008) VALUE 'MQDISC  '.           
       01  WC-ERROR-NUMBERS.                                                    
           05  WC-INVALID-ACTION       PIC 9(00004) VALUE 9001.                 
           05  WC-INVALID-QMGR         PIC 9(00004) VALUE 9002.                 
           05  WC-INVALID-QUEUE        PIC 9(00004) VALUE 9003.                 
           05  WC-INVALID-USRPARM      PIC 9(00004) VALUE 9004.                 
       01  WC-B117-COMPILED-INFO.                                               
           10  FILLER              PIC X(00015)                                 
           VALUE 'When Compiled: '.                                             
           10  WS-WHEN-COMPILED-EDT.                                            
               15  WS-COMP-DD-EDT  PIC X(00003).                                
               15  WS-COMP-MM-EDT  PIC X(00003).                                
               15  WS-COMP-YY-EDT  PIC X(00002).                                
               15  FILLER          PIC X(00001) VALUE ' '.                      
               15  WS-COMP-TIME-E  PIC X(00008).                                
           10  FILLER              PIC X(00008) VALUE SPACES.                   
       01  WC-PARAGRAPHS.                                                       
           05  WC-B000-INITIALISE      PIC X(00040)                             
               VALUE 'Starting B000-INITIALISE                '.                
           05  WC-C000-PROCESS         PIC X(00040)                             
               VALUE 'Starting C000-PROCESS                   '.                
           05  WC-C200-CONNECT         PIC X(00040)                             
               VALUE 'Starting C200-CONNECT                   '.                
           05  WC-C210-PERFORM-CONNECT PIC X(00040)                             
               VALUE 'Starting C210-PERFORM-CONNECT           '.                
           05  WC-C300-PERFORM-PUT     PIC X(00040)                             
               VALUE 'Starting C300-PERFORM-PUT               '.                
           05  WC-C400-DISCONNECT      PIC X(00040)                             
               VALUE 'Starting C400-DISCONNECT                '.                
           05  WC-C430-PERFORM-DISC    PIC X(00040)                             
               VALUE 'Starting C430-PERFORM-DISC              '.                
           05  WC-D000-FINALISE        PIC X(00040)                             
               VALUE 'Starting D000-FINALISE                  '.                
           05  WC-D100-DISPLAY-STATS   PIC X(00040)                             
               VALUE 'Starting D100-DISPLAY-STATISTICS        '.                
       01  WC-STATUS-TEXT.                                                      
           05  WC-C200-CONNECT-OK      PIC X(00040)                             
               VALUE 'MQCONN Successful                       '.                
           05  WC-C300-PUT-OK          PIC X(00040)                             
               VALUE 'MQPUT Successful                        '.                
           05  WC-C430-DISCONNECT-OK   PIC X(00040)                             
               VALUE 'MQDISC Successful                       '.                
      *                                                                         
      *    Flags                                                                
      *                                                                         
       01  FL-EOF-FLAG                 PIC 9(00001).                            
           88  NOT-EOF                 VALUE 0.                                 
           88  EOF                     VALUE 1.                                 
       01  FL-ERROR-FLAG               PIC 9(00001).                            
           88 NO-ERRORS-SO-FAR         VALUE 0.                                 
           88 ERROR-OCCURRED           VALUE 1.                                 
      *                                                                         
      *    Communication Block:                                                 
      *    Used to transfer information between calls to this program           
      *    from the same instance of the calling program                        
      *                                                                         
       01  WS-BUFFER-LEN               PIC S9(0009) COMP VALUE 0.               
       01  WS-MSG-BUFFER               PIC X(02964).                            
       01  WS-COMM-BLOCK.                                                       
           05  WS-COMM-QUEUE           PIC X(00048).                            
           05  WS-CONNECT-HANDLE       PIC S9(0009) BINARY.                     
           05  WS-PUT1-COUNT           PIC S9(0009) BINARY.                     
           05  WS-DEBUG                PIC X(00001).                            
               88  NO-DEBUG            VALUE '0'.                               
               88  MINIMAL-DEBUG       VALUE '1'.                               
      *                                                                         
      *    SYSOUT Message                                                       
      *                                                                         
       01  WS-DISPLAY-LINE.                                                     
           05  WS-DISPLAY-PREFIX       PIC X(00002) VALUE SPACES.               
           05  WS-DISPLAY-PROGRAM      PIC X(00008).                            
           05  FILLER                  PIC X(00001) VALUE ' '.                  
           05  WS-DISPLAY-VERSION      PIC X(00004).                            
           05  FILLER                  PIC X(00001) VALUE ' '.                  
           05  WS-DISPLAY-DD           PIC 9(00002).                            
           05  FILLER                  PIC X(00001) VALUE '/'.                  
           05  WS-DISPLAY-MM           PIC 9(00002).                            
           05  FILLER                  PIC X(00001) VALUE '/'.                  
           05  WS-DISPLAY-YYYY         PIC 9(00004).                            
           05  FILLER                  PIC X(00001) VALUE ' '.                  
           05  WS-DISPLAY-HOURS        PIC 9(00002).                            
           05  FILLER                  PIC X(00001) VALUE ':'.                  
           05  WS-DISPLAY-MINS         PIC 9(00002).                            
           05  FILLER                  PIC X(00001) VALUE ':'.                  
           05  WS-DISPLAY-SECS         PIC 9(00002).                            
           05  FILLER                  PIC X(00001) VALUE '.'.                  
           05  WS-DISPLAY-SUBSECS      PIC 9(00002).                            
           05  FILLER                  PIC X(00002) VALUE '- '.                 
           05  WS-DISPLAY-MESSAGE      PIC X(00040).                            
       01  WS-ERROR-MESSAGES.                                                   
           05  WS-INVALID-ACTION.                                               
               10  FILLER              PIC X(00025)                             
               VALUE '**Invalid Action Val.** :'.                               
               10  WS-INVL-ACTION-VAL  PIC X(00004).                            
               10  FILLER              PIC X(00011) VALUE SPACES.               
           05  WS-INVALID-QMGR.                                                 
               10  FILLER              PIC X(00030)                             
               VALUE '**QMGR not specified      ** :'.                          
               10  FILLER              PIC X(00010) VALUE SPACES.               
           05  WS-INVALID-QUEUE.                                                
               10  FILLER              PIC X(00030)                             
               VALUE '**QUEUE not specified     ** :'.                          
               10  FILLER              PIC X(00010) VALUE SPACES.               
           05  WS-INVALID-USRPARM.                                              
               10  FILLER              PIC X(00025)                             
               VALUE '**Invalid Parameter  ** :'.                               
               10  WS-INVL-USRPARM-VAL PIC X(00015).                            
      *                                                                         
      *    Date and Time work fields                                            
      *                                                                         
00369  01  WS-WHEN-COMPILED.                                                    
00369      05  WS-WHEN-COMP-MM             PIC X(00003).                        
00369      05  WS-WHEN-COMP-DD             PIC X(00003).                        
00369      05  WS-WHEN-COMP-YY             PIC X(00002).                        
00369      05  WS-WHEN-COMP-TIME           PIC X(00008).                        
       01  WS-DATE.                                                             
           05  WS-DATE-YYYY            PIC 9(00004).                            
           05  WS-DATE-MM              PIC 9(00002).                            
           05  WS-DATE-DD              PIC 9(00002).                            
       01  WS-TIME.                                                             
           05  WS-TIME-HOURS           PIC 9(00002).                            
           05  WS-TIME-MINS            PIC 9(00002).                            
           05  WS-TIME-SECS            PIC 9(00002).                            
           05  WS-TIME-SUBSECS         PIC 9(00002).                            
       01  WS-PUT-DATE                 PIC 9(00008).                            
       01  WS-GET-DATE                 PIC 9(00008).                            
       01  WS-PUT-TIME.                                                         
           05  WS-PUT-TIME-HOURS       PIC 9(00002).                            
           05  WS-PUT-TIME-MINS        PIC 9(00002).                            
           05  WS-PUT-TIME-SECS        PIC 9(00002).                            
           05  WS-PUT-TIME-SUBSECS     PIC 9(00002).                            
      *                                                                         
      *    Configuration Work Fields                                            
      *                                                                         
       01  WS-CONFIG-PARAMETERS.                                                
           05  WS-QMGR                 PIC X(00048).                            
           05  WS-QUEUE                PIC X(00048).                            
      *                                                                         
      *    Miscellaneous Work Fields                                            
      *                                                                         
       01  WS-PARM-SIZE                PIC S9(0008) COMP.                       
       01  WS-USRPARM-PAIRS.                                                    
           05 WS-USRPARM-NAME          PIC X(00020).                            
           05 WS-USRPARM-REST.                                                  
              10 WS-USRPARM-VALUE      PIC X(00050).                            
              10 FILLER                PIC X(00010).                            
       01  WS-ERROR-TEXT               PIC X(00040).                            
       01  WS-MQ-ERROR-TEXT.                                                    
           05  FILLER                  PIC X(00012)                             
               VALUE 'MQ Failure- '.                                            
           05  WS-MQ-ERROR-ACTION      PIC X(00008).                            
           05  FILLER                  PIC X(00001) VALUE ':'.                  
           05  WS-MQ-ERROR-CC          PIC 9(00004).                            
           05  FILLER                  PIC X(00001) VALUE '/'.                  
           05  WS-MQ-ERROR-REASON      PIC 9(00004).                            
           05  FILLER                  PIC X(00010)                             
               VALUE '.         '.                                              
      *                                                                         
      *    MQSeries API Fields                                                  
      *                                                                         
       01  WS-HCONN                    PIC S9(0009) COMP VALUE 0.               
       01  WS-HOBJ-REQUEST             PIC S9(0009) COMP VALUE 0.               
       01  WS-HOBJ-REPLY               PIC S9(0009) COMP VALUE 0.               
       01  WS-OPENOPTIONS              PIC S9(0009) COMP.                       
       01  WS-COMPCODE                 PIC S9(0009) COMP.                       
       01  WS-REASON                   PIC S9(0009) COMP.                       
      *                                                                         
      *    MQSeries API Control Blocks                                          
      *                                                                         
       01  MQM-OBJECT-DESCRIPTOR.                                               
           COPY CMQODV.                                                         
       01  MQM-PUT-MESSAGE-OPTIONS.                                             
           COPY CMQPMOV.                                                        
       01  MQM-CONSTANTS.                                                       
           COPY CMQV.                                                           
       01  MQM-PUT-MSGDESC.                                                     
            COPY CMQMDV.                                                        
      *                                                                         
       LINKAGE SECTION.                                                         
      *----------------                                                         
       01  CA-MQPUTSUB-PARM.                                                    
           05  CA-HEADER.                                                       
               10  CA-ACTION               PIC X(00004).                        
                   88  CONNECT-ACTION      VALUE 'CONN'.                        
                   88  PUTGET-ACTION       VALUE 'PUT1'.                        
                   88  DISCONNECT-ACTION   VALUE 'DISC'.                        
               10  CA-RETURN-CODE          PIC 9(00004).                        
               10  CA-REASON-CODE          PIC 9(00004).                        
               10  CA-COMM-BLOCK           PIC X(00057).                        
           05  CA-MESSAGE-LENGTH           PIC 9(00008).                        
           05  CA-MESSAGE                  PIC X(02964).                        
      *                                                                         
       PROCEDURE DIVISION USING CA-MQPUTSUB-PARM.                               
      *------------------------------------------                               
       A000-MAINLINE.                                                           
      *--------------                                                           
           PERFORM B000-INITIALISE                                              
           IF NO-ERRORS-SO-FAR                                                  
              PERFORM C000-PROCESS                                              
           END-IF                                                               
           PERFORM D000-FINALISE                                                
           GOBACK                                                               
           .                                                                    
      *                                                                         
       B000-INITIALISE.                                                         
      *----------------                                                         
      * **************************************************************          
      * ** Initialise key flags and storage areas.                  **          
      * ** If the action requested is to connect then get the       **          
      * ** runtime parameters.                                      **          
      * **************************************************************          
           MOVE CA-COMM-BLOCK              TO WS-COMM-BLOCK                     
           MOVE WC-DISPLAY-PREFIX          TO WS-DISPLAY-PREFIX                 
           MOVE WC-PROGRAM-NAME            TO WS-DISPLAY-PROGRAM                
           MOVE WC-PROGRAM-VERSION         TO WS-DISPLAY-VERSION                
           SET  NO-ERRORS-SO-FAR           TO TRUE                              
           MOVE ZEROES                     TO CA-RETURN-CODE                    
           IF CONNECT-ACTION                                                    
              INITIALIZE                   WS-COMM-BLOCK                        
              MOVE ZEROES                  TO WS-DEBUG                          
              PERFORM B100-GET-USRPARMS                                         
              IF NO-ERRORS-SO-FAR                                               
                 MOVE ZEROES               TO WS-PUT1-COUNT                     
                 MOVE WS-QUEUE             TO WS-COMM-QUEUE                     
                 PERFORM B117-DISPLAY-USRPARMS                                  
              END-IF                                                            
           END-IF                                                               
           PERFORM W500-STANDARD-DEBUG                                          
           .                                                                    
       B100-GET-USRPARMS.                                                       
      *------------------                                                       
      * **************************************************************          
      * ** Get the runtime parameters. Check that all mandatory     **          
      * ** parameters have been specified.                          **          
      * **************************************************************          
           PERFORM B111-SET-DEFAULTS                                            
           OPEN INPUT USRPARM                                                   
           SET  NOT-EOF                    TO TRUE                              
           READ USRPARM                                                         
              AT END SET EOF TO TRUE                                            
           END-READ                                                             
           PERFORM B110-READ-USRPARM                                            
              UNTIL EOF                                                         
           CLOSE USRPARM                                                        
           IF WS-QMGR = SPACES                                                  
              MOVE WS-INVALID-QMGR         TO WS-ERROR-TEXT                     
              MOVE WC-INVALID-QMGR         TO CA-REASON-CODE                    
              PERFORM W400-ERROR-OCCURRED                                       
           END-IF                                                               
           IF WS-QUEUE = SPACES                                                 
              MOVE WS-INVALID-QUEUE        TO WS-ERROR-TEXT                     
              MOVE WC-INVALID-QUEUE        TO CA-REASON-CODE                    
              PERFORM W400-ERROR-OCCURRED                                       
           END-IF                                                               
           .                                                                    
       B110-READ-USRPARM.                                                       
      *------------------                                                       
      * **************************************************************          
      * ** Read a runtime parameter. Determine which one it is.     **          
      * **************************************************************          
           MOVE SPACES        TO WS-USRPARM-PAIRS                               
           UNSTRING USRPARM-RECORD DELIMITED BY WC-DELIMITER                    
               OR ALL SPACES                                                    
               INTO WS-USRPARM-NAME                                             
                    WS-USRPARM-REST COUNT IN WS-PARM-SIZE                       
           END-UNSTRING                                                         
           EVALUATE WS-USRPARM-NAME                                             
              WHEN WC-QMGR                                                      
                 MOVE WS-USRPARM-VALUE(1:WS-PARM-SIZE)                          
                                           TO WS-QMGR                           
              WHEN WC-QUEUE                                                     
                 MOVE WS-USRPARM-VALUE(1:WS-PARM-SIZE)                          
                                           TO WS-QUEUE                          
              WHEN WC-DEBUG                                                     
                 PERFORM B113-SET-DEBUG                                         
              WHEN OTHER                                                        
                 MOVE WS-USRPARM-NAME      TO WS-INVL-USRPARM-VAL               
                 MOVE WS-INVALID-USRPARM   TO WS-ERROR-TEXT                     
                 MOVE WC-INVALID-USRPARM   TO CA-REASON-CODE                    
                 PERFORM W400-ERROR-OCCURRED                                    
           END-EVALUATE                                                         
           READ USRPARM                                                         
              AT END SET EOF TO TRUE                                            
           END-READ                                                             
           .                                                                    
       B111-SET-DEFAULTS.                                                       
      *------------------                                                       
      * **************************************************************          
      * ** Set defaults for each runtime parameter.                 **          
      * **************************************************************          
           MOVE SPACES                     TO WS-QMGR                           
           MOVE SPACES                     TO WS-QUEUE                          
           .                                                                    
00369  B117-DISPLAY-USRPARMS.                                                   
      *----------------------                                                   
      * **************************************************************          
      * ** display the parameters requested.                        **          
      * **************************************************************          
           MOVE WHEN-COMPILED           TO WS-WHEN-COMPILED                     
           MOVE WS-WHEN-COMP-MM         TO WS-COMP-MM-EDT                       
           MOVE WS-WHEN-COMP-DD         TO WS-COMP-DD-EDT                       
           MOVE WS-WHEN-COMP-YY         TO WS-COMP-YY-EDT                       
           MOVE WS-WHEN-COMP-TIME       TO WS-COMP-TIME-E                       
           MOVE WC-B117-COMPILED-INFO   TO WS-DISPLAY-MESSAGE                   
           DISPLAY '* *****************************************'                
           PERFORM W300-GET-TIMESTAMP                                           
           DISPLAY WS-DISPLAY-LINE                                              
           DISPLAY '* Parameters:'                                              
           DISPLAY '*  Queue Manager         - ', WS-QMGR                       
           DISPLAY '*  Queue Name            - ', WS-QUEUE                      
           DISPLAY '*  Debug Level           - ', WS-DEBUG                      
           DISPLAY '* *****************************************'                
           .                                                                    
       B113-SET-DEBUG.                                                          
      *---------------                                                          
      * **************************************************************          
      * ** Check the debug value specified is valid.                **          
      * ** If so, store the value specified in the COMM-BLOCK       **          
      * ** If not, report the error, set the error code and return  **          
      * **************************************************************          
           EVALUATE WS-USRPARM-VALUE                                            
              WHEN WC-NO-DEBUG                                                  
              WHEN WC-MINIMAL-DEBUG                                             
                 MOVE WS-USRPARM-VALUE     TO WS-DEBUG                          
              WHEN OTHER                                                        
                 MOVE ZEROES               TO WS-DEBUG                          
           END-EVALUATE                                                         
           .                                                                    
       C000-PROCESS.                                                            
      *-------------                                                            
      * **************************************************************          
      * ** Main Processing paragraph. Depending on the action       **          
      * ** supplied perform either Connect, Put/Get or Disconnect.  **          
      * ** If an invalid action is requested report this and end    **          
      * **************************************************************          
           MOVE WC-C000-PROCESS            TO WS-DISPLAY-MESSAGE                
           PERFORM W500-STANDARD-DEBUG                                          
           EVALUATE CA-ACTION                                                   
              WHEN WC-CONNECT-ACTION                                            
                 PERFORM C200-CONNECT                                           
              WHEN WC-PUT1-ACTION                                               
                 PERFORM C300-PERFORM-PUT                                       
              WHEN WC-DISCONNECT-ACTION                                         
                 PERFORM C400-DISCONNECT                                        
              WHEN OTHER                                                        
                 MOVE CA-ACTION            TO WS-INVL-ACTION-VAL                
                 MOVE WS-INVALID-ACTION    TO WS-ERROR-TEXT                     
                 MOVE WC-INVALID-ACTION    TO CA-REASON-CODE                    
                 PERFORM W400-ERROR-OCCURRED                                    
           END-EVALUATE                                                         
           .                                                                    
       C200-CONNECT.                                                            
      *-------------                                                            
      * **************************************************************          
      * ** Connect to the queue manager specified.                  **          
      * ** Open the request queue                                   **          
      * ** Open the reply queue                                     **          
      * ** If during any of these processes an error occurs, end    **          
      * **************************************************************          
           MOVE WC-C200-CONNECT            TO WS-DISPLAY-MESSAGE                
           PERFORM W500-STANDARD-DEBUG                                          
           PERFORM C210-PERFORM-CONNECT                                         
           .                                                                    
       C210-PERFORM-CONNECT.                                                    
      *---------------------                                                    
      * **************************************************************          
      * ** Connect to the queue manager specified.                  **          
      * ** If OK, store handle in COMM-BLOCK and display message    **          
      * ** If not, display message and end processing               **          
      * **************************************************************          
           MOVE WC-C210-PERFORM-CONNECT    TO WS-DISPLAY-MESSAGE                
           PERFORM W500-STANDARD-DEBUG                                          
           CALL 'MQCONN' USING WS-QMGR                                          
                               WS-HCONN                                         
                               WS-COMPCODE                                      
                               WS-REASON                                        
           END-CALL                                                             
           IF WS-COMPCODE = MQCC-OK                                             
              MOVE WC-C200-CONNECT-OK      TO WS-DISPLAY-MESSAGE                
              PERFORM W500-STANDARD-DEBUG                                       
              MOVE WS-HCONN                TO WS-CONNECT-HANDLE                 
           ELSE                                                                 
              MOVE WC-CONNECT-TEXT         TO WS-MQ-ERROR-ACTION                
              MOVE WS-COMPCODE             TO WS-MQ-ERROR-CC                    
              MOVE WS-REASON               TO WS-MQ-ERROR-REASON                
              MOVE WS-COMPCODE             TO CA-RETURN-CODE                    
              MOVE WS-REASON               TO CA-REASON-CODE                    
              MOVE WS-MQ-ERROR-TEXT        TO WS-ERROR-TEXT                     
              PERFORM W400-ERROR-OCCURRED                                       
           END-IF                                                               
           .                                                                    
       C300-PERFORM-PUT.                                                        
      *-----------------                                                        
      * **************************************************************          
      * ** Put the message to the request queue                     **          
      * ** If OK, get the reply                                     **          
      * ** If not continue without try to get the reply             **          
      * **************************************************************          
           MOVE WC-C300-PERFORM-PUT        TO WS-DISPLAY-MESSAGE                
           PERFORM W500-STANDARD-DEBUG                                          
           IF CA-MESSAGE-LENGTH = ZERO                                          
              MOVE LENGTH OF CA-MESSAGE    TO CA-MESSAGE-LENGTH                 
           END-IF                                                               
           MOVE MQOT-Q                     TO MQOD-OBJECTTYPE                   
           MOVE WS-COMM-QUEUE              TO MQOD-OBJECTNAME                   
           MOVE MQPER-PERSISTENT           TO MQMD-PERSISTENCE                  
           MOVE MQMT-DATAGRAM              TO MQMD-MSGTYPE                      
           MOVE MQFMT-STRING               TO MQMD-FORMAT                       
           MOVE MQMI-NONE                  TO MQMD-MSGID                        
           MOVE MQCI-NONE                  TO MQMD-CORRELID                     
           COMPUTE MQPMO-OPTIONS = MQPMO-NO-SYNCPOINT +                         
                                   MQPMO-FAIL-IF-QUIESCING                      
           MOVE CA-MESSAGE-LENGTH          TO WS-BUFFER-LEN                     
           MOVE CA-MESSAGE                 TO WS-MSG-BUFFER                     
           IF NO-ERRORS-SO-FAR                                                  
              CALL 'MQPUT1' USING WS-CONNECT-HANDLE                             
                                  MQOD                                          
                                  MQMD                                          
                                  MQPMO                                         
                                  WS-BUFFER-LEN                                 
                                  WS-MSG-BUFFER                                 
                                  WS-COMPCODE                                   
                                  WS-REASON                                     
              END-CALL                                                          
              IF WS-COMPCODE = MQCC-OK                                          
                 MOVE WC-C300-PUT-OK       TO WS-DISPLAY-MESSAGE                
                 PERFORM W500-STANDARD-DEBUG                                    
                 ADD 1                     TO WS-PUT1-COUNT                     
              ELSE                                                              
                 MOVE WC-PUT1-TEXT         TO WS-MQ-ERROR-ACTION                
                 MOVE WS-COMPCODE          TO WS-MQ-ERROR-CC                    
                 MOVE WS-REASON            TO WS-MQ-ERROR-REASON                
                 MOVE WS-COMPCODE          TO CA-RETURN-CODE                    
                 MOVE WS-REASON            TO CA-REASON-CODE                    
                 MOVE WS-MQ-ERROR-TEXT     TO WS-ERROR-TEXT                     
                 PERFORM W400-ERROR-OCCURRED                                    
              END-IF                                                            
           END-IF                                                               
           .                                                                    
       C400-DISCONNECT.                                                         
      *----------------                                                         
      * **************************************************************          
      * ** Close the request queue                                  **          
      * ** Close the reply queue                                    **          
      * ** Disconnect to the queue manager specified.               **          
      * ** If during any of these processes an error occurs, end    **          
      * **************************************************************          
           MOVE WC-C400-DISCONNECT         TO WS-DISPLAY-MESSAGE                
           PERFORM W500-STANDARD-DEBUG                                          
           IF NO-ERRORS-SO-FAR                                                  
              PERFORM C430-PERFORM-DISC                                         
           END-IF                                                               
           .                                                                    
       C430-PERFORM-DISC.                                                       
      *------------------                                                       
      * **************************************************************          
      * ** Disconnect from the queue manager                        **          
      * ** If OK, display a message if required.                    **          
      * ** If not, display message and end processing               **          
      * **************************************************************          
           MOVE WC-C430-PERFORM-DISC       TO WS-DISPLAY-MESSAGE                
           PERFORM W500-STANDARD-DEBUG                                          
           CALL 'MQDISC' USING WS-CONNECT-HANDLE                                
                               WS-COMPCODE                                      
                               WS-REASON                                        
           END-CALL                                                             
           IF WS-COMPCODE = MQCC-OK                                             
              MOVE WC-C430-DISCONNECT-OK   TO WS-DISPLAY-MESSAGE                
              PERFORM W500-STANDARD-DEBUG                                       
           ELSE                                                                 
              MOVE WC-DISCONNECT-TEXT      TO WS-MQ-ERROR-ACTION                
              MOVE WS-COMPCODE             TO WS-MQ-ERROR-CC                    
              MOVE WS-REASON               TO WS-MQ-ERROR-REASON                
              MOVE WS-COMPCODE             TO CA-RETURN-CODE                    
              MOVE WS-REASON               TO CA-REASON-CODE                    
              MOVE WS-MQ-ERROR-TEXT        TO WS-ERROR-TEXT                     
              PERFORM W400-ERROR-OCCURRED                                       
           END-IF                                                               
           .                                                                    
       D000-FINALISE.                                                           
      *--------------                                                           
      * **************************************************************          
      * ** Display final messages according to the level of         **          
      * ** messaging requested via the DEBUG option. Display the    **          
      * ** statistics collected if the action of DISC(onnect),      **          
      * ** unless no debug information has been specified.          **          
      * ** If an error will be returned, display any saved messages **          
      * ** from this invocation of the program.                     **          
      * **************************************************************          
           MOVE WC-D000-FINALISE        TO WS-DISPLAY-MESSAGE                   
           PERFORM W500-STANDARD-DEBUG                                          
           IF DISCONNECT-ACTION                                                 
              PERFORM D100-DISPLAY-STATISTICS                                   
           END-IF                                                               
           MOVE WS-COMM-BLOCK              TO CA-COMM-BLOCK                     
           .                                                                    
       D100-DISPLAY-STATISTICS.                                                 
      *------------------------                                                 
      * **************************************************************          
      * ** Display the statistics collected and stored in the       **          
      * ** COMM-BLOCK.                                              **          
      * **************************************************************          
           MOVE WC-D100-DISPLAY-STATS      TO WS-DISPLAY-MESSAGE                
           PERFORM W500-STANDARD-DEBUG                                          
           DISPLAY '* *****************************************'                
           MOVE SPACES                     TO WS-DISPLAY-MESSAGE                
           PERFORM W500-STANDARD-DEBUG                                          
           DISPLAY '* Statistics:'                                              
           DISPLAY '*  Number of Messages Put - ' WS-PUT1-COUNT                 
           DISPLAY '* *****************************************'                
           .                                                                    
       W300-GET-TIMESTAMP.                                                      
      *-------------------                                                      
      * **************************************************************          
      * ** Accept a new date and time from the system.              **          
      * **************************************************************          
           ACCEPT WS-DATE                  FROM DATE YYYYMMDD                   
           ACCEPT WS-TIME                  FROM TIME                            
           MOVE WS-TIME-HOURS              TO WS-DISPLAY-HOURS                  
           MOVE WS-TIME-MINS               TO WS-DISPLAY-MINS                   
           MOVE WS-TIME-SECS               TO WS-DISPLAY-SECS                   
           MOVE WS-TIME-SUBSECS            TO WS-DISPLAY-SUBSECS                
           MOVE WS-DATE-YYYY               TO WS-DISPLAY-YYYY                   
           MOVE WS-DATE-MM                 TO WS-DISPLAY-MM                     
           MOVE WS-DATE-DD                 TO WS-DISPLAY-DD                     
           .                                                                    
       W400-ERROR-OCCURRED.                                                     
      *--------------------                                                     
      * **************************************************************          
      * ** Display a message when an unexpected error occurs.       **          
      * **************************************************************          
           SET ERROR-OCCURRED              TO TRUE                              
           MOVE WS-ERROR-TEXT              TO WS-DISPLAY-MESSAGE                
           PERFORM W500-STANDARD-DEBUG                                          
           IF CA-RETURN-CODE = ZEROES                                           
              MOVE WC-SERIOUS-ERROR        TO CA-RETURN-CODE                    
           END-IF                                                               
           .                                                                    
       W500-STANDARD-DEBUG.                                                     
      *--------------------                                                     
      * **************************************************************          
      * ** Write a message to SYSOUT                                **          
      * **************************************************************          
           IF WS-DEBUG > 0                                                      
              PERFORM W300-GET-TIMESTAMP                                        
              DISPLAY WS-DISPLAY-LINE                                           
           END-IF                                                               
           .                                                                    
