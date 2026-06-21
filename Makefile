.DEFAULT_GOAL := help

.PHONY: help install uninstall docker-build docker-run docker-sandbox docker-clean

help: ## Show this help message
	@echo "================================================================="
	@echo "  Dotfiles Management CLI"
	@echo "================================================================="
	@echo "Usage: make [target]"
	@echo ""
	@echo "Targets:"
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "  \033[36m%-15s\033[0m %s\n", $$1, $$2}'
	@echo "================================================================="

install: ## Run the dotfiles installer on your host machine
	./install.sh

uninstall: ## Run the dotfiles uninstaller on your host machine
	./uninstall.sh

docker-build: ## Build the Docker sandbox image
	docker build -t dotfiles-sandbox .

docker-run: ## Run the Docker sandbox container interactively
	docker run -it --rm dotfiles-sandbox

# Path to mount inside the container (defaults to current directory)
# Example: make docker-sandbox path=~/projects/my-app
path ?= $(shell pwd)

docker-sandbox: ## Clean-build and run the Docker sandbox (use path=/dir to mount host files)
	./docker-sandbox.sh "$(path)"

docker-clean: ## Clean up Docker sandbox images
	docker rmi dotfiles-sandbox || true
