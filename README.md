# awsmegatests
UNDER CONSTRUCTION!

CloudFormation templates to setup the aws megatests necessary cloud infrastructure

## Process

When a a pull request is made to a pipeline's master branch, a GitHub action is triggered. It starts an AWS batch job, which has permissions to subsequently spawn more AWS batch jobs. The first batch job pulls the nf-core pipeline from GitHub and starts it. The running pipeline can access a previously created S3 bucket to store any output files, such as work directory, trace directory, and the results. The pipeline's progress can be monitored on nf-core's nextflow tower instance. The final results are provided to nf-co.re. 
 
![AWS_megatests](AWS_megatests.png)

https://docs.google.com/document/d/1gJ4LiyV-iSZqoW6V-pqsrJGgNhs1kUPsTllTbpOIzNQ/edit#
