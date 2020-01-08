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
//* 2. Update <CICS.VSAM.FILE> with the actual name of the VSAM      *
//*    data set for the CICS sample program CLAIMCI0                 *
//*                                                                  *
//********************************************************************
//*********************************************
//* SAMPLE VSAM DATA FOR CLAIMS PROCESSING
//* DEMO
//*********************************************
//STEP01  EXEC PGM=IDCAMS
//SYSPRINT DD  SYSOUT=*
//SYSIN    DD  *
 DELETE (<CICS.VSAM.FILE>) CLUSTER PURGE
 IF MAXCC > 0 THEN SET MAXCC=0
 DEFINE  CLUSTER  -
   ( NAME           (<CICS.VSAM.FILE>) -
     KEYS           (8 0)                  -
     RECORDS        (200 50)               -
     VOLUMES        (VOLU01)               -
     SHAREOPTIONS   (2 3)                  -
     FREESPACE      (10 10)                -
     RECORDSIZE     (80  80)               -
     INDEXED                               -
   )                                       -
   DATA                                    -
   ( NAME(<CICS.VSAM.FILE>.DATA)) -
   INDEX                                   -
   ( NAME(<CICS.VSAM.FILE>.INDEX))
 IF LASTCC = 0 THEN LISTCAT ALL LEVEL(<CICS.VSAM.FILE>)
/*
