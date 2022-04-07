@if(production)
package releases

podinfo: #Podinfo & {
	spec: {
		chart: version: "6.0.x"
		// These values are stored in an immutable ConfigMap.
		values: {
			hpa: {
				enabled:     true
				maxReplicas: 10
				cpu:         99
			}
			resources: {
				limits: memory: "512Mi"
				requests: {
					cpu:    "100m"
					memory: "32Mi"
				}
			}
		}
		// These values are stored in an immutable Secret encrypted with SOPS.
		secretValues: {
			redis: {
				password: secrets.redisPassword
			}
		}
	}
}

releases: [podinfo]
