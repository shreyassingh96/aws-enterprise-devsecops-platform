# platform-management.mk
# A Makefile to automate common platform tasks

PROJECT_NAME := devsecops
ENV := dev
AWS_REGION := us-east-1

.PHONY: init plan apply destroy eks-auth

init:
	cd infrastructure/environments/$(ENV) && terraform init

plan:
	cd infrastructure/environments/$(ENV) && terraform plan

apply:
	cd infrastructure/environments/$(ENV) && terraform apply --auto-approve

destroy:
	cd infrastructure/environments/$(ENV) && terraform destroy --auto-approve

eks-auth:
	aws eks update-kubeconfig --region $(AWS_REGION) --name $(PROJECT_NAME)-eks-$(ENV)

deploy-argocd:
	kubectl create namespace argocd || true
	kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml
	kubectl apply -f kubernetes/argocd/project.yaml
	kubectl apply -f kubernetes/argocd/application-$(ENV).yaml

get-grafana-pw:
	kubectl get secret -n monitoring grafana -o jsonpath="{.data.admin-password}" | base64 --decode ; echo
