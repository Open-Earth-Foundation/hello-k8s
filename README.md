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

## Run the app on Kubernetes locally

The `helloworld.yaml` file defines three resources (they're separated by "---")

- A "Deployment" that runs and manages the "Pod" containers for the helloworld app
- A "Service" that provides a network interface to the Pods; it's kind of like an internal load balancer
- An "Ingress" that provides external access to the Service interface

Run this command to create a namespace:

```
kubectl create namespace helloworld
```

Then, run this command:

```
kubectl -n helloworld apply -f ./helloworld.yaml
```

This will create all the resources.

You should be able to view the helloworld app at http://localhost/

You can see all the stuff by running:

```
kubectl -n helloworld get all
```

Run this command:

```
kubectl delete -f ./helloworld-config.yaml
```

To get rid of the app.

# Map a hostname in the openearth.dev domain to an Ingress on AWS

The AWS command line lets you add domain names, but it's wrapped in a weird JSON format.

There's a script in this directory that wraps up that command, so you can call the script for most uses.

```
kubectl get ingress name-of-ingress
```

...should show the public IP address of the ingress created. Then this will set the hostname:

```
./set-dns.sh <hostname> <ingress IP address>
```

If you need to back it out, you can call the similar deletion script:

```
./delete-dns.sh <hostname> <ingress IP address>
```

Note that you have to include the IP address in the deletion command, too.
