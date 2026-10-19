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

            # houdini spawns hserver (and other license tools) that is supposed to live beyond the lifespan of houdini process
            dieWithParent = false;

            # houdini needs to communicate with hserver process that it seem to be checking to be present in running processes
            unsharePid = false;
            targetPkgs = pkgs: (with pkgs; [
              bash
              ncurses5
              xmessage

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
            ]);
          })
        ];
      in

      {
        devshells = {

          houdini-base = {
            packages = pkgs-base;
            name = "houdini-base";
            motd = ''
              You are now in a Houdini (base) configured environment.
            '';
            devshell.startup.fhs.text = ''
              exec fhs
            '';
            # Custom Env:
            env = [
              {
                name = "DEV_SHELL";
                value = "houdini-base";
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
      };
}
