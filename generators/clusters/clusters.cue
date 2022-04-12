package clusters

import (
	"github.com/fluxcd/cues/pkg/cluster"
)

// Clusters holds the list of clusters to be bootstraped.
clusters: [...cluster.#Bootstrap]
clusters: [staging, production]

staging: cluster.#Bootstrap & {
	name: "staging"
	git: {
		// This repository must exists.
		url: "https://github.com/org/kube-fleet.git"
		// This branch will be created if it doesn't exists.
		branch: "main"
		path:   "./clusters/\(name)"
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
		url:    "https://github.com/org/kube-fleet.git"
		branch: "main"
	}
	kubeconfig: context: "kind-\(name)"
	flux: version:       "v0.29.0"
}
