{
  pkgs ? import <nixpkgs> { },
}:

# https://ryantm.github.io/nixpkgs/build-helpers/special/fhs-environments/
(pkgs.buildFHSEnv {
  name = "simple-x11-env-for-ayon";
  targetPkgs =
    pkgs:
    (with pkgs; [
      kitty
      # /home/michael/Downloads/AYON-1.6.3-linux-rocky9/ayon --headless
      # - AYON_SERVER_URL
      # - AYON_API_KEY
      #   - https://help.ayon.app/en/help/articles/6698141-user-management#klrl452c446
      # Base Packages
      zlib
      zstd
      glib
      libGL
      fontconfig
      libx11
      libxkbcommon
      freetype
      dbus

      # Tray Packages
      libxcb
      libxcb-image
      libxcb-render-util
      libxcb-cursor
      libxcb-keysyms
      libxcb-wm

    ]);
#  multiPkgs =
#    pkgs:
#    (with pkgs; [
#      udev
#      alsa-lib
#    ]);
  # Ex:
  # /home/michael/Downloads/AYON-1.6.3-linux-rocky9/ayon addon applications launch-by-workfile-id --app blender/5-2-1 --project MovieNight --workfile-id 0b2c731a44cf4e1d88f5064be8c618bc
  # /home/michael/Downloads/AYON-1.6.3-linux-rocky9/ayon addon applications launch-debug-terminal --app blender/4-4-3 --project MovieNight --task-id eeb25140c0a011f1ab1401744809f87a
  # /home/michael/Downloads/AYON-1.6.3-linux-rocky9/ayon addon applications launch-by-id --app blender/4-4-3 --project MovieNight --task-id eeb25140c0a011f1ab1401744809f87a
  #
  # $ /home/michael/Downloads/AYON-1.6.3-linux-rocky9/ayon addon applications launch-by-id --app blender/4-4-3-alacritty --project MovieNight --task-id eeb25140c0a011f1ab1401744809f87a
  # >>> [  Colorspace management is disabled globally.  ]
  # >>> [  Executable does not lead to blender file.Can't determine blender's python to check/install Qt binding.  ]
  # >>> [  Launching "blender/4-4-3-alacritty" with args (10): ['/run/current-system/sw/bin/alacritty', '--hold', '--title', 'Dummy Title', '--command', '/run/current-system/sw/bin/nix', 'run', '/home/michael/git/repos/flake-prod#blender-4-4-3-app', '--', '/data/share/projects/ayon/MovieNight/shot/work/rendering/MoN_shot_rendering_v021_4-4-3.blend']  ]
  # runScript = "set -x; /home/michael/Downloads/AYON-1.6.3-linux-rocky9/ayon --debug --verbose debug";
  runScript = "bash";
#  runScript = "env";
   profile = ''
     export AYON_SERVER_URL=https://ayon.openstudiolandscapes.meemoo.ch
     # export AYON_API_USER=ayon_tray
     # export AYON_API_KEY=<API_KEY>
     #
     # Setting XTERM seems to be needed when launching ayon from an IDE terminal
     # https://runebook.dev/en/docs/python/library/curses/curses.setupterm
     # Values for TERM:
     # - xtern
     # - screen
     # - linux
     # - xterm-256color
     export TERM=linux
     # Not sure yet if TERMINFO is needed as well
     # export TERMINFO=/etc/terminfo
   '';
}).env
