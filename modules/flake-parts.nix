# Modules starting with _ are ignored by
# import-tree, so they could be traditionally
# referenced by their file names
# i.e. ./_hardware-configuration.nix

# Flake-parts: option `flake.modules’ is defined multiple times while it’s expected to be unique
#
# https://discourse.nixos.org/t/flake-parts-option-flake-modules-is-defined-multiple-times-while-its-expected-to-be-unique/71584/4

{ inputs, ... }:
{
  imports = [
    inputs.flake-parts.flakeModules.modules
    # inputs.devshell.flakeModule
  ];

  config.systems = [
    "x86_64-linux"
#    "aarch64-linux"
#    "x86_64-darwin"
#    "aarch64-darwin"
  ];
}
