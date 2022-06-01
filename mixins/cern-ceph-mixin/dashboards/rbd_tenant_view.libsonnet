local utils = import 'mixin-utils/utils.libsonnet';
local filename = 'rbd_tenant_view.json';

(import 'dashboard-utils.libsonnet') {
  [filename]:
    ($.dashboard('RBD Tenant View') + { uid: std.md5(filename), tags: [$._config.tag, 'rbd'] })
    .addQueryTemplate('cluster', 'ceph_osd_metadata, cluster', isQuery=false)
    .addQueryTemplate('tenant', 'openstack_cinder_volume, tenant_name', includeAll=false, isQuery=false)

    .addRow(
      $.row('r/w bytes')
      .addPanel(
        $.panel('Volume Read Bytes') +
        $.queryPanel(
          |||
            openstack_cinder_volume{tenant_name=~"$tenant"} *
              on(image) group_left
                rate(ceph_rbd_read_bytes{cluster=~"$cluster"}[$__rate_interval])
          |||, '{{name}}', unit='binBps'
        )
      )
      .addPanel(
        $.panel('Volume Write Bytes') +
        $.queryPanel(
          |||
            openstack_cinder_volume{tenant_name=~"$tenant"} *
              on(image) group_left
                rate(ceph_rbd_write_bytes{cluster=~"$cluster"}[$__rate_interval])
          |||, '{{name}}', unit='binBps'
        )
      )
    )
    .addRow(
      $.row('r/w IOPS')
      .addPanel(
        $.panel('Volume Read IOPS') +
        $.queryPanel(
          |||
            openstack_cinder_volume{tenant_name=~"$tenant"} *
              on(image) group_left
                rate(ceph_rbd_read_ops{cluster=~"$cluster"}[$__rate_interval])
          |||, '{{name}}', unit='iops'
        )
      )
      .addPanel(
        $.panel('Volume Write IOPS') +
        $.queryPanel(
          |||
            openstack_cinder_volume{tenant_name=~"$tenant"} *
              on(image) group_left
                rate(ceph_rbd_write_ops{cluster=~"$cluster"}[$__rate_interval])
          |||, '{{name}}', unit='iops'
        )
      )
    )
    .addRow(
      $.row('r/w latency')
      .addPanel(
        $.panel('Volume Read Latency') +
        $.queryPanel(
          |||
            openstack_cinder_volume{tenant_name=~"$tenant"} *
              on(image) group_left
                ceph_rbd_read_latency{cluster=~"$cluster"}
          |||, '{{name}}', unit='ns'
        )
      )
      .addPanel(
        $.panel('Volume Write Latency') +
        $.queryPanel(
          |||
            openstack_cinder_volume{tenant_name=~"$tenant"} *
              on(image) group_left
                ceph_rbd_write_latency{cluster=~"$cluster"}
          |||, '{{name}}', unit='ns'
        )
      )
    ),
}
