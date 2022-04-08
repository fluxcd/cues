package tenant

#TenantSpec: {
	name:      string & =~"^[a-z0-9]([a-z0-9\\-]){0,61}[a-z0-9]$"
	namespace: string & =~"^[a-z0-9]([a-z0-9\\-]){0,61}[a-z0-9]$"
	role:      *"namespace-admin" | "cluster-admin" | string
	labels: "tenant.toolkit.fluxcd.io/name":      *name | string
	annotations: "tenant.toolkit.fluxcd.io/role": *role | string
	git: {
		token:          *"" | string
		implementation: *"go-git" | "libgit2"
		url:            string & =~"^http|ssh"
		branch:         string
		path:           *"./" | string
		interval:       *1 | int
	}
	slack: {
		token:   *"" | string
		channel: *"general" | string
		cluster: *"" | string
	}
}

#Tenant: {
	spec: #TenantSpec

	resources: {
		"\(spec.name)-namespace":      #Namespace & {_spec:      spec}
		"\(spec.name)-serviceaccount": #ServiceAccount & {_spec: spec}
		"\(spec.name)-gitrepository":  #GitRepository & {_spec:  spec}
		"\(spec.name)-kustomization":  #Kustomization & {_spec:  spec}
	}

	if spec.role == "namespace-admin" {
		resources: "\(spec.name)-rolebinding": #RoleBinding & {_spec: spec}
	}

	if spec.role == "cluster-admin" {
		resources: "\(spec.name)-clusterrolebinding": #ClusterRoleBinding & {_spec: spec}
	}

	if spec.git.token != "" {
		resources: "\(spec.name)-gitsecret": #GitSecret & {_spec: spec}
	}

	if spec.slack.token != "" {
		resources: {
			"\(spec.name)-slacksecret":   #SlackSecret & {_spec:   spec}
			"\(spec.name)-slackprovider": #SlackProvider & {_spec: spec}
			"\(spec.name)-slackalert":    #SlackAlert & {_spec:    spec}
		}
	}
}
