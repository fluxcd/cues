package tenants

import (
	"encoding/yaml"
	"tool/cli"
	"tool/exec"
	"tool/file"
	"text/tabwriter"

	kubernetes "k8s.io/apimachinery/pkg/runtime"
)

// The resources map holds the Kubernetes objects belonging to all tenants.
resources: [ID=_]: kubernetes.#Object
for t in tenants {
	resources: t.resources
}

// The build command generates the Kubernetes manifests of all tenants and prints the multi-docs YAML to stdout.
// With '-t out=/path/to/dir' you can specify a local dir where the YAML files are written, each tenant gets its own sub-dir.
// With '-t encrypt=sops' the Kubernetes Secrets manifests are encrypted with SOPS,
// the sops binary must be added to PATH and an env var must be set for encryption e.g. SOPS_AGE_RECIPIENTS.
command: build: {
	encrypt: *"" | "sops" | string @tag(encrypt)
	outDir:  *"" | string          @tag(out)

	if outDir == "" {
		if encrypt == "" {
			task: print: cli.Print & {
				text: yaml.MarshalStream([ for r in resources {r}])
			}
		}

		if encrypt == "sops" {
			res: [ for r in resources if r.kind != "Secret" {r}]
			printRes: cli.Print & {
				text: yaml.MarshalStream(res)
			}
			secrets: [ for r in resources if r.kind == "Secret" {r}]
			if len(secrets) > 0 {
				printSeparator: cli.Print & {
					$after: printRes
					text:   "---"
				}
				printSops: exec.Run & {
					$after: printSeparator
					stdin:  yaml.MarshalStream(secrets)
					cmd: [ encrypt, "-e", "--input-type=yaml", "--output-type=yaml", "--encrypted-regex=^stringData$", "/dev/stdin"]
				}
			}
		}
	}

	if outDir != "" {
		list: tenants
		for tn in list {
			(tn.spec.name): {
				res: [ for r in tn.resources if r.kind != "Secret" {r}]
				print: cli.Print & {
					text: "Exporting tenant resources to \(outDir)/\(tn.spec.name)/"
				}
				mkdir: file.MkdirAll & {
					$after: print
					path:   "\(outDir)/\(tn.spec.name)"
				}
				write: file.Create & {
					$after:   mkdir
					filename: "\(outDir)/\(tn.spec.name)/resources.yaml"
					contents: yaml.MarshalStream(res)
				}

				secrets: [ for r in tn.resources if r.kind == "Secret" {r}]
				if len(secrets) > 0 {
					printSecrets: cli.Print & {
						$after: mkdir
						text:   "Exporting tenant secrets to \(outDir)/\(tn.spec.name)/"
					}
					writeSecrets: file.Create & {
						$after:   printSecrets
						filename: "\(outDir)/\(tn.spec.name)/secrets.yaml"
						contents: yaml.MarshalStream(secrets)
					}
					if encrypt == "sops" {
						printSops: cli.Print & {
							$after: writeSecrets
							text:   "Encrypting tenant secrets to \(outDir)/\(tn.spec.name)/"
						}
						writeSops: exec.Run & {
							$after: printSops
							cmd: [ encrypt, "-e", "-i", "--encrypted-regex=^stringData$", "\(outDir)/\(tn.spec.name)/secrets.yaml"]
						}
					}
				}
			}
		}
	}
}

// The ls command prints a table with the Kubernetes resources kind, namespace, name and version of all tenants.
command: ls: {
	task: print: cli.Print & {
		text: tabwriter.Write([
			"TENANT \tRESOURCE \tAPI VERSION",
			for r in resources {
				if r.metadata.namespace == _|_ {
					"\(r.metadata.labels["tenant.toolkit.fluxcd.io/name"]) \t\(r.kind)/\(r.metadata.name) \t\(r.apiVersion)"
				}
				if r.metadata.namespace != _|_ {
					"\(r.metadata.labels["tenant.toolkit.fluxcd.io/name"]) \t\(r.kind)/\(r.metadata.namespace)/\(r.metadata.name)  \t\(r.apiVersion)"
				}
			},
		])
	}
}

// The dryrun command applies the Kubernetes resources of all tenants on the cluster using client-side dry run.
command: dryrun: {
	task: kubectl: exec.Run & {
		stdin: yaml.MarshalStream([ for r in resources {r}])
		cmd: [ "kubectl", "apply", "--dry-run=client", "-f-"]
	}
}
