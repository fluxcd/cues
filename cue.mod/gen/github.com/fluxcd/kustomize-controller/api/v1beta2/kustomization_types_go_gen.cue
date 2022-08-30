// Code generated by cue get go. DO NOT EDIT.

//cue:generate cue get go github.com/fluxcd/kustomize-controller/api/v1beta2

package v1beta2

import (
	"github.com/fluxcd/pkg/apis/meta"
	metav1 "k8s.io/apimachinery/pkg/apis/meta/v1"
	"github.com/fluxcd/pkg/apis/kustomize"
	apiextensionsv1 "k8s.io/apiextensions-apiserver/pkg/apis/apiextensions/v1"
)

#KustomizationKind:         "Kustomization"
#KustomizationFinalizer:    "finalizers.fluxcd.io"
#MaxConditionMessageLength: 20000
#DisabledValue:             "disabled"
#MergeValue:                "merge"

// KustomizationSpec defines the configuration to calculate the desired state from a Source using Kustomize.
#KustomizationSpec: {
	// DependsOn may contain a meta.NamespacedObjectReference slice
	// with references to Kustomization resources that must be ready before this
	// Kustomization can be reconciled.
	// +optional
	dependsOn?: [...meta.#NamespacedObjectReference] @go(DependsOn,[]meta.NamespacedObjectReference)

	// Decrypt Kubernetes secrets before applying them on the cluster.
	// +optional
	decryption?: null | #Decryption @go(Decryption,*Decryption)

	// The interval at which to reconcile the Kustomization.
	// +required
	interval: metav1.#Duration @go(Interval)

	// The interval at which to retry a previously failed reconciliation.
	// When not specified, the controller uses the KustomizationSpec.Interval
	// value to retry failures.
	// +optional
	retryInterval?: null | metav1.#Duration @go(RetryInterval,*metav1.Duration)

	// The KubeConfig for reconciling the Kustomization on a remote cluster.
	// When used in combination with KustomizationSpec.ServiceAccountName,
	// forces the controller to act on behalf of that Service Account at the
	// target cluster.
	// If the --default-service-account flag is set, its value will be used as
	// a controller level fallback for when KustomizationSpec.ServiceAccountName
	// is empty.
	// +optional
	kubeConfig?: null | #KubeConfig @go(KubeConfig,*KubeConfig)

	// Path to the directory containing the kustomization.yaml file, or the
	// set of plain YAMLs a kustomization.yaml should be generated for.
	// Defaults to 'None', which translates to the root path of the SourceRef.
	// +optional
	path?: string @go(Path)

	// PostBuild describes which actions to perform on the YAML manifest
	// generated by building the kustomize overlay.
	// +optional
	postBuild?: null | #PostBuild @go(PostBuild,*PostBuild)

	// Prune enables garbage collection.
	// +required
	prune: bool @go(Prune)

	// A list of resources to be included in the health assessment.
	// +optional
	healthChecks?: [...meta.#NamespacedObjectKindReference] @go(HealthChecks,[]meta.NamespacedObjectKindReference)

	// Strategic merge and JSON patches, defined as inline YAML objects,
	// capable of targeting objects based on kind, label and annotation selectors.
	// +optional
	patches?: [...kustomize.#Patch] @go(Patches,[]kustomize.Patch)

	// Strategic merge patches, defined as inline YAML objects.
	// Deprecated: Use Patches instead.
	// +optional
	patchesStrategicMerge?: [...apiextensionsv1.#JSON] @go(PatchesStrategicMerge,[]apiextensionsv1.JSON)

	// JSON 6902 patches, defined as inline YAML objects.
	// Deprecated: Use Patches instead.
	// +optional
	patchesJson6902?: [...kustomize.#JSON6902Patch] @go(PatchesJSON6902,[]kustomize.JSON6902Patch)

	// Images is a list of (image name, new name, new tag or digest)
	// for changing image names, tags or digests. This can also be achieved with a
	// patch, but this operator is simpler to specify.
	// +optional
	images?: [...kustomize.#Image] @go(Images,[]kustomize.Image)

	// The name of the Kubernetes service account to impersonate
	// when reconciling this Kustomization.
	// +optional
	serviceAccountName?: string @go(ServiceAccountName)

	// Reference of the source where the kustomization file is.
	// +required
	sourceRef: #CrossNamespaceSourceReference @go(SourceRef)

	// This flag tells the controller to suspend subsequent kustomize executions,
	// it does not apply to already started executions. Defaults to false.
	// +optional
	suspend?: bool @go(Suspend)

	// TargetNamespace sets or overrides the namespace in the
	// kustomization.yaml file.
	// +kubebuilder:validation:MinLength=1
	// +kubebuilder:validation:MaxLength=63
	// +kubebuilder:validation:Optional
	// +optional
	targetNamespace?: string @go(TargetNamespace)

	// Timeout for validation, apply and health checking operations.
	// Defaults to 'Interval' duration.
	// +optional
	timeout?: null | metav1.#Duration @go(Timeout,*metav1.Duration)

	// Force instructs the controller to recreate resources
	// when patching fails due to an immutable field change.
	// +kubebuilder:default:=false
	// +optional
	force?: bool @go(Force)

	// Wait instructs the controller to check the health of all the reconciled resources.
	// When enabled, the HealthChecks are ignored. Defaults to false.
	// +optional
	wait?: bool @go(Wait)

	// Deprecated: Not used in v1beta2.
	// +kubebuilder:validation:Enum=none;client;server
	// +optional
	validation?: string @go(Validation)
}

// Decryption defines how decryption is handled for Kubernetes manifests.
#Decryption: {
	// Provider is the name of the decryption engine.
	// +kubebuilder:validation:Enum=sops
	// +required
	provider: string @go(Provider)

	// The secret name containing the private OpenPGP keys used for decryption.
	// +optional
	secretRef?: null | meta.#LocalObjectReference @go(SecretRef,*meta.LocalObjectReference)
}

// KubeConfig references a Kubernetes secret that contains a kubeconfig file.
#KubeConfig: {
	// SecretRef holds the name of a secret that contains a key with
	// the kubeconfig file as the value. If no key is set, the key will default
	// to 'value'. The secret must be in the same namespace as
	// the Kustomization.
	// It is recommended that the kubeconfig is self-contained, and the secret
	// is regularly updated if credentials such as a cloud-access-token expire.
	// Cloud specific `cmd-path` auth helpers will not function without adding
	// binaries and credentials to the Pod that is responsible for reconciling
	// the Kustomization.
	// +required
	secretRef?: meta.#SecretKeyReference @go(SecretRef)
}

// PostBuild describes which actions to perform on the YAML manifest
// generated by building the kustomize overlay.
#PostBuild: {
	// Substitute holds a map of key/value pairs.
	// The variables defined in your YAML manifests
	// that match any of the keys defined in the map
	// will be substituted with the set value.
	// Includes support for bash string replacement functions
	// e.g. ${var:=default}, ${var:position} and ${var/substring/replacement}.
	// +optional
	substitute?: {[string]: string} @go(Substitute,map[string]string)

	// SubstituteFrom holds references to ConfigMaps and Secrets containing
	// the variables and their values to be substituted in the YAML manifests.
	// The ConfigMap and the Secret data keys represent the var names and they
	// must match the vars declared in the manifests for the substitution to happen.
	// +optional
	substituteFrom?: [...#SubstituteReference] @go(SubstituteFrom,[]SubstituteReference)
}

// SubstituteReference contains a reference to a resource containing
// the variables name and value.
#SubstituteReference: {
	// Kind of the values referent, valid values are ('Secret', 'ConfigMap').
	// +kubebuilder:validation:Enum=Secret;ConfigMap
	// +required
	kind: string @go(Kind)

	// Name of the values referent. Should reside in the same namespace as the
	// referring resource.
	// +kubebuilder:validation:MinLength=1
	// +kubebuilder:validation:MaxLength=253
	// +required
	name: string @go(Name)

	// Optional indicates whether the referenced resource must exist, or whether to
	// tolerate its absence. If true and the referenced resource is absent, proceed
	// as if the resource was present but empty, without any variables defined.
	// +kubebuilder:default:=false
	// +optional
	optional?: bool @go(Optional)
}

// KustomizationStatus defines the observed state of a kustomization.
#KustomizationStatus: {
	meta.#ReconcileRequestStatus

	// ObservedGeneration is the last reconciled generation.
	// +optional
	observedGeneration?: int64 @go(ObservedGeneration)

	// +optional
	conditions?: [...metav1.#Condition] @go(Conditions,[]metav1.Condition)

	// The last successfully applied revision.
	// The revision format for Git sources is <branch|tag>/<commit-sha>.
	// +optional
	lastAppliedRevision?: string @go(LastAppliedRevision)

	// LastAttemptedRevision is the revision of the last reconciliation attempt.
	// +optional
	lastAttemptedRevision?: string @go(LastAttemptedRevision)

	// Inventory contains the list of Kubernetes resource object references that have been successfully applied.
	// +optional
	inventory?: null | #ResourceInventory @go(Inventory,*ResourceInventory)
}

// Kustomization is the Schema for the kustomizations API.
#Kustomization: {
	metav1.#TypeMeta
	metadata?: metav1.#ObjectMeta @go(ObjectMeta)
	spec?:     #KustomizationSpec @go(Spec)

	// +kubebuilder:default:={"observedGeneration":-1}
	status?: #KustomizationStatus @go(Status)
}

// KustomizationList contains a list of kustomizations.
#KustomizationList: {
	metav1.#TypeMeta
	metadata?: metav1.#ListMeta @go(ListMeta)
	items: [...#Kustomization] @go(Items,[]Kustomization)
}
