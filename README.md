## Build
``` docker build -t public.ecr.aws/openearthfoundation/helloworld . ```

## Run
``` docker run -p 8080:80 public.ecr.aws/openearthfoundation/helloworld ```

## Push to ECR from laptop

You'll need `docker` and the [AWS CLI](https://aws.amazon.com/cli/) `aws`.

1. Get an API key
    1. Go to https://388349917737.signin.aws.amazon.com/console and log in
    2. On menu, choose "Service"
    3. Choose "IAM"
    4. Choose "Users"
    5. Choose your user name
    6. Choose "Security credentials"
    7. Create an access key and save it
2. On command line, run `aws configure` and enter your keys
    1. For default region name, put "us-east-1"
3. Run this command to give AWS credentials to docker:
```bash
aws ecr-public get-login-password --region us-east-1 | docker login --username AWS --password-stdin public.ecr.aws/openearthfoundation
```
4. Run this command to push to ECR:
```
docker push public.ecr.aws/openearthfoundation/helloworld:latest
```