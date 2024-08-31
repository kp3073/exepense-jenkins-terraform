dev:
	rm -rf .terraform
	terraform init -backend-config=env-dev/state.tfvars
	terraform apply -auto-approve -var-file=env-dev/input.tfvars

prode:
	rm -rf .terraform
	terraform init -reconfigure -backend-config=env-prode/state.tfvars
	terraform apply -auto-approve -var-file=env-prode/input.tfvars

dev-destroy:
	rm -rf .terraform
	terraform init  -backend-config=env-dev/state.tfvars
	terraform destroy -auto-approve -var-file=env-dev/input.tfvars

prode-destroy:
	rm -rf .terraform
	terraform init -backend-config=env-prode/state.tfvars
	terraform destroy -auto-approve -var-file=env-prode/input.tfvars