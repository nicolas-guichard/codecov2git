# SPDX-FileCopyrightText: 2025 Mozilla
# SPDX-FileContributor: Nicolas Qiu Guichard <nicolas.guichard@kdab.com>
#
# SPDX-License-Identifier: MPL-2.0
{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    crane.url = "github:ipetkov/crane";
  };

  outputs = {
    self,
    nixpkgs,
    crane,
  }: (
    let
      system = "x86_64-linux";
      pkgs = import nixpkgs {
        inherit system;
      };

      craneLib = crane.mkLib pkgs;

      src = craneLib.cleanCargoSource ./.;
      cargoArtifacts = craneLib.buildDepsOnly {
        inherit src;
      };
      codecov2git = craneLib.buildPackage {
        inherit src cargoArtifacts;
      };
    in {
      packages.${system} = {
        inherit codecov2git;
        default = codecov2git;
      };

      apps.${system} = {
        codecov2git = {
          type = "app";
          program = "${codecov2git}/bin/codecov2git";
          meta.description = "Turns a code-coverage-report.json from Firefox CI into a Git repository for consumption by Searchfox.";
        };
        default = self.apps.${system}.codecov2git;
      };

      devShells.${system}.default = pkgs.mkShell {
        inputsFrom = [codecov2git];

        packages = with pkgs; [
          rust-analyzer
          rr
          rustfmt
          clippy
          reuse
        ];
      };

      checks.${system} = {
        inherit codecov2git;

        clippy = craneLib.cargoClippy {
          inherit src cargoArtifacts;
          cargoClippyExtraArgs = "--all-targets -- --deny warnings";
        };

        fmt = craneLib.cargoFmt {
          inherit src;
        };

        toml-fmt = craneLib.taploFmt {
          src = pkgs.lib.sources.sourceFilesBySuffices src [".toml"];
        };

        reuse = pkgs.runCommand "check-reuse" {} ''
          cd ${self}
          ${pkgs.reuse}/bin/reuse lint
          touch $out
        '';

        nix-fmt = pkgs.runCommand "check-nix-fmt" {} ''
          ${self.formatter.${system}}/bin/${self.formatter.${system}.NIX_MAIN_PROGRAM} -c ${self}/flake.nix
          touch $out
        '';
      };

      formatter.${system} = pkgs.alejandra;
    }
  );
}
