@if(production)
package tenants

_cluster: {
	name:    "prod-eu-central-1"
	channel: "prod-alerts"
}

devTeam: #DevTeam & {
	spec: {
		git: path: "./deploy/release"
		slack: {
			channel: _cluster.channel
			cluster: _cluster.name
		}
	}
}

opsTeam: #OpsTeam & {
	spec: {
		git: path: "./clusters/\(_cluster.name)"
		slack: {
			channel: _cluster.channel
			cluster: _cluster.name
		}
	}
}

// Add all tenants to the list
tenants: [devTeam, opsTeam]
