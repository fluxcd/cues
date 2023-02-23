package main

import (
	"tool/cli"
	"encoding/yaml"
	"tool/http"
	"encoding/json"
	"strings"
	"text/tabwriter"

	fluxv1 "github.com/fluxcd/source-controller/api/v1beta2"
)

vars: {
	top:       *5 | string                    @tag(top)
	namespace: *"flux-system" | string        @tag(namespace)
	out:       *"yaml" | "list|yaml" | string @tag(out)
}

command: fetch: {
	artifacthub: http.Get & {
		url: "https://artifacthub.io/api/v1/packages/search?kind=0&facets=true&sort=stars&limit=\(vars.top)&offset=0&deprecated=false"
		request: header: "content-type": "application/json"
		response: statusCode: 200
		packages: json.Unmarshal(response.body).packages
	}

	objects: {
		for r in artifacthub.packages {
			"\(r.package_id)-repo": fluxv1.#HelmRepository & {
				apiVersion: "source.toolkit.fluxcd.io/v1beta2"
				kind:       fluxv1.#HelmRepositoryKind
				metadata: name:      "\(r.name)-\(strings.Split(r.package_id, "-")[0])"
				metadata: namespace: vars.namespace
				spec: {
					url:      r.repository.url
					interval: "10m"
					timeout:  "1m"
				}
			}
			"\(r.package_id)-chart": fluxv1.#HelmChart & {
				apiVersion: "source.toolkit.fluxcd.io/v1beta2"
				kind:       fluxv1.#HelmChartKind
				metadata: name:      "\(r.name)-\(strings.Split(r.package_id, "-")[0])"
				metadata: namespace: vars.namespace
				spec: {
					interval: "10m"
					chart:    r.name
					version:  "*"
					sourceRef: {
						kind: fluxv1.#HelmRepositoryKind
						name: metadata.name
					}
				}
			}
		}
	}

	if vars.out == "yaml" {
		task: toyaml: cli.Print & {
			text: yaml.MarshalStream([ for obj in objects {obj}])
		}
	}

	if vars.out == "list" {
		task: list: cli.Print & {
			text: tabwriter.Write([
				"ID \tCHART \tREPOSITORY",
				for r in artifacthub.packages {
					"\(r.package_id) \t\(r.name) \t\(r.repository.url)"
				},
			])
		}
	}
}
