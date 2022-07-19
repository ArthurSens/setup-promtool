#!/bin/bash

function parseInputs {
  promtoolVersion="latest"
  if [ "${INPUT_PROMTOOL_ACTIONS_VERSION}" != "" ] || [ "${INPUT_PROMTOOL_ACTIONS_VERSION}" != "latest" ]; then
    promtoolVersion=${INPUT_PROMTOOL_ACTIONS_VERSION}
  fi
}


function installPromtool {
  if [[ "${promtoolVersion}" == "latest" || "${promtoolVersion}" == "" ]]; then
    echo "Checking the latest version of Promtool"
    promtoolVersion=$(git ls-remote --tags --refs --sort="v:refname"  https://github.com/prometheus/prometheus | grep -v '[-].*' | tail -n1 | sed 's/.*\///' | cut -c 2-)
    if [[ -z "${promtoolVersion}" ]]; then
      echo "Failed to fetch the latest version"
      exit 1
    fi
  fi

  
  url="https://github.com/prometheus/prometheus/releases/download/v${promtoolVersion}/prometheus-${promtoolVersion}.linux-amd64.tar.gz"

  echo "Downloading Promtool v${promtoolVersion}"
  curl -s -S -L -o /tmp/promtool_${promtoolVersion} ${url}
  if [ "${?}" -ne 0 ]; then
    echo "Failed to download Promtool v${promtoolVersion}"
    exit 1
  fi
  echo "Successfully downloaded Promtool v${promtoolVersion}"

  echo "Unzipping Promtool v${promtoolVersion}"
  tar -zxf /tmp/promtool_${promtoolVersion} --strip-components=1 --directory /usr/local/bin &> /dev/null
  if [ "${?}" -ne 0 ]; then
    echo "Failed to unzip Promtool v${promtoolVersion}"
    exit 1
  fi
  echo "Successfully unzipped Promtool v${promtoolVersion}"
}

function main {
  # Source the other files to gain access to their functions
  scriptDir=$(dirname ${0})

  parseInputs
  cd ${GITHUB_WORKSPACE}

  installPromtool
}

main "${*}"