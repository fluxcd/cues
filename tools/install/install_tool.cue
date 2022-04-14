package install

import (
	"encoding/yaml"
	"tool/cli"
	"tool/exec"
	"text/tabwriter"
)

clusterName: string @tag(cluster)

command: install: {
	for c in clusters {
		if c.name == clusterName {
			print: cli.Print & {
				text: "► installing Flux on \(c.name)"
			}
			install: exec.Run & {
				$after: print
				cmd: [
					"flux",
					"install",
					"--namespace=\(c.flux.namespace)",
					for com in c.flux.components {
						"--components=\(com)"
					},
					if c.kubeconfig.context != "" {
						"--context=\(c.kubeconfig.context)"
					},
					if c.kubeconfig.path != "" {
						"--kubeconfig=\(c.kubeconfig.path)"
					},
					if c.flux.version != _|_ {
						"--version=\(c.flux.version)"
					},
				]
			}
			for idx, addon in c.addons {
				flux: install
				(addon.spec.name): {
					apply: exec.Run & {
						$after: flux
						stdin:  yaml.MarshalStream([ for r in addon.resources {r}])
						cmd: [
							"kubectl",
							if c.kubeconfig.context != "" {
								"--context=\(c.kubeconfig.context)"
							},
							"apply",
							"--server-side",
							"-f-",
						]
					}
					if idx+1 == len(c.addons) {
						print: cli.Print & {
							$after: apply
							text:   "► waiting for \(len(c.addons)) addon(s) to become ready"
						}
						wait: exec.Run & {
							$after: print
							cmd: [
								"kubectl",
								"-n=flux-system",
								if c.kubeconfig.context != "" {
									"--context=\(c.kubeconfig.context)"
								},
								"wait",
								"hr",
								"--all",
								"--for=condition=ready",
								"--timeout=3m",
							]
						}
					}
				}
			}
		}
	}
}

// The ls command prints a table with the defined clusters.
command: ls: {
	task: print: cli.Print & {
		text: tabwriter.Write([
			"CLUSTER \tCONTEXT \tADDONS",
			for c in clusters {
				"\(c.name) \t\(c.kubeconfig.context)  \t\(len(c.addons))"
			},
		])
	}
}
