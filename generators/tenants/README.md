# Flux tenants generator

### Define tenants

The tenant abstraction is intended to help cluster admins define tenants with CUE. It is an alternative to the 
procedure described in [fluxcd/flux2-multi-tenancy](https://github.com/fluxcd/flux2-multi-tenancy#onboard-new-tenants).

In the `env.common.cue` you define a common base for your tenants:

```cue
#DevTeam: tenant.#Tenant & {
	spec: {
		name:      "dev-team"
		namespace: "dev-apps"
		role:      "namespace-admin"
		git: {
			url:      "https://github.com/org/kube-dev-team"
			branch:   "main"
			interval: 2
		}
		slack: token: secrets.slackToken
	}
}
```

In the `env.staging.cue` you add fields that are specific to the staging environment:

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

In the `secrets.staging.cue` you add credentials that are specific to the staging environment:

```cue
devTeam: spec: {
	git: token:   "stg-dev-git-token1"
	slack: token: "stg-dev-slack-token1"
}
```

### Generate tenants

To generate the Kubernetes manifests on disk, run the `build` command:

```shell
cue -t staging \
  -t out=./out/staging/tenants \
  build ./generators/tenants/
```

The above command generates the following structure:

```text
./out/
└── staging
    └── tenants
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

### Encrypt secrets in YAML output

For each tenant, the generated manifests can contain secrets such as Git and Slack credentials.
These secrets should be encrypted before you push the manifests to the branch synced by Flux.

To encrypt the Kubernetes secrets on disk using [SOPS](https://github.com/mozilla/sops),
run the `build` command with `-t encrypt=sops`:

```shell
export SOPS_AGE_RECIPIENTS=FLUX-PUBLIC-KEY

cue -t staging \
  -t out=./out/staging/tenants  \
  -t encrypt=sops \
  build ./generators/tenants/
```

### Publish manifests

The generated manifests can be pushed to the Git repository where you've run `flux bootstrap`.

if you're using SOPS, you must configure Flux to
[decrypt the secrets](https://fluxcd.io/flux/components/kustomize/kustomization/#secrets-decryption)
in the bootstrapped repository.
