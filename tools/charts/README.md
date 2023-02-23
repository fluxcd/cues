# ArtifactHub generator

This tool is for generating Flux HelmRepositories and HelmCharts from ArtifactHub API.

## Usage

List top 50 charts:

```shell
cue -t top=50 -t out=list fetch
```

Generate and apply top 10 charts:

```shell
cue -t top=10 -t out=yaml -t namespace=flux-system fetch | kubectl apply -f- 
```
