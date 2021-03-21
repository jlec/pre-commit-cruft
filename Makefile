PIPENV := pipenv run

.PHONY: help

help:
	@echo "Make targets:\n"
	@$(MAKE) -pRrq -f $(lastword $(MAKEFILE_LIST)) : 2>/dev/null | awk -v RS= -F: '/^# File/,/^# Finished Make data base/ {if ($$1 !~ "^[#.]") {print $$1}}' | sort | egrep -v -e '^[^[:alnum:]]' -e '^$@$$'

################################################################################
#
# Environment Setup
#
################################################################################
.PHONY: setup setup-dev

Pipfile.lock: Pipfile
	pipenv lock

setup.done: Pipfile.lock
	pipenv sync
	$(PIPENV) pre-commit install
	$(PIPENV) pre-commit install --install-hooks
	touch setup.done

setup-dev.done: Pipfile.lock setup.done
	pipenv sync --dev
	touch setup-dev.done

setup: setup.done
setup-dev: setup-dev.done

################################################################################
#
# Release management
#
################################################################################
.PHONY: publish release release-major release-micro

release: setup-dev.done
	$(PIPENV) bumpversion --verbose minor

release-major: setup-dev.done
	$(PIPENV) bumpversion --verbose major

release-micro: setup-dev.done
	$(PIPENV) bumpversion --verbose patch

publish:
	git push -v --progress
	git push -v --progress --tags

################################################################################
#
# Checking and Linting
#
################################################################################
.PHONY: check lint linting

check: lint

pre-commit:
	$(PIPENV) pre-commit run --all-files

lint: linting
linting: pre-commit

################################################################################
#
# Custom options
#
################################################################################
.PHONY: clean

clean:
	rm -rvf tmp
