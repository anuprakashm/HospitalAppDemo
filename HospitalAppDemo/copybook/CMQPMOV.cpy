      ******************************************************************        
      **                                                              **        
      **                  WebSphere MQ for z/OS                       **        
      **                                                              **        
      **  FILE NAME:      CMQPMOV                                     **        
      **                                                              **        
      **  DESCRIPTION:    Put Message Options Structure               **        
      **                                                              **        
      ******************************************************************        
      **  @START_COPYRIGHT@                                           **        
      **  Statement:     Licensed Materials - Property of IBM         **        
      **                                                              **        
      **                 5655-F10                                     **        
      **                 (C) Copyright IBM Corporation. 1993, 2002    **        
      **                                                              **        
      **  Status:        Version 5 Release 3                          **        
      **  @END_COPYRIGHT@                                             **        
      ******************************************************************        
      **                                                              **        
      **  FUNCTION:       This file declares the structure MQPMO,     **        
      **                  which is used by the main MQI.              **        
      **                                                              **        
      **  PROCESSOR:      COBOL                                       **        
      **                                                              **        
      ******************************************************************        
                                                                                
                                                                                
      ******************************************************************        
      **  MQPMO Structure -- Put Message Options                      **        
      ******************************************************************        
                                                                                
      ** MQPMO structure                                                        
       10  MQPMO.                                                               
      ** Structure identifier                                                   
       15  MQPMO-STRUCID PIC X(4) VALUE 'PMO '.                                 
      ** Structure version number                                               
       15  MQPMO-VERSION PIC S9(9) BINARY VALUE 1.                              
      ** Options that control the action of MQPUT and MQPUT1                    
       15  MQPMO-OPTIONS PIC S9(9) BINARY VALUE 0.                              
      ** Reserved                                                               
       15  MQPMO-TIMEOUT PIC S9(9) BINARY VALUE -1.                             
      ** Object handle of input queue                                           
       15  MQPMO-CONTEXT PIC S9(9) BINARY VALUE 0.                              
      ** Number of messages sent successfully to local queues                   
       15  MQPMO-KNOWNDESTCOUNT PIC S9(9) BINARY VALUE 0.                       
      ** Number of messages sent successfully to remote queues                  
       15  MQPMO-UNKNOWNDESTCOUNT PIC S9(9) BINARY VALUE 0.                     
      ** Number of messages that could not be sent                              
       15  MQPMO-INVALIDDESTCOUNT PIC S9(9) BINARY VALUE 0.                     
      ** Resolved name of destination queue                                     
       15  MQPMO-RESOLVEDQNAME PIC X(48) VALUE SPACES.                          
      ** Resolved name of destination queue manager                             
       15  MQPMO-RESOLVEDQMGRNAME PIC X(48) VALUE SPACES.                       
                                                                                
      ******************************************************************        
      **  End of CMQPMOV                                                        
      ******************************************************************        
