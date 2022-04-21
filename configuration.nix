# This bit is the NixOS configuration
# It makses some assumptions about arion-sompose.nix
# (e.g. that systemd would be enabled)
{ pkgs, ... }:
{
  boot.isContainer = true;
  # boot.tmpOnTmpfs = true;

  services.hercules-ci-agent.enable = true;
  services.hercules-ci-agent.settings = {
    # Two is the minimum
    concurrentTasks = 2;

    # This is the mutable state location that you need to bind-mount
    # baseDirectory = "/var/lib/hercules-ci-agent";
  };
}
