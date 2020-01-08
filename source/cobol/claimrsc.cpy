      ******************************************************************
      *                                                                *
      * Licensed Materials - Property of IBM                           *
      *                                                                *
      * COPYBOOK FOR SAMPLE CICS CLAIMS APPLICATION (RESPONSE)         *
      *                                                                *
      * (c) Copyright IBM Corp. 2019 All Rights Reserved               *
      *                                                                *
      * US Government Users Restricted Rights - Use, duplication or    *
      * disclosure restricted by GSA ADP Schedule Contract with IBM    *
      * Corp                                                           *
      *                                                                *
      ******************************************************************
       01 RSP-CLAIM-CONTAINER.
          03 RSP-CLAIM-RECORD.
             05 RSP-CLAIM-ID             PIC X(8).
             05 RSP-CLAIM-DETAILS.
                10 RSP-CLAIM-TYPE        PIC X(8).
                10 RSP-CLAIM-AMOUNT      COMP-2 SYNC.
                10 RSP-CLAIM-DATE        PIC X(10).
                10 RSP-CLAIM-DESC        PIC X(21).
                10 RSP-CLAIM-PROVIDER    PIC X(21).
                10 RSP-CLAIM-STATUS      PIC X(4).
          03 RSP-CLAIM-CICS-RESP         PIC S9(8) COMP.
          03 RSP-CLAIM-CICS-RESP2        PIC S9(8) COMP.
          03 RSP-CLAIM-OUTPUT-MESSAGE    PIC X(80).
