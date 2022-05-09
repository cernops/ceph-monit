# ceph-monit

This repository contains all of the grafana dashboards, prometheus rules and
alerts used by the Ceph team.

It mainly relies on [Jsonnet](https://jsonnet.org/) and [Prometheus mixins](https://monitoring.mixins.dev/)
to generate the dashboards and the Prometheus alerts/rules.

## Development

All the external Jsonnet dependencies are handled by
[jsonnet-bundler](https://github.com/jsonnet-bundler/jsonnet-bundler).

To generate the dashboards and the Prometheus rules/alerts you need to install
`jsonnet`, `jsonnet-bundler` and install the jsonnet dependencies with `jb
install`. Then you can run `make` which will generate `dashboards_out/`,
`alerts.yaml` and `rules.yaml`.

In case you want to update a dependency, you need to update `jsonnetfile.json`
and then update the lock file by invoking the jsonnet-bundler (i.e. with `jb
update`).

If you want to add a mixin you would need to add a file in
`mixins/${mixin_name}.libsonnet` where you would import the external mixin and
update the config as you want (see `mixins/node-mixin` for an example). Then you
can add the mixin in `mixins.libsonnet`.

For internal dashboards/alerts/rules related to Ceph we have our own mixin in
`mixins/cern-ceph/`, before creating anything here please check for an existing
open source mixin.

## Deployment

The dashboards are deployed with Terraform (see the `terraform/` folder) to
[monit-grafana](https://monit-grafana.cern.ch/?orgId=49) as the production
environment and [monit-grafana-dev](https://monit-grafana-dev.cern.ch/?orgId=49) as
the qa environment (deployed on every PR, state here represent the latest
pipeline run on PR/main). Dashboards should not be edited manually on
Grafana, if you want to test a dashboard please copy an existing dashboard or
create a new one.

Once they reach the main branch, alerts/rules are automatically pushed to the
ceph hostgroup in a PR(see `utils/make_mr.py`). Alerts and rules in the
hostgroup should not be edited manually.
