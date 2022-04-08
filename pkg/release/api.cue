package release

#ReleaseSpec: {
	name:      string & =~"^[a-z0-9]([a-z0-9\\-]){0,61}[a-z0-9]$"
	namespace: string & =~"^[a-z0-9]([a-z0-9\\-]){0,61}[a-z0-9]$"
	labels: "release.toolkit.fluxcd.io/name":         *name | string
	annotations: "release.toolkit.fluxcd.io/version": *chart.version | string
	serviceAccountName?: string & =~"^[a-z0-9]([a-z0-9\\-]){0,61}[a-z0-9]$"
	interval:            *10 | int
	repository: {
		url:      string & =~"^[http|oci]"
		user:     *"" | string
		password: *"" | string
	}
	chart: {
		name:    string
		version: string
	}
	values:       *null | {...}
	secretValues: *null | {...}
}

#Release: {
	spec: #ReleaseSpec
	valuesFrom: [ string]: string

	if spec.values != null {
		let rv = #ReleaseValues & {_spec: spec}
		resources: "\(spec.name)-values": rv
		valuesFrom: "\(rv.kind)":         rv.metadata.name
	}

	if spec.secretValues != null {
		let rs = #ReleaseSecretValues & {_spec: spec}
		resources: "\(spec.name)-secrets": rs
		valuesFrom: "\(rs.kind)":          rs.metadata.name
	}

	resources: {
		"\(spec.name)-repository": #HelmRepository & {_spec: spec}
		"\(spec.name)-release":    #HelmRelease & {_spec:    spec, _valuesFrom: valuesFrom}
	}

	if spec.repository.password != "" {
		resources: "\(spec.name)-reposecret": #HelmSecret & {_spec: spec}
	}
}
