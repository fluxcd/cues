# cues

[![build](https://github.com/fluxcd/cues/workflows/build/badge.svg)](https://github.com/fluxcd/cues/actions)
[![license](https://img.shields.io/github/license/fluxcd/cues.svg)](https://github.com/fluxcd/cues/blob/main/LICENSE)

A collection of [CUE](https://cuelang.org) packages for generating [Flux](https://fluxcd.io) configurations.

## Get started

### Install prerequisites

To use the CUE generators for Flux, you'll need the following tools installed on your dev machine:

- Git >= 2.34.0
- Go >= 1.17.0
- CUE >= 0.4.3
- SOPS >= 3.7.0
- Flux >= 0.28.0

On macOS or Linux you can install the prerequisites with Homebrew:

```shell
brew install git go cue sops fluxcd/tap/flux
```

### Clone the cues repo

Clone the [fluxcd/cues](https://github.com/fluxcd/cues) repository locally:

```shell
mkdir -p ~/go/src/github.com/fluxcd
cd ~/go/src/github.com/fluxcd
git clone https://github.com/fluxcd/cues.git
cd cues
```

### Run the tenants examples

The tenant generator is intended to help cluster admins to onboard tenants, it's an alternative to the 
procedure described in [fluxcd/flux2-multi-tenancy](https://github.com/fluxcd/flux2-multi-tenancy#onboard-new-tenants).

In the `generators/tenants/tenants.cue` file you can find an example of how to define Flux tenants:

```cue
#DevTeam: tenant.#Tenant & {
	spec: {
		name:      "dev-team"
		namespace: "dev-apps"
		role:      "namespace-admin"
		git: {
			token:    secrets.gitToken
			url:      "https://github.com/org/kube-dev-team"
			branch:   "main"
			interval: 2
		}
		slack: token: secrets.slackToken
	}
}
```

In the `generators/tenants/tenants.staging.cue` file you can find an example of how to set the cluster name for altering
and the path that's being reconciled by Flux on the staging cluster:

```cue
devTeam: #DevTeam & {
	spec: {
		git: path: "./deploy/staging"
		slack: {
			channel: "dev-alerts"
			cluster: _cluster.name
		}
	}
}
```

To generate the Kubernetes manifests for on disk, run the `build` command:

```shell
export GITHUB_TOKEN=my-gh-personal-access-token
export SLACK_TOKEN=my-slack-bot-token

cue -t staging \
  -t out=./out \
  -t gitToken=${GITHUB_TOKEN} \
  -t slackToken=${SLACK_TOKEN} \
  build ./generators/tenants/
```

The above command generates the following structure:

```text
./out/
├── dev-team
│   ├── resources.yaml
│   └── secrets.yaml
└── ops-team
    ├── resources.yaml
    └── secrets.yaml
```

To list all the Kubernetes objects, run the `ls` command:

```console
$ cue -t staging -t out=./out -t gitToken=${GITHUB_TOKEN} -t slackToken=${SLACK_TOKEN} ls ./generators/tenants/
TENANT    RESOURCE                                API VERSION
dev-team  Namespace/dev-apps                      v1
dev-team  ServiceAccount/dev-apps/flux-dev-team   v1
dev-team  RoleBinding/dev-apps/flux-dev-team      rbac.authorization.k8s.io/v1
dev-team  GitRepository/dev-apps/dev-team         source.toolkit.fluxcd.io/v1beta2
dev-team  Kustomization/dev-apps/dev-team         kustomize.toolkit.fluxcd.io/v1beta2
dev-team  Secret/dev-apps/git-dev-team            v1
dev-team  Secret/dev-apps/slack-dev-team          v1
dev-team  Provider/dev-apps/slack-dev-team        notification.toolkit.fluxcd.io/v1beta1
dev-team  Alert/dev-apps/slack-dev-team           notification.toolkit.fluxcd.io/v1beta1
ops-team  Namespace/ops-apps                      v1
ops-team  ServiceAccount/ops-apps/flux-ops-team   v1
ops-team  RoleBinding/ops-apps/flux-ops-team      rbac.authorization.k8s.io/v1
ops-team  GitRepository/ops-apps/ops-team         source.toolkit.fluxcd.io/v1beta2
ops-team  Kustomization/ops-apps/ops-team         kustomize.toolkit.fluxcd.io/v1beta2
ops-team  ClusterRoleBinding/flux-ops-team        rbac.authorization.k8s.io/v1
ops-team  Secret/ops-apps/slack-ops-team          v1
ops-team  Provider/ops-apps/slack-ops-team        notification.toolkit.fluxcd.io/v1beta1
ops-team  Alert/ops-apps/slack-ops-team           notification.toolkit.fluxcd.io/v1beta1
```

To encrypt the Kubernetes secrets on disk using SOPS, run the `build` command with `-t encrypt=sops`:

```shell
export SOPS_AGE_RECIPIENTS=age10uk5fkvfld6v3ep53me5npz6zz9fqwfs2l8dvv5m29pmalnaefsssslkw4

cue -t staging \
  -t out=./out \
  -t gitToken=${GITHUB_TOKEN} \
  -t slackToken=${SLACK_TOKEN} \
  build ./generators/tenants/
```
