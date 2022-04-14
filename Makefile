# Flux cue utils

REPO_ROOT := $(shell git rev-parse --show-toplevel)
BUILD_DIR := $(REPO_ROOT)/build

all: vet fmt

vet:
	@cue vet ./... -c
	@cue vet ./pkg/... -c
	@cue vet ./generators/... -c
	@cue vet ./tools/... -c

fmt:
	@cue fmt ./...
	@cue fmt ./pkg/...
	@cue fmt ./generators/...
	@cue fmt ./tools/...

mod:
	go get -u k8s.io/api/...
	cue get go k8s.io/api/...
	go get -u github.com/fluxcd/source-controller/api/v1beta2
	cue get go github.com/fluxcd/source-controller/api/v1beta2
	go get -u github.com/fluxcd/kustomize-controller/api/v1beta2
	cue get go github.com/fluxcd/kustomize-controller/api/v1beta2
	go get -u github.com/fluxcd/notification-controller/api/v1beta1
	cue get go github.com/fluxcd/notification-controller/api/v1beta1
	go get -u github.com/fluxcd/helm-controller/api/v2beta1
	cue get go github.com/fluxcd/helm-controller/api/v2beta1
	go get -u github.com/fluxcd/image-reflector-controller/api/v1beta1
	cue get go github.com/fluxcd/image-reflector-controller/api/v1beta1
	go get -u github.com/fluxcd/image-automation-controller/api/v1beta1
	cue get go github.com/fluxcd/image-automation-controller/api/v1beta1
