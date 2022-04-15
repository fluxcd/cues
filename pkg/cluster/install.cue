package cluster

import (
	"github.com/fluxcd/cues/pkg/release"
	kubernetes "k8s.io/apimachinery/pkg/runtime"
)

#Install: {
	name: string & =~"^[a-z0-9]([a-z0-9\\-]){0,61}[a-z0-9]$"
	kubeconfig: {
		context: *"" | string
		path:    *"" | string
	}
	flux: {
		namespace:  *"flux-system" | string & =~"^[a-z0-9]([a-z0-9\\-]){0,61}[a-z0-9]$"
		version?:   string & =~"^v(0|[1-9]\\d*)\\.(0|[1-9]\\d*)\\.(0|[1-9]\\d*)"
		components: *Components.Default | [...string]
	}
	addons: [...release.#Release]
	addonsConfig: [...kubernetes.#Object]
}
