// Code generated by cue get go. DO NOT EDIT.

//cue:generate cue get go github.com/fluxcd/source-controller/api/v1beta2

package v1beta2

import (
	"github.com/fluxcd/pkg/apis/meta"
	metav1 "k8s.io/apimachinery/pkg/apis/meta/v1"
	"github.com/fluxcd/pkg/apis/acl"
)

// BucketKind is the string representation of a Bucket.
#BucketKind: "Bucket"

// GenericBucketProvider for any S3 API compatible storage Bucket.
#GenericBucketProvider: "generic"

// AmazonBucketProvider for an AWS S3 object storage Bucket.
// Provides support for retrieving credentials from the AWS EC2 service.
#AmazonBucketProvider: "aws"

// GoogleBucketProvider for a Google Cloud Storage Bucket.
// Provides support for authentication using a workload identity.
#GoogleBucketProvider: "gcp"

// AzureBucketProvider for an Azure Blob Storage Bucket.
// Provides support for authentication using a Service Principal,
// Managed Identity or Shared Key.
#AzureBucketProvider: "azure"

// BucketSpec specifies the required configuration to produce an Artifact for
// an object storage bucket.
#BucketSpec: {
	// Provider of the object storage bucket.
	// Defaults to 'generic', which expects an S3 (API) compatible object
	// storage.
	// +kubebuilder:validation:Enum=generic;aws;gcp;azure
	// +kubebuilder:default:=generic
	// +optional
	provider?: string @go(Provider)

	// BucketName is the name of the object storage bucket.
	// +required
	bucketName: string @go(BucketName)

	// Endpoint is the object storage address the BucketName is located at.
	// +required
	endpoint: string @go(Endpoint)

	// Insecure allows connecting to a non-TLS HTTP Endpoint.
	// +optional
	insecure?: bool @go(Insecure)

	// Region of the Endpoint where the BucketName is located in.
	// +optional
	region?: string @go(Region)

	// SecretRef specifies the Secret containing authentication credentials
	// for the Bucket.
	// +optional
	secretRef?: null | meta.#LocalObjectReference @go(SecretRef,*meta.LocalObjectReference)

	// Interval at which to check the Endpoint for updates.
	// +kubebuilder:validation:Type=string
	// +kubebuilder:validation:Pattern="^([0-9]+(\\.[0-9]+)?(ms|s|m|h))+$"
	// +required
	interval: metav1.#Duration @go(Interval)

	// Timeout for fetch operations, defaults to 60s.
	// +kubebuilder:default="60s"
	// +kubebuilder:validation:Type=string
	// +kubebuilder:validation:Pattern="^([0-9]+(\\.[0-9]+)?(ms|s|m))+$"
	// +optional
	timeout?: null | metav1.#Duration @go(Timeout,*metav1.Duration)

	// Ignore overrides the set of excluded patterns in the .sourceignore format
	// (which is the same as .gitignore). If not provided, a default will be used,
	// consult the documentation for your version to find out what those are.
	// +optional
	ignore?: null | string @go(Ignore,*string)

	// Suspend tells the controller to suspend the reconciliation of this
	// Bucket.
	// +optional
	suspend?: bool @go(Suspend)

	// AccessFrom specifies an Access Control List for allowing cross-namespace
	// references to this object.
	// NOTE: Not implemented, provisional as of https://github.com/fluxcd/flux2/pull/2092
	// +optional
	accessFrom?: null | acl.#AccessFrom @go(AccessFrom,*acl.AccessFrom)
}

// BucketStatus records the observed state of a Bucket.
#BucketStatus: {
	// ObservedGeneration is the last observed generation of the Bucket object.
	// +optional
	observedGeneration?: int64 @go(ObservedGeneration)

	// Conditions holds the conditions for the Bucket.
	// +optional
	conditions?: [...metav1.#Condition] @go(Conditions,[]metav1.Condition)

	// URL is the dynamic fetch link for the latest Artifact.
	// It is provided on a "best effort" basis, and using the precise
	// BucketStatus.Artifact data is recommended.
	// +optional
	url?: string @go(URL)

	// Artifact represents the last successful Bucket reconciliation.
	// +optional
	artifact?: null | #Artifact @go(Artifact,*Artifact)

	// ObservedIgnore is the observed exclusion patterns used for constructing
	// the source artifact.
	// +optional
	observedIgnore?: null | string @go(ObservedIgnore,*string)

	meta.#ReconcileRequestStatus
}

// BucketOperationSucceededReason signals that the Bucket listing and fetch
// operations succeeded.
#BucketOperationSucceededReason: "BucketOperationSucceeded"

// BucketOperationFailedReason signals that the Bucket listing or fetch
// operations failed.
#BucketOperationFailedReason: "BucketOperationFailed"

// Bucket is the Schema for the buckets API.
#Bucket: {
	metav1.#TypeMeta
	metadata?: metav1.#ObjectMeta @go(ObjectMeta)
	spec?:     #BucketSpec        @go(Spec)

	// +kubebuilder:default={"observedGeneration":-1}
	status?: #BucketStatus @go(Status)
}

// BucketList contains a list of Bucket objects.
// +kubebuilder:object:root=true
#BucketList: {
	metav1.#TypeMeta
	metadata?: metav1.#ListMeta @go(ListMeta)
	items: [...#Bucket] @go(Items,[]Bucket)
}
