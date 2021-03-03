      ******************************************************************
      *                                                                *
      * Licensed Materials - Property of IBM                           *
      *                                                                *
      * IMSCLAIM SAMPLE COPYBOOK                                       *
      *                                                                *
      * (c) Copyright IBM Corp. 2020 All Rights Reserved               *
      *                                                                *
      * US Government Users Restricted Rights - Use, duplication or    *
      * disclosure restricted by GSA ADP Schedule Contract with IBM    *
      * Corp                                                           *
      *                                                                *
      ******************************************************************
      * DATA AREA FOR TERMINAL INPUT
       01 INPUT-MSG.
          05  IN-LL               PIC S9(3) COMP.
          05  IN-ZZ               PIC S9(3) COMP.
          05  IN-TRANCODE         PIC X(10).
          05  IN-CLAIM-TYPE       PIC X(8).
          05  IN-CLAIM-DATE       PIC X(10).
          05  IN-CLAIM-AMOUNT     PIC 9(7).9(2).
          05  IN-CLAIM-DESC       PIC X(20).
      * DATA AREA FOR TERMINAL OUTPUT
       01 OUTPUT-MSG.
          05  OUT-LL              PIC S9(3) COMP VALUE +0.
          05  OUT-ZZ              PIC S9(3) COMP VALUE +0.
          05  OUT-CLAIM-TYPE      PIC X(8).
          05  OUT-CLAIM-STATUS    PIC X(10).
          05  OUT-CLAIM-DESC      PIC X(20).
          05  OUT-CLAIM-AMOUNT    PIC 9(7).9(2).
          05  OUT-MESSAGE         PIC X(40).
