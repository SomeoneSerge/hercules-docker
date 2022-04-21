{
  description = "Pack hercules-ci-agent into a docker image";

  inputs.nixpkgs.url = github:NixOS/nixpkgs/release-21.11;
  inputs.hercules-ci-agent.url = github:hercules-ci/hercules-ci-agent/hercules-ci-agent-0.9.3;
  inputs.arion.url = github:hercules-ci/arion/v0.1.3.0;

  inputs.hercules-ci-agent.inputs.nixpkgs.follows = "nixpkgs";
  inputs.arion.inputs.nixpkgs.follows = "nixpkgs";

  outputs = { self, nixpkgs, hercules-ci-agent, arion }:
    let
      inherit (nixpkgs) lib;

      systems = [ "x86_64-linux" ];
      eachSystem = lib.genAttrs systems;
      eachSystem' = f: lib.listToAttrs (map f systems);

      nixosDefinitions = eachSystem' (system: {
        name = "nixpkgs-unfree-hercules-${system}";
        value = {
          inherit system;
          modules = [
            ./configuration.nix
            hercules-ci-agent.nixosModules.agent-service
          ];
        };
      });
    in
    {
      packages = eachSystem (system: {
        mk-image =
          let
            pkgs = nixpkgs.legacyPackages.${system};
            # FIXME: pass the pinned hercules-ci-agent
            arionEval = arion.lib.eval {
              modules = [ ./arion-compose.nix ];
              inherit pkgs;
            };
            exe = (builtins.head arionEval.config.build.imagesToLoad).imageExe;
            yaml = arionEval.config.out;
          in
          pkgs.runCommand "hercules-ci-agent-image" { } ''
            ln -s ${exe} $out
          '';

      });

      # just for nix flake show
      nixosConfigurations = lib.mapAttrs (name: value: lib.nixosSystem value) nixosDefinitions;
    };
}
