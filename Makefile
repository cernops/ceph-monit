JSONNET_FILES := $(shell find . -name 'vendor' -prune -o -name '*.jsonnet' -print -o -name '*.libsonnet' -print)

all: lint dashboards_out alerts.yaml rules.yaml

jsonnetfmt:
	jsonnetfmt $(JFMT_ARGS) $(JSONNET_FILES)

fmt: JFMT_ARGS += -i
fmt: jsonnetfmt

lint: JFMT_ARGS += --test
lint: jsonnetfmt

dashboards_out: $(JSONNET_FILES) jsonnetfile.lock.json
	@mkdir -p dashboards_out
	jsonnet -J vendor -m dashboards_out dashboards.jsonnet

alerts.yaml: alerts.jsonnet mixins
	jsonnet -J vendor -S alerts.jsonnet -o $@

rules.yaml: rules.jsonnet mixins
	jsonnet -J vendor -S rules.jsonnet -o $@

lint-dashboards: dashboards_out
	for file in dashboards_out/*.json ; do \
		dashboard-linter lint $${file} ; \
	done

clean:
	$(RM) alerts.yaml rules.yaml
	$(RM) dashboards_out/*.json

.PHONY: all jsonnetfmt fmt lint lint-dashboards clean
