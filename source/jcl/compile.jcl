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
//* Sample JCL to compile and link edit the sample CICS COBOL        *
//* program that will be used with z/OS Connect. The sample JCL was  *
//* created using COBOL 6.2 Compiler and CICS Transaction Server     *
//* Version 5.5.                                                     *
//*                                                                  *
//* 1. Add Job card                                                  *
//* 2. Update <LNGPRFX> with the HLQ for COBOL compiler data set,    *
//*    for example COBOL.V6R2                                        *
//* 3. Update <CICSPRFX> with the HLQ for CICS data sets, for        *
//*    example CICSTS.V5R5                                           *
//* 4. Update <LIBPRFX> with the HLQ for LE data sets, for           *
//*    example CEE                                                   *
//* 5. Update <COPYBOOK.PDS.LIB> with the name of the PDS data set   *
//*    containing the Copybooks used by program CLAIMCI0             *
//* 6. Update <SOURCE.PDS.LIB> with the name of the PDS data set     *
//*    containing the source member CLAIMCI0                         *
//* 7. Update <ZCEEPRFX> with the HLQ for z/OS Connect data set,     *
//*    for example ZCEE.V3R0                                         *
//* 8. Update <USER.LOAD.LIB> with the name of the PDSE library      *
//*    where you want to store the load module                       *
//*                                                                  *
//********************************************************************
//CBLPROC  PROC MEM=
//*-------------------------------------------------------------------*
//*  INVOKE THE COBOL COMPILE                                         *
//*-------------------------------------------------------------------*
//*
//COBOL    EXEC PGM=IGYCRCTL,
//  PARM=('NODYNAM,RENT','CICS(''SP'')')
//STEPLIB  DD DSN=<LNGPRFX>.SIGYCOMP,DISP=SHR
//         DD DSN=<CICSPRFX>.SDFHLOAD,DISP=SHR
//SYSLIB   DD DSN=<CICSPRFX>.SDFHCOB,DISP=SHR
//         DD DSN=<CICSPRFX>.SDFHMAC,DISP=SHR
//         DD DSN=<CICSPRFX>.SDFHSAMP,DISP=SHR
//         DD DISP=SHR,DSN=<COPYBOOK.PDS.LIB> 
//         DD DISP=SHR,DSN=<ZCEEPRFX>.SBAQCOB
//SYSIN    DD DISP=SHR,DSN=<SOURCE.PDS.LIB>(&MEM)
//SYSLIN   DD DSN=&&LOADSET,DISP=(NEW,PASS),UNIT=SYSDA,
//         SPACE=(TRK,(20,10))
//SYSUT1   DD UNIT=SYSDA,SPACE=(460,(350,100))
//SYSUT2   DD UNIT=SYSDA,SPACE=(460,(350,100))
//SYSUT3   DD UNIT=SYSDA,SPACE=(460,(350,100))
//SYSUT4   DD UNIT=SYSDA,SPACE=(460,(350,100))
//SYSUT5   DD UNIT=SYSDA,SPACE=(460,(350,100))
//SYSUT6   DD UNIT=SYSDA,SPACE=(460,(350,100))
//SYSUT7   DD UNIT=SYSDA,SPACE=(460,(350,100))
//SYSUT8   DD UNIT=SYSDA,SPACE=(460,(350,100))
//SYSUT9   DD UNIT=SYSDA,SPACE=(460,(350,100))
//SYSUT10  DD UNIT=SYSDA,SPACE=(460,(350,100))
//SYSUT11  DD UNIT=SYSDA,SPACE=(460,(350,100))
//SYSUT12  DD UNIT=SYSDA,SPACE=(460,(350,100))
//SYSUT13  DD UNIT=SYSDA,SPACE=(460,(350,100))
//SYSUT14  DD UNIT=SYSDA,SPACE=(460,(350,100))
//SYSUT15  DD UNIT=SYSDA,SPACE=(460,(350,100))
//SYSMDECK DD UNIT=SYSDA,SPACE=(CYL,(1,1))
//SYSPRINT DD SYSOUT=*
//*-------------------------------------------------------------------*
//*  REBLOCK DFHEILID, FOR USE BY THE LINKEDIT STEP                   *
//*-------------------------------------------------------------------*
//*
//COPYLINK EXEC PGM=IEBGENER,COND=(7,LT,COBOL)
//SYSUT1   DD DISP=SHR,DSN=<CICSPRFX>.SDFHCOB(DFHEILIC)
//SYSUT2   DD DISP=(NEW,PASS),DSN=&&COPYLINK,
//            DCB=(LRECL=80,BLKSIZE=400,RECFM=FB),
//            UNIT=SYSDA,SPACE=(400,(20,20))
//SYSPRINT DD DUMMY
//SYSIN    DD DUMMY
//*
//*-------------------------------------------------------------------*
//*  INVOKE THE MVS LINKAGE-EDITOR PROGRAM                            *
//*-------------------------------------------------------------------*
//*
//LKED     EXEC PGM=IEWL,COND=(7,LT,COBOL),
//  PARM='LIST,XREF,RENT,NAME=&MEM'
//SYSLIB   DD DISP=SHR,DSN=<CICSPRFX>.SDFHLOAD
//         DD DISP=SHR,DSN=<LIBPRFX>.SCEELKED
//SYSLMOD  DD DISP=SHR,DSN=<USER.LOAD.LIB>(&MEM)
//SYSUT1   DD UNIT=SYSDA,DCB=BLKSIZE=1024,
//            SPACE=(CYL,(1,1))
//SYSPRINT DD SYSOUT=*
//SYSLIN   DD DISP=(OLD,DELETE),DSN=&&COPYLINK
//         DD DISP=(OLD,DELETE),DSN=&&LOADSET
//         DD DISP=SHR,DSN=<ZCEEPRFX>.SBAQLIB1(BAQCSTUB)
//   PEND
//*
//COMPVSAM EXEC CBLPROC,MEM=CLAIMCI0
/*