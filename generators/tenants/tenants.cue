package tenants

import (
	"github.com/fluxcd/cues/pkg/tenant"
)

// Secret tokens set at runtime from env vars or files
_secrets: {
	GITHUB_TOKEN: *"" | string @tag(gitToken)
	SLACK_TOKEN:  *"" | string @tag(slackToken)
}

// Dev team definition
devs: tenant.#Tenant & {
	spec: {
		name:      "dev-team"
		namespace: "dev-apps"
		role:      "namespace-admin"
		git: {
			token:    _secrets.GITHUB_TOKEN
			url:      "https://github.com/stefanprodan/podinfo"
			branch:   "master"
			path:     "kustomize"
			interval: 5
		}
		slack: {
			token:   _secrets.SLACK_TOKEN
			channel: "general"
			cluster: "dev-eu-central-1"
		}
	}
}

// Platform team definition
ops: tenant.#Tenant & {
	spec: {
		name:      "ops-team"
		namespace: "ops-apps"
		role:      "cluster-admin"
		git: {
			url:      "https://github.com/stefanprodan/podinfo"
			branch:   "master"
			path:     "kustomize"
			interval: 5
		}
		slack: {
			token:   _secrets.SLACK_TOKEN
			channel: "ops-alerts"
			cluster: "dev-eu-central-1"
		}
	}
}

// Add all tenants to the list
tenants: [...tenant.#Tenant]
tenants: [devs, ops]
