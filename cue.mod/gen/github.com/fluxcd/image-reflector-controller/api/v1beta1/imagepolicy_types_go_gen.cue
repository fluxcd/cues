// Code generated by cue get go. DO NOT EDIT.

//cue:generate cue get go github.com/fluxcd/image-reflector-controller/api/v1beta1

package v1beta1

import (
	"github.com/fluxcd/pkg/apis/meta"
	metav1 "k8s.io/apimachinery/pkg/apis/meta/v1"
)

#ImagePolicyKind: "ImagePolicy"

#ImagePolicyFinalizer: "finalizers.fluxcd.io"

// ImagePolicySpec defines the parameters for calculating the
// ImagePolicy
#ImagePolicySpec: {
	// ImageRepositoryRef points at the object specifying the image
	// being scanned
	// +required
	imageRepositoryRef: meta.#NamespacedObjectReference @go(ImageRepositoryRef)

	// Policy gives the particulars of the policy to be followed in
	// selecting the most recent image
	// +required
	policy: #ImagePolicyChoice @go(Policy)

	// FilterTags enables filtering for only a subset of tags based on a set of
	// rules. If no rules are provided, all the tags from the repository will be
	// ordered and compared.
	// +optional
	filterTags?: null | #TagFilter @go(FilterTags,*TagFilter)
}

// ImagePolicyChoice is a union of all the types of policy that can be
// supplied.
#ImagePolicyChoice: {
	// SemVer gives a semantic version range to check against the tags
	// available.
	// +optional
	semver?: null | #SemVerPolicy @go(SemVer,*SemVerPolicy)

	// Alphabetical set of rules to use for alphabetical ordering of the tags.
	// +optional
	alphabetical?: null | #AlphabeticalPolicy @go(Alphabetical,*AlphabeticalPolicy)

	// Numerical set of rules to use for numerical ordering of the tags.
	// +optional
	numerical?: null | #NumericalPolicy @go(Numerical,*NumericalPolicy)
}

// SemVerPolicy specifies a semantic version policy.
#SemVerPolicy: {
	// Range gives a semver range for the image tag; the highest
	// version within the range that's a tag yields the latest image.
	// +required
	range: string @go(Range)
}

// AlphabeticalPolicy specifies a alphabetical ordering policy.
#AlphabeticalPolicy: {
	// Order specifies the sorting order of the tags. Given the letters of the
	// alphabet as tags, ascending order would select Z, and descending order
	// would select A.
	// +kubebuilder:default:="asc"
	// +kubebuilder:validation:Enum=asc;desc
	// +optional
	order?: string @go(Order)
}

// NumericalPolicy specifies a numerical ordering policy.
#NumericalPolicy: {
	// Order specifies the sorting order of the tags. Given the integer values
	// from 0 to 9 as tags, ascending order would select 9, and descending order
	// would select 0.
	// +kubebuilder:default:="asc"
	// +kubebuilder:validation:Enum=asc;desc
	// +optional
	order?: string @go(Order)
}

// TagFilter enables filtering tags based on a set of defined rules
#TagFilter: {
	// Pattern specifies a regular expression pattern used to filter for image
	// tags.
	// +optional
	pattern: string @go(Pattern)

	// Extract allows a capture group to be extracted from the specified regular
	// expression pattern, useful before tag evaluation.
	// +optional
	extract: string @go(Extract)
}

// ImagePolicyStatus defines the observed state of ImagePolicy
#ImagePolicyStatus: {
	// LatestImage gives the first in the list of images scanned by
	// the image repository, when filtered and ordered according to
	// the policy.
	latestImage?: string @go(LatestImage)

	// +optional
	observedGeneration?: int64 @go(ObservedGeneration)

	// +optional
	conditions?: [...metav1.#Condition] @go(Conditions,[]metav1.Condition)
}

// ImagePolicy is the Schema for the imagepolicies API
#ImagePolicy: {
	metav1.#TypeMeta
	metadata?: metav1.#ObjectMeta @go(ObjectMeta)
	spec?:     #ImagePolicySpec   @go(Spec)

	// +kubebuilder:default={"observedGeneration":-1}
	status?: #ImagePolicyStatus @go(Status)
}

// ImagePolicyList contains a list of ImagePolicy
#ImagePolicyList: {
	metav1.#TypeMeta
	metadata?: metav1.#ListMeta @go(ListMeta)
	items: [...#ImagePolicy] @go(Items,[]ImagePolicy)
}
