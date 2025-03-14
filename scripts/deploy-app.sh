#!/usr/bin/env bash
set -eu

# Function to display script usage
usage() {
  echo "Usage: $0 [OPTIONS]"
  echo -e "Deploys the project code.\n"
  echo "Options:"
  echo " -r  Resource group"
  echo " -l Package path"
  echo " -n  Application name"
}

ensure_variable() {
  local value="$1"
  local message="$2"
  if [ -z "${value}" ]; then
    printf "\n"
    echo -e "\e[31m${message}\e[0m" >&2
    printf "\n"
    usage
    exit 1
  fi
}

main() {
  # Default variable values
  local resource_group=""
  local web_app_name=""
  local package_path=""

  while getopts ":r:l:n:" option; do
    case $option in
      n)
        web_app_name="${OPTARG}"
        ;;
      l)
        package_path="${OPTARG}"
        ;;
      r)
        resource_group="${OPTARG}"
        ;;
      *)
        if [ -n "${OPTARG}" ]; then
          echo "Unknown argument: $OPTARG"
        fi
        usage
        exit 1
        ;;
    esac
  done
  
  ensure_variable "${resource_group}" "Resource group is required"
  ensure_variable "${app_service_name}" "App service name is required"
  
  az webapp deployment source config-zip --resource-group "${resource_group}" \
            --name "${app_service_name}" \
            --src "${package_path}"
}

main "$@"