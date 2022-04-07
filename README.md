# cues

[![build](https://github.com/fluxcd/cues/workflows/build/badge.svg)](https://github.com/fluxcd/cues/actions)
[![license](https://img.shields.io/github/license/fluxcd/cues.svg)](https://github.com/fluxcd/cues/blob/main/LICENSE)

A collection of [CUE](https://cuelang.org) packages and tools for generating [Flux](https://fluxcd.io) configurations.

This project is for Flux users who want to reduce the Kubernetes boilerplate when configuring delivery pipelines across
environments and teams. Instead of working with Kubernetes YAML, you will build abstractions with CUE, encode good
practices and validation to simply complex tasks such as creating a new environment, onboard teams, drive workload
promotion and ultimately reduce toil.

## Project structure

- In [fluxcd/cues/pkg](pkg) are CUE packages that offer a high-level abstraction layer on top of Kubernetes and Flux APIs.
- In [fluxcd/cues/generators](generators) are CUE tools for generating, validating and encrypting Kubernetes manifests.

To use the CUE generators, you'll need the following tools installed on your dev machine:

- Git >= 2.34.0
- Go >= 1.17.0
- CUE >= 0.4.3
- SOPS >= 3.7.0
- Flux >= 0.28.0

On macOS or Linux you can install the prerequisites with Homebrew:

```shell
brew install git go cue sops fluxcd/tap/flux
```

## Abstractions

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

### Releases

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
			hpa: {
				enabled:     true
				maxReplicas: 10
				cpu:         99
			}
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
