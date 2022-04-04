package tenant

import (
	corev1 "k8s.io/api/core/v1"
	fluxv1 "github.com/fluxcd/source-controller/api/v1beta2"
)

#GitRepository: fluxv1.#GitRepository & {
	_spec:      #TenantSpec
	apiVersion: "source.toolkit.fluxcd.io/v1beta2"
	kind:       "GitRepository"
	metadata: {
		name:        _spec.name
		namespace:   _spec.namespace
		labels:      _spec.labels
		annotations: _spec.annotations
	}
	spec: {
		interval: "\(_spec.git.interval)m"
		url:      _spec.git.url
		ref: branch: _spec.git.branch
		if _spec.git.token != "" {
			secretRef: name: "git-\(_spec.name)"
		}
		timeout: "2m"
	}
}

#GitSecret: corev1.#Secret & {
	_spec:      #TenantSpec
	apiVersion: "v1"
	kind:       "Secret"
	metadata: {
		name:        "git-\(_spec.name)"
		namespace:   _spec.namespace
		labels:      _spec.labels
		annotations: _spec.annotations
	}
	stringData: {
		user:     "git"
		password: _spec.git.token
	}
}
