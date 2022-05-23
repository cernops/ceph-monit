local utils = import 'mixin-utils/utils.libsonnet';
local filename = 'top_rbd_tenants.json';

(import 'dashboard-utils.libsonnet') {
  [filename]:
    local prefix = 'topk($top, sum by(tenant_id) (openstack_cinder_volume * on(image) group_left sum by (image)';
    local regex = '/.*tenant_id="([^"]*).*/';
    ($.dashboard('RBD Top Tenants') + { uid: std.md5(filename), tags: [$._config.tag, 'rbd'] })
    .addCustomTemplate('top', ['5'], type='textbox')
    .addQueryTemplate('pool', 'ceph_rbd_read_bytes, pool', isQuery=false)
    .addQueryTemplate('cluster', 'ceph_osd_metadata, cluster', includeAll=false, isQuery=false)
    .addQueryTemplate('topreadbytes', '%(prefix)s (avg_over_time(ceph_rbd_read_bytes{cluster="$cluster"}[${__range_s}s] @ end()))))' % prefix, regex=regex, hide=2, refresh=2)
    .addQueryTemplate('topwritebytes', '%(prefix)s (avg_over_time(ceph_rbd_write_bytes{cluster="$cluster"}[${__range_s}s] @ end()))))' % prefix, regex=regex, hide=2, refresh=2)
    .addQueryTemplate('topreadiops', '%(prefix)s (avg_over_time(ceph_rbd_read_ops{cluster="$cluster"}[${__range_s}s] @ end()))))' % prefix, regex=regex, hide=2, refresh=2)
    .addQueryTemplate('topwriteiops', '%(prefix)s (avg_over_time(ceph_rbd_write_ops{cluster="$cluster"}[${__range_s}s] @ end()))))' % prefix, regex=regex, hide=2, refresh=2)
    .addQueryTemplate('topreadlatency', '%(prefix)s (avg_over_time(ceph_rbd_read_latency{cluster="$cluster"}[${__range_s}s] @ end()))))' % prefix, regex=regex, hide=2, refresh=2)
    .addQueryTemplate('topwritelatency', '%(prefix)s (avg_over_time(ceph_rbd_write_latency{cluster="$cluster"}[${__range_s}s] @ end()))))' % prefix, regex=regex, hide=2, refresh=2)
    .addQueryTemplate('topcombinedbytes', '%(prefix)s ((avg_over_time(ceph_rbd_write_bytes{cluster="$cluster"}[${__range_s}s] @ end())) + (avg_over_time(ceph_rbd_read_bytes{cluster="$cluster"}[${__range_s}s] @ end())))))' % prefix, regex=regex, hide=2, refresh=2)
    .addQueryTemplate('topcombinediops', '%(prefix)s ((avg_over_time(ceph_rbd_write_ops{cluster="$cluster"}[${__range_s}s] @ end())) + (avg_over_time(ceph_rbd_read_ops{cluster="$cluster"}[${__range_s}s] @ end())))))' % prefix, regex=regex, hide=2, refresh=2)


    .addRow(
      $.row('Combined Activity')
      .addPanel(
        $.panel('Combined Read/Writes activity') +
        $.piePanel(
          |||
            sum by(tenant_name) (openstack_cinder_volume{tenant_id=~"$topcombinedbytes"} *
            on(image) group_left sum by (image)
            (rate(ceph_rbd_write_bytes{cluster="$cluster", pool=~"$pool"}[$__rate_interval]) +
            rate(ceph_rbd_read_bytes{cluster="$cluster", pool=~"$pool"}[$__rate_interval])))
          |||, '{{tenant_name}}', unit='binBps'
        )
      )
      .addPanel(
        $.panel('Combined Read/Write IOPS Activity') +
        $.piePanel(
          |||
            sum by(tenant_name) (openstack_cinder_volume{tenant_id=~"$topcombinediops"} *
            on(image) group_left sum by (image)
            (rate(ceph_rbd_write_ops{cluster="$cluster", pool=~"$pool"}[$__rate_interval]) +
            rate(ceph_rbd_read_ops{cluster="$cluster", pool=~"$pool"}[$__rate_interval])))
          |||, '{{tenant_name}}', unit='iops'
        )
      )
    )
    .addRow(
      $.row('Top Tenants r/w bytes')
      .addPanel(
        $.panel('Top tenants read bytes') +
        $.queryPanel(
          |||
            sum by(tenant_name) (openstack_cinder_volume{tenant_id=~"$topreadbytes"} *
            on(image) group_left
            rate(ceph_rbd_read_bytes{cluster="$cluster", pool=~"$pool"}[$__rate_interval]))
          |||, '{{tenant_name}}', unit='binBps'
        )
      )
      .addPanel(
        $.panel('Top tenants write bytes') +
        $.queryPanel(
          |||
            sum by(tenant_name) (openstack_cinder_volume{tenant_id=~"$topwritebytes"} *
            on(image) group_left
            rate(ceph_rbd_write_bytes{cluster="$cluster", pool=~"$pool"}[$__rate_interval]))
          |||, '{{tenant_name}}', unit='binBps'
        )
      )
    )
    .addRow(
      $.row('Top Tenants r/w iops')
      .addPanel(
        $.panel('Top tenants read iops') +
        $.queryPanel(
          |||
            sum by(tenant_name) (openstack_cinder_volume{tenant_id=~"$topreadiops"} *
            on(image) group_left
            rate(ceph_rbd_read_ops{cluster="$cluster", pool=~"$pool"}[$__rate_interval]))
          |||, '{{tenant_name}}', unit='iops'
        )
      )
      .addPanel(
        $.panel('Top tenants write iops') +
        $.queryPanel(
          |||
            sum by(tenant_name) (openstack_cinder_volume{tenant_id=~"$topwriteiops"} *
            on(image) group_left
            rate(ceph_rbd_write_ops{cluster="$cluster", pool=~"$pool"}[$__rate_interval]))
          |||, '{{tenant_name}}', unit='iops'
        )
      )
    )
    .addRow(
      $.row('Top Tenants r/w latency')
      .addPanel(
        $.panel('Top tenant average read latency') +
        $.queryPanel(
          |||
            sum by(tenant_name) (openstack_cinder_volume{tenant_id=~"$topreadlatency"} *
            on(image) group_left
            ceph_rbd_read_latency{cluster="$cluster", pool=~"$pool"} > 0)
          |||, '{{tenant_name}}', unit='ns'
        )
      )
      .addPanel(
        $.panel('Top tenant average write latency') +
        $.queryPanel(
          |||
            sum by(tenant_name) (openstack_cinder_volume{tenant_id=~"$topwritelatency"} *
            on(image) group_left
            ceph_rbd_write_latency{cluster="$cluster", pool=~"$pool"} > 0)
          |||, '{{tenant_name}}', unit='ns'
        )
      )
    ),

}
