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

      fhs-blender-4-4-3 = pkgs.buildFHSEnv {
        name = "blender-4-4-3-package";
        # /data/share/tools/blender-4.4.3-linux-x64/blender
        # bash: /data/share/tools/blender-4.4.3-linux-x64/blender: Permission denied
        profile = ''
          export PATH=${path}:$PATH
          export LD_LIBRARY_PATH=${pkgs.wayland}/lib:$LD_LIBRARY_PATH
          # export QT_QPA_PLATFORM=xcb
          export AYON_BLENDER_USE_SYSTEM_PATH=1
          # No effect; still uses xterm:
          # export TERM=linux
        '';

        runScript = pkgs.lib.getExe runScript-4-4-3;

        # it seems like nix is `exec`ing:
        # runScript = "(${pkgs.lib.getExe runScript-4-4-3})";
        # Results in:
        # /nix/store/22hh7ylmf62r31vzas0ir8da9kprcll8-fhs-blender-4-4-3-init: line 3: syntax error near unexpected token `/nix/store/r8mmqvnjj3ln69slmz1p2c6azkclwr41-blender-4-4-3-bin/bin/blender-4-4-3-bin'
        # /nix/store/22hh7ylmf62r31vzas0ir8da9kprcll8-fhs-blender-4-4-3-init: line 3: `exec (/nix/store/r8mmqvnjj3ln69slmz1p2c6azkclwr41-blender-4-4-3-bin/bin/blender-4-4-3-bin) "$@"'
        # nix run /home/michael/git/repos/my-test-flake-01#blender-4-4-3

        # tarkgetPkgs expects a function
        targetPkgs = pkgs: (pkgs-deps-blender-4-4-3);
      };

      pkgs-dev-4-4-3 = (with pkgs; [
        # fhs shell
        (pkgs.buildFHSEnv {
          name = "fhs";
          runScript = "bash";
          targetPkgs = pkgs: (pkgs-deps-blender-4-4-3);
        })
      ]);

      # # This is the launch script for Blender 4.4.3
      runScript-4-4-3 = pkgs.writeScriptBin "blender-4-4-3-bin" ''
        echo "Running ${pkgs.lib.getBin (pkgs.glibc)}/bin/ldd $(which blender)..." \
          && ${pkgs.lib.getBin (pkgs.glibc)}/bin/ldd $(which blender) \
          && echo "Launching $(which blender)" \
          && echo "- with default args \"${builtins.toString blender-default-args}\"" \
          && echo "- with extra args \"$@\"" \
          && echo "..." \
          && blender ${builtins.toString blender-default-args} $@
      '';

