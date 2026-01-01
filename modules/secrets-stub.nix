{ lib, ... }:
{
  options.secrets = lib.mkOption {
    type = lib.types.attrsOf lib.types.anything;
    default = {
      hashedPasswordFile = "/dev/null";
      credentialFiles = {
        cloudflareToken = "/dev/null";
        googleGenerativeAiApiKey = "/dev/null";
        tauriSigningPrivateKey = "/dev/null";
      };
      ssh = {
        gitKeyFile = "/dev/null";
        hostMatchBlocks = {};
      };
      wolHosts = {};
      desktop = {
        ssh = {
          authorizedKeys = [];
          ports = [ 22 ];
        };
      };
      leggero = {
        ssh = {
          authorizedKeys = [];
          ports = [ 22 ];
        };
        wireguard = {
          privateKeyFile = "/dev/null";
          peers = [];
        };
        ddns = {
          domains = [];
        };
        caddy = {
          homeAssistantHost = "homeassistant.local";
        };
      };
      macchiato = {
        ssh = {
          authorizedKeys = [];
          ports = [ 22 ];
        };
        wireguard = {
          privateKeyFile = "/dev/null";
          peers = [];
        };
        ddns = {
          domains = [];
        };
        homebridge = {
          username = "admin";
          pin = "000-00-000";
        };
      };
    };
  };
}
