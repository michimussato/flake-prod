# an example for github:numtide/devshell shells (see flake.nix also)

# https://dev.to/arnu515/easy-development-environments-with-nix-and-nix-flakes-21mb

{ inputs, self, ... }:

{
  imports = [ inputs.devshell.flakeModule ];

  perSystem =
    { pkgs, lib, ... }:

    let
      # Base Deps
      # For all Houdinis?
      pkgs-base = with pkgs; [
        bash
        ncurses5
        xmessage
        curl

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

        libdrm
        libxshmfence
        libxkbfile
      ];

      # Houdini 21.0.792
      version = "21.0.792";
      version-dashed = builtins.replaceStrings ["."] ["-"] version;
      houdini-setup-base = "/data/share/tools/houdini-${version}-linux_x86_64_gcc11.2";
      path = "${houdini-setup-base}/bin";
      # # Deps
      pkgs-deps-houdini = with pkgs; [
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

        export DEFAULT_ARGS="${builtins.toString houdini-default-args}"

        export SESI_LMHOST="http://miniboss.meemoo.lan:1715"
      '';

      fhs-houdini = pkgs.buildFHSEnv {
        name = "houdini-${version-dashed}-package";
        # /data/share/tools/blender-4.4.3-linux-x64/blender
        # bash: /data/share/tools/blender-4.4.3-linux-x64/blender: Permission denied
        inherit profile;

        runScript = pkgs.lib.getExe runScript-houdini;

        # it seems like nix is `exec`ing:
        # runScript = "(${pkgs.lib.getExe runScript-4-4-3})";
        # Results in:
        # /nix/store/22hh7ylmf62r31vzas0ir8da9kprcll8-fhs-blender-4-4-3-init: line 3: syntax error near unexpected token `/nix/store/r8mmqvnjj3ln69slmz1p2c6azkclwr41-blender-4-4-3-bin/bin/blender-4-4-3-bin'
        # /nix/store/22hh7ylmf62r31vzas0ir8da9kprcll8-fhs-blender-4-4-3-init: line 3: `exec (/nix/store/r8mmqvnjj3ln69slmz1p2c6azkclwr41-blender-4-4-3-bin/bin/blender-4-4-3-bin) "$@"'
        # nix run /home/michael/git/repos/my-test-flake-01#blender-4-4-3

        # tarkgetPkgs expects a function
        targetPkgs = pkgs: (pkgs-deps-houdini);

        # houdini spawns hserver (and other license tools) that is supposed to live beyond the lifespan of houdini process
        dieWithParent = false;

        # houdini needs to communicate with hserver process that it seem to be checking to be present in running processes
        unsharePid = false;
      };

      pkgs-dev-houdini = (with pkgs; [
        # fhs shell
        (pkgs.buildFHSEnv {
          name = "fhs";
          runScript = "bash";
          targetPkgs = pkgs: (pkgs-deps-houdini);
        })
      ]);

      # # This is the launch script for Blender 4.4.3
      # maybe we could use `/run/current-system/sw/bin/xdg-terminal "command"`
      runScript-houdini = pkgs.writeScriptBin "houdini-${version-dashed}-bin" ''
        echo "Running ${pkgs.lib.getBin (pkgs.glibc)}/bin/ldd $(which houdini-bin)..." \
          && ${pkgs.lib.getBin (pkgs.glibc)}/bin/ldd $(which houdini-bin) | sort --ignore-leading-blanks --ignore-case | grep -E --color "\b(not found)\b|$" \
          && echo "Launching $(which houdini-bin)" \
          && echo "- with default args \"${builtins.toString houdini-default-args}\"" \
          && echo "- with extra args \"$@\"" \
          && echo "..." \
          && houdini-bin ${builtins.toString houdini-default-args} $@
      '';

    houdini-default-args = [
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
      "houdini-${version-dashed}-package" = fhs-houdini;
    };

    # https://discourse.nixos.org/t/flakes-way-of-creating-a-fhs-environment/20821
    # https://nixos.wiki/wiki/Flakes#nix_run
    # https://nix.dev/manual/nix/2.34/command-ref/new-cli/nix3-run.html#apps
    # https://vtimofeenko.com/posts/practical-nix-flake-anatomy-a-guided-tour-of-flake.nix/#apps}
    apps = {
      "houdini-${version-dashed}-app" = {
        type = "app";
        program = self.packages.x86_64-linux."houdini-${version-dashed}-package";
        meta.description = "Launch Houdini ${version}";
      };
    };

    # https://hugosum.com/blog/recreating-development-environment-with-nix-flake
    devshells = {
      "houdini-${version-dashed}-devshell" = {
        packages = pkgs-dev-houdini;
        name = "houdini-${version-dashed}-devshell";
        motd = ''
          You are now in a Houdini ${version} configured environment.
          Call "fhs" to setup File Hierarchy Standard.

          DEFAULT_ARGS = "$DEFAULT_ARGS"

          Available commands:
          $(find ${path} -maxdepth 1 -type f -executable | sort)

          SESI_LMHOST = "$SESI_LMHOST"
        '';
        devshell.startup.fhs.text = ''
          echo "Initializing Houdini..."
          echo "sourcing houdini_setup..."
          pushd ${houdini-setup-base} &> /dev/null
          source ./houdini_setup
          popd &> /dev/null

          # `inherit profile;` does not work for devshells.
          # so seems to be the only option to get the
          # same env in the devshell
          ${profile}

          # aliases are not exported to subshells
          # hence, use functions
          #
          # automatically export all functions declared here:
          set -a

          # override houdini with houdini-bin
          houdini() {
            set -x;
            command houdini-bin;
            set +x;
          }

          # blender() {
          #   set -x;
          #   command blender $DEFAULT_ARGS "$@";
          #   set +x;
          # }

          # blenderpy() {
          #   set -x;
          #   command blender $DEFAULT_ARGS --background --python-console "$@";
          #   set +x;
          # }

          set +a
        '';
        # Custom Env:
        # env = [
        #   {
        #     name = "DEV_SHELL";
        #     value = "houdini-base";
        #   }
        # ];
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
  };
}
