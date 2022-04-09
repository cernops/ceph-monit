JSONNET_FILES := $(shell find . -name 'vendor' -prune -o -name '*.jsonnet' -print -o -name '*.libsonnet')

all: lint dashboards_out

jsonnetfmt:
	jsonnetfmt $(JFMT_ARGS) $(JSONNET_FILES)

fmt: JFMT_ARGS += -i
fmt: jsonnetfmt

lint: JFMT_ARGS += --test
lint: jsonnetfmt

dashboards_out: dashboards.jsonnet mixins.libsonnet mixins
	@mkdir -p dashboards_out
	jsonnet -J vendor -m dashboards_out dashboards.jsonnet

.PHONY: all jsonnetfmt fmt lint
