function main(config) {
  const proxyName = "TS-Tailnet";
  const groupName = "Tailnet";
  const tailnetDomain = __CLASH_VERGE_TAILNET_DOMAIN__;
  const tailnetCidr = __CLASH_VERGE_TAILNET_CIDR__;
  const dnsUpstream = __CLASH_VERGE_DNS_UPSTREAM__;

  const tailscaleNode = {
    name: proxyName,
    type: "tailscale",
    hostname: __CLASH_VERGE_HOSTNAME__,
    "state-dir": __CLASH_VERGE_STATE_DIR__,
    udp: true,
    "accept-routes": true,
  };

  config.proxies = Array.isArray(config.proxies) ? config.proxies : [];

  const proxyIndex = config.proxies.findIndex(
    (proxy) => proxy && proxy.name === proxyName,
  );

  if (proxyIndex === -1) {
    config.proxies.push(tailscaleNode);
  } else {
    config.proxies[proxyIndex] = {
      ...config.proxies[proxyIndex],
      ...tailscaleNode,
    };
  }

  config["proxy-groups"] = Array.isArray(config["proxy-groups"])
    ? config["proxy-groups"]
    : [];

  let group = config["proxy-groups"].find(
    (item) => item && item.name === groupName,
  );

  if (!group) {
    config["proxy-groups"].unshift({
      name: groupName,
      type: "select",
      proxies: [proxyName],
    });
  } else {
    group.proxies = Array.isArray(group.proxies) ? group.proxies : [];

    if (!group.proxies.includes(proxyName)) {
      group.proxies.push(proxyName);
    }
  }

  const tailnetRules = [
    `DOMAIN-SUFFIX,${tailnetDomain},Tailnet`,
    `IP-CIDR,${tailnetCidr},Tailnet,no-resolve`,
    "DOMAIN-SUFFIX,ts.net,Tailnet",
  ];

  config.rules = tailnetRules.concat(
    Array.isArray(config.rules)
      ? config.rules.filter((rule) => !tailnetRules.includes(rule))
      : [],
  );

  config.dns = config.dns && typeof config.dns === "object" ? config.dns : {};

  config.dns["nameserver-policy"] =
    config.dns["nameserver-policy"] &&
    typeof config.dns["nameserver-policy"] === "object"
      ? config.dns["nameserver-policy"]
      : {};

  config.dns["nameserver-policy"][`+.${tailnetDomain}`] =
    `${dnsUpstream}#Tailnet`;

  config.dns["fake-ip-filter"] = Array.isArray(config.dns["fake-ip-filter"])
    ? config.dns["fake-ip-filter"]
    : [];

  if (
    !config.dns["fake-ip-filter"].includes(`+.${tailnetDomain}`)
  ) {
    config.dns["fake-ip-filter"].push(`+.${tailnetDomain}`);
  }

  return config;
}
