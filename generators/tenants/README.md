# Flux tenants generator

### Define tenants

The tenant abstraction is intended to help cluster admins define tenants with CUE. It is an alternative to the 
procedure described in [fluxcd/flux2-multi-tenancy](https://github.com/fluxcd/flux2-multi-tenancy#onboard-new-tenants).

In the `tenants.cue` file you can find an example of how to define Flux tenants:

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

In the `tenants.staging.cue` file you can find an example of how to set the cluster name
for distinguishing alerts based on environment, and how to set the path that's being reconciled by Flux:

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

### Generate tenants

To generate the Kubernetes manifests on disk, run the `build` command:

```shell
export GITHUB_TOKEN=my-gh-personal-access-token
export SLACK_TOKEN=my-slack-bot-token

cue -t staging \
  -t out=./out/staging \
  -t gitToken=${GITHUB_TOKEN} \
  -t slackToken=${SLACK_TOKEN} \
  build ./generators/tenants/
```

The above command generates the following structure:

```text
./out/
└── staging
    ├── dev-team
    │   ├── resources.yaml
    │   └── secrets.yaml
    └── ops-team
        ├── resources.yaml
        └── secrets.yaml
```

To list all the Kubernetes objects, run the `ls` command:

```console
$ cue -t staging -t gitToken=${GITHUB_TOKEN} -t slackToken=${SLACK_TOKEN} ls ./generators/tenants/
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
  -t out=./out/staging \
  -t gitToken=${GITHUB_TOKEN} \
  -t slackToken=${SLACK_TOKEN} \
  -t encrypt=sops \
  build ./generators/tenants/
```

The generated manifests can be pushed to the Git repository where you've run `flux bootstrap`
under the `clusters/staging` directory. Note that Flux must be configured to
[decrypt the secrets](https://fluxcd.io/docs/components/kustomize/kustomization/#secrets-decryption)
if you're using SOPS.
