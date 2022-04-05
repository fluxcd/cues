package tenant

import (
	fluxv1 "github.com/fluxcd/kustomize-controller/api/v1beta2"
)

#Kustomization: fluxv1.#Kustomization & {
	_spec:      #TenantSpec
	apiVersion: "kustomize.toolkit.fluxcd.io/v1beta2"
	kind:       "Kustomization"
	metadata: {
		name:        _spec.name
		namespace:   _spec.namespace
		labels:      _spec.labels
		annotations: _spec.annotations
	}
	spec: {
		if _spec.role != "cluster-admin" {
			targetNamespace: _spec.namespace
		}
		serviceAccountName: "flux-\(_spec.name)"
		sourceRef: {
			kind: "GitRepository"
			name: _spec.name
		}
		path:     _spec.git.path
		prune:    true
		timeout:  "1m"
		interval: "10m"
	}
}
