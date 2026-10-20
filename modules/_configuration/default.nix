{ self, inputs, ... }:

  let
    stateVersion = "26.05";
    hostName = "lenovo";
  in

  {

  flake.nixosConfigurations.prod-config = inputs.nixpkgs.lib.nixosSystem {

    modules = [
      self.nixosModules.prod-module
      # self.nixosModules.home-manager-module
    ];

  };

}
