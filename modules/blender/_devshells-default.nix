# an example for a standard devShells

{ inputs, ... }: {

  perSystem = { pkgs, ... }:

  let
#    system = "x86_64-linux";
#    pkgs = import nixpkgs { inherit system; };
    pkgs-base = with pkgs; [
      # fhs shell
      (pkgs.buildFHSEnv {
        name = "fhs";
        runScript = "bash";
        targetPkgs = pkgs: (with pkgs; [
          udev
          alsa-lib
          libX11
          libXrender
          libXfixes
          libXi
          libxkbcommon
          libSM
          libICE
          libGL
        ]);
      })
    ];
  in

  {
    # https://michael.stapelberg.ch/posts/2025-07-27-dev-shells-with-nix-4-quick-examples/
    formatter = pkgs.nixfmt-tree;
    devShells = {

      # blender-base = pkgs.mkShellNoCC {
      #   buildInputs = pkgs-base;
      #   shellHook = ''
      #     echo "You are now in a Blender configured environment."
      #     fhs
      #   '';
      #   env.TEST_VAR = "hello";
      # };

      blender-3 = pkgs.mkShellNoCC {
        buildInputs = pkgs-base;
        shellHook = ''
          echo "You are now in a Blender 3 configured environment."
          fhs
        '';
        # Custom Env:
        # env.MY_CUSTOM_VAR = "custom value";
      };

      blender-4 = pkgs.mkShellNoCC {
        buildInputs = pkgs-base;
        shellHook = ''
          echo "You are now in a Blender 4 configured environment."
          fhs
        '';
        # Custom Env:
        # env.MY_CUSTOM_VAR = "custom value";
      };

      blender-5 = pkgs.mkShellNoCC {
        buildInputs = pkgs-base;
        shellHook = ''
          echo "You are now in a Blender 5 configured environment."
          fhs
        '';
        # Custom Env:
        # env.MY_CUSTOM_VAR = "custom value";
      };

    };
  };
}