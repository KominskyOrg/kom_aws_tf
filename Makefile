###############################################################################
# Variables
###############################################################################

# Default values
REPO_NAME         := kom_aws_tf
INFRA_ENV         ?= dev
ORG               ?= kominskyorg
REGION            ?= us-east-1

# Ensure TF_PROJ is set and valid
VALID_TF_PROJS := eks rds vpc main

ifeq ($(origin TF_PROJ), undefined)
  $(error TF_PROJ is not set. Please specify: make TF_PROJ=<eks|rds|vpc|main> <target>)
endif

ifneq ($(filter $(TF_PROJ),$(VALID_TF_PROJS)),)
  ifeq ($(TF_PROJ),main)
    TF_DIR                  := tf
	TF_STATE_KEY            := $(REPO_NAME)/$(TF_PROJ)/terraform_state.tfstate
	TF_STATE_BUCKET         ?= tf-statelock
	TF_STATE_REGION         ?= $(REGION)
	TF_STATE_DYNAMODB_TABLE ?= tf-state-table
  else
	TF_DIR                  := tf/$(TF_PROJ)
	TF_STATE_KEY            := $(REPO_NAME)/$(TF_PROJ)/$(INFRA_ENV)/terraform_state.tfstate
	TF_STATE_BUCKET         ?= $(ORG)-$(INFRA_ENV)-tf-state
	TF_STATE_REGION         ?= $(REGION)
	TF_STATE_DYNAMODB_TABLE ?= tf-state-lock-$(INFRA_ENV)
  endif
else
  $(error Invalid TF_PROJ value "$(TF_PROJ)". Valid options: $(VALID_TF_PROJS))
endif

TF_VARS           := -var-file="secrets.tfvars"
DEFAULT_TF_VARS   := -var="infra_env=$(INFRA_ENV)" -var="org=$(ORG)" -var="region=$(REGION)"
BACKEND_TF_VARS   := \
  --backend-config="bucket=$(TF_STATE_BUCKET)" \
  --backend-config="key=$(TF_STATE_KEY)" \
  --backend-config="region=$(REGION)" \
  --backend-config="dynamodb_table=$(TF_STATE_DYNAMODB_TABLE)" \
  --backend-config="encrypt=true"

# Combine commonly used Terraform arguments into a single variable
TF_COMMON_ARGS    := $(TF_VARS) $(DEFAULT_TF_VARS) $(ARGS)

###############################################################################
# Targets
###############################################################################

# Make targets are phony (they're not associated with real files)
.PHONY: init validate fmt plan apply destroy list clean output help

# Default goal
.DEFAULT_GOAL := help

init: ## Initialize Terraform, install providers
	terraform -chdir=$(TF_DIR) init $(TF_COMMON_ARGS) $(BACKEND_TF_VARS)

validate: ## Validate Terraform files
	terraform -chdir=$(TF_DIR) validate $(TF_COMMON_ARGS)

fmt: ## Format Terraform files
	terraform -chdir=$(TF_DIR) fmt -recursive

plan: ## Plan Terraform changes
	terraform -chdir=$(TF_DIR) plan $(TF_COMMON_ARGS)

apply: ## Apply Terraform changes
	terraform -chdir=$(TF_DIR) apply $(TF_COMMON_ARGS)

destroy: ## Destroy Terraform-managed infrastructure
	terraform -chdir=$(TF_DIR) destroy $(TF_COMMON_ARGS)

list: ## List Terraform resources
	terraform -chdir=$(TF_DIR) state list

clean: ## Remove all generated files
	rm -f $(TF_PLAN_FILE)

output: ## Show Terraform outputs
	terraform -chdir=$(TF_DIR) output $(TF_COMMON_ARGS)

help: ## Display this help message
	@echo "Usage:"
	@echo "  make <target> [TF_PROJ=<eks|rds|vpc|main>] [INFRA_ENV=<INFRA_ENV>] [ORG=<org>] [REGION=<region>]"
	@echo
	@echo "Targets:"
	@awk 'BEGIN {FS = ":.*?##"} /^[a-zA-Z_-]+:.*?##/ \
		{ printf "  \033[36m%-15s\033[0m %s\n", $$1, $$2 }' $(MAKEFILE_LIST)
