package cluster

#Bootstrap: {
	name: string & =~"^[a-z0-9]([a-z0-9\\-]){0,61}[a-z0-9]$"
	git: {
		token:  *"" | string & =~".{1,}"
		url:    string & =~"^http"
		branch: string & =~".{1,}"
		path:   *"./clusters/\(name)" | string
	}
	kubeconfig: {
		context: *"" | string
		path:    *"" | string
	}
	flux: {
		namespace:  *"flux-system" | string & =~"^[a-z0-9]([a-z0-9\\-]){0,61}[a-z0-9]$"
		version?:   string & =~"^v(0|[1-9]\\d*)\\.(0|[1-9]\\d*)\\.(0|[1-9]\\d*)"
		components: *Components.Default | [...string]
	}
}

Components: {
	Required: [
		"source-controller",
		"kustomize-controller",
	]
	Default: [
		for c in Required {c},
		"helm-controller",
		"notification-controller",
	]
	All: [
		for c in Default {c},
		"image-reflector-controller",
		"image-automation-controller",
	]
}
