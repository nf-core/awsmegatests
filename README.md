# awsmegatests

CloudFormation templates to setup the necessary cloud infrastructure
for aws megatests.

## Process

When this GitHub Action workflow is triggered, it starts an AWS batch job, which has permissions to subsequently spawn more AWS batch jobs. 
The first batch job pulls the nf-core pipeline from GitHub and starts it. 
The running pipeline can access a previously created S3 bucket to store any output files, such as the work directory, the trace directory, and the results. 
The pipeline's progress can be monitored on nf-core's nextflow tower instance. The final results are provided to nf-co.re. 

![AWS_megatests](AWS_megatests.png)

## Prerequisites

- Access to nf-core AWS account

## Steps

This process was set up by following this [guide](https://docs.opendata.aws/genomics-workflows/quick-start/) but some of the templates were adapted to include missing permission, so we recommend to use the templates in this repository instead.

### Set up permissions

### (Create an S3 bucket)

If an S3 bucket does not exist yet, create an S3 bucket to store the run intermediate files and results. An S3 bucket was created to store all `work` and `results` directories for the AWS tests: `S3:nf-core-awsmegatests`.
1. Log in to AWS
2. Navigate to `S3`
3. Create new bucket, remember the name, i.e.:  `nf-core-awsmegatests`

### Step 1: set up a Virtual Private Cloud (VPC)

1. Our template is based on the template on this tutorial: ['Launch Quick Start'](https://eu-west-1.console.aws.amazon.com/cloudformation/home?region=eu-west-1#/stacks/create/template?stackName=Quick-Start-VPC&templateURL=https://aws-quickstart.s3.amazonaws.com/quickstart-aws-vpc/templates/aws-vpc.template). You can directly launch this one, or the [VPCsetup.yml](./templates/VPCsetup.yml) template in this repository.

:warning: Check that the region in which you are launching all the templates is the desired region. In our case, we set up all the infrastructure in `eu-west-1`.

2. Under `CloudFormation`, select 'Create Template' with new resources.
3. Select 'Template is ready' and 'Upload a template file'
4. Upload the template [VPCsetup.yml](https://github.com/nf-core/awsmegatests/blob/master/templates/VPCsetup.yml)
5. Set 'Availability Zones' to `eu-west-1, eu-west-2, eu-west-3`
6. Set 'Number of Availability Zones' to `3`
7. Follow to the next steps of the wizard, acknowledge the capabilities and create stack.

### Set up Core Environment
The template used in this step is based on the template available here: ['Option A: Full Stack'](https://docs.opendata.aws/genomics-workflows/quick-start/):
1. Press 'Launch Stack'
2. Select 'Template is ready'
3. Select 'Upload a template file'
4. Use [GWFcore.yml](https://github.com/nf-core/awsmegatests/blob/master/templates/GWFcore.yml) and press 'Next'
5. Follow the launch wizard. Give the stack a name (e.g. GWFcore). 
6. Set 'S3 bucket name' to `nf-core-awsmegatests` (or the name specified in the previous step).  Set existing to 'true' if the S3 bucket exists.
7. Set 'Workflow orchestrator' to `Nextflow`
8. Private subnet -> VPC created on previous step (check on previous step in resources tab), private subnet 1A/2A/3A
9. Set max spot bid % to a reasonable number (e.g. 60 %), alter any other defaults settings as necessary. We left the rest of the settings by default
10. Follow to the next step of the wizard, acknowledge the capabilities and create stack.

### Setup Nextflow resources
1. Launch the [Nextflow resources template](./templates/Nextflow_resources.yml)
2. Provide a name to the stack (e.g. NextflowResources).
3. Provide the S3 bucket name for the data and nextflow logs (we provided the `nf-core-awstests` bucket). The bucket must exist.
4. Provide the default job queue ARNs that were generated as output when running the previous template.
5. Leave the Nextflow container image field empty. You can leave the optional fields as default.
6. Provide the high priority job queue ARNs generated as output of the previous template.
7. Acknowledge the capabilities and create stack.

### Setup GitHub Actions
A GitHub Actions workflow example to trigger the AWS tests can be found [here](.github/workflows/awstest.yml). The secrets that it uses need to be set up at an organization level, so that all pipelines can use them:

* AWSTEST_KEY_ID: IAM key ID for the AWS user in the nf-core account organization. A specific user was set with restricted roles to run these tests.
* AWSTEST_KEY_SECRET: IAM key secret for the same user.
* AWSTEST_TOWER_TOKEN: token for Nextflow tower, to be able to track all pipeline tests running on AWS.
* AWS_JOB_DEFINITION: this job definition needs to be created once manually on AWS batch and can then be used in all pipeline runs. Currently, it is called `nextflow`.
* AWS_JOB_QUEUE: the name of the default queue that was created with CloudFormation templates.
* AWS_S3_BUCKET: the name of the s3 bucket specified during the template launch (nf-core-awsmegatests).
```
name: AWS Megatests
# This workflow is triggered on pushes and PRs to the repository.
# Currently the -profile 'test' is used on AWS batch. In the future 
# this will be replaced by using actual data sets as test data.

on:
  pull_request:
    branches:
    - 'master'
  release:
    types: [published]

jobs:
  run-awstest:
    name: Run AWS test
    runs-on: ubuntu-latest
    steps:
      - name: Setup Miniconda
        uses: goanpeca/setup-miniconda@v1.0.2
        with:
          auto-update-conda: true
          python-version: 3.7
      - name: Install awscli
        run: conda install -c conda-forge awscli
      - name: Start AWS batch job
        env:
          AWS_ACCESS_KEY_ID: ${{secrets.AWS_KEY_ID}}
          AWS_SECRET_ACCESS_KEY: ${{secrets.AWS_KEY_SECRET}}
          TOWER_ACCESS_TOKEN: ${{secrets.TOWER_ACCESS_TOKEN}}
        run: |
          aws batch submit-job --region eu-west-1 --job-name <name> --job-queue '<queue name>' --job-definition nextflow --container-overrides command=nf-core/<pipeline name>,"-r ${GITHUB_SHA} -profile <AWS test profile> --outdir s3://nf-core-awsmegatests/<pipeline name>/results-${GITHUB_SHA} -w s3://nf-core-awsmegatests/<pipeline name>/work-${GITHUB_SHA}" 
```
#### Description
`Miniconda` is needed to install up `awscli`. In order to use `Miniconda` the latest stable release of a GitHub Action offered from the [marketplace](https://github.com/marketplace/actions/setup-miniconda) is used. Subsequently, `awscli` is installed via the `conda-forge` channel. For accessing the nf-core AWS account as well the nextflow tower instance, secrets have to be set. This can only be done by one of the core members within the repository under Settings > Secrets > Add new secret.
