       IDENTIFICATION DIVISION.
       PROGRAM-ID.    CLAIMCI0.
      ******************************************************************
      * THIS CICS SAMPLE PROGRAM IS USE WITH Z/OS CONNECT DEMO OF BOTH *
      * API PROVIDER AND API REQUESTER CAPABILITY                      *
      *                                                                *
      * THE CLAIM SAMPLE PROGRAM PROVIDES THE OPTION TO SUBMIT (S),    *
      * READ (R), AND UPDATE (U) A HEALTH INSURANCE CLAIM RECORD.      *
      *                                                                *
      * THE RECORD IS STORED IN A VSAM KSDS DATA SET.                  *
      * THE CONTENTS OF THE CLAIM RECORD ARE                           *
      *                                                                *
      * CLAIM RECORD ID (KEY)                                          *
      * CLAIM TYPE                                                     *
      * CLAIM AMOUNT                                                   *
      * CLAIM DATE                                                     *
      * CLAIM DESCRIPTION                                              *
      * CLAIM SERVICE PROVIDER                                         *
      * CLAIM STATUS                                                   *
      *                                                                *
      * FILE : CLAIMCIF (VSAM KSDS DATA SET)                           *
      *                                                                *
      ******************************************************************
       ENVIRONMENT DIVISION.
      ***********************
       DATA DIVISION.
      ****************
       WORKING-STORAGE SECTION.
      **************************
      *
      ******************************************************************
      * INCLUDE THE COPYBOOK FOR z/OS CONNECT API REQUESTER
      ******************************************************************
       COPY BAQRINFO.
      ******************************************************************
      * INCLUDE THE COPYBOOK FOR THE API REQUEST / RESPONSE
      * AND API INFO FILE (GENERATED BY THE ZCONBT UTILITY)
      ******************************************************************
       01  REQUEST.
           COPY CLAIMREQ.
       01  RESPONSE.
           COPY CLAIMRSP.
       01  API-INFO.
           COPY CLAIMINF.
      ******************************************************************
      * INCLUDE THE COPYBOOK FOR REQUEST AND RESPONSE DATA STRUCTURE.
      * THIS INCLUDES THE VSAM FILE LAYOUT FOR THE INSURANCE
      * CLAIM APP.
      ******************************************************************
       COPY CLAIMRQC.
       COPY CLAIMRSC.
      ******************************************************************
      * DECLARE THE WORKING STORAGE VARIABLES USED IN THIS PROGRAM
      ******************************************************************
       01 WS-STORAGE.
          05 WS-INPUT-LENGTH         PIC S9(8) COMP-4.
          05 WS-CHANNEL-NAME         PIC X(16).
          05 WS-CONTAINER-NAME       PIC X(16).
          05 WS-CICS-RESP-CODE-NUM   PIC 9(08) VALUE ZEROS.
          05 WS-FILE-NAME            PIC X(08).
          05 WS-TOKEN                PIC S9(8) COMP-5 SYNC.
          05 WS-MSG-TO-WRITE         PIC X(90).
          05 WS-CSMT-OUTAREA         PIC X(121).
          05 WS-ABSTIME              PIC S9(15) COMP-3.
          05 WS-CURRENT-DATE         PIC X(8).
          05 WS-CURRENT-TIME         PIC X(8).
          05 WS-WRITEQ-RESP-CODE     PIC S9(8) COMP.
      ******************************************************************
      * DECLARE THE WORKING STORAGE VARIABLES FOR API REQUESTER
      ******************************************************************
       01 BAQ-REQUEST-PTR             USAGE POINTER.
       01 BAQ-REQUEST-LEN             PIC S9(9) COMP-5 SYNC.
       01 BAQ-RESPONSE-PTR            USAGE POINTER.
       01 BAQ-RESPONSE-LEN            PIC S9(9) COMP-5 SYNC.
       77 COMM-STUB-PGM-NAME          PIC X(8) VALUE 'BAQCSTUB'.
      ******************************************************************
      * THIS PROGRAM USES CHANNELS AND CONTAINERS TO RECEIVE REQUEST
      * FROM CALL AND TO SEND RESPONSE BACK TO CALLER
      ******************************************************************
       PROCEDURE DIVISION.
      *********************
       DO-MAIN-CONTROL SECTION.
      **************************
      *
      ******************************************************************
      * PERFORM INITIALIZATION
      ******************************************************************
           PERFORM DO-INITIALIZATION
      ******************************************************************
      * OBTAIN THE CHANNEL NAME THAT WAS PASSED BY THE CALLING PROGRAM
      ******************************************************************
           EXEC CICS ASSIGN CHANNEL(WS-CHANNEL-NAME) END-EXEC.
      ******************************************************************
      * IF NO CHANNEL NAME WAS PASSED, THEN ASSIGN RETURNS SPACES.
      * IF SPACES WERE RETURNED THEN TERMINATE WITH ABEND CODE NOCN
      ******************************************************************
           IF WS-CHANNEL-NAME = SPACES THEN
                EXEC CICS
                     ABEND ABCODE('NOCN') NODUMP
                END-EXEC
           END-IF
      ******************************************************************
      * BROWSE THE CHANNEL FOR CONTAINERS
      ******************************************************************
           EXEC CICS
                STARTBROWSE CONTAINER
                CHANNEL(WS-CHANNEL-NAME)
                BROWSETOKEN(WS-TOKEN)
                RESP(RSP-CLAIM-CICS-RESP)
                RESP2(RSP-CLAIM-CICS-RESP2)
           END-EXEC.

           IF RSP-CLAIM-CICS-RESP NOT = DFHRESP(NORMAL)
                MOVE 'EXEC CICS STARTBROWSE ERROR'
                  TO WS-MSG-TO-WRITE
                PERFORM DO-WRITE-TO-CSMT
                PERFORM DO-RETURN-TO-CICS
           END-IF
      ******************************************************************
      * OBTAIN THE NAME OF THE CONTAINER IN THE CHANNEL
      ******************************************************************
           EXEC CICS
                GETNEXT CONTAINER(WS-CONTAINER-NAME)
                BROWSETOKEN(WS-TOKEN)
                RESP(RSP-CLAIM-CICS-RESP)
                RESP2(RSP-CLAIM-CICS-RESP2)
           END-EXEC.

           IF RSP-CLAIM-CICS-RESP NOT = DFHRESP(NORMAL)
                MOVE 'EXEC CICS GETNEXT CONTAINER ERROR'
                  TO WS-MSG-TO-WRITE
                PERFORM DO-WRITE-TO-CSMT
                PERFORM DO-RETURN-TO-CICS
           END-IF
      ******************************************************************
      * VALIDATE THE CONTAINER
      ******************************************************************
           EXEC CICS
                GET CONTAINER(WS-CONTAINER-NAME)
                CHANNEL(WS-CHANNEL-NAME)
                NODATA FLENGTH(WS-INPUT-LENGTH)
                NOCONVERT
                RESP(RSP-CLAIM-CICS-RESP)
                RESP2(RSP-CLAIM-CICS-RESP2)
           END-EXEC.
      ******************************************************************
      * EVALUATE THE RESPONSE OF THE EXEC GET CONTAINER CALL
      ******************************************************************
           EVALUATE RSP-CLAIM-CICS-RESP
                WHEN DFHRESP(CONTAINERERR)
                    STRING WS-CONTAINER-NAME DELIMITED BY SPACE
                      ' CONTAINER WAS NOT PASSED TO THE PROGRAM'
                      DELIMITED BY SIZE
                      INTO WS-MSG-TO-WRITE END-STRING
                    PERFORM DO-WRITE-TO-CSMT
                    PERFORM DO-RETURN-TO-CICS
                WHEN DFHRESP(CCSIDERR)
                    IF RSP-CLAIM-CICS-RESP = 3
                         STRING 'CONTAINER '
                          DELIMITED BY SIZE
                          WS-CONTAINER-NAME
                          DELIMITED BY SPACE
                          ' IS TYPE BIT, NOT CHAR'
                          DELIMITED BY SIZE
                          INTO WS-MSG-TO-WRITE END-STRING
                         PERFORM DO-WRITE-TO-CSMT
                         PERFORM DO-RETURN-TO-CICS
                    ELSE
                         STRING 'EXEC GET CONTAINER ERROR'
                          DELIMITED BY SIZE
                          INTO WS-MSG-TO-WRITE END-STRING
                         PERFORM DO-WRITE-TO-CSMT
                         PERFORM DO-RETURN-TO-CICS
                    END-IF
                WHEN DFHRESP(NORMAL)
                    STRING 'GET CONTAINER FOR ' DELIMITED BY SIZE
                     WS-CONTAINER-NAME DELIMITED BY SPACE
                     ' WAS SUCCESSFUL' DELIMITED BY SIZE
                     INTO WS-MSG-TO-WRITE END-STRING
                    PERFORM DO-WRITE-TO-CSMT
                WHEN OTHER
                    STRING 'EXEC GET CONTAINER UNEXPECTED ERROR'
                     DELIMITED BY SIZE
                     INTO WS-MSG-TO-WRITE END-STRING
                     PERFORM DO-WRITE-TO-CSMT
                     PERFORM DO-RETURN-TO-CICS
           END-EVALUATE.
      ******************************************************************
      * NOW READ THE CONTENTS OF THE REQUEST CONTAINER FOR PROCESSING
      ******************************************************************
           EXEC CICS
                GET CONTAINER(WS-CONTAINER-NAME)
                    CHANNEL(WS-CHANNEL-NAME)
                    FLENGTH(WS-INPUT-LENGTH)
                    INTO(REQ-CLAIM-CONTAINER)
                    NOCONVERT
                    RESP(RSP-CLAIM-CICS-RESP)
                    RESP2(RSP-CLAIM-CICS-RESP2)
           END-EXEC.

           IF RSP-CLAIM-CICS-RESP NOT = DFHRESP(NORMAL)
                MOVE 'ERROR READING CONTAINER DATA'
                  TO WS-MSG-TO-WRITE
                PERFORM DO-WRITE-TO-CSMT
                PERFORM DO-RETURN-TO-CICS
           END-IF
      ******************************************************************
      * CHECK THE OPERATION TYPE REQUESTED BY CALLER AND
      * PERFORM ACTION REQUESTED
      ******************************************************************
           EVALUATE REQ-CLAIM-ACTION
                WHEN 'S'
                    PERFORM DO-SUBMIT-CLAIM-REC
                WHEN 'R'
                    PERFORM DO-READ-CLAIM-REC
                WHEN 'U'
                    PERFORM DO-UPDATE-CLAIM-REC
                WHEN OTHER
                    MOVE 'ERROR: UNKNOWN OPERATION FOUND IN REQUEST'
                         TO RSP-CLAIM-OUTPUT-MESSAGE
           END-EVALUATE
      ******************************************************************
      * PROCESSING COMPLETED, RETURN THE CONTROL BACK TO CICS
      ******************************************************************
           PERFORM DO-RETURN-TO-CICS
           EXIT.
      ******************************************************************
      /
       DO-INITIALIZATION SECTION.
      ****************************
      *
      ******************************************************************
      * INITIALIZE THE LOCAL VARIABLES USED IN THIS PROGRAM.
      ******************************************************************
           INITIALIZE REQUEST.
           INITIALIZE RESPONSE.
           INITIALIZE REQ-CLAIM-CONTAINER.
           INITIALIZE RSP-CLAIM-CONTAINER.
           INITIALIZE WS-CICS-RESP-CODE-NUM.
           INITIALIZE WS-FILE-NAME.
      ******************************************************************
      * SET POINTER AND LENGTH TO SPECIFY THE LOCATION OF REQUEST
      * AND RESPONSE SEGMENT
      ******************************************************************
           SET BAQ-REQUEST-PTR TO ADDRESS OF REQUEST
           MOVE LENGTH OF REQUEST TO BAQ-REQUEST-LEN

           SET BAQ-RESPONSE-PTR TO ADDRESS OF RESPONSE
           MOVE LENGTH OF RESPONSE TO BAQ-RESPONSE-LEN

           MOVE 'CLAIMCIF' TO WS-FILE-NAME
           EXIT.
      ******************************************************************
      /
       DO-SUBMIT-CLAIM-REC SECTION.
      ******************************
      *
      ******************************************************************
      * WRITE THE FIELDS THAT WAS SPECIFIED IN THE REQUEST
      * AS A RECORD IN THE CLAIMCIF FILE.
      ******************************************************************
           MOVE REQ-CLAIM-RECORD TO RSP-CLAIM-RECORD
      ******************************************************************
      * AUTOMATIC APPROVAL IS DETERMINED BY THE CLAIM SERVER BUSINESS
      * RULE. CALL THE PROGRAM TO SET THE STATUS.
      ******************************************************************

           PERFORM DO-CALL-CLAIM-RULE

           EXEC CICS
                WRITE FILE(WS-FILE-NAME)
                      FROM(RSP-CLAIM-RECORD)
                      RIDFLD(REQ-CLAIM-ID)
                      RESP(RSP-CLAIM-CICS-RESP)
                      RESP2(RSP-CLAIM-CICS-RESP2)
           END-EXEC.
      ******************************************************************
      * CHECK THE CICS RESPONSE CODE RETURNED FOR WRITE FILE COMMAND.
      ******************************************************************
           EVALUATE RSP-CLAIM-CICS-RESP
                WHEN DFHRESP(NORMAL)
                    STRING 'SUCCESS: CLAIM RECORD SUBMITTED FOR '
                        REQ-CLAIM-ID DELIMITED BY SIZE
                                         INTO RSP-CLAIM-OUTPUT-MESSAGE
                WHEN OTHER
                    MOVE RSP-CLAIM-CICS-RESP TO WS-CICS-RESP-CODE-NUM
                    STRING 'ERROR: WRITE FILE RESPONSE CODE = '
                        WS-CICS-RESP-CODE-NUM DELIMITED BY SIZE
                                         INTO RSP-CLAIM-OUTPUT-MESSAGE
           END-EVALUATE
           EXIT.
      ******************************************************************
      /
       DO-CALL-CLAIM-RULE SECTION.
      *****************************
      *
      ******************************************************************
      * USE Z/OS CONNECT TO CALL REST API TO EVALUATE CLAIM BASED
      * ON BUSINESS RULES
      ******************************************************************
           MOVE REQ-CLAIM-TYPE TO claimType OF REQUEST
           MOVE REQ-CLAIM-AMOUNT TO claimAmount OF REQUEST

           EVALUATE REQ-CLAIM-TYPE
             WHEN 'DRUG'
               MOVE 4 TO claimType-length
             WHEN 'DENTAL'
               MOVE 6 TO claimType-length
             WHEN 'MEDICAL'
               MOVE 7 TO claimType-length
             WHEN OTHER
               MOVE 7 TO claimType-length
               MOVE 'MEDICAL' TO claimType
           END-EVALUATE
      ******************************************************************
      * CALL API CLIENT CODE THAT WAS GENERATED BY THE BUILD TOOLKIT
      * THIS IS USED TO PASS PARAMETER AND RECEIVE RESULTS FOR THE
      * REST API THAT WILL BE INVOKED BY z/OS CONNECT.
      ******************************************************************
           CALL COMM-STUB-PGM-NAME USING
                BY REFERENCE API-INFO
                BY REFERENCE BAQ-REQUEST-INFO
                BY REFERENCE BAQ-REQUEST-PTR
                BY REFERENCE BAQ-REQUEST-LEN
                BY REFERENCE BAQ-RESPONSE-INFO
                BY REFERENCE BAQ-RESPONSE-PTR
                BY REFERENCE BAQ-RESPONSE-LEN
      ******************************************************************
      * CHECK IF THE API CALL WAS SUCCESSFUL AND EVALUATE IF THE
      * CLAIM WAS ACCEPTED OR REQUIRES FURTHER REVIEW AND SET
      * THE STATUS TO 'OKAY' OR 'PEND'.
      ******************************************************************
           IF BAQ-SUCCESS THEN
              IF Xstatus2(1:Xstatus2-length) = 'Accepted'
                 MOVE 'OKAY' TO RSP-CLAIM-STATUS
              ELSE
                 MOVE 'PEND' TO RSP-CLAIM-STATUS
              END-IF

              STRING REQ-CLAIM-ID
                ' WAS PROCESSED, STATUS = '
                Xstatus2(1:Xstatus2-length)
                ', REASON = '
                reason2(1:reason2-length) DELIMITED BY SIZE
                INTO WS-MSG-TO-WRITE END-STRING

              PERFORM DO-WRITE-TO-CSMT
      ******************************************************************
      * OTHERWISE AN ERROR OCCURED WHEN CALLING THE REST API
      * CHECK THE BAQ-STATUS-CODE AND BAQ-STATUS-MESSAGE FOR
      * DETAILS OF THE ERROR.  SET THE STATUS TO 'PEND'.
      ******************************************************************
           ELSE
              EVALUATE TRUE
      ******************************************************************
      * WHEN ERROR HAPPENS IN API, BAQ-RETURN-CODE IS BAQ-ERROR-IN-API.
      * BAQ-STATUS-CODE IS THE HTTP RESPONSE CODE OF THE API.
      ******************************************************************
                 WHEN BAQ-ERROR-IN-API
                   STRING 'ERROR IN API, MESSAGE = '
                     BAQ-STATUS-MESSAGE DELIMITED BY SIZE
                     INTO WS-MSG-TO-WRITE END-STRING
      ******************************************************************
      * WHEN ERROR HAPPENS IN SERVER, BAQ-RETURN-CODE IS
      * BAQ-ERROR-IN-ZCEE
      * BAQ-STATUS-CODE IS THE HTTP RESPONSE CODE OF
      * Z/OS CONNECT EE SERVER.
      ******************************************************************
                 WHEN BAQ-ERROR-IN-ZCEE
                   STRING 'ERROR IN ZCEE, MESSAGE = '
                     BAQ-STATUS-MESSAGE DELIMITED BY SIZE
                     INTO WS-MSG-TO-WRITE END-STRING
      ******************************************************************
      * WHEN ERROR HAPPENS IN COMMUNICATION STUB, BAQ-RETURN-CODE IS
      * BAQ-ERROR-IN-STUB, BAQ-STATUS-CODE IS THE ERROR CODE OF STUB.
      ******************************************************************
                 WHEN BAQ-ERROR-IN-STUB
                   STRING 'ERROR IN STUB, MESSAGE = '
                     BAQ-STATUS-MESSAGE DELIMITED BY SIZE
                     INTO WS-MSG-TO-WRITE END-STRING

              END-EVALUATE

              PERFORM DO-WRITE-TO-CSMT
              MOVE 'PEND' TO RSP-CLAIM-STATUS
           END-IF.
           EXIT.
      ******************************************************************
      /
       DO-READ-CLAIM-REC SECTION.
      ****************************
      *
      ******************************************************************
      * READ THE CLAIMCIF FILE AND LOOK FOR THE CLAIM RECORD BASED ON
      * THE CLAIM ID THAT WAS SPECIFIED IN THE REQUEST.
      ******************************************************************
           EXEC CICS
                READ FILE(WS-FILE-NAME)
                     INTO(RSP-CLAIM-RECORD)
                     RIDFLD(REQ-CLAIM-ID)
                     RESP(RSP-CLAIM-CICS-RESP)
                     RESP2(RSP-CLAIM-CICS-RESP2)
           END-EXEC.
      ******************************************************************
      * CHECK THE CICS RESPONSE CODE RETURNED FOR READ FILE COMMAND.
      ******************************************************************
           EVALUATE RSP-CLAIM-CICS-RESP
                WHEN DFHRESP(NOTFND)
                    MOVE 'ERROR: CLAIM RECORD NOT FOUND'
                         TO RSP-CLAIM-OUTPUT-MESSAGE
                WHEN DFHRESP(NORMAL)
                    STRING 'SUCCESS: CLAIM RECORD FOUND FOR '
                        REQ-CLAIM-ID DELIMITED BY SIZE
                                         INTO RSP-CLAIM-OUTPUT-MESSAGE
                WHEN OTHER
                    MOVE RSP-CLAIM-CICS-RESP TO WS-CICS-RESP-CODE-NUM
                    STRING 'ERROR: READ FILE RESPONSE CODE = '
                        WS-CICS-RESP-CODE-NUM DELIMITED BY SIZE
                                         INTO RSP-CLAIM-OUTPUT-MESSAGE
           END-EVALUATE
           EXIT.
      ******************************************************************
      /
       DO-UPDATE-CLAIM-REC SECTION.
      ******************************
      *
      ******************************************************************
      * READ THE CLAIMCIF FILE AND LOOK FOR THE CLAIM RECORD TO BE
      * UPDATED.
      ******************************************************************
           EXEC CICS
                READ FILE(WS-FILE-NAME)
                     INTO(RSP-CLAIM-RECORD)
                     RIDFLD(REQ-CLAIM-ID)
                     UPDATE
                     RESP(RSP-CLAIM-CICS-RESP)
                     RESP2(RSP-CLAIM-CICS-RESP2)
           END-EXEC.
      ******************************************************************
      * CHECK THE CICS RESPONSE CODE RETURNED FOR READ WITH UPDATE
      * COMMAND.
      ******************************************************************
           EVALUATE RSP-CLAIM-CICS-RESP
                WHEN DFHRESP(NOTFND)
                    MOVE 'ERROR: CLAIM RECORD FOR UPDATE NOT FOUND'
                         TO RSP-CLAIM-OUTPUT-MESSAGE
                WHEN DFHRESP(NORMAL)
                    PERFORM DO-REWRITE-CLAIM-REC
                WHEN OTHER
                    MOVE RSP-CLAIM-CICS-RESP TO WS-CICS-RESP-CODE-NUM
                    STRING 'ERROR: CICS READ UPDATE RESPONSE CODE = '
                        WS-CICS-RESP-CODE-NUM DELIMITED BY SIZE
                                         INTO RSP-CLAIM-OUTPUT-MESSAGE
           END-EVALUATE
           EXIT.
      ******************************************************************
      /
       DO-REWRITE-CLAIM-REC SECTION.
      *******************************
      *
      ******************************************************************
      * UPDATE THE CLAIMCIF FILE WITH THE NEW VALUES THAT WAS SPECIFIED
      * IN THE REQUEST.
      ******************************************************************
           MOVE REQ-FILLER TO RSP-CLAIM-STATUS

           EXEC CICS
                REWRITE FILE(WS-FILE-NAME)
                        FROM(RSP-CLAIM-RECORD)
                        RESP(RSP-CLAIM-CICS-RESP)
                        RESP2(RSP-CLAIM-CICS-RESP2)
           END-EXEC.
      *
      * CHECK THE CICS RESPONSE CODE RETURNED FOR REWRITE COMMAND.
      *
           EVALUATE RSP-CLAIM-CICS-RESP
                WHEN DFHRESP(NORMAL)
                    STRING 'SUCCESS: CLAIM RECORD UPDATED FOR '
                       REQ-CLAIM-ID DELIMITED BY SIZE
                       INTO RSP-CLAIM-OUTPUT-MESSAGE
                WHEN OTHER
                    MOVE RSP-CLAIM-CICS-RESP TO WS-CICS-RESP-CODE-NUM
                    STRING 'ERROR: CICS REWRITE RESPONSE CODE = '
                        WS-CICS-RESP-CODE-NUM DELIMITED BY SIZE
                                         INTO RSP-CLAIM-OUTPUT-MESSAGE
           END-EVALUATE
           EXIT.
      ******************************************************************
      /
       DO-WRITE-TO-CSMT SECTION.
      ***************************
      *
      ******************************************************************
      * WRITE ADDITIONAL INFORMATION TO CSMT TD QUEUE
      ******************************************************************
           EXEC CICS ASKTIME ABSTIME(WS-ABSTIME) END-EXEC.

           EXEC CICS
                FORMATTIME ABSTIME(WS-ABSTIME)
                DATE(WS-CURRENT-DATE) DATESEP('/')
                TIME(WS-CURRENT-TIME) TIMESEP(':')
           END-EXEC.

           STRING 'CLAIMCI0: ' WS-CURRENT-DATE ' '
                WS-CURRENT-TIME ' ' WS-MSG-TO-WRITE DELIMITED BY SIZE
                INTO WS-CSMT-OUTAREA

           EXEC CICS
                WRITEQ TD QUEUE('CSMT')
                FROM(WS-CSMT-OUTAREA)
                LENGTH(LENGTH OF WS-CSMT-OUTAREA)
                RESP(WS-WRITEQ-RESP-CODE)
           END-EXEC.

           INITIALIZE WS-MSG-TO-WRITE.
           INITIALIZE WS-CSMT-OUTAREA.

           EXIT.
      ******************************************************************
      /
       DO-RETURN-TO-CICS SECTION.
      ****************************
      *
      ******************************************************************
      * COPY THE LOCAL VARIABLES BACK TO THE CONTAINER. CICS WILL
      * RETURN THE DATA FROM THE CONTAINER TO THE CLIENT THAT
      * INVOKED THIS TRANSACTION.
      ******************************************************************
           EXEC CICS
                PUT CONTAINER(WS-CONTAINER-NAME)
                    FROM(RSP-CLAIM-CONTAINER)
                    FLENGTH(LENGTH OF RSP-CLAIM-CONTAINER)
                    RESP(RSP-CLAIM-CICS-RESP)
           END-EXEC.

           IF RSP-CLAIM-CICS-RESP NOT = DFHRESP(NORMAL)
                MOVE 'ERROR WRITING CONTAINER DATA'
                  TO WS-MSG-TO-WRITE
                PERFORM DO-WRITE-TO-CSMT
           END-IF
      ******************************************************************
      * RETURN THE CONTROL BACK TO CICS.
      ******************************************************************
           EXEC CICS RETURN END-EXEC.
           EXIT.
