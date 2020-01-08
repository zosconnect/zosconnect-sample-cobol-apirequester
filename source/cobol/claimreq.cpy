      * ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
      * This file contains the generated language structure(s) for
      *  request JSON schema 'getClaimRule_request.json'.
      * This structure was generated using 'DFHJS2LS' at mapping level
      *  '4.3'.
      *
      *
      *      06 ReqQueryParameters.
      *
      * Comments for field 'claimType':
      * This field represents the value of JSON schema keyword
      *  'ReqQueryParameters->claimType'.
      * JSON schema description: The claim type. Valid values are
      *  dental, drug and medical.
      * JSON schema type: 'string'.
      * This field contains a varying length array of characters or
      *  binary data.
      *        09 claimType-length              PIC S9999 COMP-5 SYNC.
      *        09 claimType                     PIC X(255).
      *
      * Comments for field 'claimAmount':
      * This field represents the value of JSON schema keyword
      *  'ReqQueryParameters->claimAmount'.
      * JSON schema description: The claim type. Valid values are
      *  dental, drug and medical.
      * JSON schema type: 'number'.
      * JSON schema keyword 'format' value: 'double'.
      * This field contains a "HEXADEC" type floating point number.
      *        09 claimAmount                   COMP-2 SYNC.
      *
      *
      * ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

             06 ReqQueryParameters.
               09 claimType-length              PIC S9999 COMP-5 SYNC.
               09 claimType                     PIC X(255).
               09 claimAmount                   COMP-2 SYNC.

