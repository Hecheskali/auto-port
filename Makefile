SHELL := /usr/bin/env bash

.PHONY: bootstrap format analyze test ci

bootstrap:
	flutter pub get

format:
	dart format lib test

analyze:
	flutter analyze

test:
	flutter test

ci:
	./tool/quality_gate.sh
