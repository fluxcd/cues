package install

import (
	"github.com/fluxcd/cues/pkg/cluster"
)

// Clusters holds the list of clusters where Flux should be installed.
clusters: [...cluster.#Install]
clusters: [local, aws, gcp]

local: cluster.#Install & {
	name: "kind"
	kubeconfig: context: "kind-\(name)"
	flux: {
		namespace:  "flux-system"
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

aws: cluster.#Install & {
	name: "eks"
	kubeconfig: context: "demo@fluxcd.io@test.eu-central-1.eksctl.io"
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

gcp: cluster.#Install & {
	name: "gke"
	kubeconfig: context: "gke_demo_europe-west4-a_test"
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
	]
}
