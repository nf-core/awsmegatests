# awsmegatests
UNDER CONSTRUCTION!

CloudFormation templates to setup the aws megatests necessary cloud infrastructure

## Process

When a a pull request is made to a pipeline's master branch, a GitHub action is triggered. It starts an AWS batch job, which has permissions to subsequently spawn more AWS batch jobs. The first batch job pulls the nf-core pipeline from GitHub and starts it. The running pipeline can access a previously created S3 bucket to store any output files, such as work directory, trace directory, and the results. The pipeline's progress can be monitored on nf-core's nextflow tower instance. The final results are provided to nf-co.re. 

![AWS_megatests](AWS_megatests.png)

https://docs.google.com/document/d/1gJ4LiyV-iSZqoW6V-pqsrJGgNhs1kUPsTllTbpOIzNQ/edit#

## Prerequisites

- Access to nf-core AWS account

## Steps

This process was setup by following this [guide](https://docs.opendata.aws/genomics-workflows/quick-start/) and customizing a few steps.

### Set up a Virtual Private Cloud (VPC)

1. 

### Configure VPC


### Setup Nextflow resources


### Setup GitHub Actions

```
name: nf-core aws test
# This workflow is triggered on pushes and PRs to the repository.
# It runs the -profile 'test' on AWS batch
on:
  push:
  pull_request:
  release:
    types: [published]

jobs:
    Awstest:
        runs-on: ${{ matrix.os }}
        strategy:
            matrix:
                os: ['ubuntu-latest']
                python-version: ['3.7']
        steps:
        - uses: goanpeca/setup-miniconda@v1
          with:
            auto-update-conda: true
            python-version: ${{ matrix.python-version }}
        - name: Install aws client
          run: conda install -c conda-forge awscli
        - name: Start AWS batch job
          env:
            AWS_ACCESS_KEY_ID: ${{secrets.AWS_KEY_ID}}
            AWS_SECRET_ACCESS_KEY: ${{secrets.AWS_KEY_SECRET}}
          run: |
            aws batch submit-job --region <region> --job-name <name> --job-queue '<queue-name>' --job-definition nextflow --container-overrides command=nf-core/<mypipelinename>,"-profile test"

```

### Provide access to nextflow tower



