.PHONY: all dev staging prod clean

AWS_REGION := us-east-1

all: dev staging prod

dev:
	@echo "--- Deploying to DEV ---"
	terraform -chdir=./terraform/environments/dev init
	terraform -chdir=./terraform/environments/dev plan -var="environment_name=dev" -var="region=$(AWS_REGION)"
	terraform -chdir=./terraform/environments/dev apply -auto-approve -var="environment_name=dev" -var="region=$(AWS_REGION)"

staging:
	@echo "--- Deploying to STAGING ---"
	terraform -chdir=./terraform/environments/staging init
	terraform -chdir=./terraform/environments/staging plan -var="environment_name=staging" -var="region=$(AWS_REGION)"
	terraform -chdir=./terraform/environments/staging apply -auto-approve -var="environment_name=staging" -var="region=$(AWS_REGION)"

prod:
	@echo "--- Deploying to PROD (Blue/Green) ---"
	terraform -chdir=./terraform/environments/prod init
	terraform -chdir=./terraform/environments/prod plan -var="environment_name=prod" -var="region=$(AWS_REGION)"
	terraform -chdir=./terraform/environments/prod apply -auto-approve -var="environment_name=prod" -var="region=$(AWS_REGION)"

clean:
	@echo "--- Destroying all environments ---"
	terraform -chdir=./terraform/environments/dev destroy -auto-approve
	terraform -chdir=./terraform/environments/staging destroy -auto-approve
	terraform -chdir=./terraform/environments/prod destroy -auto-approve