# Copyright 2021 Amazon.com, Inc. or its affiliates. All Rights Reserved.
# Permission is hereby granted, free of charge, to any person obtaining a copy of this
# software and associated documentation files (the "Software"), to deal in the Software
# without restriction, including without limitation the rights to use, copy, modify,
# merge, publish, distribute, sublicense, and/or sell copies of the Software, and to
# permit persons to whom the Software is furnished to do so.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED,
# INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A
# PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT
# HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION
# OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE
# SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

ifeq ($(OS),Windows_NT)
SHELL := powershell.exe
.SHELLFLAGS := -NoProfile -ExecutionPolicy Bypass -Command

RED :=
GRE :=
NC :=

version  ?= "1.0.10"
os       ?= windows

ifeq ($(PROCESSOR_ARCHITECTURE),AMD64)
  arch   ?= "amd64"
endif
ifeq ($(PROCESSOR_ARCHITECTURE),x86)
  arch   ?= "386"
endif
ifeq ($(PROCESSOR_ARCHITECTURE),ARM64)
  arch   ?= "arm64"
endif

TERRAFORM := $(shell Get-Command terraform -ErrorAction SilentlyContinue | Select-Object -ExpandProperty Source)
USER_HOME_DIRECTORY := $(USERPROFILE)
TERRAFORM_VERSION := $(shell terraform --version 2>$$null | Select-Object -First 1)
else
SHELL := /usr/bin/env bash

# COLORS
RED=$(shell echo -e "\033[0;31m")
GRE=$(shell echo -e "\033[0;32m")
NC=$(shell echo -e "\033[0m")

# TERRAFORM INSTALL
version  ?= "1.0.10"
os       ?= $(shell uname|tr A-Z a-z)
ifeq ($(shell uname -m),x86_64)
  arch   ?= "amd64"
endif
ifeq ($(shell uname -m),i686)
  arch   ?= "386"
endif
ifeq ($(shell uname -m),aarch64)
  arch   ?= "arm"
endif

# CHECK TERRAFORM VERSION
TERRAFORM := $(shell command -v terraform 2> /dev/null)
USER_HOME_DIRECTORY := $(HOME)
TERRAFORM_VERSION := $(shell terraform --version 2> /dev/null)
REGION := $(shell sed -n 's/^[[:space:]]*aws_region[[:space:]]*=[[:space:]]*"\([^"]*\)".*/\1/p' terraform/terraform.tfvars 2>/dev/null)
endif

all: local plan apply git-private configure-auth upload configure-external-dns configure-keycloak destroy clean
	@echo "$(GRE) INFO: Applying all options"

.PHONY: apply clean destroy configure-auth plan upload
local:
	@terraform --version
ifdef TERRAFORM
	@echo "$(GRE) INFO: The local Terraform version is $(TERRAFORM_VERSION)"
else
	@echo "$(RED) ERROR: Terraform is not installed"
endif

clean:
	@echo "$(RED) INFO: Removing local Terraform generated files"
ifeq ($(OS),Windows_NT)
	@if (Test-Path .terraform) { Remove-Item -Recurse -Force .terraform }
	@if (Test-Path .terraform.lock.hcl) { Remove-Item -Force .terraform.lock.hcl }
	@if (Test-Path terraform.tfstate) { Remove-Item -Force terraform.tfstate }
	@if (Test-Path terraform.tfstate.backup) { Remove-Item -Force terraform.tfstate.backup }
else
	@rm -rf .terraform* terraform.tfs*
endif

plan:
	@echo "$(GRE) INFO: Initialize the working directory and planning"
ifeq ($(OS),Windows_NT)
	@Set-Location terraform; terraform init -reconfigure; terraform fmt -recursive; terraform validate; terraform plan
else
	cd terraform/ && \
	terraform init -reconfigure && \
	terraform fmt -recursive && \
	terraform validate && \
	terraform plan
endif

apply:
	@echo "$(GRE) INFO: Applying planned resources"
ifeq ($(OS),Windows_NT)
	@Set-Location terraform; terraform init -reconfigure; terraform validate; terraform apply --% -var-file=terraform.tfvars -auto-approve
else
	( \
		cd terraform && \
		terraform init -reconfigure && \
		terraform validate && \
		terraform apply -var-file=terraform.tfvars -auto-approve \
	)
endif

update-kube-config:
	@echo "$(GRE) INFO: Configuring Kube config."
ifeq ($(OS),Windows_NT)
	@$$regionMatch = Select-String -Path terraform\\terraform.tfvars -Pattern '^\s*aws_region\s*=\s*"([^"]+)"'; $$region = if ($$regionMatch) { $$regionMatch.Matches[0].Groups[1].Value } else { aws configure get region }; aws eks update-kubeconfig --name keycloak-demo --region "$$region"
else
	set -ex
	aws eks update-kubeconfig --name keycloak-demo --region $(REGION)
endif

deploy-keycloak:
	@echo "$(GRE) INFO: Deploying Keycloak to EKS."
ifeq ($(OS),Windows_NT)
	@Set-Location terraform; kubectl apply -f manifest/keycloak.yml
else
	set -ex
	cd terraform/ && \
	kubectl apply -f manifest/keycloak.yml
endif

destroy:
	@echo "$(RED) INFO: Removing all Terraform created resources"
ifeq ($(OS),Windows_NT)
	@Set-Location terraform; kubectl delete -f manifest/keycloak.yml --ignore-not-found=true; terraform init -reconfigure; terraform validate; terraform destroy --% -var-file=terraform.tfvars -auto-approve
else
	set -ex
	(\
		cd terraform/ && \
		kubectl delete -f manifest/keycloak.yml --ignore-not-found=true && \
		terraform init -reconfigure && \
		terraform validate && \
		terraform destroy -var-file=terraform.tfvars -auto-approve \
	)
endif
