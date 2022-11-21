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
    id: hello-world
    label: hello world app
    inputs:
      url:
        type: string?
    outputs:
      - id: wf_outputs
        type: Directory
        outputSource:
          - app/results
    steps:
      app:
        run: "#app"
        in:
          url: url
        out:
          - results

  # app.sh - takes input args `--url`
  - class: CommandLineTool
    id: app
    inputs:
      url:
        type: string?
        inputBinding:
          prefix: --url
    outputs:
      results:
        type: Directory
        outputBinding:
          glob: .
    requirements:
      DockerRequirement:
        dockerPull: rconway/hello-world-app:main
