{ pkgs, config, ... }:

let
  nixosCfg = config.services.hercules.nixos.evaluatedConfig;
  agentCfg = nixosCfg.services.hercules-ci-agent;
  agentBaseDir = agentCfg.settings.baseDirectory;
in
{
  config.services.hercules = {
    service.useHostStore = true;
    service.capabilities.SYS_ADMIN = true;
    service.volumes = [ "./hercules-data:${agentBaseDir}" ];
    nixos.useSystemd = true;
    nixos.configuration = ./configuration.nix;
  };
}
