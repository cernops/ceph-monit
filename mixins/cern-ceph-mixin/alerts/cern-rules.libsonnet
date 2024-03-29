{
  groups+: [
    {
      name: 'openstack_rules',
      rules: [
        {
          record: 'openstack_cinder_volume_expanded',
          expr: 'last_over_time(openstack_cinder_volume_gb[2h])',
        },
        {
          record: 'openstack_cinder_volume',
          expr: |||
            label_replace(openstack_cinder_volume_expanded * 0 + 1, "image", "volume-$1", "id", "(.*)") *
              on (tenant_id) group_left(tenant_name)
                label_replace(
                  label_replace(openstack_identity_project_info_expanded, "tenant_id", "$1", "id", "(.*)"
                  ), "tenant_name", "$1", "name", "(.*)"
                )
          |||,
        },
        {
          record: 'openstack_identity_project_info_expanded',
          expr: 'last_over_time(openstack_identity_project_info[2h])',
        },
        {
          record: 'ceph_rbd_read_latency',
          expr: 'rate(ceph_rbd_read_latency_sum[1m]) / rate(ceph_rbd_read_latency_count[1m])',
        },
        {
          record: 'ceph_rbd_write_latency',
          expr: 'rate(ceph_rbd_write_latency_sum[1m]) / rate(ceph_rbd_write_latency_count[1m])',
        },
      ],
    },
    {
      name: 'ceph.record.rules',
      rules: [
        {
          record: 'ceph:cluster_osd_op_r_latency:avg_rate5m',
          expr: |||
            avg by(cluster) (
              (rate(ceph_osd_op_r_latency_sum[5m])) / (rate(ceph_osd_op_r_latency_count[5m])) >= 0
            )
          |||,
        },
        {
          record: 'ceph:cluster_osd_op_w_latency:avg_rate5m',
          expr: |||
            avg by(cluster) (
              (rate(ceph_osd_op_w_latency_sum[5m])) / (rate(ceph_osd_op_w_latency_count[5m])) >= 0
            )
          |||,
        },
        {
          record: 'ceph:cluster_osd_bluestore:count',
          expr: 'count by (cluster) (ceph_bluestore_commit_lat_count)',
        },
        {
          record: 'ceph:cluster_osd_filestore:count',
          expr: 'count by (cluster) (ceph_filestore_journal_latency_count)',
        },
        {
          record: 'ceph:cluster_osd_apply_latency:avg',
          expr: 'avg by(cluster) (ceph_osd_apply_latency_ms)',
        },
        {
          record: 'ceph:cluster_osd_commit_latency:avg',
          expr: 'avg by(cluster) (ceph_osd_commit_latency_ms)',
        },
        {
          record: 'ceph:cluster_osd_down:count',
          expr: 'count by (cluster) (ceph_osd_up == 0) OR vector(0)',
        },
        {
          record: 'ceph:cluster_osd_up:count',
          expr: 'count by (cluster) (ceph_osd_up == 1) OR vector(0)',
        },
        {
          record: 'ceph:cluster_osd_in:count',
          expr: 'count by (cluster) (ceph_osd_in == 1) OR vector(0)',
        },
        {
          record: 'ceph:cluster_version_osd_count',
          expr: 'count by (cluster, ceph_version) (ceph_osd_metadata)',
        },
        {
          record: 'ceph:cluster_osd_op_w_in_bytes:sum',
          expr: 'sum by (cluster) (ceph_osd_op_w_in_bytes)',
        },
        {
          record: 'ceph:cluster_osd_op_r_out_bytes:sum',
          expr: 'sum by (cluster) (ceph_osd_op_r_out_bytes)',
        },
        {
          record: 'ceph:cluster_osd_op_w:sum',
          expr: 'sum by (cluster) (ceph_osd_op_w)',
        },
        {
          record: 'ceph:cluster_osd_op_r:sum',
          expr: 'sum by (cluster) (ceph_osd_op_r)',
        },
      ],
    },
    {
      name: 's3_lb.rules',
      rules: [
        {
          record: 's3:slo_errors_per_request:ratio_rate5m',
          expr: |||
            sum by (cluster)(rate(traefik_entrypoint_requests_total{code=~"5.*"}[5m])) /
              sum by (cluster)(rate(traefik_entrypoint_requests_total[5m]))
          |||,
        },
        {
          record: 's3:slo_errors_per_request:ratio_rate30m',
          expr: |||
            sum by (cluster)(rate(traefik_entrypoint_requests_total{code=~"5.*"}[30m])) /
              sum by (cluster)(rate(traefik_entrypoint_requests_total[30m]))
          |||,
        },
        {
          record: 's3:slo_errors_per_request:ratio_rate1h',
          expr: |||
            sum by (cluster)(rate(traefik_entrypoint_requests_total{code=~"5.*"}[1h])) /
              sum by (cluster)(rate(traefik_entrypoint_requests_total[1h]))
          |||,
        },
        {
          record: 's3:slo_errors_per_request:ratio_rate2h',
          expr: |||
            sum by (cluster)(rate(traefik_entrypoint_requests_total{code=~"5.*"}[2h])) /
              sum by (cluster)(rate(traefik_entrypoint_requests_total[2h]))
          |||,
        },
        {
          record: 's3:slo_errors_per_request:ratio_rate6h',
          expr: |||
            sum by (cluster)(rate(traefik_entrypoint_requests_total{code=~"5.*"}[6h])) /
              sum by (cluster)(rate(traefik_entrypoint_requests_total[6h]))
          |||,
        },
        {
          record: 's3:slo_errors_per_request:ratio_rate24h',
          expr: |||
            sum by (cluster)(rate(traefik_entrypoint_requests_total{code=~"5.*"}[24h])) /
              sum by (cluster)(rate(traefik_entrypoint_requests_total[24h]))
          |||,
        },
        {
          record: 's3:slo_errors_per_request:ratio_rate3d',
          expr: |||
            sum by (cluster)(rate(traefik_entrypoint_requests_total{code=~"5.*"}[3d])) /
              sum by (cluster)(rate(traefik_entrypoint_requests_total[3d]))
          |||,
        },
      ],
    },
    {
      name: 'filer_rules',
      rules: [
        {
          record: 'instance:node_filesystem_avail:ratio',
          expr: |||
            node_filesystem_avail_bytes{group="filer"} /
              node_filesystem_size_bytes{group="filer"}
          |||,
        },
      ],
    },
  ],
}
