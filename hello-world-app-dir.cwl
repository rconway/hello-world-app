cwlVersion: v1.0
$namespaces:
  s: https://schema.org/
schemas:
  - http://schema.org/version/9.0/schemaorg-current-http.rdf
s:softwareVersion: 0.0.1

$graph:
  # Workflow entrypoint
  - class: Workflow
    doc: Hello World App
    id: hello-world-dir
    label: hello world app
    inputs:
      dir:
        type: Directory?
    outputs:
      - id: wf_outputs
        type: Directory
        outputSource:
          - app/results
    steps:
      app:
        run: "#app"
        in:
          dir: dir
        out:
          - results

  # app.sh - takes input args `--dir`
  - class: CommandLineTool
    id: app
    baseCommand: app.sh
    inputs:
      dir:
        type: Directory?
        inputBinding:
          prefix: --dir
    outputs:
      results:
        type: Directory
        outputBinding:
          glob: .
    requirements:
      DockerRequirement:
        dockerPull: rconway/hello-world-app:main
