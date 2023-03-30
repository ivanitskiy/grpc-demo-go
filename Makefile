.PHONY: all proto

OUT_DIR ?= target

all: proto build

proto:  ## Compile proto
	mkdir -p gen/go
	mkdir -p gen/openapiv2
	for f in $$(find proto -maxdepth 4 -type f -name '*.proto'); do \
		$(ECHO) protoc -I  . \
		--proto_path=$$(dirname $$f)/ \
		--proto_path=$(GOPATH)/src/github.com/googleapis/googleapis  \
		--go_out ./gen/go/ --go_opt paths=source_relative \
		--go-grpc_out ./gen/go/ --go-grpc_opt paths=source_relative \
		--grpc-gateway_out ./gen/go \
		--grpc-gateway_opt logtostderr=true \
		--grpc-gateway_opt paths=source_relative \
		--grpc-gateway_opt standalone=true \
		--openapiv2_out ./gen/openapiv2 --openapiv2_opt logtostderr=true \
		$$f; done


build: ## build service
	$(ECHO) mkdir -p $(OUT_DIR)
	$(ECHO) CGO_ENABLED=0 GO111MODULE=$(GO111MODULE) go build  \
		-o $(OUT_DIR)/$(CI_PROJECT_NAME) \
		-v -ldflags=$(GOLDFLAGS) $(MAIN)

# We use the `go` and `go-grpc` plugins to generate Go types and gRPC service definitions.
# We're outputting the generated files relative to the `proto` folder, and we're using the
#  `paths=source_relative` option, which means that the generated files will appear in the
#   same directory as the source `.proto` file.
