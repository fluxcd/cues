package install

import (
	corev1 "k8s.io/api/core/v1"
	sourcev1 "github.com/fluxcd/source-controller/api/v1beta2"
	ksv1 "github.com/fluxcd/kustomize-controller/api/v1beta2"

	"github.com/fluxcd/cues/pkg/release"
)

// This configuration deploys a tiny Minio instance in flux-system namespace,
// and creates a bucket for Flux to sync its content in the cluster.

// To push YAML manifests to the bucket:
// $ kubectl -n flux-system port-forward svc/minio 9000:9000
// $ mc alias set minio http://localhost:9000 flux toolkit.fluxcd.io --api S3v4
// $ mc mirror ./out/ minio/flux

// To sync the manifests from the bucket:
// $ flux reconcile ks flux-system --with-source

minio: {
	metadata: {
		name:      "flux-system"
		namespace: "flux-system"
	}
	bucket: "flux"
}

#Minio: release.#Release & {
	spec: {
		name:      "minio"
		namespace: minio.metadata.namespace
		repository: {
			url: "https://charts.min.io/"
		}
		chart: {
			name: "\(spec.name)"
		}
		values: {
			mode: "standalone"
			persistence: enable: false
			resources: requests: memory:     "32Mi"
			makeBucketJob: requests: memory: "12Mi"
			buckets: [{
				name:       minio.bucket
				policy:     "upload"
				versioning: false
			}]
		}
		secretValues: {
			rootUser:     minio.accesskey
			rootPassword: minio.secretkey
		}
	}
	resources: {
		"flux-bucket":        #MinioBucket & {}
		"flux-bucket-secret": #MinioSecret & {}
		"flux-kustomization": #MinioKustomization & {}
	}
}

#MinioBucket: sourcev1.#Bucket & {
	apiVersion: "source.toolkit.fluxcd.io/v1beta2"
	kind:       "Bucket"
	metadata:   minio.metadata
	spec: {
		interval: "10s"
		endpoint: "minio.\(minio.metadata.namespace).svc.cluster.local.:9000"
		insecure: true
		secretRef: name: minio.metadata.name
		bucketName: minio.bucket
	}
}

#MinioSecret: corev1.#Secret & {
	apiVersion: "v1"
	kind:       "Secret"
	metadata:   minio.metadata
	stringData: {
		accesskey: minio.accesskey
		secretkey: minio.secretkey
	}
}

#MinioKustomization: ksv1.#Kustomization & {
	apiVersion: "kustomize.toolkit.fluxcd.io/v1beta2"
	kind:       "Kustomization"
	metadata:   minio.metadata
	spec: {
		serviceAccountName: "kustomize-controller"
		sourceRef: {
			kind: "Bucket"
			name: "flux-system"
		}
		path:     "./"
		prune:    true
		wait:     true
		timeout:  "1m"
		interval: "60m"
	}
}
