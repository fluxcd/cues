# Flux bootstrap

### Define clusters

The cluster abstraction is intended to help cluster admins install and upgrade Flux in a declarative manner.

In the `clusters.cue` you define the Kubernetes clusters that are subject to bootstrap:

```cue
staging: cluster.#Bootstrap & {
	name: "staging"
	git: {
		// This repository must exists.
		url: "https://github.com/org/kube-fleet.git"
		// This branch will be created if it doesn't exists.
		branch: "main"
		path:  "./clusters/\(name)"
	}
	kubeconfig: context: "kind-\(name)"
	flux: {
		namespace:  "flux-system"
		version:    "v0.28.5"
		components: cluster.Components.All
	}
}
```

In the `secrets.clusters.cue` you store the Git token with write access to the repository:

```cue
staging: token: "flux-stg-token"
```

The PAT is persisted in-cluster as a secret in the flux namespace.

### Bootstrap clusters

To bootstrap one of the defined clusters, run the `bootstrap` command:

```shell
cue -t cluster=staging \
  bootstrap ./generators/clusters/
```

The above command runs `flux bootstrap git` with args takes from the staging definition.

To list all the defined clusters, run the `ls` command:

```console
$ cue ls ./generators/clusters/
CLUSTER     REPOSITORY                              PATH
staging     https://github.com/org/kube-fleet.git   ./clusters/staging
production  https://github.com/org/kube-fleet.git   ./clusters/production
```
