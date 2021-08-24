# Use bash instead of sh
SHELL := /usr/bin/env bash

.PHONY: env
env:
	@source scripts/2-environments/environments.sh
