SHELL:=/bin/sh
POETRY := $(shell command -v poetry --directory=$(ROOT_DIR) 2> /dev/null)

help:
	@fgrep -h "##" $(MAKEFILE_LIST) | fgrep -v fgrep | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}'

init: export POETRY_VIRTUALENVS_IN_PROJECT=true
init: export POETRY_VIRTUALENVS_PREFER_ACTIVE_PYTHON=true
init:  ## Set the initial project settings
	@$(MAKE) install
	@git config pull.rebase true
	@$(POETRY) self show plugins
	@$(POETRY) env info

force-init:  ## Force initialize poetry virtual environment
	@echo "removing old venv..."
	@rm -rf .venv
	@$(MAKE) init

install:  ## Install development dependencies
	@echo "installing dependencies..."
	@$(POETRY) install -v --all-extras
	@$(MAKE) export-prod-requirements
	@$(POETRY) env info
	@$(POETRY) show -o

update:  ## Update dependencies
	@echo "updating dependencies..."
	pip install --upgrade pip
	@$(POETRY) update -v
	@$(MAKE) export-prod-requirements
	@$(POETRY) show -o

export-prod-requirements:  ## Export requirements
	@echo "exporting dependencies to requirements.txt..."
	@$(POETRY) self add poetry-plugin-export
	@$(POETRY) export --without-hashes > requirements.txt
