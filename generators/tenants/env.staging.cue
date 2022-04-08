@if(staging)
package tenants

_cluster: {
	name: "stg-eu-central-1"
}

// Tenants included in this cluster
tenants: [devTeam, opsTeam]

devTeam: #DevTeam & {
	spec: {
		git: path: "./deploy/staging"
		slack: {
			channel: "dev-alerts"
			cluster: _cluster.name
		}
	}
}

opsTeam: #OpsTeam & {
	spec: {
		git: path: "./clusters/\(_cluster.name)"
		slack: {
			channel: "infra-alerts"
			cluster: _cluster.name
		}
	}
}