#      # Blender 5
#      # # Deps
#      pkg-deps-blender-5 = pkgs: (with pkgs; [
#        udev
#        alsa-lib
#        libX11
#        libXrender
#        libXfixes
#        libXi
#        libxkbcommon
#        libSM
#        libICE
#        libGL

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
#      ]);

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

      blender-4-4-3-package = fhs-blender-4-4-3;

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

      blender-4-4-3-app = {
        # This does not work
        # $ nix run .#blender-4-4-3-shell
        # $ /home/michael/Downloads/AYON-1.6.3-linux-rocky9/ayon addon applications launch-by-id --app blender/4-4-3 --project MovieNight --task-id eeb25140c0a011f1ab1401744809f87a
        #/home/michael/Downloads/AYON-1.6.3-linux-rocky9/dependencies/blessed/terminal.py:241: UserWarning: Failed to setupterm(kind='xterm-256color'): setupterm: could not find terminal
        #  warnings.warn(msg)
        #>>> Reached main entry point (0.12s).
        #>>> Connected to AYON server https://ayon.openstudiolandscapes.meemoo.ch
        #>>> Global AYON connection created (0.99s).
        #>>> Distribution finished (1.48s).
        #>>> Bootstrap finished (Total: 1.60s).
        #*** AYON [1.6.3] -------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
        #>>> Using AYON from [ /home/michael/Downloads/AYON-1.6.3-linux-rocky9 ]
        #... AYON variant:        [ production ]
        #... AYON studio bundle:  [ 2026.09.0-2026-10-05-01 ]
        #... AYON project bundle: [ None ]
        #>>> Initializing done (0.03s).
        #>>> loading environments ...
        #  - global AYON ...
        #  - for addons ...
        #/home/michael/Downloads/AYON-1.6.3-linux-rocky9/dependencies/blessed/terminal.py:241: UserWarning: Failed to setupterm(kind='xterm-256color'): setupterm: could not find terminal
        #  warnings.warn(msg)
        #*** WRN: >>> { clockify }: [  Clockify Workspace is not set in settings.  ]
        #*** WRN: >>> { clockify }: [  Clockify Workspace is not set in settings.  ]
        #
        #*** WRN: >>> { clockify }: [  Clockify Workspace is not set in settings.  ]
        #*** WRN: >>> { clockify }: [  Clockify Workspace is not set in settings.  ]
        #*** WRN: >>> { clockify }: [  Clockify Workspace is not set in settings.  ]
        #>>> [  Will add environments for apps and tools: blender/4-4-3  ]
        #*** WRN: >>> { clockify }: [  Clockify Workspace is not set in settings.  ]
        #>>> [  Last workfile does not exist.  ]
        #>>> [  Seems like old version of settings is used. Can't access custom templates in host "blender".  ]
        #>>> [  Registered custom templates didn't match current context.  ]
        #>>> [  Colorspace management is disabled globally.  ]
        #>>> [  Current context does not have any workfile yet.  ]
        #>>> [  Executable does not lead to blender file.Can't determine blender's python to check/install Qt binding.  ]
        #>>> [  Launching "blender/4-4-3" with args (4): ['/run/current-system/sw/bin/nix', 'run', '/home/michael/git/repos/my-test-flake-01#blender-4-4-3', '--']  ]
        #*** WRN: >>> { PostStartTimerHook }: [  Couldn't find webserver url  ]
        #
        #
        # Problematic line:
        #>>> [  Executable does not lead to blender file.Can't determine blender's python to check/install Qt binding.  ]
        #
        #
        # Variant:
        #
        #{
        #  "name": "4-4-3",
        #  "label": "4.4.3",
        #  "group_label": "",
        #  "show_grouped": true,
        #  "executables": {
        #    "windows": [],
        #    "linux": [
        #        "/run/current-system/sw/bin/nix"
        #    ],
        #    "darwin": []
        #    },
        #  "arguments": {
        #    "windows": [],
        #    "linux": [
        #        "run",
        #        "/home/michael/git/repos/my-test-flake-01#blender-4-4-3",
        #        "--"
        #    ],
        #    "darwin": []
        #    },
        #  "environment": "{}",
        #  "redirect_output": true
        #}
        type = "app";
        program = self.packages.x86_64-linux.blender-4-4-3-package;
        meta.description = "Launch Blender 4.4.3";
      };

      # blender-4-4-3-shell = {
      #   # This works:
      #   # $ nix run .#blender-4-4-3-shell
      #   # $ /home/michael/Downloads/AYON-1.6.3-linux-rocky9/ayon addon applications launch-by-id --app blender/4-4-3-test --project MovieNight --task-id eeb25140c0a011f1ab1401744809f87a
      #   #/home/michael/Downloads/AYON-1.6.3-linux-rocky9/dependencies/blessed/terminal.py:241: UserWarning: Failed to setupterm(kind='xterm-256color'): setupterm: could not find terminal
      #   #  warnings.warn(msg)
      #   #>>> Reached main entry point (0.12s).
      #   #>>> Connected to AYON server https://ayon.openstudiolandscapes.meemoo.ch
      #   #>>> Global AYON connection created (0.97s).
      #   #>>> Distribution finished (2.20s).
      #   #>>> Bootstrap finished (Total: 2.32s).
      #   #*** AYON [1.6.3] -------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
      #   #>>> Using AYON from [ /home/michael/Downloads/AYON-1.6.3-linux-rocky9 ]
      #   #... AYON variant:        [ production ]
      #   #... AYON studio bundle:  [ 2026.09.0-2026-10-05-01 ]
      #   #... AYON project bundle: [ None ]
      #   #>>> Initializing done (0.03s).
      #   #>>> loading environments ...
      #   #  - global AYON ...
      #   #  - for addons ...
      #   #/home/michael/Downloads/AYON-1.6.3-linux-rocky9/dependencies/blessed/terminal.py:241: UserWarning: Failed to setupterm(kind='xterm-256color'): setupterm: could not find terminal
      #   #  warnings.warn(msg)
      #   #*** WRN: >>> { clockify }: [  Clockify Workspace is not set in settings.  ]
      #   #*** WRN: >>> { clockify }: [  Clockify Workspace is not set in settings.  ]
      #   #
      #   #*** WRN: >>> { clockify }: [  Clockify Workspace is not set in settings.  ]
      #   #*** WRN: >>> { clockify }: [  Clockify Workspace is not set in settings.  ]
      #   #*** WRN: >>> { clockify }: [  Clockify Workspace is not set in settings.  ]
      #   #>>> [  Will add environments for apps and tools: blender/4-4-3-test  ]
      #   #*** WRN: >>> { clockify }: [  Clockify Workspace is not set in settings.  ]
      #   #>>> [  Last workfile does not exist.  ]
      #   #>>> [  Seems like old version of settings is used. Can't access custom templates in host "blender".  ]
      #   #>>> [  Registered custom templates didn't match current context.  ]
      #   #>>> [  Colorspace management is disabled globally.  ]
      #   #>>> [  Current context does not have any workfile yet.  ]
      #   #Traceback (most recent call last):
      #   #  File "<string>", line 1, in <module>
      #   #ModuleNotFoundError: No module named 'PySide6'
      #   #*** WRN: >>> { InstallPySideToBlender }: [  Could not import PySide6, will attempt to install it.  ]
      #   #  WARNING: The scripts pyside6-android-deploy, pyside6-assistant, pyside6-balsam, pyside6-balsamui, pyside6-deploy, pyside6-designer, pyside6-genpyi, pyside6-linguist, pyside6-lrelease, pyside6-lupdate, pyside6-metaobjectdump, pyside6-project, pyside6-qml, pyside6-qmlcachegen, pyside6-qmlformat, pyside6-qmlimportscanner, pyside6-qmllint, pyside6-qmlls, pyside6-qmltyperegistrar, pyside6-qsb, pyside6-qtpy2cpp, pyside6-rcc, pyside6-svgtoqml and pyside6-uic are installed in '/home/michael/.local/bin' which is not on PATH.
      #   #  Consider adding this directory to PATH or, if you prefer to suppress this warning, use --no-warn-script-location.
      #   #
      #   #[notice] A new release of pip is available: 24.0 -> 26.2.1
      #   #[notice] To update, run: /data/share/tools/blender-4.4.3-linux-x64/4.4/python/bin/python3.11 -m pip install --upgrade pip
      #   #>>> [  Successfully installed PySide6 module to blender.  ]
      #   #>>> [  Launching "blender/4-4-3-test" with args (2): ['/data/share/tools/blender-4.4.3-linux-x64/blender', '--python-use-system-env']  ]
      #   #*** WRN: >>> { PostStartTimerHook }: [  Couldn't find webserver url  ]
      #   #
      #   #
      #   #
      #   # Variant:
      #   #
      #   #{
      #   #  "name": "4-4-3-test",
      #   #  "label": "4.4.3 Test",
      #   #  "group_label": "",
      #   #  "show_grouped": true,
      #   #  "executables": {
      #   #    "windows": [],
      #   #    "linux": [
      #   #      "/data/share/tools/blender-4.4.3-linux-x64/blender"
      #   #    ],
      #   #    "darwin": []
      #   #  },
      #   #  "arguments": {
      #   #    "windows": [],
      #   #    "linux": [
      #   #      "--python-use-system-env"
      #   #    ],
      #   #    "darwin": []
      #   #  },
      #   #  "environment": "{}",
      #   #  "redirect_output": true
      #   #}
      #   #
      #   type = "app";
      #   meta.description = "Launch Blender 4.4.3";
      #   program = pkgs.buildFHSEnv {
      #     name = "fhs-blender-4-4-3";
      #     profile = ''
      #       export PATH=/data/share/tools/blender-4.4.3-linux-x64/:$PATH
      #       export LD_LIBRARY_PATH=${pkgs.wayland}/lib:$LD_LIBRARY_PATH
      #       # export QT_QPA_PLATFORM=xcb
      #       export AYON_BLENDER_USE_SYSTEM_PATH=1
      #     '';
      #     runScript = "bash";
      #     # nix run /home/michael/git/repos/my-test-flake-01#blender-4-4-3
      #     # runScript = "bash";
      #     targetPkgs = pkg-deps-blender-4-4-3;
      #   };
      # };

