## Deploy H2O cluster in AWS


### Requirements

* python
* virtualenv
* pip
* boto3


## Setup



### 1. Setup AWS Credentials for boto3

```
pip install boto3
```

- Add key info to `~/.aws/credentials`:

```
[default]
aws_access_key_id = YOUR_ACCESS_KEY
aws_secret_access_key = YOUR_SECRET_KEY
```

You may also want to set a default region. This can be done in the configuration file. By default, its location is at `~/.aws/config`:

```
[default]
region=us-east-1
```

### 2. Install python dependencies in virtualenv

```bash
cd h2o.ai-UI
virtualenv venv
source venv/bin/activate
pip install requirements.txt

```

### 3. Run the flask application locally


```bash
cd h2o.ai-UI
source venv/bin/activate
python run.py
```

Access the application in the browser

```
127.0.0.0.1:5000
```
