      * ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
      * This file contains the generated language structure(s) for
      *  response JSON schema 'getClaimRule_200_response.json'.
      * This structure was generated using 'DFHJS2LS' at mapping level
      *  '4.3'.
      *
      *
      *      06 RespBody.
      *
      *
      * JSON schema keyword 'RespBody->claim-type' is optional. The
      *  number of instances present is indicated in field
      *  'claim-type-num'.
      * There should be at least '0' instance(s).
      * There should be at most '1' instance(s).
      *        09 claim-type-num                PIC S9(9) COMP-5 SYNC.
      *
      *
      *        09 claim-type.
      *
      * Comments for field 'claim-type2':
      * This field represents the value of JSON schema keyword
      *  'RespBody->claim-type'.
      * JSON schema type: 'string'.
      * This field contains a varying length array of characters or
      *  binary data.
      *          12 claim-type2-length            PIC S9999 COMP-5
      *  SYNC.
      *          12 claim-type2                   PIC X(255).
      *
      *
      * JSON schema keyword 'RespBody->amount' is optional. The number
      *  of instances present is indicated in field 'amount-num'.
      * There should be at least '0' instance(s).
      * There should be at most '1' instance(s).
      *        09 amount-num                    PIC S9(9) COMP-5 SYNC.
      *
      *
      *        09 amount.
      *
      * Comments for field 'amount2':
      * This field represents the value of JSON schema keyword
      *  'RespBody->amount'.
      * JSON schema type: 'string'.
      * This field contains a varying length array of characters or
      *  binary data.
      *          12 amount2-length                PIC S9999 COMP-5
      *  SYNC.
      *          12 amount2                       PIC X(255).
      *
      *
      * JSON schema keyword 'RespBody->status' is optional. The number
      *  of instances present is indicated in field 'Xstatus-num'.
      * There should be at least '0' instance(s).
      * There should be at most '1' instance(s).
      *        09 Xstatus-num                   PIC S9(9) COMP-5 SYNC.
      *
      *
      *        09 Xstatus.
      *
      * Comments for field 'Xstatus2':
      * This field represents the value of JSON schema keyword
      *  'RespBody->status'.
      * JSON schema type: 'string'.
      * This field contains a varying length array of characters or
      *  binary data.
      *          12 Xstatus2-length               PIC S9999 COMP-5
      *  SYNC.
      *          12 Xstatus2                      PIC X(255).
      *
      *
      * JSON schema keyword 'RespBody->reason' is optional. The number
      *  of instances present is indicated in field 'reason-num'.
      * There should be at least '0' instance(s).
      * There should be at most '1' instance(s).
      *        09 reason-num                    PIC S9(9) COMP-5 SYNC.
      *
      *
      *        09 reason.
      *
      * Comments for field 'reason2':
      * This field represents the value of JSON schema keyword
      *  'RespBody->reason'.
      * JSON schema type: 'string'.
      * This field contains a varying length array of characters or
      *  binary data.
      *          12 reason2-length                PIC S9999 COMP-5
      *  SYNC.
      *          12 reason2                       PIC X(255).
      *
      *
      * ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

             06 RespBody.

               09 claim-type-num                PIC S9(9) COMP-5 SYNC.

               09 claim-type.
                 12 claim-type2-length            PIC S9999 COMP-5
            SYNC.
                 12 claim-type2                   PIC X(255).

               09 amount-num                    PIC S9(9) COMP-5 SYNC.

               09 amount.
                 12 amount2-length                PIC S9999 COMP-5
            SYNC.
                 12 amount2                       PIC X(255).

               09 Xstatus-num                   PIC S9(9) COMP-5 SYNC.

               09 Xstatus.
                 12 Xstatus2-length               PIC S9999 COMP-5
            SYNC.
                 12 Xstatus2                      PIC X(255).

               09 reason-num                    PIC S9(9) COMP-5 SYNC.

               09 reason.
                 12 reason2-length                PIC S9999 COMP-5
            SYNC.
                 12 reason2                       PIC X(255).

