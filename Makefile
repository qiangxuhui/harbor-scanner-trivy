SOURCES := $(shell find . -name '*.go')
BINARY := scanner-trivy
IMAGE_TAG := dev
IMAGE := aquasec/harbor-scanner-trivy:$(IMAGE_TAG)

build: $(BINARY)

test: build
	GO111MODULE=on go test -v -short -race -coverprofile=coverage.txt -covermode=atomic ./...

.PHONY: test-integration
test-integration: build
	GO111MODULE=on go test -count=1 -v -tags=integration ./test/integration/...

.PHONY: test-component
test-component: docker-build
	GO111MODULE=on go test -count=1 -v -tags=component ./test/component/...

$(BINARY): $(SOURCES)
	GOOS=linux GO111MODULE=on CGO_ENABLED=0 go build -o $(BINARY) cmd/scanner-trivy/main.go

.PHONY: docker-build
docker-build: build
	docker build --no-cache -t $(IMAGE) .

loong64-docker-build:
	docker build \
		--build-arg http_proxy=http://10.130.0.20:7890 \
		--build-arg https_proxy=http://10.130.0.20:7890 \
	       	--no-cache \
		-f Dockerfile.loong64 \
		-t cr.loongnix.cn/qxh_deploy/scanner-trivy:0.18 \
		.

lint:
	./bin/golangci-lint --build-tags component,integration run -v

.PHONY: setup
setup:
	curl -sfL https://raw.githubusercontent.com/golangci/golangci-lint/master/install.sh| sh -s v1.21.0

run: 
	docker run -d -p 8080:8080 --name trivy_deploy --hostname trivy_deploy -v /var/run/docker.sock:/var/run/docker.sock cr.loongnix.cn/qxh_deploy/scanner-trivy:0.18
