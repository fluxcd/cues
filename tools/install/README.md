# Flux install

This tool is intended for **non-gitops** deployments of Flux.
Instead of [bootstrapping](../bootstrap) Flux for a Git repository,
we install Flux and Minio directly on a cluster, then using the Minio client
we can upload Kubernetes manifests generated with CUE. Flux will be using
a Minio bucket to reconcile the cluster state.

## Define clusters and addons

In the `clusters.cue` you define the Kubernetes clusters that are subject to install:

```cue
local: cluster.#Install & {
	name: "kind"
	kubeconfig: context: "kind-\(name)"
	flux: {
		namespace:  "flux-system"
		components: cluster.Components.All
	}
	addons: [
		#MetricsServer & {
			spec: chart: version: "v3.x"
		},
		#Minio & {
			spec: chart: version: "v3.x"
		},
	]
}
```

In the `addons.cue` you define the cluster addons that are managed by Flux:

```cue
#CertManager: release.#Release & {
	spec: {
		name:            "cert-manager"
		namespace:       "flux-system"
		targetNamespace: "cert-manager"
		repository: {
			url: "https://charts.jetstack.io"
		}
		chart: {
			name: "cert-manager"
		}
		values: {
			installCRDs: true
		}
	}
}
```

When you add an addon to a cluster, you have to specify the Helm chart version.
To allow Flux to automatically upgrade the addon when a new chart is released,
the version can be a semver range:

```cue
local: cluster.#Install & {
	...
	addons: [
		#CertManager & {
			spec: chart: version: "v1.8.x" //<- upgrade to the latest patch version
		},
	]
}
```

To list all the defined clusters, run the `ls` command:

```console
$ cue ls ./tools/install/
CLUSTER  CONTEXT                                      ADDONS
kind     kind-kind                                    3
eks      demo@fluxcd.io@test.eu-central-1.eksctl.io   4
gke      gke_demo_europe-west4-a_test                 3
```

## Setup Flux and Minio on Kubernetes Kind

### Create a local cluster

Create a local cluster with [Kubernetes Kind](https://kind.sigs.k8s.io/):

```shell
kind create cluster
```

### Install Flux

To install Flux and Minio on your local cluster, run the `install` command:

```console
$ cue -t cluster=kind install ./tools/install/
► installing components in flux-system namespace
✔ install finished
► waiting for 2 addon(s) to become ready
helmrelease.helm.toolkit.fluxcd.io/metrics-server condition met
helmrelease.helm.toolkit.fluxcd.io/minio condition met
```

To upgrade Flux or change any of the addons, rerun `cue install`.

At install time, Flux is configured to reconcile the cluster with the
content of the `flux` bucket hosted by Minio.

```shell
flux get source bucket flux-system
flux get kustomization flux-system
```

### Connect to Minio

Install the Minio client CLI with `brew install minio-mc`.
The start port forwarding to the Minio instance and create an alias for it:

```shell
kubectl -n flux-system port-forward svc/minio 9000:9000  &
mc alias set minio http://localhost:9000 flux toolkit.fluxcd.io --api S3v4
```

You can generate Kubernetes YAMLs with the CUE generators,
then you can sync the local `out` dir to the cluster with:

```shell
mc mirror --watch ./out/ minio/flux
```

Flux monitors the bucket and reconciles the changes on the cluster.
