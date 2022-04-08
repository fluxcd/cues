package releases

import (
	"github.com/fluxcd/cues/pkg/release"
)

// Environment defines the destination cluster
env: *"" | string @tag(env,short=staging|production)

// Secrets can be set at runtime from env vars or files
secrets: {
	helmUser:      *"" | string @tag(helmUser)
	helmPassword:  *"" | string @tag(helmPassword)
	redisPassword: *"" | string @tag(redisPassword)
}

// Releases holds the list of releases per env
releases: [...release.#Release]

// Podinfo base definition
#Podinfo: release.#Release & {
	spec: {
		name:      "podinfo"
		namespace: "dev-apps"
		repository: {
			url:      "https://stefanprodan.github.io/podinfo"
			user:     secrets.helmUser
			password: secrets.helmPassword
		}
		chart: {
			name: "podinfo"
		}
	}
}
