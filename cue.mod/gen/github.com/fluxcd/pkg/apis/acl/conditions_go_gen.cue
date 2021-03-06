// Code generated by cue get go. DO NOT EDIT.

//cue:generate cue get go github.com/fluxcd/pkg/apis/acl

package acl

// AccessDeniedCondition indicates that access to a resource has been denied by an ACL assertion.
// The Condition adheres to an "abnormal-true" polarity pattern, and MUST only be present on the resource if the
// Condition is True.
#AccessDeniedCondition: "AccessDenied"

// AccessDeniedReason indicates that access to a resource has been denied by an ACL assertion.
#AccessDeniedReason: "AccessDenied"
