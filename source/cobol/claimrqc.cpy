      ******************************************************************
      *                                                                *
      * Licensed Materials - Property of IBM                           *
      *                                                                *
      * COPYBOOK FOR SAMPLE CICS CLAIMS APPLICATION (REQUEST)          *
      *                                                                *
      * (c) Copyright IBM Corp. 2019 All Rights Reserved               *
      *                                                                *
      * US Government Users Restricted Rights - Use, duplication or    *
      * disclosure restricted by GSA ADP Schedule Contract with IBM    *
      * Corp                                                           *
      *                                                                *
      ******************************************************************
       01 REQ-CLAIM-CONTAINER.
          03 REQ-CLAIM-RECORD.
             05 REQ-CLAIM-ID             PIC X(8).
             05 REQ-CLAIM-DETAILS.
                10 REQ-CLAIM-TYPE        PIC X(8).
                10 REQ-CLAIM-AMOUNT      COMP-2 SYNC.
                10 REQ-CLAIM-DATE        PIC X(10).
                10 REQ-CLAIM-DESC        PIC X(21).
                10 REQ-CLAIM-PROVIDER    PIC X(21).
                10 REQ-FILLER            PIC X(4).
          03 REQ-CLAIM-ACTION            PIC X(1).
