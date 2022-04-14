# Flux install

### Define clusters

The cluster abstraction is intended to help cluster admins install and upgrade Flux in a declarative manner.

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
		#CertManager & {
			spec: chart: version: "v1.8.x"
		},
		#Kyverno & {
			spec: chart: version: "v2.3.x"
		},
		#MetricsServer & {
			spec: chart: version: "v3.8.x"
		},
	]
}
```

### Define addons

In the `addons.cue` you define cluster addons that are managed by Flux:

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
		#MetricsServer & {
			spec: chart: version: "v3.8.x" //<- upgrade to the latest patch release
		},
	]
}
```

### Install/Upgrade

Create a local cluster with Kubernetes kind:

```shell
kind create cluster
```

To install Flux and the addons, run the `install` command:

```console
$ cue -t cluster=kind install ./tools/install/
► installing components in flux-system namespace
✔ install finished
► waiting for 3 addon(s) to become ready
helmrelease.helm.toolkit.fluxcd.io/cert-manager condition met
helmrelease.helm.toolkit.fluxcd.io/kyverno condition met
helmrelease.helm.toolkit.fluxcd.io/metrics-server condition met
```

The above command runs `flux bootstrap git` with args takes from the staging definition.

To list all the defined clusters, run the `ls` command:

```console
$ cue ls ./tools/install/
CLUSTER  CONTEXT                                      ADDONS
kind     kind-kind                                    3
eks      demo@fluxcd.io@test.eu-central-1.eksctl.io   3
gke      gke_demo_europe-west4-a_test                 2
```
