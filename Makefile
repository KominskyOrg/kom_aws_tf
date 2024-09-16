# Directory where Terraform configurations are located
TF_DIR = tf

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
