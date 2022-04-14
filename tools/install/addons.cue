package install

import (
	"github.com/fluxcd/cues/pkg/release"
)

#CertManager: release.#Release & {
	spec: {
		name:            "cert-manager"
		namespace:       "flux-system"
		targetNamespace: "\(name)"
		repository: {
			url: "https://charts.jetstack.io"
		}
		chart: {
			name: "\(spec.name)"
		}
		values: {
			installCRDs: true
		}
	}
}

#Kyverno: release.#Release & {
	spec: {
		name:            "kyverno"
		namespace:       "flux-system"
		targetNamespace: "\(name)"
		repository: {
			url: "https://kyverno.github.io/kyverno"
		}
		chart: {
			name: "\(spec.name)"
		}
		values: {
			createSelfSignedCert: true
			installCRDs:          true
		}
	}
}

#MetricsServer: release.#Release & {
	spec: {
		name:            "metrics-server"
		namespace:       "flux-system"
		targetNamespace: "monitoring"
		repository: {
			url: "https://kubernetes-sigs.github.io/metrics-server/"
		}
		chart: {
			name: "\(spec.name)"
		}
		values: {
			apiService: create: true
			args: ["--kubelet-insecure-tls"]
		}
	}
}
