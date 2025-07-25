An application in this context is defined by a **Common Workflow Language (CWL)** file. This file describes the inputs, outputs and steps of our scientific workflow.

We're going to create a very simple "showcase" application. First, let's clean up the template's default test files and create a new directory for our app.

```bash
rm tests/test.py
rm -rf tests/water_bodies
mkdir tests/simple_showcase
```{{exec}}

Now, let's create the CWL file `app-package.cwl`. We'll use a `cat` command to write the content directly to the file.

```bash
cat <<EOF > tests/simple_showcase/app-package.cwl
cwlVersion: v1.0
\$graph:
  - class: Workflow
    id: simple-showcase
    label: A simple showcase workflow
    doc: This workflow creates a dummy STAC catalog to satisfy the stage-out step.
    inputs: {}
    outputs:
      - id: result_directory
        outputSource: success_step/output_dir
        type: Directory
    steps:
      success_step:
        run: "#success-tool"
        in: {}
        out:
          - output_dir

  - class: CommandLineTool
    id: success-tool
    label: Create a dummy STAC catalog
    requirements:
      ResourceRequirement:
        coresMax: 1
        ramMax: 1024
    hints:
      DockerRequirement:
        # A simple alpine image with wget is all that's needed
        dockerPull: alpine:latest
    baseCommand: ["/bin/sh", "-c"]
    # This command creates the directory and downloads a dummy catalog into it.
    arguments:
      - "mkdir output && wget -O output/catalog.json https://raw.githubusercontent.com/EOEPCA/deployment-guide/refs/heads/killercoda-jh-changes/scripts/processing/oapip/examples/stac-catalog.json"
    inputs: {}
    outputs:
      output_dir:
        type: Directory
        outputBinding:
          glob: "output"
EOF
```{{exec}}

As you can see, this workflow is straightforward: it runs a single command-line tool inside an `alpine` container. The tool creates an `output` directory and downloads a sample STAC `catalog.json` file into it. This will be our final result.