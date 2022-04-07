package release

import (
	corev1 "k8s.io/api/core/v1"
	fluxv1 "github.com/fluxcd/source-controller/api/v1beta2"
)

#HelmRepository: fluxv1.#HelmRepository & {
	_spec:      #ReleaseSpec
	apiVersion: "source.toolkit.fluxcd.io/v1beta2"
	kind:       "HelmRepository"
	metadata: {
		name:        _spec.name
		namespace:   _spec.namespace
		labels:      _spec.labels
		annotations: _spec.annotations
	}
	spec: {
		interval: "\(_spec.interval)m"
		url:      _spec.repository.url
		if _spec.repository.password != "" {
			secretRef: name: "\(_spec.name)-helm"
		}
		timeout: "2m"
	}
}

#HelmSecret: corev1.#Secret & {
	_spec:      #ReleaseSpec
	apiVersion: "v1"
	kind:       "Secret"
	metadata: {
		name:        "\(_spec.name)-helm"
		namespace:   _spec.namespace
		labels:      _spec.labels
		annotations: _spec.annotations
	}
	stringData: {
		user:     _spec.repository.user
		password: _spec.repository.password
	}
}
