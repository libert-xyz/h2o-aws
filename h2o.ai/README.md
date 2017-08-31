## Deploy H2O cluster in AWS


### Requirements

* aws-cli


## Setup


### 1. Install awscli

#### Mac and Linux

```bash
 pip install awscli
```

#### Windows


Download and run the [64-bit](https://s3.amazonaws.com/aws-cli/AWSCLI64.msi) or [32-bit](https://s3.amazonaws.com/aws-cli/AWSCLI32.msi) Windows installer.


### 2. Set up Amazon Credentials

- Add key info to `~/.bash_profile`:
```
# EC2 keys
export AWS_ACCESS_KEY_ID=""
export AWS_SECRET_ACCESS_KEY=""
```

### 3. Update the h2o-aws.sh file

If necessary update the default variables

```bash
MAX_INSTANCES=15
KEY_PAIR='h2o'
ALLOWED_NETWORK='0.0.0.0/0'
AWS_REGION='us-east-1'
INSTANCE_TYPE='t2.micro'
PROFILE='default'
```

### 4. Launch the Cluster

from the h2o.ai directory

```bash
cd h2o.ai
bash h2o-aws.sh
```
