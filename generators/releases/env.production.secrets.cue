@if(production)
package releases

podinfo: spec: {
	repository: {
		user:     "helm-user1"
		password: "helm-pass1"
	}
	secretValues: password: "redis=prod-pass1"
}
