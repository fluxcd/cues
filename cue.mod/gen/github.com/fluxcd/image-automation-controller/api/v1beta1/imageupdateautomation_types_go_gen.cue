// Code generated by cue get go. DO NOT EDIT.

//cue:generate cue get go github.com/fluxcd/image-automation-controller/api/v1beta1

package v1beta1

import (
	metav1 "k8s.io/apimachinery/pkg/apis/meta/v1"
	"github.com/fluxcd/pkg/apis/meta"
)

#ImageUpdateAutomationKind:      "ImageUpdateAutomation"
#ImageUpdateAutomationFinalizer: "finalizers.fluxcd.io"

// ImageUpdateAutomationSpec defines the desired state of ImageUpdateAutomation
#ImageUpdateAutomationSpec: {
	// SourceRef refers to the resource giving access details
	// to a git repository.
	// +required
	sourceRef: #CrossNamespaceSourceReference @go(SourceRef)

	// GitSpec contains all the git-specific definitions. This is
	// technically optional, but in practice mandatory until there are
	// other kinds of source allowed.
	// +optional
	git?: null | #GitSpec @go(GitSpec,*GitSpec)

	// Interval gives an lower bound for how often the automation
	// run should be attempted.
	// +required
	interval: metav1.#Duration @go(Interval)

	// Update gives the specification for how to update the files in
	// the repository. This can be left empty, to use the default
	// value.
	// +kubebuilder:default={"strategy":"Setters"}
	update?: null | #UpdateStrategy @go(Update,*UpdateStrategy)

	// Suspend tells the controller to not run this automation, until
	// it is unset (or set to false). Defaults to false.
	// +optional
	suspend?: bool @go(Suspend)
}

// UpdateStrategyName is the type for names that go in
// .update.strategy. NB the value in the const immediately below.
// +kubebuilder:validation:Enum=Setters
#UpdateStrategyName: string // #enumUpdateStrategyName

#enumUpdateStrategyName:
	#UpdateStrategySetters

// UpdateStrategySetters is the name of the update strategy that
// uses kyaml setters. NB the value in the enum annotation for the
// type, above.
#UpdateStrategySetters: #UpdateStrategyName & "Setters"

// UpdateStrategy is a union of the various strategies for updating
// the Git repository. Parameters for each strategy (if any) can be
// inlined here.
#UpdateStrategy: {
	// Strategy names the strategy to be used.
	// +required
	// +kubebuilder:default=Setters
	strategy: #UpdateStrategyName @go(Strategy)

	// Path to the directory containing the manifests to be updated.
	// Defaults to 'None', which translates to the root path
	// of the GitRepositoryRef.
	// +optional
	path?: string @go(Path)
}

// ImageUpdateAutomationStatus defines the observed state of ImageUpdateAutomation
#ImageUpdateAutomationStatus: {
	// LastAutomationRunTime records the last time the controller ran
	// this automation through to completion (even if no updates were
	// made).
	// +optional
	lastAutomationRunTime?: null | metav1.#Time @go(LastAutomationRunTime,*metav1.Time)

	// LastPushCommit records the SHA1 of the last commit made by the
	// controller, for this automation object
	// +optional
	lastPushCommit?: string @go(LastPushCommit)

	// LastPushTime records the time of the last pushed change.
	// +optional
	lastPushTime?: null | metav1.#Time @go(LastPushTime,*metav1.Time)

	// +optional
	observedGeneration?: int64 @go(ObservedGeneration)

	// +optional
	conditions?: [...metav1.#Condition] @go(Conditions,[]metav1.Condition)

	meta.#ReconcileRequestStatus
}

// GitNotAvailableReason is used for ConditionReady when the
// automation run cannot proceed because the git repository is
// missing or cannot be cloned.
#GitNotAvailableReason: "GitRepositoryNotAvailable"

// NoStrategyReason is used for ConditionReady when the automation
// run cannot proceed because there is no update strategy given in
// the spec.
#NoStrategyReason: "MissingUpdateStrategy"

// ImageUpdateAutomation is the Schema for the imageupdateautomations API
#ImageUpdateAutomation: {
	metav1.#TypeMeta
	metadata?: metav1.#ObjectMeta         @go(ObjectMeta)
	spec?:     #ImageUpdateAutomationSpec @go(Spec)

	// +kubebuilder:default={"observedGeneration":-1}
	status?: #ImageUpdateAutomationStatus @go(Status)
}

// ImageUpdateAutomationList contains a list of ImageUpdateAutomation
#ImageUpdateAutomationList: {
	metav1.#TypeMeta
	metadata?: metav1.#ListMeta @go(ListMeta)
	items: [...#ImageUpdateAutomation] @go(Items,[]ImageUpdateAutomation)
}
