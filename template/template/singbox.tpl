{
  "dns": {
    "servers": [
      {
        "tag": "dnspod-doh",
        "address": "https://1.12.12.12/dns-query",
        "detour": "direct"
      },
      {
        "tag": "remote",
        "address": "fakeip"
      },
      {
        "tag": "block",
        "address": "rcode://success"
      }
    ],
    "rules": [
      {
        "rule_set": "geosite-category-ads-all",
        "server": "block"
      },
      {
        "query_type": ["A", "AAAA"],
        "server": "remote"
      },
      {
        "outbound": "any",
        "server": "dnspod-doh"
      }
    ],
    "fakeip": {
      "enabled": true,
      "inet4_range": "198.18.0.0/15",
      "inet6_range": "fc00::/18"
    },
    "independent_cache": true
  },
  "inbounds": [
    {
      "type": "tun",
      "inet4_address": "172.19.0.1/30",
      "inet6_address": "fdfe:dcba:9876::1/126",
      "auto_route": true,
      "strict_route": true,
      "sniff": true
    }
  ],
  "outbounds": [
    {
      "type": "selector",
      "tag": "proxy",
      "outbounds": {{ getSingboxNodeNames(nodeList, null, ['auto']) | json }},
      "interrupt_exist_connections": false
    },
    {
      "type": "urltest",
      "tag": "auto",
      "outbounds": {{ getSingboxNodeNames(nodeList) | json }},
      "url": "{{ proxyTestUrl }}",
      "interrupt_exist_connections": false
    },
    {{ getSingboxNodesString(nodeList) }},
    {
      "type": "direct",
      "tag": "direct",
      "tcp_fast_open": true,
      "tcp_multi_path": true
    },
    {
      "type": "block",
      "tag": "block"
    },
    {
      "type": "dns",
      "tag": "dns"
    }
  ],
  "route": {
    "rules": [
      {
        "type": "logical",
        "mode": "or",
        "rules": [
          {
            "protocol": "dns"
          },
          {
            "port": 53
          }
        ],
        "outbound": "dns"
      },
      {
        "ip_is_private": true,
        "outbound": "direct"
      },
      {
        "clash_mode": "Direct",
        "outbound": "direct"
      },
      {
        "clash_mode": "Global",
        "outbound": "proxy"
      },
      {
        "geosite": "geosite-category-ads-all",
        "outbound": "block"
      },
      {
        "type": "logical",
        "mode": "and",
        "rules": [
          {
            "rule_set": "geosite-geolocation-!cn",
            "invert": true
          },
          {
            "rule_set": ["geoip-cn", "geosite-cn"]
          }
        ],
        "outbound": "direct"
      }
    ],
    "rule_set": [
      {
        "tag": "geosite-category-ads-all",
        "type": "remote",
        "format": "binary",
        "url": "https://cdn.jsdelivr.net/gh/SagerNet/sing-geosite@rule-set/geosite-category-ads-all.srs"
      },
      {
        "type": "remote",
        "tag": "geosite-geolocation-!cn",
        "format": "binary",
        "url": "https://cdn.jsdelivr.net/gh/SagerNet/sing-geosite@rule-set/geosite-geolocation-!cn.srs"
      },
      {
        "tag": "geosite-cn",
        "type": "remote",
        "format": "binary",
        "url": "https://cdn.jsdelivr.net/gh/SagerNet/sing-geosite@rule-set/geosite-cn.srs"
      },
      {
        "tag": "geoip-cn",
        "type": "remote",
        "format": "binary",
        "url": "https://cdn.jsdelivr.net/gh/SagerNet/sing-geoip@rule-set/geoip-cn.srs"
      }
    ],
    "auto_detect_interface": true
  },
  "experimental": {
    "cache_file": {
      "enabled": true,
      "store_fakeip": true
    },
    "clash_api": {
      "external_controller": ":9090",
      "external_ui_download_url": "https://github.abskoop.workers.dev/https://github.com/MetaCubeX/metacubexd/archive/gh-pages.zip",
      "secret": "MY_PASSWORD"
    }
  }
}
