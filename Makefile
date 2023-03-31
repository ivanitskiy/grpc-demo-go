.PHONY: all proto clean generate build

PROJECT_NAME			?= grpc-demo-go
OUT_DIR			   		?= target
PBGEN					 = pbgen
GWGEN					 = gwgen
GEN					 	 = gen
OPENAPI_GEN				 = $(GEN)/openapiv2
SCHEMAS					 = schema
GOOGLEAPIS_PATH	   		?= $(GOPATH)/src/github.com/googleapis/googleapis
PROTOC_GEN_VALIDATE   	?= $(GOPATH)/src/github.com/bufbuild/protoc-gen-validate
PROTO_FILES				 = $$(find $(SCHEMAS) -maxdepth 4 -type f -name '*.proto')
MAIN				 	 = main.go

all: help

debug:
	@echo "OUT_DIR: 			$(OUT_DIR)"
	@echo "PBGEN:			 	$(PBGEN)"
	@echo "GEN: 				$(GEN)"
	@echo "GWGEN: 				$(GWGEN)"
	@echo "OPENAPI_GEN: 		$(OPENAPI_GEN)"
	@echo "SCHEMAS: 			$(SCHEMAS)"
	@echo "GOOGLEAPIS_PATH:		$(GOOGLEAPIS_PATH)"
	@echo "PROTOC_GEN_VALIDATE: $(PROTOC_GEN_VALIDATE)"
	@echo "PROTO_FILES: 		$(PROTO_FILES)"

clean:  ## Clean worspace
	@rm -fr $(GEN)
	@rm -fr $(PBGEN)
	@rm -fr $(OPENAPI_GEN)
	@rm -fr $(OUT_DIR)

proto: ## Compile using protoc
	@mkdir -p $(PBGEN)
	@mkdir -p $(OPENAPI_GEN)
	protoc -I  . \
		--proto_path=$(SCHEMAS)/ \
		--proto_path=$(PROTOC_GEN_VALIDATE)/ \
		--proto_path=$(GOOGLEAPIS_PATH)  \
		--go_out $(PBGEN) \
		--go_opt paths=source_relative \
		--go-grpc_out $(PBGEN) \
		--go-grpc_opt paths=source_relative \
		--grpc-gateway_out $(GWGEN) \
		--grpc-gateway_opt logtostderr=true \
		--grpc-gateway_opt paths=source_relative \
		--grpc-gateway_opt standalone=true \
		--openapiv2_out $(OPENAPI_GEN) \
		--openapiv2_opt logtostderr=true \
		--validate_out="lang=go,paths=source_relative:$(PBGEN)" \
		$(PROTO_FILES)

buf-generate: ## Compile using bug generate
	buf generate

build:  clean buf-generate ## Build service
	@mkdir -p $(OUT_DIR)
	$(ECHO) CGO_ENABLED=0 go build  \
		-o $(OUT_DIR)/$(PROJECT_NAME) \
		-v  $(MAIN)

api-linter:  ## Run google api linter
	$(ECHO) api-linter -I $(SCHEMAS) -I $(PROTOC_GEN_VALIDATE) -I $(GOOGLEAPIS_PATH)\
		--output-format yaml \
		 --disable-rule core::0191::java-package \
		$(PROTO_FILES)

buf-lint: ## Run bug lint
	buf lint

help: ## Display this help screen
	@grep -h -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}'
