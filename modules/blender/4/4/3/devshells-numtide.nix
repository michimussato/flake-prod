# an example for github:numtide/devshell shells (see flake.nix also)

# https://dev.to/arnu515/easy-development-environments-with-nix-and-nix-flakes-21mb

{ inputs, self, ... }:

{
  imports = [ inputs.devshell.flakeModule ];

  perSystem =
    { pkgs, lib, ... }:

    let
      # Base Deps
      # For all Blenders?
      pkgs-base = with pkgs; [
        # kitty

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
        egl-wayland
      ];

      # Blender 4.4.3
      path = "/data/share/tools/blender-4.4.3-linux-x64";
      # # Deps
      pkgs-deps-blender-4-4-3 = with pkgs; [
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

      profile = ''
        export PATH=${path}:$PATH

        # don't remember what this was for:
        # (does not seem to have an effect on the env anyway)
        # an alternative could be to use lib.makeLibraryPath
        # - https://noogle.dev/f/lib/makeLibraryPath/
        export LD_LIBRARY_PATH=${pkgs.lib.makeLibraryPath [
          pkgs.wayland
        ]}:$LD_LIBRARY_PATH

        # export QT_QPA_PLATFORM=xcb
        export AYON_BLENDER_USE_SYSTEM_PATH=1

        # No effect; still uses xterm:
        # export TERM=linux

        export DEFAULT_ARGS="${builtins.toString blender-default-args}"
      '';

      fhs-blender-4-4-3 = pkgs.buildFHSEnv {
        name = "blender-4-4-3-package";
        # /data/share/tools/blender-4.4.3-linux-x64/blender
        # bash: /data/share/tools/blender-4.4.3-linux-x64/blender: Permission denied
        inherit profile;

        runScript = pkgs.lib.getExe runScript-4-4-3;

        # it seems like nix is `exec`ing:
        # runScript = "(${pkgs.lib.getExe runScript-4-4-3})";
        # Results in:
        # /nix/store/22hh7ylmf62r31vzas0ir8da9kprcll8-fhs-blender-4-4-3-init: line 3: syntax error near unexpected token `/nix/store/r8mmqvnjj3ln69slmz1p2c6azkclwr41-blender-4-4-3-bin/bin/blender-4-4-3-bin'
        # /nix/store/22hh7ylmf62r31vzas0ir8da9kprcll8-fhs-blender-4-4-3-init: line 3: `exec (/nix/store/r8mmqvnjj3ln69slmz1p2c6azkclwr41-blender-4-4-3-bin/bin/blender-4-4-3-bin) "$@"'
        # nix run /home/michael/git/repos/my-test-flake-01#blender-4-4-3

        # tarkgetPkgs expects a function
        targetPkgs = pkgs: (pkgs-deps-blender-4-4-3);
        # targetPkgs = pkgs: (pkgs-deps-blender-4-4-3 ++ lib.makeLibraryPath [
        #   pkgs.wayland
        # ]);
      };

      pkgs-dev-4-4-3 = (with pkgs; [
        # fhs shell
        (pkgs.buildFHSEnv {
          name = "fhs";
          runScript = "bash";
          targetPkgs = pkgs: (pkgs-deps-blender-4-4-3);
        })
      ]);

      # pkgs-dev-4-4-3 = (with pkgs; [
      #   # fhs shell
      #   (fhs-blender-4-4-3)
      # ]);

      # # This is the launch script for Blender 4.4.3
      # maybe we could use `/run/current-system/sw/bin/xdg-terminal "command"`
      runScript-4-4-3 = pkgs.writeScriptBin "blender-4-4-3-bin" ''
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
      "--enable-autoexec"
      "--verbose" # expects a verbosity level
      "4"  # fatal, error, warning, info, debug, and trace
      "--debug"
      "--debug-cycles"
      "--debug-ffmpeg"
    ];

  in

  {
    # https://determinate.systems/blog/nix-run/
    # A simple executable package
    packages = {
      blender-4-4-3-package = fhs-blender-4-4-3;
    };

    # https://discourse.nixos.org/t/flakes-way-of-creating-a-fhs-environment/20821
    # https://nixos.wiki/wiki/Flakes#nix_run
    # https://nix.dev/manual/nix/2.34/command-ref/new-cli/nix3-run.html#apps
    # https://vtimofeenko.com/posts/practical-nix-flake-anatomy-a-guided-tour-of-flake.nix/#apps}
    apps = {
      blender-4-4-3-app = {
        type = "app";
        program = self.packages.x86_64-linux.blender-4-4-3-package;
        meta.description = "Launch Blender 4.4.3";
      };
    };

    # https://hugosum.com/blog/recreating-development-environment-with-nix-flake
    devshells = {
      blender-4-4-3-devshell = {
#        packages = self.packages.blender-4-4-3-package.targetPkgs;
#        packages = pkgs.mkShell {
#          nativeBuildInputs = [pkgs-dev-4-4-3];
#          shellHook = ''
#            # set -a;
#            # export FOO="bar";
#            # set +a;
#            alias blender="blender $DEFAULT_ARGS"
#          '';
#        };
        packages = pkgs-dev-4-4-3;
        name = "blender-4-4-3-devshell";
        motd = ''
          You are now in a Blender 4.4.3 configured environment.
          Call "fhs" to setup File Hierarchy Standard.

          DEFAULT_ARGS = "$DEFAULT_ARGS"

          Available commands:
          $(find ${path} -maxdepth 1 -type f -executable)
        '';
        devshell.startup.fhs.text = ''
          # `inherit profile;` does not work for devshells.
          # so seems to be the only option to get the
          # same env in the devshell
          ${profile}

          # aliases are not exported to subshells
          # hence, use functions
          #
          # automatically export all functions declared here:
          set -a

          blenderhelp() {
            set -x;
            command blender $DEFAULT_ARGS --background --help;
            set +x;
          }

          blender() {
            set -x;
            command blender $DEFAULT_ARGS "$@";
            set +x;
          }

          blenderpy() {
            set -x;
            command blender $DEFAULT_ARGS --background --python-console "$@";
            set +x;
          }

          set +a
        '';
        # Custom Env:
        # env = [
        #   {
        #     name = "DEV_SHELL";
        #     value = "blender-4-4-3";
        #   }
        #   # {
        #   #   name = "PATH";
        #   #   prefix = path;
        #   # }
        #   # {
        #   #   name = "DEFAULT_ARGS";
        #   #   value = "${builtins.toString blender-default-args}";
        #   # }
        # ];
      };
    };
  };
}
