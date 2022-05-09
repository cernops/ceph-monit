JSONNET_FILES := $(shell find . -name 'vendor' -prune -o -name '*.jsonnet' -print -o -name '*.libsonnet')

all: lint dashboards_out alerts.yaml rules.yaml

jsonnetfmt:
	jsonnetfmt $(JFMT_ARGS) $(JSONNET_FILES)

fmt: JFMT_ARGS += -i
fmt: jsonnetfmt

lint: JFMT_ARGS += --test
lint: jsonnetfmt

dashboards_out: dashboards.jsonnet mixins.libsonnet mixins
	@mkdir -p dashboards_out
	jsonnet -J vendor -m dashboards_out dashboards.jsonnet

alerts.yaml: alerts.jsonnet mixins
	jsonnet -J vendor -S alerts.jsonnet -o $@

rules.yaml: rules.jsonnet mixins
	jsonnet -J vendor -S rules.jsonnet -o $@

.PHONY: all jsonnetfmt fmt lint
