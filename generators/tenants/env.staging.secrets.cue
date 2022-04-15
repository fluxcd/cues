@if(staging)
package tenants

devTeam: spec: {
	git: token:   "stg-dev-git-token1"
	slack: token: "stg-dev-slack-token1"
}

opsTeam: spec: {
	git: token:   "stg-ops-git-token2"
	slack: token: "stg-ops-slack-token2"
}
