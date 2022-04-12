@if(production)
package tenants

devTeam: spec: {
	git: token:   "prod-dev-git-token1"
	slack: token: "prod-dev-slack-token1"
}

opsTeam: spec: {
	git: token:   "prod-ops-git-token2"
	slack: token: "prod-ops-slack-token2"
}
