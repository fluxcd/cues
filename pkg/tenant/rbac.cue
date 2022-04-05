package tenant

import (
	rbacv1 "k8s.io/api/rbac/v1"
)

#RoleBinding: rbacv1.#RoleBinding & {
	_spec:      #TenantSpec
	apiVersion: "rbac.authorization.k8s.io/v1"
	kind:       "RoleBinding"
	metadata: {
		name:        "flux-\(_spec.name)"
		namespace:   _spec.namespace
		labels:      _spec.labels
		annotations: _spec.annotations
	}
	roleRef: {
		apiGroup: "rbac.authorization.k8s.io"
		kind:     "ClusterRole"
		name:     "cluster-admin"
	}
	subjects: [
		{
			kind:      "ServiceAccount"
			name:      "flux-\(_spec.name)"
			namespace: _spec.namespace
		},
	]
}

#ClusterRoleBinding: rbacv1.#ClusterRoleBinding & {
	_spec:      #TenantSpec
	apiVersion: "rbac.authorization.k8s.io/v1"
	kind:       "ClusterRoleBinding"
	metadata: {
		name:        "flux-\(_spec.name)"
		labels:      _spec.labels
		annotations: _spec.annotations
	}
	roleRef: {
		apiGroup: "rbac.authorization.k8s.io"
		kind:     "ClusterRole"
		name:     "cluster-admin"
	}
	subjects: [
		{
			kind:      "ServiceAccount"
			name:      _spec.name
			namespace: _spec.namespace
		},
	]
}
