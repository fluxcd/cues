@if(staging)
package releases

// Releases included in this cluster.
releases: [podinfo]

podinfo: #Podinfo & {
	spec: {
		chart: version: "6.1.x"
		values: {
			hpa: enabled: false
			resources: {
				limits: memory:   "256Mi"
				requests: memory: "32Mi"
			}
		}
	}
}
