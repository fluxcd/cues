# cues

[![build](https://github.com/fluxcd/cues/workflows/build/badge.svg)](https://github.com/fluxcd/cues/actions)
[![license](https://img.shields.io/github/license/fluxcd/cues.svg)](https://github.com/fluxcd/cues/blob/main/LICENSE)
[![release](https://img.shields.io/github/v/tag/fluxcd/cues?include_prereleases&label=release)](https://github.com/fluxcd/cues/tags)

A collection of [CUE](https://cuelang.org) packages and tools for generating [Flux](https://fluxcd.io) configurations.

## Project

This project is for Flux users who want to reduce the Kubernetes boilerplate when configuring delivery pipelines across
environments. Instead of working with Kubernetes YAML, you will build abstractions with CUE, encode good
practices and validation to simplify complex tasks such as creating a new environment, onboard teams, drive workload
promotion and ultimately reduce toil.

> Note that this project is in the experimental phase, the CUE APIs may change in a breaking manner.

### Prerequisites

To run `cue` commands, you'll need the following tools:

- Go >= 1.17.0
- CUE >= 0.4.3
- SOPS >= 3.7.0
- Flux >= 0.28.0

On macOS or Linux you can install the prerequisites with Homebrew:

```shell
brew install go cue sops fluxcd/tap/flux
```

### Secrets management

Secrets such as access tokens, SSH keys, certs, etc are stored in plain text in CUE files
that follow the `<name>.secrets.cue` naming convention.

To safely store these secrets in Git, you'll be using [Mozilla SOPS](https://github.com/mozilla/sops)
with Age keys or cloud KMS.

Each user with access to this repo, would have its own [Age](https://github.com/FiloSottile/age)
private key in env and all the other users public keys:

```shell
export SOPS_AGE_KEY=USER1-SECRET-KEY
export SOPS_AGE_RECIPIENTS=USER1-PUB-KEY,USER2-PUB-KEY
```

Before committing changes to Git, you can encrypt all `*.secrets.cue` files with:

```shell
cue seal .
```

After pulling changes from Git, you can decrypt the secrets locally with:

```shell
cue unseal .
```

## Abstractions

### Cluster

The [cluster](pkg/cluster) CUE package is an abstraction for making `flux install` and `flux bootstrap` declarative.

#### Install tool

Example definition:

```cue
local: cluster.#Install & {
	name: "kind"
	kubeconfig: context: "kind-\(name)"
	flux: {
		namespace:  "flux-system"
		version:    "v0.28.5"
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

To get started with the `cue install` tool please see this [guide](tools/install).

#### Bootstrap tool

Example definition:

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

To get started with the `cue bootstrap` tool please see this [guide](tools/bootstrap).

### Tenant

The [tenant](pkg/tenant) CUE package is an abstraction built on top of Kubernetes RBAC and Flux account impersonation
with the goal of simplifying the onboard procedure of teams and their workloads onto Kubernetes clusters.

Example definition:

```cue
awesomeTeam: tenant.#Tenant & {
	spec: {
		name:      "awesome-team"
		namespace: "awesome-apps"
		role:      "namespace-admin"
		git: {
			token:  secrets.gitToken
			url:    "https://github.com/org/kube-awesome-team"
			branch: "main"
			path:   "./deploy/releases"
		}
		slack: {
			token:   secrets.slackToken
			channel: "awesome-alerts"
			cluster: "prod-eu-central-1"
		}
	}
}
```

The [tenants generator](generators/tenants) can be used by platform admins to generate the Kubernetes YAML
manifests needed by Flux for tenants onboarding, such as: namespaces, service accounts, role bindings, secrets,
Flux Git repositories, kustomizations, notification providers and alerts.

To get started with the tenants generator please see this [guide](generators/tenants/README.md).

### Release

The [release](pkg/tenant) CUE package is an abstraction built on top of Helm and Flux
with the goal of simplifying the delivery of applications across environments.

Example definition:

```cue
awesomeApp: release.#Release & {
	spec: {
		name:      "awesome-app"
		namespace: "apps"
		repository: {
			url:      "https://org.github.io/charts"
			user:     secrets.helmUser
			password: secrets.helmPassword
		}
		chart: {
			name: "app"
			version: "1.2.x"
		}
		// These values are stored in an immutable ConfigMap.
		values: {
			hpa: maxReplicas: 10
			resources: {
				limits: memory: "512Mi"
				requests: memory: "32Mi"
			}
		}
		// These values are stored in an immutable Secret encrypted with SOPS.
		secretValues: {
			redis: password: secrets.redisPassword
		}
	}
}
```

The [releases generator](generators/releases) can be used by various teams to generate the Kubernetes YAML
manifests needed by Flux for installing and upgrading Helm releases.
