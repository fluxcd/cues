// Code generated by cue get go. DO NOT EDIT.

//cue:generate cue get go github.com/fluxcd/notification-controller/api/v1beta1

package v1beta1

import (
	"github.com/fluxcd/pkg/apis/meta"
	metav1 "k8s.io/apimachinery/pkg/apis/meta/v1"
)

#ProviderKind: "Provider"

// ProviderSpec defines the desired state of Provider
#ProviderSpec: {
	// Type of provider
	// +kubebuilder:validation:Enum=slack;discord;msteams;rocket;generic;github;gitlab;bitbucket;azuredevops;googlechat;webex;sentry;azureeventhub;telegram;lark;matrix;opsgenie;alertmanager;grafana;githubdispatch;
	// +required
	type: string @go(Type)

	// Alert channel for this provider
	// +optional
	channel?: string @go(Channel)

	// Bot username for this provider
	// +optional
	username?: string @go(Username)

	// HTTP/S webhook address of this provider
	// +kubebuilder:validation:Pattern="^(http|https)://"
	// +kubebuilder:validation:Optional
	// +optional
	address?: string @go(Address)

	// HTTP/S address of the proxy
	// +kubebuilder:validation:Pattern="^(http|https)://"
	// +kubebuilder:validation:Optional
	// +optional
	proxy?: string @go(Proxy)

	// Secret reference containing the provider webhook URL
	// using "address" as data key
	// +optional
	secretRef?: null | meta.#LocalObjectReference @go(SecretRef,*meta.LocalObjectReference)

	// CertSecretRef can be given the name of a secret containing
	// a PEM-encoded CA certificate (`caFile`)
	// +optional
	certSecretRef?: null | meta.#LocalObjectReference @go(CertSecretRef,*meta.LocalObjectReference)

	// This flag tells the controller to suspend subsequent events handling.
	// Defaults to false.
	// +optional
	suspend?: bool @go(Suspend)
}

#GenericProvider:        "generic"
#SlackProvider:          "slack"
#GrafanaProvider:        "grafana"
#DiscordProvider:        "discord"
#MSTeamsProvider:        "msteams"
#RocketProvider:         "rocket"
#GitHubDispatchProvider: "githubdispatch"
#GitHubProvider:         "github"
#GitLabProvider:         "gitlab"
#BitbucketProvider:      "bitbucket"
#AzureDevOpsProvider:    "azuredevops"
#GoogleChatProvider:     "googlechat"
#WebexProvider:          "webex"
#SentryProvider:         "sentry"
#AzureEventHubProvider:  "azureeventhub"
#TelegramProvider:       "telegram"
#LarkProvider:           "lark"
#Matrix:                 "matrix"
#OpsgenieProvider:       "opsgenie"
#AlertManagerProvider:   "alertmanager"

// ProviderStatus defines the observed state of Provider
#ProviderStatus: {
	// ObservedGeneration is the last reconciled generation.
	// +optional
	observedGeneration?: int64 @go(ObservedGeneration)

	// +optional
	conditions?: [...metav1.#Condition] @go(Conditions,[]metav1.Condition)
}

// Provider is the Schema for the providers API
#Provider: {
	metav1.#TypeMeta
	metadata?: metav1.#ObjectMeta @go(ObjectMeta)
	spec?:     #ProviderSpec      @go(Spec)

	// +kubebuilder:default:={"observedGeneration":-1}
	status?: #ProviderStatus @go(Status)
}

// ProviderList contains a list of Provider
#ProviderList: {
	metav1.#TypeMeta
	metadata?: metav1.#ListMeta @go(ListMeta)
	items: [...#Provider] @go(Items,[]Provider)
}
