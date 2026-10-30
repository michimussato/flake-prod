{

  packages.${pkgs.stdenv.hostPlatform.system}.default = pkgs.symlinkJoin {
    name = "blender";
    buildInputs = [
      (pkgs.buildFHSEnv {
        name = "blender-fhs";
        runScript = pkgs.writeScriptBin "blender-fhs-bin" ''
          #!${pkgs.lib.getExe pkgs.bash}
          /data/share/tools/blender-4.4.3-linux-x64/blender --python-use-system-env --verbose 4 --debug --debug-cycles --debug-ffmpeg
        '';
        #runScript = "/data/share/tools/blender-4.4.3-linux-x64/blender --python-use-system-env --verbose 4 --debug --debug-cycles --debug-ffmpeg";
      })
    ];
  };

}