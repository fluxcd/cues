package clusters

import (
	"tool/cli"
	"tool/exec"
	"text/tabwriter"
)

// The bootstrap command targets the cluster specified with '-t cluster=name'
// using the Git credentials specified with '- gitToken=token'.
command: bootstrap: {
	clusterName: string @tag(cluster)

	for c in clusters {
		if c.name == clusterName {
			"print-\(c.name)": cli.Print & {
				text: "► starting bootstrap for \(c.name)"
			}
			"run-\(c.name)": exec.Run & {
				$after: "print-\(c.name)"
				cmd: [
					"flux",
					"bootstrap",
					"git",
					"--url=\(c.git.url)",
					"--path=\(c.git.path)",
					"--branch=\(c.git.branch)",
					"--token-auth",
					"--password=\(c.git.token)",
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
		}
	}
}

// The ls command prints a table with the defined clusters.
command: ls: {
	task: print: cli.Print & {
		text: tabwriter.Write([
			"CLUSTER \tREPOSITORY \tPATH",
			for c in clusters {
				"\(c.name) \t\(c.git.url)  \t\(c.git.path)"
			},
		])
	}
}
