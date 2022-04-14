package cluster

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
