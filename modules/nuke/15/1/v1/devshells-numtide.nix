# an example for github:numtide/devshell shells (see flake.nix also)

{ inputs, self, ... }:

{
  imports = [ inputs.devshell.flakeModule ];

  perSystem =
    { pkgs, ... }:

    let
      # Base Deps
      # For all Nukes?
      pkgs-base = with pkgs; [
        # This could probably need some cleanup
        bash
        ncurses5

        libgssglue
        libkrb5

        glib
        libxcrypt-legacy

        libGLU
        libGL
        alsa-lib
        fontconfig
        zlib
        libpng
        dbus
        nss
        nspr
        expat
        pciutils
        libxkbcommon
        libudev0-shim
        tbb
        xwayland
        qt5.qtwayland
        nettools  # needed by licensing tools
        bintools  # needed for ld and other tools, so ctypes can find/load sos from python
        ocl-icd  # needed for opencl
        numactl  # needed by hfs ocl backend
        zstd  # needed from 20.0

        libice
        libsm
        libxmu
        libxi
        libxext
        libx11
        libxrender
        libxcursor
        libxfixes
        libxcomposite
        libxdamage
        libxtst
        libxcb
        libxscrnsaver
        libxrandr
        libxcb-util
        libxcb-image
        libxcb-render-util
        libxcb-cursor
        libxcb-keysyms
        libxcb-wm
      ];

      # Nuke
      version = "15.1";
      version-dashed = builtins.replaceStrings ["."] ["-"] version;
      v = "v1";
      # version-dashed = builtins.replaceStrings ["."] ["-"] version;
      path = "/data/share/tools/Nuke15.1v1-linux-x86_64";
      # # Deps
      pkgs-deps-nuke = with pkgs; [
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
        # export AYON_BLENDER_USE_SYSTEM_PATH=1

        # No effect; still uses xterm:
        # export TERM=linux

        export DEFAULT_ARGS="${builtins.toString nuke-default-args}"

        export foundry_LICENSE="5053@miniboss.meemoo.lan"
      '';

      fhs-nuke = pkgs.buildFHSEnv {
        name = "nuke-${version}${v}-package";
        inherit profile;

        runScript = pkgs.lib.getExe runScript-nuke;

        # it seems like nix is `exec`ing:
        # runScript = "(${pkgs.lib.getExe runScript-4-4-3})";
        # Results in:
        # /nix/store/22hh7ylmf62r31vzas0ir8da9kprcll8-fhs-blender-4-4-3-init: line 3: syntax error near unexpected token `/nix/store/r8mmqvnjj3ln69slmz1p2c6azkclwr41-blender-4-4-3-bin/bin/blender-4-4-3-bin'
        # /nix/store/22hh7ylmf62r31vzas0ir8da9kprcll8-fhs-blender-4-4-3-init: line 3: `exec (/nix/store/r8mmqvnjj3ln69slmz1p2c6azkclwr41-blender-4-4-3-bin/bin/blender-4-4-3-bin) "$@"'
        # nix run /home/michael/git/repos/my-test-flake-01#blender-4-4-3

        # tarkgetPkgs expects a function
        targetPkgs = pkgs: (pkgs-deps-nuke);

        # houdini spawns hserver (and other license tools) that is supposed to live beyond the lifespan of houdini process
        # dieWithParent = false;

        # houdini needs to communicate with hserver process that it seem to be checking to be present in running processes
        # unsharePid = false;
      };

      pkgs-dev-nuke = (with pkgs; [
        # fhs shell
        (pkgs.buildFHSEnv {
          name = "fhs";
          runScript = "bash";
          targetPkgs = pkgs: (pkgs-deps-nuke);
        })
      ]);

      # # This is the launch script for Blender 4.4.3
      # maybe we could use `/run/current-system/sw/bin/xdg-terminal "command"`
      runScript-nuke = pkgs.writeScriptBin "nuke-${version}${v}-bin" ''
        echo "Running ${pkgs.lib.getBin (pkgs.glibc)}/bin/ldd $(which Nuke${version})..." \
          && ${pkgs.lib.getBin (pkgs.glibc)}/bin/ldd $(which Nuke${version}) | sort --ignore-leading-blanks --ignore-case | grep -E --color "\b(not found)\b|$" \
          && echo "Launching $(which Nuke${version})" \
          && echo "- with default args \"${builtins.toString nuke-default-args}\"" \
          && echo "- with extra args \"$@\"" \
          && echo "..." \
          && Nuke${version} ${builtins.toString nuke-default-args} $@
      '';

      nuke-default-args = [
        # "--python-use-system-env"
        # "--enable-autoexec"
        # "--verbose" # expects a verbosity level
        # "4"  # fatal, error, warning, info, debug, and trace
        # "--debug"
        # "--debug-cycles"
        # "--debug-ffmpeg"
      ];




#      pkgs-base = with pkgs; [
#        # fhs shell
#        (pkgs.buildFHSEnv {
#          name = "fhs";
#          runScript = "bash";
#          # name = "houdini-${unwrapped.version}";
#
#          # # houdini spawns hserver (and other license tools) that is supposed to live beyond the lifespan of houdini process
#          # dieWithParent = false;
#
#          # # houdini needs to communicate with hserver process that it seem to be checking to be present in running processes
#          # unsharePid = false;
#          targetPkgs = pkgs: (with pkgs; [
#            # This could probably need some cleanup
#            bash
#            ncurses5
#
#            libgssglue
#            libkrb5
#
#            glib
#            libxcrypt-legacy
#
#            libGLU
#            libGL
#            alsa-lib
#            fontconfig
#            zlib
#            libpng
#            dbus
#            nss
#            nspr
#            expat
#            pciutils
#            libxkbcommon
#            libudev0-shim
#            tbb
#            xwayland
#            qt5.qtwayland
#            nettools  # needed by licensing tools
#            bintools  # needed for ld and other tools, so ctypes can find/load sos from python
#            ocl-icd  # needed for opencl
#            numactl  # needed by hfs ocl backend
#            zstd  # needed from 20.0
#
#            libice
#            libsm
#            libxmu
#            libxi
#            libxext
#            libx11
#            libxrender
#            libxcursor
#            libxfixes
#            libxcomposite
#            libxdamage
#            libxtst
#            libxcb
#            libxscrnsaver
#            libxrandr
#            libxcb-util
#            libxcb-image
#            libxcb-render-util
#            libxcb-cursor
#            libxcb-keysyms
#            libxcb-wm
#
#          ]);
#        })
#      ];
    in

  {
    # https://determinate.systems/blog/nix-run/
    # A simple executable package
    packages = {
      "nuke-${version-dashed}${v}-package" = fhs-nuke;
    };

    # https://discourse.nixos.org/t/flakes-way-of-creating-a-fhs-environment/20821
    # https://nixos.wiki/wiki/Flakes#nix_run
    # https://nix.dev/manual/nix/2.34/command-ref/new-cli/nix3-run.html#apps
    # https://vtimofeenko.com/posts/practical-nix-flake-anatomy-a-guided-tour-of-flake.nix/#apps}
    apps = {
      "nuke-${version-dashed}${v}-app" = {
        type = "app";
        program = self.packages.x86_64-linux."nuke-${version-dashed}${v}-package";
        meta.description = "Launch Nuke ${version}${v}";
      };
    };

    # https://hugosum.com/blog/recreating-development-environment-with-nix-flake
    devshells = {
      "nuke-${version-dashed}${v}-devshell" = {
        packages = pkgs-dev-nuke;
        name = "nuke-${version}${v}-devshell";
        motd = ''
          You are now in a Nuke ${version}${v} configured environment.
          Call "fhs" to setup File Hierarchy Standard.

          DEFAULT_ARGS = "$DEFAULT_ARGS"

          Available commands:
          $(find ${path} -maxdepth 1 -type f -executable | sort)

          foundry_LICENSE = "$foundry_LICENSE"
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

          # # override houdini with houdini-bin
          # houdini() {
          #   set -x;
          #   command houdini-bin;
          #   set +x;
          # }

          set +a
        '';
        # Custom Env:
        env = [
          {
            name = "DEV_SHELL";
            value = "nuke-${version}${v}";
          }
        ];
#            extraBwrapArgs = [
#              "--ro-bind-try /run/opengl-driver/etc/OpenCL/vendors /etc/OpenCL/vendors" # this is the case of NixOS
#              "--ro-bind-try /etc/OpenCL/vendors /etc/OpenCL/vendors" # this is the case of not NixOS
#            ];
        # runScript = pkgs.writeScript "houdini-wrapper" ''
        #   # ncurses5 is needed by hfs ocl backend
        #   # workaround for this issue: https://github.com/NixOS/nixpkgs/issues/89769
        #   export LD_LIBRARY_PATH=/nix/store/qz68yx7v9zcpq490y6sb83v2dvygj4cr-ncurses-abi5-compat-6.6/lib:$LD_LIBRARY_PATH
        #   exec "$@"
        # '';
        # set the environment variables that Qt apps expect
#            shellHook = ''
#              echo "You are now in a Houdini configured environment."
#              # There must be a better way:
#              # pkgs.ncurses5 ?
#              # export LD_LIBRARY_PATH=/nix/store/qz68yx7v9zcpq490y6sb83v2dvygj4cr-ncurses-abi5-compat-6.6/lib:$LD_LIBRARY_PATH
#              fhs
#            '';
      };
    };






#    devshells = {
#
#      nuke-base = {
#        packages = pkgs-base;
#        name = "nuke-base";
#        motd = ''
#          You are now in a Nuke (base) configured environment.
#        '';
#        devshell.startup.fhs.text = ''
#          exec fhs
#        '';
#        # Custom Env:
#        env = [
#          {
#            name = "DEV_SHELL";
#            value = "nuke-base";
#          }
#          {
#            name = "foundry_LICENSE";
#            value = "5053@miniboss.meemoo.lan";
#          }
#        ];
#      };
#    };
  };
}
