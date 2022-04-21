{ pkgs, ... }:

{
  config.services.hercules = {
    service.useHostStore = true;
    nixos.useSystemd = true;
    nixos.configuration = ./configuration.nix;
  };
}
