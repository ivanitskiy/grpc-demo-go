.PHONY: all proto clean

OUT_DIR			   		?= target
PBGEN					 = pbgen
GEN					 	 = gen
OPENAPI_GEN				 = $(GEN)/openapiv2
SCHEMAS					 = schema
GOOGLEAPIS_PATH	   		?= $(GOPATH)/src/github.com/googleapis/googleapis
PROTOC_GEN_VALIDATE   	?= $(GOPATH)/src/github.com/bufbuild/protoc-gen-validate
PROTO_FILES				 = $$(find $(SCHEMAS) -maxdepth 4 -type f -name '*.proto')

debug:
	@echo "OUT_DIR: $(OUT_DIR)"
	@echo "PBGEN: $(PBGEN)"
	@echo "GEN: $(GEN)"
	@echo "OPENAPI_GEN: $(OPENAPI_GEN)"
	@echo "SCHEMAS: $(SCHEMAS)"
	@echo "GOOGLEAPIS_PATH: $(GOOGLEAPIS_PATH)"
	@echo "PROTOC_GEN_VALIDATE: $(PROTOC_GEN_VALIDATE)"
	@echo "PROTO_FILE: $(PROTO_FILE)"

clean:  ## clean worspace
	@rm -fr $(GEN)
	@rm -fr $(PBGEN)
	@rm -fr $(OPENAPI_GEN)

proto: ## Compile proto
	@mkdir -p $(PBGEN)
	@mkdir -p $(OPENAPI_GEN)
	protoc -I  . \
		--proto_path=$(SCHEMAS)/ \
		--proto_path=$(PROTOC_GEN_VALIDATE)/ \
		--proto_path=$(GOPATH)/src/github.com/googleapis/googleapis  \
		--go_out $(PBGEN) --go_opt paths=source_relative \
		--go-grpc_out $(PBGEN) --go-grpc_opt paths=source_relative \
		--grpc-gateway_out $(PBGEN) \
		--grpc-gateway_opt logtostderr=true \
		--grpc-gateway_opt paths=source_relative \
		--grpc-gateway_opt standalone=true \
		--openapiv2_out $(OPENAPI_GEN) --openapiv2_opt logtostderr=true \
		--validate_out="lang=go,paths=source_relative:$(PBGEN)" \
		$(PROTO_FILES)

build: ## build service
	$(ECHO) mkdir -p $(OUT_DIR)
	$(ECHO) CGO_ENABLED=0 GO111MODULE=$(GO111MODULE) go build  \
		-o $(OUT_DIR)/$(CI_PROJECT_NAME) \
		-v -ldflags=$(GOLDFLAGS) $(MAIN)
