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
      version = "4.4.3";
      version-dashed = builtins.replaceStrings ["."] ["-"] version;
      path = "/data/share/tools/blender-${version}-linux-x64";
      # # Deps
      pkgs-deps-blender = with pkgs; [
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

        export BLENDER_USER_SCRIPTS="/data/share/tools/AYON-deps/addons/blender_1.1.9/ayon_blender/blender_addon/"

        # don't remember what this was for:
        # (does not seem to have an effect on the env anyway)
        # an alternative could be to use lib.makeLibraryPath
        # - https://noogle.dev/f/lib/makeLibraryPath/
        export LD_LIBRARY_PATH=${pkgs.lib.makeLibraryPath [
          pkgs.wayland
        ]}:$LD_LIBRARY_PATH

        # export QT_QPA_PLATFORM=xcb
        # Does this have an effect?
        # equivalent to --python-use-system-env
        export AYON_BLENDER_USE_SYSTEM_PATH=1

        # No effect; still uses xterm:
        # export TERM=linux

        export DEFAULT_ARGS="${builtins.toString blender-default-args}"
      '';

      fhs-blender = pkgs.buildFHSEnv {
        name = "blender-${version-dashed}-package";
        # /data/share/tools/blender-4.4.3-linux-x64/blender
        # bash: /data/share/tools/blender-4.4.3-linux-x64/blender: Permission denied
        inherit profile;

        runScript = pkgs.lib.getExe runScript-blender;

        # it seems like nix is `exec`ing:
        # runScript = "(${pkgs.lib.getExe runScript-4-4-3})";
        # Results in:
        # /nix/store/22hh7ylmf62r31vzas0ir8da9kprcll8-fhs-blender-init: line 3: syntax error near unexpected token `/nix/store/r8mmqvnjj3ln69slmz1p2c6azkclwr41-blender-4-4-3-bin/bin/blender-4-4-3-bin'
        # /nix/store/22hh7ylmf62r31vzas0ir8da9kprcll8-fhs-blender-init: line 3: `exec (/nix/store/r8mmqvnjj3ln69slmz1p2c6azkclwr41-blender-4-4-3-bin/bin/blender-4-4-3-bin) "$@"'
        # nix run /home/michael/git/repos/my-test-flake-01#blender-4-4-3

        # tarkgetPkgs expects a function
        targetPkgs = pkgs: (pkgs-deps-blender);
      };

      pkgs-dev-blender = (with pkgs; [
        # fhs shell
        (pkgs.buildFHSEnv {
          name = "fhs";
          runScript = "bash";
          targetPkgs = pkgs: (pkgs-deps-blender);
        })
      ]);

      # # This is the launch script for Blender 4.4.3
      # maybe we could use `/run/current-system/sw/bin/xdg-terminal "command"`
      runScript-blender = pkgs.writeScriptBin "blender-${version-dashed}-bin" ''
        echo "Process ID:" $$

        echo "BLENDER_USER_SCRIPTS is:" $BLENDER_USER_SCRIPTS

        # We can't use `readlink /data` in the container
        # echo "/data points to: $(readlink /data)"

        ${pkgs.util-linux}/bin/findmnt --task 1 /mounts/data/sshfs > /dev/null

        # $? represents the last return code
        if [ $? -gt 0 ]; then
          echo -e "\nIs /data mounted?\n"
          echo "Exitting."
          exit 1
        fi

        echo "PYTHONPATH =" $PYTHONPATH
        # PYTHONPATH = /data/share/tools/AYON-deps/addons/blender_1.1.9/ayon_blender/blender_addon:/data/share/tools/AYON-deps/addons/core_1.9.12/ayon_core/vendor/python:/data/share/tools/AYON-1.6.3-linux-rocky9/common:/data/share/tools/AYON-1.6.3-linux-rocky9/dependencies:/data/share/tools/AYON-deps/addons/aftereffects_0.3.7:/data/share/tools/AYON-deps/addons/applications_1.4.6:/data/share/tools/AYON-deps/addons/ayon_ocio_1.2.2:/data/share/tools/AYON-deps/addons/ayon_third_party_1.4.0:/data/share/tools/AYON-deps/addons/blender_1.1.9:/data/share/tools/AYON-deps/addons/celaction_0.2.5:/data/share/tools/AYON-deps/addons/cinema4d_0.2.0:/data/share/tools/AYON-deps/addons/clockify_0.2.2:/data/share/tools/AYON-deps/addons/core_1.9.12:/data/share/tools/AYON-deps/addons/deadline_0.7.3:/data/share/tools/AYON-deps/addons/equalizer_0.2.1:/data/share/tools/AYON-deps/addons/flame_1.4.3:/data/share/tools/AYON-deps/addons/fusion_0.4.2:/data/share/tools/AYON-deps/addons/harmony_0.5.4:/data/share/tools/AYON-deps/addons/hiero_0.6.3:/data/share/tools/AYON-deps/addons/houdini_0.10.7:/data/share/tools/AYON-deps/addons/kitsu_1.2.7:/data/share/tools/AYON-deps/addons/marvelous_designer_1.1.3:/data/share/tools/AYON-deps/addons/max_0.5.1:/data/share/tools/AYON-deps/addons/maya_0.6.12:/data/share/tools/AYON-deps/addons/mocha_1.1.0:/data/share/tools/AYON-deps/addons/motionbuilder_0.2.1:/data/share/tools/AYON-deps/addons/nuke_0.4.15:/data/share/tools/AYON-deps/addons/openrv_1.2.3:/data/share/tools/AYON-deps/addons/photoshop_0.4.7:/data/share/tools/AYON-deps/addons/premiere_0.2.3:/data/share/tools/AYON-deps/addons/resolve_0.6.3:/data/share/tools/AYON-deps/addons/silhouette_0.2.2:/data/share/tools/AYON-deps/addons/sitesync_1.3.2:/data/share/tools/AYON-deps/addons/slack_1.3.1:/data/share/tools/AYON-deps/addons/substancedesigner_0.2.1:/data/share/tools/AYON-deps/addons/substancepainter_0.3.6:/data/share/tools/AYON-deps/addons/timers_manager_0.2.0:/data/share/tools/AYON-deps/addons/traypublisher_0.4.5:/data/share/tools/AYON-deps/addons/tvpaint_0.4.3:/data/share/tools/AYON-deps/addons/unreal_0.4.0:/data/share/tools/AYON-deps/addons/zbrush_0.4.1:/data/share/tools/AYON-deps/dependency_packages/ayon_2609041250_linux-rocky9.zip/dependencies

        echo "Running ${pkgs.lib.getBin (pkgs.glibc)}/bin/ldd $(which blender)..." \
          && ${pkgs.lib.getBin (pkgs.glibc)}/bin/ldd $(which blender) | sort --ignore-leading-blanks --ignore-case | grep -E --color "\b(not found)\b|$" \
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
      "blender-${version-dashed}-package" = fhs-blender;
    };

    # https://discourse.nixos.org/t/flakes-way-of-creating-a-fhs-environment/20821
    # https://nixos.wiki/wiki/Flakes#nix_run
    # https://nix.dev/manual/nix/2.34/command-ref/new-cli/nix3-run.html#apps
    # https://vtimofeenko.com/posts/practical-nix-flake-anatomy-a-guided-tour-of-flake.nix/#apps}
    apps = {
      "blender-${version-dashed}-app" = {
        type = "app";
        program = self.packages.${pkgs.stdenv.hostPlatform.system}."blender-${version-dashed}-package";
        meta.description = "Launch Blender ${version}";
      };
    };

    # https://hugosum.com/blog/recreating-development-environment-with-nix-flake
    devshells = {
      "blender-${version-dashed}-devshell" = {
        packages = pkgs-dev-blender;
        name = "blender-${version-dashed}-devshell";
        motd = ''
          You are now in a Blender ${version} configured environment.
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
