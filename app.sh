#!/usr/bin/env bash
# Ref. https://docs.ogc.org/bp/20-089r1.html#toc27

ORIG_DIR="$(pwd)"
cd "$(dirname "$0")"
BIN_DIR="$(pwd)"
cd "${ORIG_DIR}"

onExit() {
  cd "${ORIG_DIR}"
}
trap onExit EXIT

OUTPUT_DIR="${ORIG_DIR}"

main() {
  echo "Invocation args: $0 $@"
  if [ $# -lt 2 ]; then echo "ERROR: Not enough args"; return 1; fi
  case "$1" in
    "--dir" )
      echo "Processing directory = ${2}..."
      processDirectory "${2}"
      ;;
    "--url" )
      echo "Processing URL = ${2}..."
      processUrl "${2}"
      ;;
    * )
      echo "ERROR: Unknown input = ${1}"
      return 1
      ;;
  esac
}

processDirectory() {
  inputDir="${1}"
  # create the output file (i.e. the 'results')
  cat - <<EOF > "${OUTPUT_DIR}/output.txt"
Input directory is: ${inputDir}
Output directory is: ${OUTPUT_DIR}
$(ls -lR "${inputDir}")
EOF
  # create the STAC catalog for the output
  createStacOutput
}

processUrl() {
  url="${1}"
  # create the output file (i.e. the 'results')
  cat - <<EOF > "${OUTPUT_DIR}/output.txt"
Requested URL is: ${url}
Output directory is: ${OUTPUT_DIR}
$(curl -L --head --silent "${url}")
EOF
  # create the STAC catalog for the output
  createStacOutput
}

createStacOutput() {
  createStacCatalogRoot
  createStacItem "$(date +%s.%N)"
}

createStacCatalogRoot() {
  cat - <<EOF > "${OUTPUT_DIR}/catalog.json"
{
  "stac_version": "1.0.0",
  "id": "catalog",
  "type": "Catalog",
  "description": "Root catalog"
  "links": [{
    "type": "application/geo+json",
    "rel": "item",
    "href": "item.json"
  }, {
    "type": "application/json",
    "rel": "self",
    "href": "catalog.json"
  }]
}
EOF
}

createStacItem() {
  now="${1}"
  dateNow="$(date -u --date=@${now} +%Y-%m-%dT%T.%03NZ)"
  cat - <<EOF > "${OUTPUT_DIR}/item.json"
{
  "stac_version": "1.0.0",
  "id": "hello-world-${now}",
  "type": "Feature",
  "geometry": {
    "type": "Polygon",
    "coordinates": [
      [
        [30.155974613579858, 28.80949327971016],
        [30.407037927198104, 29.805008695373978],
        [31.031551610920825, 29.815791988006527],
        [31.050481437029678, 28.825387639743422],
        [30.155974613579858, 28.80949327971016]
      ]
    ]
  },
  "properties": {
    "created": "${dateNow}",
    "datetime": "${dateNow}",
    "updated": "${dateNow}"
  },
  "bbox": [30.155974613579858, 28.80949327971016, 31.050481437029678, 29.815791988006527],
  "assets": {
    "output": {
      "type": "text/plain",
      "roles": ["data"],
      "href": "output.txt",
      "file:size": $(stat --printf="%s" "${OUTPUT_DIR}/output.txt")
    }
  },
  "links": [{
    "type": "application/json",
    "rel": "parent",
    "href": "../catalog.json"
  }, {
    "type": "application/geo+json",
    "rel": "self",
    "href": "item.json"
  }, {
    "type": "application/json",
    "rel": "root",
    "href": "catalog.json"
  }]
}
EOF
}

main "$@"
