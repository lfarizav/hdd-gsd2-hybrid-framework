# Makefile for Heritage Project

# Go packages — exclude node_modules which may contain third-party Go files
GO_PKGS := $(shell go list ./cmd/... ./internal/... ./tests/... 2>/dev/null)

.PHONY: help gsd-next gsd-manual test lint build cover clean

help:
	@echo "Heritage Kind Cluster Provisioner"
	@echo ""
	@echo "GSD-2 Manual Execution:"
	@echo "  make gsd-next        Run next GSD task (reads ROADMAP, guides execution)"
	@echo "  make gsd-manual      Alias for gsd-next"
	@echo ""
	@echo "Go Development:"
	@echo "  make test            Run all tests with coverage report"
	@echo "  make cover           Show coverage report in browser"
	@echo "  make lint            Run golangci-lint checks"
	@echo "  make build           Build kind-cluster binary"
	@echo "  make format          Format code (gofmt + goimports)"
	@echo "  make vet             Run go vet"
	@echo "  make clean           Clean build artifacts"
	@echo ""
	@echo "Documentation:"
	@echo "  make docs            Open HYBRID_FRAMEWORK_COMPLETE_GUIDE.md"

# GSD-2 Manual Execution Targets
gsd-next: 
	@bash gsd-manual

gsd-manual: 
	@bash gsd-manual

# Go Development Targets
test:
	@echo "Running tests..."
	@go test -coverprofile=coverage.out $(GO_PKGS)
	@echo ""
	@echo "Coverage Summary:"
	@go tool cover -func=coverage.out | tail -1

cover: test
	@go tool cover -html=coverage.out -o /tmp/coverage.html
	@echo "Coverage report: /tmp/coverage.html"

lint:
	@echo "Running linters..."
	@golangci-lint run $(GO_PKGS)
	@go vet $(GO_PKGS)

build:
	@echo "Building heritage CLI..."
	@go build -o heritage ./cmd/kind-cluster
	@echo "Binary: ./heritage"

format:
	@echo "Formatting code..."
	@gofmt -w .
	@goimports -w .
	@echo "Done"

vet:
	@go vet $(GO_PKGS)

clean:
	@rm -f heritage coverage.out /tmp/coverage.html
	@go clean

docs:
	@command -v code >/dev/null && code docs/HYBRID_FRAMEWORK_COMPLETE_GUIDE.md || cat docs/HYBRID_FRAMEWORK_COMPLETE_GUIDE.md | head -50

# Default target
.DEFAULT_GOAL := help
