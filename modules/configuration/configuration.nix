{ self, inputs, ... }:

  let
    stateVersion = "26.05";
    # hostName = "lenovo";
  in

  {

  # Todo
  # - [ ] enable automatic GC; potentially in settings-module

  flake.nixosModules.prod-module = { pkgs, ... }: {

#    imports = [
#      self.nixosModules."${hostName}-hardware"
#      self.nixosModules."${hostName}-nvidia"
#      self.nixosModules.shell-module
#      self.nixosModules.nix-settings-module
#      self.nixosModules.trusted-users-module
#      self.nixosModules.settings-module
#      self.nixosModules.openrazer-module
#      # self.nixosModules.filesystems-nfs-module
#      self.nixosModules.webdav-kdrive-module
#      self.nixosModules.package-overrides-module
#      self.nixosModules.system-packages-module
#      self.nixosModules.docker-module
#      self.nixosModules.apptainer-module
#      self.nixosModules.system-fonts-module
#      self.nixosModules.systemd-module
#      self.nixosModules.openssh-service-module
#      self.nixosModules.known-hosts-module
#      self.nixosModules.localization-module
#      self.nixosModules.xserver-module
#      self.nixosModules.kde-plasma-module
#      # self.nixosModules.niri-module
#      # self.nixosModules.stylix-module
#      self.nixosModules.virtualisation-module
#    ];

    # List packages installed in system profile.
    # You can use https://search.nixos.org/ to find more packages (and options).
    environment = {
      sessionVariables = {
        # KEY = "value";
      };
      systemPackages = with pkgs; [
      #   vim # Do not forget to add an editor to edit configuration.nix! The Nano editor is also installed by default.
      #   wget
        # bash
        # Todo: what does this do? bashFHS
#        git
#        git-crypt
#        tree
#        file
#        dnsutils
#        htop
#        btop
#        lshw
#        rsnapshot
#        rclone
#        gparted
#        ffmpeg
#        # qemu_full  # causes errors
#        podman
#        podman-compose
#        podman-tui
#        devenv
#        graphviz
#        libwacom
#        openrazer-daemon
#        sshfs
#        jq
#        bat
        kitty
        alacritty
        # Adding djv from packageOverride in here
        # - [x] works
        # djv
        # nvidia-container-toolkit
      ];
    };

    system.stateVersion = "${stateVersion}";

    security = {
      # Blender
      # Could not query RTKit: No such file or directory
      rtkit = {
        enable = true;
        args = [];
        package = pkgs.rtkit;
      };

      # $ mount /data
      # mount.nfs4: not installed setuid - "user" NFS mounts not supported.
      # - https://github.com/NixOS/nixpkgs/issues/24913
      # - https://discourse.nixos.org/t/cant-mount-samba-share-as-a-user/49171/5
#      wrappers = {
#        mount.source = "${pkgs.utillinux}/bin/mount";
#        umount.source = "${pkgs.utillinux}/bin/umount";
#        "mount.nfs4" = {
#          program = "mount.nfs4";
#          setuid = true;
#          owner = "root";
#          group = "root";
#          source = "${pkgs.nfs-utils.out}/bin/mount.nfs4";
#        };
#        "umount.nfs4" = {
#          program = "umount.nfs4";
#          setuid = true;
#          owner = "root";
#          group = "root";
#          source = "${pkgs.nfs-utils.out}/bin/umount.nfs4";
#        };
#      };
      # config.allowUnfree = true;
      nixpkgs = {
        config = {
          # Allow unfree packages
          allowUnfree = true;
          allowUnfreePredicate = (_: true);
          permittedInsecurePackages = [
            # deps for djv
            "openexr-2.5.10"
            "ilmbase-2.5.10"
            # deps for logseq
            "electron-39.8.10"
          ];
        };
      };
    };
  };

}
