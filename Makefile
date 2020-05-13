SHELL := /bin/bash -o pipefail

REPO := $(shell go list -m -f '{{ .Dir }}')

GO_FILES := $(shell find $(CURDIR) -name *.go | grep -v vendor)
GO_MOD   := $(shell go list -m -f '{{ .Path }}')

GO_PKGS  := $(shell go list ./... | sed -n "s/$${GO_MOD}//g")
GO_PKG_DIRS  := $(shell "\$$GO_PKGS" | awk '{split($$0, a, "/"); print a[0]}')

default: help

.PHONY: all
all: fmt vet staticcheck test-race build install ## Runs all of the actionable make targets.

.PHONY: check-fmt
check-fmt: ## Is a check for go-related files that fail cleanliness checks.
	echo ${GO_PKG_DIRS}
	@sh -c ./scripts/check-fmt.sh

.PHONY: fmt
fmt: ## Resolves formatting issues identified by `make check-fmt`.
	@goimports -w ${GO_FILES}
	@gofmt -w -s ${GO_FILES}
	@go mod tidy

.PHONY: vet
vet: ## Runs a set of static analyses using go vet.
	@go vet {cmd,pkg}/...

.PHONY: staticcheck
staticcheck: ## Runs a set of static analyses and linters using the staticcheck tools.
	@staticcheck {cmd,pkg}/...

.PHONY: build
build: ## Builds a ${REPO} binary.
	@go build -o bin/${REPO} $(CURDIR)/cmd/${REPO}

.PHONY: install
install: ## Adds the ${REPO} binary to your $GOPATH/bin.
	@go install $(CURDIR)/cmd/${REPO}

.PHONY: test
test: ## Runs the test suit with minimal flags for quick iteration.
	@go test -v {cmd,pkg}/...

.PHONY: test-race
test-race: ## Runs the test suit with flags for verifying correctness and safety.
	@go test -v -race -count=1 {cmd,pkg}/...

.PHONY: test-coverage
test-coverage: ## Collects test coverage information.
	./scripts/test-coverage.sh --html

.PHONY: help
help: ## Prints this help menu.
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}'
