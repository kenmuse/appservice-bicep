ARG VARIANT="6.0-bullseye-slim"
FROM mcr.microsoft.com/vscode/devcontainers/dotnet:0-${VARIANT}

ARG BICEP_VERSION=latest
ARG POWERSHELL_VERSION=7.2.6
ARG TARGETARCH

# Install PowerShell and  Azure CLI [requires elevated permissions]
RUN dotnet tool install -g powershell --version $POWERSHELL_VERSION \
 && curl -sL https://aka.ms/InstallAzureCLIDeb | bash

RUN if ["${TARGETARCH}" = "amd64" ]; then \
    { \
        curl -Lo /tmp/bicep https://github.com/Azure/bicep/releases/${BICEP_VERSION}/download/bicep-linux-x64;\
        chmod +x /tmp/bicep; \
        mv /tmp/bicep /usr/local/bin/bicep; \
    }\ 
    else \
    { \
        curl -Lo /tmp/bicep https://github.com/Azure/bicep/releases/${BICEP_VERSION}/download/bicep-linux-arm64;\
        chmod +x /tmp/bicep; \
        mv /tmp/bicep /usr/local/bin/bicep; \
    } \
    fi
