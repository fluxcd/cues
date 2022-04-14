package release

import (
	"strings"
	"uuid"
	"encoding/yaml"

	corev1 "k8s.io/api/core/v1"
	fluxv1 "github.com/fluxcd/helm-controller/api/v2beta1"
)

#HelmRelease: fluxv1.#HelmRelease & {
	_spec: #ReleaseSpec
	_valuesFrom: [ string]: string
	apiVersion: "helm.toolkit.fluxcd.io/v2beta1"
	kind:       "HelmRelease"
	metadata: {
		name:        _spec.name
		namespace:   _spec.namespace
		labels:      _spec.labels
		annotations: _spec.annotations
	}
	spec: {
		if _spec.serviceAccountName != _|_ {
			serviceAccountName: _spec.serviceAccountName
		}
		if _spec.targetNamespace != _|_ {
			install: createNamespace: true
			targetNamespace:  _spec.targetNamespace
			storageNamespace: _spec.targetNamespace
		}
		interval: "\(2*_spec.interval)m"
		chart: {
			spec: {
				chart:   _spec.chart.name
				version: _spec.chart.version
				sourceRef: {
					kind: "HelmRepository"
					name: _spec.name
				}
				interval: "\(_spec.interval)m"
			}
		}
		install: crds: "Create"
		upgrade: crds: "CreateReplace"
		valuesFrom: [
			for k, n in _valuesFrom {
				kind: k
				name: n
			},
		]
	}
}

#ReleaseValues: corev1.#ConfigMap & {
	_spec: #ReleaseSpec
	let _values_yaml = yaml.Marshal(_spec.values)
	let _values_sha = strings.Split(uuid.SHA1(uuid.ns.DNS, _values_yaml), "-")[0]
	apiVersion: "v1"
	kind:       "ConfigMap"
	metadata: {
		name:        "\(_spec.name)-\(_values_sha)"
		namespace:   _spec.namespace
		labels:      _spec.labels
		annotations: _spec.annotations
	}
	immutable: true
	data: {
		"values.yaml": _values_yaml
	}
}

#ReleaseSecretValues: corev1.#Secret & {
	_spec: #ReleaseSpec
	let _values_yaml = yaml.Marshal(_spec.secretValues)
	let _values_sha = strings.Split(uuid.SHA1(uuid.ns.DNS, _values_yaml), "-")[0]
	apiVersion: "v1"
	kind:       "Secret"
	metadata: {
		name:        "\(_spec.name)-\(_values_sha)"
		namespace:   _spec.namespace
		labels:      _spec.labels
		annotations: _spec.annotations
	}
	immutable: true
	stringData: {
		"values.yaml": _values_yaml
	}
}
