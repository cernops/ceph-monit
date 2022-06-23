{
  groups+: [
    {
      name: 'general.alerts',
      rules: [
        {
          alert: 'AbsentMetrics',
          'for': '30m',
          expr: 'absent(up)',
          labels: { severity: 'ticket' },
          annotations: {
            summary: 'No metric reports from {{ $labels.instance }} for the last 30 minutes.',
          },
        },
        {
          alert: 'TargetDown',
          'for': '15m',
          expr: 'up == 0',
          labels: { severity: 'ticket' },
          annotations: {
            summary: 'Target {{ $labels.instance }} is down',
            description: 'Target {{ $labels.instance }} of job {{ $labels.job }} is down for more than 15 minutes.',
            procedure_url: 'http://s3-website.cern.ch/cephdocs/ops/rota.html#cephtargetdown',
          },
        },
      ],
    },
    {
      name: 'ceph.alerts',
      rules: [
        {
          alert: 'CephNearFullOSD',
          'for': '10m',
          expr: |||
            (ceph_osd_stat_bytes - ceph_osd_stat_bytes_used) / (ceph_osd_stat_bytes) < 0.15
          |||,
          labels: { severity: 'ticket' },
          annotations: {
            summary: '{{ $labels.ceph_daemon }} of cluster {{ $labels.cluster }} Free Space is Below 15%',
          },
        },
        {
          alert: 'CephLowSpace',
          'for': '15m',
          expr: |||
            (ceph_cluster_total_bytes-ceph_cluster_total_used_bytes) / ceph_cluster_total_bytes < 0.15
          |||,
          labels: { severity: 'ticket' },
          annotations: {
            summary: 'Cluster {{ $labels.cluster }} Free Space is Below 15%',
          },
        },
        {
          alert: 'CephHealthError',
          'for': '5m',
          expr: 'ceph_health_status == 2',
          labels: { severity: 'ticket' },
          annotations: {
            summary: 'Cluster {{ $labels.cluster }} is in HEALTH ERROR Status',
          },
        },
        {
          alert: 'CephHostOSDsDown',
          'for': '30m',
          expr: |||
            count(
              (ceph_osd_up == 0) *
                on(cluster, ceph_daemon) group_left(hostname) ceph_osd_metadata) by (hostname, cluster) ==
                  (count (ceph_osd_metadata) by (hostname, cluster))
          |||,
          labels: { severity: 'ticket' },
          annotations: {
            summary: 'All OSDs from host {{ $labels.hostname }} seem down',
          },
        },
        {
          alert: 'CephInconsistentPGs',
          'for': '5m',
          expr: 'ceph_pg_inconsistent > 0',
          labels: { severity: 'ticket' },
          annotations: {
            summary: 'There are inconsistent PGs',
            procedure_url: 'http://s3-website.cern.ch/cephdocs/ops/rota.html#cephinconsistentpgs',
          },
        },
        {
          alert: 'CephMdsTooManyStrays',
          'for': '5m',
          expr: 'ceph_mds_cache_num_strays > 500000',
          labels: { severity: 'ticket' },
          annotations: {
            summary: 'The number of strays is above 500K',
            procedure_url: 'http://s3-website.cern.ch/cephdocs/ops/rota.html#cephmdstoomanystrays',
          },
        },
        {
          alert: 'CephNearFullPoolQuota',
          'for': '10m',
          expr: |||
            (((ceph_pool_quota_bytes > 0) - ceph_pool_bytes_used ) / ceph_pool_quota_bytes) < 0.002
          |||,
          labels: { severity: 'ticket' },
          annotations: {
            summary: 'Pool {{ $labels.pool_id }} free quota of cluster {{ $labels.cluster }} is Below 0.2%',
            procedure_url: 'http://s3-website.cern.ch/cephdocs/ops/rota.html#cephnearfullpoolquota',
          },
        },
      ],
    },
    {
      name: 's3_lb.alerts',
      rules: [
        {
          alert: 'S3ErrorRateSLOBurnFast',
          expr: |||
            (
              s3:slo_errors_per_request:ratio_rate1h > (14.4*0.001) and
                s3:slo_errors_per_request:ratio_rate5m > (14.4*0.001)
            ) or (
              s3:slo_errors_per_request:ratio_rate6h > (6*0.001) and
                s3:slo_errors_per_request:ratio_rate30m > (6*0.001)
            )
          |||,
          labels: { severity: 'page' },
          annotations: {
            summary: 'Cluster {{ $labels.cluster }} returns a lot of errors, please ACT NOW !',
          },
        },
        {
          alert: 'S3ErrorRateSLOBurnSlow',
          expr: |||
            (
              s3:slo_errors_per_request:ratio_rate1h > (3*0.001) and
                s3:slo_errors_per_request:ratio_rate5m > (3*0.001)
            ) or (
              s3:slo_errors_per_request:ratio_rate6h > 0.001 and
                s3:slo_errors_per_request:ratio_rate30m > 0.001
            )
          |||,
          labels: { severity: 'ticket' },
          annotations: {
            summary: |||
              Cluster {{ $labels.cluster }} has a low background error rate that
              might consume our error budget in the coming days... please act !
            |||,
          },
        },
        {
          alert: 'S3SSLCertExpiresSoon',
          'for': '30m',
          expr: 'probe_ssl_earliest_cert_expiry{job="blackbox"} - time() < 21 * 60 * 60 * 24',
          labels: { severity: 'ticket' },
          annotations: {
            summary: 'SSL Certificate for {{ $labels.instance }} is about to expire. Please contact the CERN CA team',
          },
        },
        {
          alert: 'S3Down',
          'for': '3m',
          expr: 'probe_http_status_code{instance="https://s3.cern.ch", job="blackbox"} != 200',
          labels: { severity: 'page' },
          annotations: {
            summary: '{{ $labels.instance }} is down for more than 3 minutes! Please create an SSB Entry http://cern.ch/itssb',
          },
        },
      ],
    },
    {
      name: 'filer_alerts_realtime',
      rules: [
        {
          alert: 'NFSFilerDown',
          'for': '2m',
          expr: 'up{group="filer", job="nfs-servers"} == 0',
          labels: { severity: 'page' },
          annotations: {
            description: 'One NFS server is down, this might affect users and cause downtime',
          },
        },
      ],
    },
    {
      name: 'filer_alerts_lowprio',
      rules: [
        {
          alert: 'NFSPredictLowFreeSpace',
          'for': '1h',
          expr: |||
            predict_linear(
              instance:node_filesystem_avail:ratio{mountpoint!~"/export/.*"}[7d], 14*86400
            ) < 0.1
          |||,
          labels: { severity: 'ticket' },
          annotations: {
            description: 'Please check with the user if the growth is expected, and maybe schedule an intervention to enlarge the volume if necessary',
          },
        },
      ],
    },
  ],
}
