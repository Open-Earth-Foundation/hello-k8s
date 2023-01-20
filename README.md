## Build

`docker build -t public.ecr.aws/openearthfoundation/helloworld .`

## Run

`docker run -p 8080:80 public.ecr.aws/openearthfoundation/helloworld`

## Push the image to ECR from laptop

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

## Now Push to EKS

Check to make sure you are connected to the AWS EKS cluster. In order to connect to the cluster make sure you've configured your terminal using `aws configure` from the previous step. Then connect to the EKS cluster using `aws eks --region us-east-1 update-kubeconfig --name ${CLUSTER_NAME}`.

This updates your `kubectrl` to refer to the AWS EKS cluster.

To confirm the connection, run `kubectl -n default get all` and verify you are in the right cluster. To see the ingress run `kubectl -n default get ingress`

Now you are ready to push to the cluster. Make sure you have your EKS configuration setup, for reference, in this Github these files are located at hello-k8s/helloworld-\*.yml. Make sure in the configuration you point the container image to the image you just uploaded to ECR above.

_Important note! An EKS push doesn't need the ingress configuration as [it should be setup with an AWS ALB ingress controller](https://aws.amazon.com/blogs/opensource/kubernetes-ingress-aws-alb-ingress-controller/), it only needs the deployment and service. Compare this to the local kubernetes process which requires the configuration for the ingresses as that is necessary for local hosting._

Once the connection has been configured and the EKS file definition is setup, you apply the configuration using the following command `kubectl apply -f ${ROUTE_TO_COINFIGURATION_FILE} -n default`.

In our situation we would run the following two commands.

```
kubectl apply -f helloworld-deployment.yml -n default
kubectl apply -f helloworld-service.yml -n default
```

Confirm that the new services are up and deployed by running `kubectl -n default get all`. The deployments can be restarted with `kubectl rollout restart deployment helloworld-deployment -n default`

## Once you see the services up and running on the AWS EKS cluster you now need to edit the ingress

The following command will open the vim to edit the ingress.

```
kubectl edit ingress ingress -n default
```

As an example of what you will see in the ingress file, we've included a copy in this repo as example-aws-ingress.yml.

Append an additional route for your new service and the save and close the text editor. The AWS load balancer should automatically add the route and have it up at the path you've specified in your ingress configuration. In our example we added this additional route on line 42-51.

```
    - host: helloworld.openearth.dev
      http:
        paths:
          - backend:
              service:
                name: helloworld
                port:
                  number: 80
            path: /
            pathType: Prefix
```

The load balancer should automatically detect the new route and it should be available shortly under both HTTP and HTTPS.

## Run the app on Kubernetes locally

You need to have an Ingress controller running on your local Docker Desktop in order for this to work! Run this command to install it.

````

kubectl apply -f https://raw.githubusercontent.com/kubernetes/ingress-nginx/controller-v1.5.1/deploy/static/provider/cloud/deploy.yaml

```

The `helloworld-*.yml` files defines three resources

- A "Deployment" that runs and manages the "Pod" containers for the helloworld app
- A "Service" that provides a network interface to the Pods; it's kind of like an internal load balancer
- An "Ingress" that provides external access to the Service interface

Run this command to create a namespace:

```

kubectl create namespace helloworld

```

Then, run this command:

```

for f in ./helloworld-\*.yml; do kubectl -n helloworld apply -f $f; done

```

This will create all the resources.

You should be able to view the helloworld app at http://localhost/

You can see most of the stuff by running:

```

kubectl -n helloworld get all

```

You have to run this to see the ingress:

```

kubectl -n helloworld get ingresses

```

:shrug:

Run this command to clean up:

```

for f in ./helloworld-\*.yml; do kubectl -n helloworld delete -f $f; done

```

Or this (will wipe the whole namespace!). You need to delete the ingress separately because... reasons?

```

kubectl -n helloworld delete all --all
kubectl -n helloworld delete ingress helloworld-ingress

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

Note: just the hostname ("hello"), not the fully-qualified domain name ("hello.openearth.dev").

If you need to back it out, you can call the similar deletion script:

```

./delete-dns.sh <hostname> <ingress IP address>

```

Note that you have to include the IP address in the deletion command, too.
```
````
