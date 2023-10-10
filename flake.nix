{
  description = "Hydra RunCommand Log Capture";

  inputs.nixpkgs.url = "https://flakehub.com/f/NixOS/nixpkgs/0.1.533189.tar.gz";

  outputs =
    { self
    , nixpkgs
    , ...
    } @ inputs:
    let
      nameValuePair = name: value: { inherit name value; };
      genAttrs = names: f: builtins.listToAttrs (map (n: nameValuePair n (f n)) names);
      allSystems = [ "x86_64-linux" "aarch64-linux" "i686-linux" "x86_64-darwin" ];

      pkgsFor = pkgs: system:
        import pkgs { inherit system; };

      forAllSystems = f: genAttrs allSystems (system: f {
        inherit system;
        pkgs = pkgsFor nixpkgs system;
      });
    in
    {
      devShell = forAllSystems ({ system, pkgs, ... }:
        pkgs.mkShell {
          name = "hydra-runcommand-log";

          buildInputs = with pkgs; [
            codespell
            nixpkgs-fmt
          ];
        });

      hydraJobs = import ./example.nix {
        pkgs = (pkgsFor nixpkgs "x86_64-linux");
      };
    };
}
