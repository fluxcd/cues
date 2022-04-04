package tenant

import (
	corev1 "k8s.io/api/core/v1"
)

#ServiceAccount: corev1.#ServiceAccount & {
	_spec:      #TenantSpec
	apiVersion: "v1"
	kind:       "ServiceAccount"
	metadata: {
		name:        "flux-\(_spec.name)"
		namespace:   _spec.namespace
		labels:      _spec.labels
		annotations: _spec.annotations
	}
}
