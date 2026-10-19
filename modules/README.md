

---

# devShells

References:
- https://flake.parts/options/flake-parts.html#opt-flake.devShells
- https://github.com/alucascu/flake-devshells
- https://michael.stapelberg.ch/posts/2025-07-27-dev-shells-with-nix-4-quick-examples/
- https://blog.eigenvalue.net/2024-flake-parts-nodejs-devshell/
- https://github.com/numtide/devshell
- https://import-tree.denful.dev/guides/dendritic/
- https://jeffkreeftmeijer.com/nix-devshells/
- https://devenv.sh/guides/using-with-flake-parts/

---

# LDD (Shared Libraries)

Resources:
- https://github.com/nix-community/nix-ld
  - https://wiki.nixos.org/wiki/Nix-ld
- https://discourse.nixos.org/t/how-to-find-needed-librarys-for-closed-source-bin-applications/39118/132

Example:

```shell
ldd --verbose /data/share/tools/${pname}-${version}-linux-x64/blender > /mnt/home/git/repos/nixos-configuration/configs/components/fhs/buildFHSEnv/blender/ldd__${pname}-${version}-linux-x64.txt
# list missing libs:
ldd /data/share/tools/${pname}-${version}-linux-x64/blender | grep -E " => not found$"
```

Find packages that provide missing libraries:
```shell
# https://discourse.nixos.org/t/how-to-find-needed-librarys-for-closed-source-bin-applications/39118/16
nix run “github:thiagokokada/nix-alien#nix-alien-find-libs” – /home/wolf/APP/stereo_tool_gui_64
```

- `nix search nixpkgs libgcc`

# Shared Objects

Resources:
- https://www.baeldung.com/linux/show-shared-libraries-executables
- https://discourse.nixos.org/t/where-can-i-get-libgthread-2-0-so-0/16937/7


# FHS

- https://nixos.org/manual/nixpkgs/stable/#sec-fhs-environments

`buildFHSEnv` == `buildFHSUserEnv`
- https://discourse.nixos.org/t/difference-between-pkgs-buildfhsenv-and-pkgs-buildfhsuserenv/48712

# Foundry Licensing

- https://support.foundry.com/hc/en-us/articles/207823889-Q100104-How-to-set-up-Nuke-and-Nuke-licenses-for-a-render-farm
