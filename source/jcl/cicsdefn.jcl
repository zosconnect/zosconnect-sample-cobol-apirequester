//********************************************************************
//*                                                                  *
//* Licensed Materials - Property of IBM                             *
//*                                                                  *
//* SAMPLE JCL                                                       *
//*                                                                  *
//* (c) Copyright IBM Corp. 2020 All Rights Reserved                 *
//*                                                                  *
//* US Government Users Restricted Rights - Use, duplication or      *
//* disclosure restricted by GSA ADP Schedule Contract with IBM      *
//* Corp                                                             *
//*                                                                  *
//********************************************************************
//*                                                                  *
//* NOTES:                                                           *
//*                                                                  *
//* Sample JCL to define the CICS resources for the sample CICS      *
//* program.                                                         *
//*                                                                  * 
//* 1. Add Job card                                                  *
//* 2. Update <CICSPRFX> with the HLQ for CICS data sets, for        *
//*    example CICSTS.V5R5                                           *
//* 3. Update <CICSAOR1> with the HLQ for CICS Region data sets,     *
//*    for example CICSTS.CICSAOR1                                   *
//* 4. Update <CICS.VSAM.FILE> with the actual name of the VSAM      *
//*    data set created for the CICS sample program CLAIMCI0         *
//*                                                                  *
//********************************************************************
//CSDDEFS  EXEC PGM=DFHCSDUP,REGION=1M
//STEPLIB  DD DISP=SHR,DSN=<CICSPRFX>.SDFHLOAD
//DFHCSD   DD DISP=SHR,DSN=<CICSAOR1>.DFHCSD
//SYSUT1   DD UNIT=SYSDA,SPACE=(1024,(100,100))
//SYSPRINT DD SYSOUT=*
//SYSIN    DD *
ADD    GROUP(DEMOGRP) LIST(DEMOLIST)

***** Program
Define Program(CLAIMCI0) Group(DEMOGRP)
       Description(Sample Cobol Demo for zOS Connect)
       Language(Cobol)   DataLocation(Any)   Execkey(User)

***** File Definitions
Define File(CLAIMCIF)    Group(DEMOGRP)
       DSname(<CICS.VSAM.FILE>)
       Recordsize(80)    Keylength(8)
       Status(Enabled)   Opentime(Firstref)
       Add(Yes)          Browse(Yes)        Read(Yes)
       Delete(Yes)       Update(Yes)
