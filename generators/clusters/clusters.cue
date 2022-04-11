package clusters

import (
	"github.com/fluxcd/cues/pkg/cluster"
)

// Secrets can be set at build time from env vars or files:
// '-t gitToken=${GITHUB_TOKEN}'
// '-t gitToken=$(cat ./git.token)'
secrets: {
	gitToken: *"" | string @tag(gitToken)
}

// Clusters holds the list of clusters to be bootstraped.
clusters: [...cluster.#Bootstrap]
clusters: [staging, production]

staging: cluster.#Bootstrap & {
	name: "staging"
	git: {
		// This repository must exists.
		url: "https://github.com/stefanprodan/local-fleet.git"
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

production: cluster.#Bootstrap & {
	name: "production"
	git: {
		token:  secrets.gitToken
		url:    "https://github.com/org/kube-fleet.git"
		branch: "main"
	}
	kubeconfig: context: "kind-\(name)"
	flux: version:       "v0.29.0"
}