#      blender-5-2-1-app = {
#        type = "app";
#        meta.description = "Launch Blender 5.2.1";
#        program = pkgs.buildFHSEnv {
#          name = "fhs-blender-5";
#  #        runScript = "bash";
#  #        runScript = "ls -al /";
#          # nix run --set-env-var PATH /data/share/tools/blender-5.2.1-linux-x64:$PATH /home/michael/git/repos/my-test-flake-01#blender-5
#          # nix run --set-env-var PATH /data/share/tools/blender-5.2.1-linux-x64:$PATH /home/michael/git/repos/my-test-flake-01#blender-5 -- --help
#          # runScript = "blender";
#          # Custom Env:
#          profile = ''
#            export PATH=/data/share/tools/blender-5.2.1-linux-x64:$PATH
#            export LD_LIBRARY_PATH=${pkgs.wayland}/lib:$LD_LIBRARY_PATH
#            # export QT_QPA_PLATFORM=xcb
#          '';
#  #        runScript = ''
#  #          ${pkgs.lib.getBin (pkgs.glibc)}/bin/ldd $(which blender) \
#  #          && blender --python-use-system-env --debug
#  #        '';
#
#          #runScript = "${packages.blender-5-bin}/bin/blender-5-bin";
#  #        runScript = "bash";
#          runScript = pkgs.lib.getExe self.packages.x86_64-linux.blender-5-2-1;
#
#          targetPkgs = pkg-deps-blender-5;
#  #      }; in "ls -al /";
#        }; # in pkgs.lib.getExe (pkgs.writeShellScriptBin "blender-5" "ls -al /");
#      };
    };

    devshells = {
#      blender-3 = {
#        packages = pkgs-base;
#        name = "blender-3";
#        motd = ''
#          You are now in a Blender 3 configured environment.
#        '';
#        devshell.startup.fhs.text = ''
#          exec fhs
#        '';
#        # Custom Env:
#        env = [
#          {
#            name = "DEV_SHELL";
#            value = "blender-3";
#          }
#          # {
#          #   name = "PATH";
#          #   prefix = "/data/share/tools/blender-5.2.1-linux-x64";
#          # }
#        ];
#      };
      blender-4-4-3-devshell = {
#        packages = self.packages.blender-4-4-3-package.targetPkgs;
        packages = pkgs-dev-4-4-3;
        name = "blender-4-4-3-devshell";
        motd = ''
          You are now in a Blender 4.4.3 configured environment.
          Call "fhs" to setup File Hierarchy Standard.
        '';
        # devshell.startup.fhs.text = ''
        # '';
        # Custom Env:
        env = [
          {
            name = "DEV_SHELL";
            value = "blender-4-4-3";
          }
          {
            name = "PATH";
            prefix = path;
          }
        ];
      };
    };
  };
}