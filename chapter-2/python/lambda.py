#############################################################################
# lambda.py                                                                 #
#                                                                           #
# DESCRIPTION: This lambda function is used to update the EKS Cluster       #
#              network configuration. It will do the following:             #
#                1) Create SSM Parameter store for EKS endpoint             #
#                2) Create SSM Parameter store for EKS certificateAuthority #
#                3) Set the endpointpublic access to True                   #
#                4) Set the endpointprivate access to True                  #
#                5) Add public access CIDRS                                 #
#############################################################################

import json
import logging
import random
import threading
import urllib3
import uuid
import boto3

http = urllib3.PoolManager()

logger = logging.getLogger()

_uu = str(uuid.uuid4())

#==================================================================================================
# Function: cfnresponse
# Purpose:  Handles the response back to CloudFormation
#==================================================================================================
def cfnresponse(event, context, responseStatus, responseData,
physicalResourceId=None, noEcho=False):
    responseBody = {}
    responseBody['Status'] = responseStatus
    responseBody['Reason'] = 'See the details in CloudWatch Log Stream: '+ context.log_stream_name
    responseBody['PhysicalResourceId'] = physicalResourceId or context.log_stream_name
    responseBody['StackId'] = event['StackId']
    responseBody['RequestId'] = event['RequestId']
    responseBody['LogicalResourceId'] = event['LogicalResourceId']
    responseBody['NoEcho'] = noEcho
    responseBody['Data'] = responseData
    json_responseBody = json.dumps(responseBody)
    headers = {'content-type': '','content-length': str(len(json_responseBody))}
    print("Response body:" + json_responseBody)
    try:
        response = http.request(
            'PUT', event['ResponseURL'], body=json_responseBody.encode('utf-8'), headers=headers)
        logger.debug('Status code: ' + response.reason)
    except Exception as e:
        logger.error('cfnresponse(..) failed executing requests.put(..): ' + str(e))

#==================================================================================================
# Function: timeout
# Purpose:  Handles the timeout response to CloudFormtion
#==================================================================================================
def timeout(event, context):
    logging.error(
        'Execution is about to time out, sending failure response to CloudFormation')
    cfnresponse(event, context, 'FAILED')

#==================================================================================================
# Function: lambda_handler
# Purpose:  Main function coordinating operations
#==================================================================================================
def lambda_handler(event, context):
    print(json.dumps(event))
    _ret = {}
    timer = threading.Timer((context.get_remaining_time_in_millis()/ 1000.00) - 0.5, timeout, args=[event, context])
    timer.start()
    status = 'SUCCESS'

    try:

# if event is delete then process. Cleanup

        if event['RequestType'] == 'Delete':
          print (event)

          eks_client = boto3.client('eks')

          response = eks_client.update_cluster_config(
             name=event['ResourceProperties']['ClusterName'],
             resourcesVpcConfig={
               'endpointPublicAccess': True,
               'endpointPrivateAccess': False,
               'publicAccessCidrs': ['0.0.0.0/0']
             },)
          print (response)


# if event is create then process. Otherwise, exit immediately

        if event['RequestType'] == 'Create':

# Get EKS Cluster information to be placed in SSM parameter store

            eks_client = boto3.client('eks')

            cluster_info = eks_client.describe_cluster(name=event['ResourceProperties']['ClusterName'])
            print (cluster_info)

# Update EKS endpoint access and public access CIDRS

            response = eks_client.update_cluster_config(
               name=event['ResourceProperties']['ClusterName'],
               resourcesVpcConfig={
                 'endpointPublicAccess': True,
                 'endpointPrivateAccess': True,
                 'publicAccessCidrs': [
                         event['ResourceProperties']['PublicIP1'],
                         event['ResourceProperties']['PublicIP2'],
                         event['ResourceProperties']['PublicIP3'],
                         event['ResourceProperties']['PublicIP4'],
                         event['ResourceProperties']['PublicIP5']
                  ]
               },)

        print (response)
        _ret['Arn'] = status
        cfnresponse(event, context, status, _ret)
        return

    except eks_client.exceptions.InvalidParameterException as e:
        logging.warning('Exception: %s' % e, exc_info=True)
        status = 'SUCCESS'
    except Exception as e:
        print(e)
        logging.error('Exception: %s' % e, exc_info=True)
        status = 'FAILED'
    finally:
        timer.cancel()
        cfnresponse(event, context, status, _ret)
