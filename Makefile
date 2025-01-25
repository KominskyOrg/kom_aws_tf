# Ensure TF_PROJ is set to one of the allowed options
ifeq ($(origin TF_PROJ), undefined)
    $(error TF_PROJ is not set. Please specify it as a variable when running make. Options are: eks, rds, vpc, or main. Example: make TF_PROJ=eks apply)
endif

ifneq ($(filter $(TF_PROJ),eks rds vpc main),)
    # Directory where Terraform configurations are located
    ifeq ($(TF_PROJ),main)
        TF_DIR = tf
    else
        TF_DIR = tf/$(TF_PROJ)
    endif
else
    $(error Invalid TF_PROJ value "$(TF_PROJ)". Allowed options are: eks, rds, vpc, or main. Example: make TF_PROJ=eks apply)
endif

# Default goal
.DEFAULT_GOAL := help

# Terraform commands
init: ## Initialize Terraform, install providers
	terraform -chdir=$(TF_DIR) init -var-file=secrets.tfvars

validate: ## Validate Terraform files
	terraform -chdir=$(TF_DIR) validate -var-file=secrets.tfvars

fmt: ## Format Terraform files
	terraform -chdir=$(TF_DIR) fmt -recursive

plan: ## Plan Terraform changes
	terraform -chdir=$(TF_DIR) plan -var-file=secrets.tfvars

apply: ## Apply Terraform changes
	terraform -chdir=$(TF_DIR) apply -var-file=secrets.tfvars

destroy: ## Destroy Terraform-managed infrastructure
	terraform -chdir=$(TF_DIR) destroy -var-file=secrets.tfvars

clean: ## Remove all generated files
	rm -f $(TF_PLAN_FILE)

output: ## Show Terraform outputs
	terraform -chdir=$(TF_DIR) output -var-file=secrets.tfvars

help: ## Display this help message
	@echo "Available make targets:"
	@awk 'BEGIN {FS = ":.*##"; printf "\nUsage:\n  make \033[36m<target>\033[0m\n\nTargets:\n"} /^[a-zA-Z_-]+:.*?##/ { printf "  \033[36m%-15s\033[0m %s\n", $$1, $$2 }' $(MAKEFILE_LIST)
