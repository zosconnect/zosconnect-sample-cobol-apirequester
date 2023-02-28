# Sample CICS application for z/OS Connect Enterprise Edition (EE)

This repository contains a sample CICS COBOL application that uses the API Requester function of z/OS Connect EE to call a health insurance claim rule API hosted on the IBM Cloud.  The CICS application is invoked as a REST API using z/OS Connect EE.

![Diagram 1](https://github.com/zosconnect/zosconnect-sample-cobol-apirequester/blob/master/media/DiagFlow.png)

## Prerequisites

* z/OS Connect Enterprise Edition is installed and a z/OS Connect EE instance has been created and configured with the [CICS Service Provider](https://www.ibm.com/support/knowledgecenter/SS4SVW_3.0.0/configuring/cics_service_provider.html) and the [API Requester function](https://www.ibm.com/support/knowledgecenter/SS4SVW_3.0.0/configuring/config_zCEE_apireq.html). 
* CICS Transaction Server v5.2 or later 
* The CICS region is running and [configured to access z/OS Connect EE to call APIs](https://www.ibm.com/support/knowledgecenter/SS4SVW_3.0.0/configuring/config_cics_commstub.html).
* Enterprise COBOL Compiler

## Installing

* Clone this repository `git clone git@github.com:zosconnect/zosconnect-sample-cobol-apirequester.git`
* Allocate a PDS with 30 tracks for the jobs and sample source files

```text
Average record unit
Primary quantity  . . 30
Secondary quantity    5
Directory blocks  . . 10
Record format . . . . FB
Record length . . . . 80
Block size  . . . . . 27920
Data set name type    PDS
```

* Upload the following source and sample JCLs to your z/OS system and store on the PDS that was allocated

```text
claimci0.cbl
claiminf.cpy
claimreq.cpy
claimrqc.cpy
claimrsc.cpy
claimrsp.cpy
cicsdefn.jcl
compile.jcl
vsam.jcl
```

* Customize the uploaded copy of **compile.jcl** for your environment and submit to compile the sample CICS COBOL program. The load module should be installed on a PDSE library that is accessible to the CICS region. Additional instructions are provided in the sample JCL. The expected return code is **0**.

* Customize the uploaded copy of **vsam.jcl** for your environment and submit to define the VSAM data set used by the CICS program. Additional instructions are provided in the sample JCL. The expected return code is **0**.

* Customize the uploaded copy of **ciscdefn.jcl** for your environment and submit to define the CICS resources. Additional instructions are provided in the sample JCL. The expected return code is **0**.

## Configuring

* Create the following directories (if not done yet) called **resources/zosconnect/services**, **resources/zosconnect/apis**, and **resources/zosconnect/apiRequesters** under your server path.
  ```text
  /var/zosconnect/servers/<server-name>/resources/zosconnect/services
  /var/zosconnect/servers/<server-name>/resources/zosconnect/apis
  /var/zosconnect/servers/<server-name>/resources/zosconnect/apiRequesters
  ```
* Recursively chown and chmod the output directories so your z/OS Connect server ID has access to them.
  ```sh
  cd /var/zosconnect/servers/<server-name>
  chown -R <serverID>:<serverGroup> ./resources
  chmod -R 750 ./resources
  ```

* Setup definitions for the API Requester end-point (outbound) and the CICS IPIC connection (inbound) in server.xml. The server.xml should have the following entries added.
  ```xml
  <zosconnect_endpointConnection id="nodejsClaims"
     host="claims-rule-node-demo.mybluemix.net"
     port="80"/>

  <zosconnect_cicsIpicConnection id="zconipic"
  	 host="<hostname>"
  	 port="<portnum>"/>
  ```

**NOTE:** Change the hostname and portnum to the actual hostname and port number of the CICS region where the CICS sample program (CLAIMCI0) was installed. A sample server.xml is included in the package. If you want to use the sample server.xml file then upload it to z/OS in binary mode to keep the contents in ASCII format.

* To enable the CICS applications to call REST APIs through the z/OS Connect EE server, [the communication stub in the CICS region needs to be configured](https://www.ibm.com/support/knowledgecenter/SS4SVW_3.0.0/configuring/config_cics_commstub.html). This requires setting up the following resources: TDQUEUE, URIMAP, and PROGRAM. Below is a sample URIMAP definition that handles HTTP client requests from the communication stub to the z/OS Connect EE server. In the sample, the same z/OS Connect EE server is used for the inbound request (API Provider) and outbound request (API Requester).

![Diagram 1](https://github.com/zosconnect/zosconnect-sample-cobol-apirequester/blob/master/media/DiagBAQURIMP.png)

## Deploying the sample API

This repository includes the sample API (**cicsClaimsAPI.aar**), service (**CICSClaimsService.sar**) and API requester (**claims.ara**) archive files. 

Follow the steps below to deploy the included archive files:

* To deploy the sample service (**CICSClaimsService.sar**), follow the steps described in the [Automated service archive management](https://www.ibm.com/support/knowledgecenter/SS4SVW_3.0.0/administering/auto_sar_mgmnt.html) section of the z/OS Connect EE documentation in the IBM Knowledge Center. If transferring the file via ftp, ensure the file is transferred as binary.

* To deploy the sample API (**cicsClaimsAPI.aar**), follow the steps described in the [Automated API management](https://www.ibm.com/support/knowledgecenter/SS4SVW_3.0.0/com.ibm.zosconnect.doc/administering/auto_api_mgmnt.html) section of the z/OS Connect EE documentation in the IBM Knowledge Center. If transferring the file via ftp, ensure the file is transferred as binary.

* To deploy the sample API Requester (**claims.ara**), follow the steps described in the [How to deploy an API requester automatically](https://www.ibm.com/support/knowledgecenter/SS4SVW_3.0.0/administering_apireqs/auto_apiReq_mgmnt.html) section of the z/OS Connect EE documentation in the IBM Knowledge Center. If transferring the file via ftp, ensure the file is transferred as binary.

Follow the steps below to generate and deploy from the sample projects / source provided:

* On your IBM Explorer for z/OS (or any of the supported Eclipse environment), click on **File -> Import** then click on **General -> Existing Projects into Workspace**. Select the CICSClaimsServiceProject.zip file included in the package (confirm that the CICSClaimsService project is selected under the Projects field) and click **Finish**. Repeat the same steps for CICSClaimsAPIProject.zip (confirm that the CICSClaimsAPI project is selected under the Projects field).

* To deploy the service from the API Toolkit, follow the steps described in the [Deploying a service](https://www.ibm.com/support/knowledgecenter/SS4SVW_3.0.0/designing/service_deploy_service.html) section of the z/OS Connect EE documentation in the IBM Knowledge Center.

* To deploy the API from the API Toolkit, follow the steps described in the [Deploying an API in the API toolkit](https://www.ibm.com/support/knowledgecenter/SS4SVW_3.0.0/designing/api_deploy_aar.html) section of the z/OS Connect EE documentation in the IBM Knowledge Center.

* Create the ARA file and other API Requester artifacts using the z/OS Connect Enterprise Edition build toolkit and follow the steps described in the [How to deploy an API requester automatically](https://www.ibm.com/support/knowledgecenter/SS4SVW_3.0.0/administering_apireqs/auto_apiReq_mgmnt.html) section of the z/OS Connect EE documentation in the IBM Knowledge Center. If transferring the file via ftp, ensure the file is transferred as binary.
  ```sh
  zconbt -p=claims.properties -f=claims.ara
  ```

## Testing the sample API

At this point, the sample API is now ready for testing. Start by testing the REST API that is called from the CICS application.

On a browser, type the following for an **Accepted** health insurance claim:

  ```text
  https://yt-claims-multi-arch-yt-zosconnect-demo.ytcluster01-tor01-m3c-4x3-fb24546bc9d850e9e034b4027bf0ce8c-0000.us-east.containers.appdomain.cloud/claims/claim/rule?claimType=MEDICAL&claimAmount=100.00
  ```

This will return the following results:

  ```json
  {
   "claimType": "MEDICAL",
   "claimAmount": "100.00",
   "status": "Accepted",
   "reason": "Normal claim"
  }
  ```

and type the following for a **Rejected** health insurance claim.

  ```text
  https://yt-claims-multi-arch-yt-zosconnect-demo.ytcluster01-tor01-m3c-4x3-fb24546bc9d850e9e034b4027bf0ce8c-0000.us-east.containers.appdomain.cloud/claims/claim/rule?claimType=MEDICAL&claimAmount=350.00
  ```

This will return the following results:

  ```json
  {
    "claimType": "MEDICAL",
    "claimAmount": "350.00",
    "status": "Rejected",
    "reason": "Amount exceeded 300.00. Claim require further review."
  }
  ```
  
**NOTE:** If you prefer to run the health claim business rule locally, you can get the sample source code (sample-3.js) provided in the [GitHub Sample on Node.js clients](https://github.com/zosconnect/sample-nodejs-clients).

Next step is to test the CICS sample application that calls the health insurance claim REST API.

To test the API using the z/OS Connect EE API Editor, refer to the section on [Examining, testing, starting and stopping an API](https://www.ibm.com/support/knowledgecenter/SS4SVW_3.0.0/com.ibm.zosconnect.doc/designing/api_edit_view_start_stop.html) section of the z/OS Connect EE documentation in the IBM Knowledge Center.  

Use the **POST** action in the **cicsClaimsAPI** and specify the following values to get a status of **Accepted** from the health insurance claim REST API call:

* Type **00000001** under **claimID**
* Type **MEDICAL** under **claimType**
* Type **100.00** under **claimAmount**
* Type **01/01/2020** under **serviceDate**
* Type **AMBULANCE** under **Description**
* Type **GENERAL HOSPITAL** under **ServiceProvider**

To test the API using **curl**, type the following:

  ```sh
  curl -X POST --header 'Content-Type: application/json' --header 'Accept: application/json' -d '{"CICSClaimsServiceOperation":{"CLAIMCI0_CONT":{"REQ_CLAIM_CONTAINER":{"REQ_CLAIM_RECORD":{"REQ_CLAIM_DETAILS":{"ClaimType":"MEDICAL","ClaimAmount":100,"ServiceDate":"01/01/2020","Description":"AMBULANCE","ServiceProvider":"GENERAL HOSPITAL"}}}}}}' 'http://<hostname>:<port>/cics/health/claims/00000001'
  ```

Below is the sample output, note that the **ClaimStatus** field was set to **OKAY**. This is the value set by the CICS application when the claim is **Accepted**.

  ```json
  {
    "CICSClaimsServiceOperationResponse": {
      "CLAIMCI0_CONT": {
        "RSP_CLAIM_CONTAINER": {
          "OutputMessage": "SUCCESS: CLAIM RECORD SUBMITTED FOR 00000001",
          "CICSResponseCode": 0,
          "CICSResponseCode2": 0,
          "RSP_CLAIM_RECORD": {
            "ClaimID": "00000001",
            "RSP_CLAIM_DETAILS": {
              "ClaimAmount": 100,
              "ServiceDate": "01/01/2020",
              "Description": "AMBULANCE",
              "ServiceProvider": "GENERAL HOSPITAL",
              "ClaimStatus": "OKAY",
              "ClaimType": "MEDICAL"
            }
          }
        }
      }
    }
  }
  ```

Use the **POST** action in the **cicsClaimsAPI** and specify the following values to get a status of **Rejected** from the health insurance claim REST API call:

* Type **00000002** under **claimID**
* Type **MEDICAL** under **claimType**
* Type **250.00** under **claimAmount**
* Type **01/02/2020** under **serviceDate**
* Type **DOCTOR VISIT** under **Description**
* Type **DR JOHN DOE** under **ServiceProvider**

To test the API using **curl**, type the following:

  ```sh
  curl -X POST --header 'Content-Type: application/json' --header 'Accept: application/json' -d '{"CICSClaimsServiceOperation":{"CLAIMCI0_CONT":{"REQ_CLAIM_CONTAINER":{"REQ_CLAIM_RECORD":{"REQ_CLAIM_DETAILS":{"ClaimType":"MEDICAL","ClaimAmount":250,"ServiceDate":"01/02/2020","Description":"DOCTOR VISIT","ServiceProvider":"DR JOHN DOE"}}}}}}' 'http://<hostname>:<port>/cics/health/claims/00000002'
  ```

Below is the sample output, note that the **ClaimStatus** field was set to **PEND**. This is the value set by the CICS application when the claim is **Rejected**.

  ```json
  {
    "CICSClaimsServiceOperationResponse": {
      "CLAIMCI0_CONT": {
        "RSP_CLAIM_CONTAINER": {
          "OutputMessage": "SUCCESS: CLAIM RECORD SUBMITTED FOR 00000002",
          "CICSResponseCode": 0,
          "CICSResponseCode2": 0,
          "RSP_CLAIM_RECORD": {
            "ClaimID": "00000002",
            "RSP_CLAIM_DETAILS": {
              "ClaimAmount": 250,
              "ServiceDate": "01/02/2020",
              "Description": "DOCTOR VISIT",
              "ServiceProvider": "DR JOHN DOE",
              "ClaimStatus": "PEND",
              "ClaimType": "MEDICAL"
            }
          }
        }
      }
    }
  }
  ```

## Notice

&copy; Copyright IBM Corporation 2020

## License

```text
Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.
```
