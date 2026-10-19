# an example for github:numtide/devshell shells (see flake.nix also)

# https://dev.to/arnu515/easy-development-environments-with-nix-and-nix-flakes-21mb

{ inputs, self, ... }:

{
  imports = [ inputs.devshell.flakeModule ];

  perSystem =
    { pkgs, ... }:

    let
      # Base Deps
      # For all Blenders?
      pkgs-base = with pkgs; [
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
        wayland
      ];

      # Blender 5.2.1
      path = "/data/share/tools/blender-5.2.1-linux-x64";
      # # Deps
      pkgs-deps-blender-5-2-1 = with pkgs; [
        libxxf86vm
        libdecor

        ## For Ayon Launcher
        glib
        fontconfig
        freetype
        xwayland
        qt5.qtwayland
        qt6.qtwayland
        libxcb
        libxcb-image
        libxcb-render-util
        libxcb-cursor
        libxcb-keysyms
        libxcb-wm

        # testing manual command
        zlib
        zstd
        dbus
        libc
      ] ++ pkgs-base;

      fhs-blender-5-2-1 = pkgs.buildFHSEnv {
        name = "blender-5-2-1-package";
        profile = ''
          export PATH=s:$PATH
          export LD_LIBRARY_PATH=${pkgs.wayland}/lib:$LD_LIBRARY_PATH
          # export QT_QPA_PLATFORM=xcb
          export AYON_BLENDER_USE_SYSTEM_PATH=1
          # No effect; still uses xterm:
          # export TERM=linux
        '';

        runScript = pkgs.lib.getExe runScript-5-2-1;

        # tarkgetPkgs expects a function
        targetPkgs = pkgs: (pkgs-deps-blender-5-2-1);
      };

      pkgs-dev-5-2-1 = (with pkgs; [
        # fhs shell
        (pkgs.buildFHSEnv {
          name = "fhs";
          runScript = "bash";
          targetPkgs = pkgs: (pkgs-deps-blender-5-2-1);
        })
      ]);

      # # This is the launch script for Blender 5.2.1
      runScript-5-2-1 = pkgs.writeScriptBin "blender-5-2-1-bin" ''
        echo "Running ${pkgs.lib.getBin (pkgs.glibc)}/bin/ldd $(which blender)..." \
          && ${pkgs.lib.getBin (pkgs.glibc)}/bin/ldd $(which blender) \
          && echo "Launching $(which blender)" \
          && echo "- with default args \"${builtins.toString blender-default-args}\"" \
          && echo "- with extra args \"$@\"" \
          && echo "..." \
          && blender ${builtins.toString blender-default-args} $@
      '';

    blender-default-args = [
      "--python-use-system-env"
      "--debug"
      "--debug-cycles"
      "--debug-ffmpeg"
    ];

  in

  {
    # https://determinate.systems/blog/nix-run/
    # A simple executable package
    packages = {

      blender-5-2-1-package = fhs-blender-5-2-1;

#       blender-4-4-3-testblender-5-2-1 = pkgs.writeScriptBin "blender-5-2-3-bin" ''
#        echo "Running ${pkgs.lib.getBin (pkgs.glibc)}/bin/ldd $(which blender)..."
#        ${pkgs.lib.getBin (pkgs.glibc)}/bin/ldd $(which blender)
#
#        echo "Launching $(which blender) with extra args $@..."
#        blender --python-use-system-env --debug --debug-cycles --debug-ffmpeg $@
#      '';

    };

    # https://discourse.nixos.org/t/flakes-way-of-creating-a-fhs-environment/20821
    # https://nixos.wiki/wiki/Flakes#nix_run
    # https://nix.dev/manual/nix/2.34/command-ref/new-cli/nix3-run.html#apps
    # https://vtimofeenko.com/posts/practical-nix-flake-anatomy-a-guided-tour-of-flake.nix/#apps}
    apps = {
      blender-5-2-1-app = {
        type = "app";
        program = self.packages.x86_64-linux.blender-5-2-1-package;
        meta.description = "Launch Blender 5.2.1";
      };
    };

    devshells = {
      blender-5-2-1-devshell = {
        packages = pkgs-dev-5-2-1;
        name = "blender-5-2-1-devshell";
        motd = ''
          You are now in a Blender 5.2.1 configured environment.
          Call "fhs" to setup File Hierarchy Standard.
          DEFAULT_ARGS = "${builtins.toString blender-default-args}"
        '';
        # devshell.startup.fhs.text = ''
        # '';
        shellHook = ''
          # set -a;
          # export FOO="bar";
          # set +a;
          alias blender="blender $DEFAULT_ARGS"
        '';
        # Custom Env:
        env = [
          {
            name = "DEV_SHELL";
            value = "blender-5-2-1";
          }
          {
            name = "PATH";
            prefix = path;
          }
          {
            name = "DEFAULT_ARGS";
            value = "${builtins.toString blender-default-args}";
          }
        ];
      };
    };
  };
}