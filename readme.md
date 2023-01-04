# Deploying Temporal server and Temporal appication for Production on EKS

## Install Temporal service on a Kubernetes cluster

## Prerequisites

This sequence assumes

- that your system is configured to access a kubernetes cluster (e. g. [AWS EKS](https://aws.amazon.com/eks/), [kind](https://kind.sigs.k8s.io/), or [minikube](https://kubernetes.io/docs/tasks/tools/install-minikube/)), and
- that your machine has
  - [AWS CLI V2](https://docs.aws.amazon.com/cli/latest/userguide/install-cliv2.html),
  - [kubectl](https://kubernetes.io/docs/tasks/tools/install-kubectl/), and
  - [Helm v3](https://helm.sh)
    installed and able to access your cluster.

## Download Helm Chart Dependencies

Download Helm dependencies:

```bash
$ helm dependencies update
```

## Install Temporal with Helm Chart

Temporal can be configured to run with various dependencies. The default "Batteries Included" Helm Chart configuration deploys and configures the following components:

- Cassandra
- ElasticSearch
- Prometheus
- Grafana

The sections that follow describe various deployment configurations, from a minimal one-replica installation using included dependencies, to a replicated deployment on existing infrastructure.

### Minimal installation with required dependencies only

To install Temporal in a limited but working and self-contained configuration (one replica of Cassandra and each of Temporal's services, no metrics or ElasticSearch), you can run the following command

```
cd helm chat
```

```
~/helm-chats$ helm install \
    --set server.replicaCount=1 \
    --set cassandra.config.cluster_size=1 \
    --set prometheus.enabled=false \
    --set grafana.enabled=false \
    --set elasticsearch.enabled=false \
    temporaltest . --timeout 15m
```

Below is an example of an environment installed in this configuration:

```
$ kubectl get pods
NAME                                           READY   STATUS    RESTARTS   AGE
temporaltest-admintools-6cdf56b869-xdxz2       1/1     Running   0          11m
temporaltest-cassandra-0                       1/1     Running   0          11m
temporaltest-frontend-5d5b6d9c59-v9g5j         1/1     Running   2          11m
temporaltest-history-64b9ddbc4b-bwk6j          1/1     Running   2          11m
temporaltest-matching-c8887ddc4-jnzg2          1/1     Running   2          11m
temporaltest-metrics-server-7fbbf65cff-rp2ks   1/1     Running   0          11m
temporaltest-web-77f68bff76-ndkzf              1/1     Running   0          11m
temporaltest-worker-7c9d68f4cf-8tzfw           1/1     Running   2          11m
```

### Running Temporal CLI From the Admin Tools Container

You can also shell into `admin-tools` container via [k9s](https://github.com/derailed/k9s) or by running

```
$ kubectl exec -it services/temporaltest-admintools /bin/bash
bash-5.0#
```

and run Temporal CLI from there:

```
bash-5.0# tctl namespace list
Name: temporal-system
Id: 32049b68-7872-4094-8e63-d0dd59896a83
Description: Temporal internal system namespace
OwnerEmail: temporal-core@temporal.io
NamespaceData: map[string]string(nil)
Status: Registered
RetentionInDays: 7
EmitMetrics: true
ActiveClusterName: active
Clusters: active
HistoryArchivalStatus: Disabled
VisibilityArchivalStatus: Disabled
Bad binaries to reset:
+-----------------+----------+------------+--------+
| BINARY CHECKSUM | OPERATOR | START TIME | REASON |
+-----------------+----------+------------+--------+
+-----------------+----------+------------+--------+
```

```
bash-5.0# tctl --namespace nonesuch namespace desc
Error: Namespace nonesuch does not exist.
Error Details: Namespace nonesuch does not exist.
```

```
bash-5.0# tctl --namespace nonesuch namespace re
Namespace nonesuch successfully registered.
```

```
bash-5.0# tctl --namespace nonesuch namespace desc
Name: nonesuch
UUID: 465bb575-8c01-43f8-a67d-d676e1ae5eae
Description:
OwnerEmail:
NamespaceData: map[string]string(nil)
Status: Registered
RetentionInDays: 3
EmitMetrics: false
ActiveClusterName: active
Clusters: active
HistoryArchivalStatus: ArchivalStatusDisabled
VisibilityArchivalStatus: ArchivalStatusDisabled
Bad binaries to reset:
+-----------------+----------+------------+--------+
| BINARY CHECKSUM | OPERATOR | START TIME | REASON |
+-----------------+----------+------------+--------+
+-----------------+----------+------------+--------+
```

### Forwarding Your Machine's Local Port to Temporal FrontEnd

You can also expose your instance's front end port on your local machine:

```
$ kubectl port-forward services/temporaltest-frontend-headless 7233:7233
Forwarding from 127.0.0.1:7233 -> 7233
Forwarding from [::1]:7233 -> 7233
```

and, from a separate window, use the local port to access the service from your application or Temporal samples.

### Forwarding Your Machine's Local Port to Temporal Web UI

Similarly to how you accessed Temporal front end via kubernetes port forwarding, you can access your Temporal instance's web user interface.

To do so, forward your machine's local port to the Web service in your Temporal installation

```
$ kubectl port-forward services/temporaltest-web 8080:8080
Forwarding from 127.0.0.1:8080 -> 8080
Forwarding from [::1]:8080 -> 8080
```

and navigate to http://127.0.0.1:8080 in your browser.

### Package this temporal app as a docker image

The dockerFile at the root of the folder can be used to dockerize the application to be deloped on Kubernetes

```
docker build -t starwars-node .

```

this image can be pushed to a private reository like AWS ECR which will be refrenced in the CICD phase

### deploy the app using Kubernetes

The delopment folder contains the deployment files for the temporal app
which is a simple deployment for the application on Kubernetes

- change directory deployment folder

```
cd deployment
```

```
kubectl apply -f app-deployment.yml

kubectl get deployment
```

```
kubectl apply -f app-service.yml

kubectl get service

```

Observe that app-service created

### write a CICD for the app

The CICD process can be handeled with aws codePipline and the buildspec file containes the CICD stages for AWS Code build to deploy the application.
AWS_ACCESS_KEY_ID, REPOSITORY_URI, TAG are all held in code build enviroment vaiables

### How would you improve this app?

logs for all the services can be streamed to cloudwatch an external resources Fluent Bit or Fluentd to send logs from your containers to your CloudWatch logs
aws conatiner insite can be used for detail monitoring of custer resoures and metics

AWS X-Ray can be used which provides application-tracing functionality, giving deep insights into all microservices deployed. With X-Ray, every request can be traced as it flows through the involved microservices. This provides your DevOps teams the insights they need to understand how your services interact with their peers and enables them to analyze and debug issues much faster.

Services meshes such as AWS App Mesh help you to connect services, monitor your application’s network, and control the traffic flow. When an application is running within a service mesh, the application services are run alongside proxies which form the data plane of the mesh another platform diagnostic is Isto
