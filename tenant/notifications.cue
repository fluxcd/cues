package tenant

import (
	corev1 "k8s.io/api/core/v1"
	fluxv1 "github.com/fluxcd/notification-controller/api/v1beta1"
)

#SlackAlert: fluxv1.#Alert & {
	_spec:      #TenantSpec
	apiVersion: "notification.toolkit.fluxcd.io/v1beta1"
	kind:       "Alert"
	metadata: {
		name:        "slack-\(_spec.name)"
		namespace:   _spec.namespace
		labels:      _spec.labels
		annotations: _spec.annotations
	}
	spec: {

		eventSeverity: "info"
		providerRef: name: "slack-\(_spec.name)"
		eventSources: [
			{
				kind: "GitRepository"
				name: "*"
			},
			{
				kind: "Kustomization"
				name: "*"
			},
			{
				kind: "HelmRelease"
				name: "*"
			},
		]
		if _spec.slack.cluster != "" {
			summary: "cluster \(_spec.slack.cluster)"
		}
	}
}

#SlackProvider: fluxv1.#Provider & {
	_spec:      #TenantSpec
	apiVersion: "notification.toolkit.fluxcd.io/v1beta1"
	kind:       "Provider"
	metadata: {
		name:        "slack-\(_spec.name)"
		namespace:   _spec.namespace
		labels:      _spec.labels
		annotations: _spec.annotations
	}
	spec: {
		type:    "slack"
		channel: _spec.slack.channel
		secretRef: name: "slack-\(_spec.name)"
	}
}

#SlackSecret: corev1.#Secret & {
	_spec:      #TenantSpec
	apiVersion: "v1"
	kind:       "Secret"
	metadata: {
		name:        "slack-\(_spec.name)"
		namespace:   _spec.namespace
		labels:      _spec.labels
		annotations: _spec.annotations
	}
	stringData: {
		address: "https://slack.com/api/chat.postMessage"
		token:   _spec.slack.token
	}
}
