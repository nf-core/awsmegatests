#!/bin/bash
# WARNING: this script will help you deregister all job definitions, 
# and disable and remove all job queues 
# and compute environments in your AWS account, in the specified region
# Based on https://ec2spotworkshops.com/nextflow-on-aws-batch/60_cleanup.html
# -----------------------------------------------
# Requires aws cli installation, and set up with your credentials by executing
# $ aws configure
# -----------------------------------------------
# Requires jq tool installation: http://macappstore.org/jq/
# ------------------------------------------------

# AWS region set up
AWS_REGION='eu-west-1'

# Deregister job definitions
for jd in $(aws batch --region=${AWS_REGION} describe-job-definitions |jq -r '.jobDefinitions[] | .jobDefinitionArn' |xargs)
do
  echo "# aws batch --region=${AWS_REGION} deregister-job-definition --job-definition=${jd}"
  echo "-> (remove? press any key)" ; read ; aws batch --region=${AWS_REGION} deregister-job-definition --job-definition=${jd}
done

# Disable all job queues
for jq in $(aws batch --region=${AWS_REGION} describe-job-queues |jq -r '.jobQueues[] |.jobQueueName' |xargs)
do
  echo "# aws batch --region=${AWS_REGION} update-job-queue --state=DISABLED --job-queue=${jq}"
  echo "-> (DISABLE? press any key)"
  read
  aws batch --region=${AWS_REGION} update-job-queue   --state=DISABLED --job-queue=${jq}
done

# Delete all job queues
for jq in $(aws batch --region=${AWS_REGION} describe-job-queues |jq -r '.jobQueues[] |.jobQueueName' |xargs)
do 
  echo "# aws batch --region=${AWS_REGION} delete-job-queue --job-queue=${jq}"
  aws batch --region=${AWS_REGION} delete-job-queue --job-queue=${jq}
done

# Disable all compute environments
for ce in $(aws batch --region=${AWS_REGION} describe-compute-environments |jq -r '.computeEnvironments[] |.computeEnvironmentName' |xargs)
do
  echo "# aws batch --region=${AWS_REGION} update-compute-environment --state=DISABLED --compute-environment=${ce}"
  echo "-> (DISABLE? press any key)"
  read
  aws batch --region=${AWS_REGION} update-compute-environment --state=DISABLED --compute-environment=${ce}
done

# Delete all compute environments
for ce in $(aws batch --region=${AWS_REGION} describe-compute-environments |jq -r '.computeEnvironments[] |.computeEnvironmentName' |xargs)
do
  echo "# aws batch --region=${AWS_REGION} delete-compute-environment --compute-environment=${ce}"
  aws batch --region=${AWS_REGION} delete-compute-environment --compute-environment=${ce}
done


