package tenant

import (
	corev1 "k8s.io/api/core/v1"
)

#Namespace: corev1.#Namespace & {
	_spec:      #TenantSpec
	apiVersion: "v1"
	kind:       "Namespace"
	metadata: {
		name:        _spec.namespace
		labels:      _spec.labels
		annotations: _spec.annotations
	}
}
