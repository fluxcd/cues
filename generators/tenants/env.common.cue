package tenants

import (
	"github.com/fluxcd/cues/pkg/tenant"
)

// Environment defines the destination cluster
env: *"" | string @tag(env,short=staging|production)

// Secret tokens can be set at runtime from env vars or files
secrets: {
	gitToken:   *"" | string @tag(gitToken)
	slackToken: *"" | string @tag(slackToken)
}

// Tenants holds the list of tenants per env
tenants: [...tenant.#Tenant]

// Dev team base definition
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
	// Reconcile the dev team workloads only after the ops team has been provisioned.
	resources: "\(spec.name)-kustomization": spec: dependsOn: [
		{
			name:      #OpsTeam.spec.name
			namespace: #OpsTeam.spec.namespace
		},
	]
}

// Ops team base definition
#OpsTeam: tenant.#Tenant & {
	spec: {
		name:      "ops-team"
		namespace: "ops-apps"
		role:      "cluster-admin"
		git: {
			url:      "https://github.com/org/kube-ops-team"
			branch:   "main"
			interval: 5
		}
		slack: token: secrets.slackToken
	}
	// Wait for all workloads to be read.
	resources: "\(spec.name)-kustomization": spec: wait: true
}
