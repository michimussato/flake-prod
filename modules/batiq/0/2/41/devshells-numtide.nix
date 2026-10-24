# an example for github:numtide/devshell shells (see flake.nix also)

# https://dev.to/arnu515/easy-development-environments-with-nix-and-nix-flakes-21mb

{ inputs, self, ... }:

{
  imports = [ inputs.devshell.flakeModule ];

  perSystem =
    { pkgs, lib, ... }:

    let
      # Base Deps
      # For all Batiqs?
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
        egl-wayland
      ];

      # batiq 0.2.41
      version = "v0.2.41";
      version-dashed = builtins.replaceStrings ["."] ["-"] version;
      exe = "batiq";
      path = "/mounts/data/sshfs/share/tools/batiq-${version}-linux-x86_64";
      # # Deps
      pkgs-deps-batiq = with pkgs; [
#        libxxf86vm
#        libdecor
#
#        ## For Ayon Launcher
#        glib
#        fontconfig
#        freetype
#        xwayland
#        qt5.qtwayland
#        qt6.qtwayland
#        libxcb
#        libxcb-image
#        libxcb-render-util
#        libxcb-cursor
#        libxcb-keysyms
#        libxcb-wm
#
#        # testing manual command
#        zlib
#        zstd
#        dbus
#        libc
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

        # No effect; still uses xterm:
        # export TERM=linux

        export DEFAULT_ARGS="${builtins.toString batiq-default-args}"
      '';

      fhs-batiq = pkgs.buildFHSEnv {
        name = "batiq-${version-dashed}-package";
        inherit profile;

        runScript = pkgs.lib.getExe runScript-batiq;

        # tarkgetPkgs expects a function
        targetPkgs = pkgs: (pkgs-deps-batiq);
      };

      pkgs-dev-batiq = (with pkgs; [
        # fhs shell
        (pkgs.buildFHSEnv {
          name = "fhs";
          runScript = "bash";
          targetPkgs = pkgs: (pkgs-deps-batiq);
        })
      ]);

      # # This is the launch script for Batiq 0.2.41
      # maybe we could use `/run/current-system/sw/bin/xdg-terminal "command"`
      runScript-batiq = pkgs.writeScriptBin "batiq-${version-dashed}-bin" ''
        echo "Running ${pkgs.lib.getBin (pkgs.glibc)}/bin/ldd $(which ${exe})..." \
          && ${pkgs.lib.getBin (pkgs.glibc)}/bin/ldd $(which ${exe}) | sort --ignore-leading-blanks --ignore-case | grep -E --color "\b(not found)\b|$" \
          && echo "Launching $(which ${exe})" \
          && echo "- with default args \"${builtins.toString batiq-default-args}\"" \
          && echo "- with extra args \"$@\"" \
          && echo "..." \
          && ${exe} ${builtins.toString batiq-default-args} $@
      '';

    batiq-default-args = [
      # "--python-use-system-env"
      # "--enable-autoexec"
      # "--verbose" # expects a verbosity level
      # "4"  # fatal, error, warning, info, debug, and trace
      # "--debug"
      # "--debug-cycles"
      # "--debug-ffmpeg"
    ];

  in

  {
    # https://determinate.systems/blog/nix-run/
    # A simple executable package
    packages = {
      "batiq-${version-dashed}-package" = fhs-batiq;
    };

    # https://discourse.nixos.org/t/flakes-way-of-creating-a-fhs-environment/20821
    # https://nixos.wiki/wiki/Flakes#nix_run
    # https://nix.dev/manual/nix/2.34/command-ref/new-cli/nix3-run.html#apps
    # https://vtimofeenko.com/posts/practical-nix-flake-anatomy-a-guided-tour-of-flake.nix/#apps}
    apps = {
      "batiq-${version-dashed}-app" = {
        type = "app";
        program = self.packages.x86_64-linux."batiq-${version-dashed}-package";
        meta.description = "Launch Batiq ${version}";
      };
    };

    # https://hugosum.com/blog/recreating-development-environment-with-nix-flake
    devshells = {
      "batiq-${version-dashed}-devshell" = {
        packages = pkgs-dev-batiq;
        name = "batiq-${version-dashed}-devshell";
        motd = ''
          You are now in a Batiq ${version} configured environment.
          Call "fhs" to setup File Hierarchy Standard.

          DEFAULT_ARGS = "$DEFAULT_ARGS"

          Available commands:
          $(find ${path} -maxdepth 1 -type f -executable | sort)
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

          # Custom functions in this section...

          set +a
        '';
        # Custom Env:
        # env = [
        #   {
        #     name = "DEV_SHELL";
        #     value = "batiq-4-4-3";
        #   }
        #   # {
        #   #   name = "PATH";
        #   #   prefix = path;
        #   # }
        #   # {
        #   #   name = "DEFAULT_ARGS";
        #   #   value = "${builtins.toString batiq-default-args}";
        #   # }
        # ];
      };
    };
  };
}
