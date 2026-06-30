cwlVersion: v1.1

$namespaces:
  s: https://schema.org/

s:softwareVersion: 0.1.2

$graph:
  - class: Workflow
    id: convert-url
    label: convert url app
    doc: Convert URL

    requirements:
      ResourceRequirement:
        coresMax: 1
        ramMax: 1024

    inputs:
      fn:
        label: the operation to perform
        doc: the operation to perform
        type: string
        default: resize

      url:
        label: the image to convert
        doc: the image to convert
        type: string
        default: https://eoepca.org/media_portal/images/logo6_med.original.png

      size:
        label: the percentage for a resize operation
        doc: the percentage for a resize operation
        type: string
        default: 50%

    outputs:
      converted_image:
        type: Directory
        outputSource: convert/results

    steps:
      convert:
        run: "#convert"
        in:
          fn: fn
          url: url
          size: size
        out:
          - results

  - class: CommandLineTool
    id: convert

    requirements:
      ResourceRequirement:
        coresMax: 1
        ramMax: 512

      DockerRequirement:
        dockerPull: eoepca/convert:latest

      NetworkAccess:
        networkAccess: true

    baseCommand: convert.sh

    inputs:
      fn:
        type: string
        inputBinding:
          position: 1

      url:
        type: string
        inputBinding:
          position: 2
          prefix: --url

      size:
        type: string
        inputBinding:
          position: 3

    outputs:
      image:
        type: File
        outputBinding:
          glob: "*-resize.png"

      results:
        type: Directory
        outputBinding:
          glob: .