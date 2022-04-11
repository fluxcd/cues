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
		// This PAT must have push access to the repository.
		// The PAT is persisted in-cluster as a secret in the flux namespace.
		token: secrets.gitToken
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

### Bootstrap clusters

To bootstrap one of the defined clusters, run the `bootstrap` command:

```shell
export GITHUB_TOKEN=flux-personal-access-token

cue -t cluster=staging \
  -t gitToken=${GITHUB_TOKEN} \
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
