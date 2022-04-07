@if(staging)
package releases

podinfo: #Podinfo & {
	spec: {
		chart: version: "6.1.x"
		// these values are stored in a ConfigMap
		values: {
			hpa: enabled: false
			resources: {
				limits: memory:   "256Mi"
				requests: memory: "32Mi"
			}
		}
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
