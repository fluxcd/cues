package releases

import (
	"github.com/fluxcd/cues/pkg/release"
)

// Environment defines the destination cluster.
env: *"" | string @tag(env,short=staging|production)

// Releases holds the list of releases per env.
releases: [...release.#Release]

// Podinfo base definition.
#Podinfo: release.#Release & {
	spec: {
		name:      "podinfo"
		namespace: "dev-apps"
		repository: {
			url: "https://stefanprodan.github.io/podinfo"
		}
		chart: {
			name: "podinfo"
		}
	}
}
