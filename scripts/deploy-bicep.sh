#!/usr/bin/env bash
set -eu

# Function to display script usage
usage() {
  echo "Usage: $0 [OPTIONS]"
  echo -e "Deploys the project infrastructure using Bicep.\n"
  echo "Options:"
  echo " -r  Resource group"
  echo " -l  Resource group location"
  echo " -n  Web app name"
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
  local resource_group_location=""
  local web_app_name=""

  while getopts ":r:l:n:" option; do
    case $option in
      n)
        web_app_name="${OPTARG}"
        ;;
      l)
        resource_group_location="${OPTARG}"
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
  
  ensure_variable "${resource_group}" "Resource! group is required"
  ensure_variable "${resource_group_location}" "Resource group location is required"
  ensure_variable "${web_app_name}" "Web app name is required"
  
  if [ $(az group exists --name "${resource_group}") = false ]; then
    az group create --name "${resource_group}" --location "${resource_group_location}"
  fi

  RESULTS=$(az deployment group create \
            --resource-group "${resource_group}" \
            --query "properties.outputs" \
            --template-file "./infra/main.bicep" \
            --parameters webAppName="${web_app_name}" \
            isLinuxDeploy=true \
            sku=B1)

  APPSERVICENAME="$(echo $RESULTS | jq -r '.appServiceName.value' )"
  APPSERVICEHOST="$(echo $RESULTS | jq -r '.appServiceHost.value' )"

  if [ -n "${GITHUB_OUTPUT:=}" ]; then
    echo "appServiceName=$APPSERVICENAME" >> $GITHUB_OUTPUT
    echo "appServiceHost=$APPSERVICEHOST" >> $GITHUB_OUTPUT
  else
     jq -cn --arg SERVICE $APPSERVICENAME --arg HOST $APPSERVICEHOST '{appServiceName: $SERVICE, appServiceHost: $HOST}'
  fi
}

main "$@"