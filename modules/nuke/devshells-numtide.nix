# an example for github:numtide/devshell shells (see flake.nix also)

{ inputs, ... }:

{
  imports = [ inputs.devshell.flakeModule ];

  perSystem =
    { pkgs, ... }:

    let
      pkgs-base = with pkgs; [
        # fhs shell
        (pkgs.buildFHSEnv {
          name = "fhs";
          runScript = "bash";
          # name = "houdini-${unwrapped.version}";

          # # houdini spawns hserver (and other license tools) that is supposed to live beyond the lifespan of houdini process
          # dieWithParent = false;

          # # houdini needs to communicate with hserver process that it seem to be checking to be present in running processes
          # unsharePid = false;
          targetPkgs = pkgs: (with pkgs; [
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

          ]);
        })
      ];
    in

  {
    devshells = {

      nuke-base = {
        packages = pkgs-base;
        name = "nuke-base";
        motd = ''
          You are now in a Nuke (base) configured environment.
        '';
        devshell.startup.fhs.text = ''
          exec fhs
        '';
        # Custom Env:
        env = [
          {
            name = "DEV_SHELL";
            value = "nuke-base";
          }
          {
            name = "foundry_LICENSE";
            value = "5053@miniboss.meemoo.lan";
          }
        ];
      };
    };
  };
}
