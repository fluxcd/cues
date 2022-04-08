@if(staging)
package releases

// Releases included in this cluster.
releases: [podinfo]

podinfo: #Podinfo & {
	spec: {
		chart: version: "6.1.x"
		// These values are stored in an immutable ConfigMap.
		values: {
			hpa: enabled: false
			resources: {
				limits: memory:   "256Mi"
				requests: memory: "32Mi"
			}
		}
		// These values are stored in an immutable Secret encrypted with SOPS.
		if secrets.redisPassword != "" {
			secretValues: {
				redis: {
					password: secrets.redisPassword
				}
			}
		}
	}
}

releases: [podinfo]
