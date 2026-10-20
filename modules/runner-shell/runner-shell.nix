# an example for github:numtide/devshell shells (see flake.nix also)

# https://dev.to/arnu515/easy-development-environments-with-nix-and-nix-flakes-21mb

{ inputs, self, ... }:

{
  imports = [ inputs.devshell.flakeModule ];

  perSystem =
    { pkgs, lib, ... }:

  {

    # https://hugosum.com/blog/recreating-development-environment-with-nix-flake
    devshells = rec {
      # Sets the default dev shell so that
      # - `nix develop github:michimussato/flake-prod`
      # is the implicit equivalent of
      # - `nix develop github:michimussato/flake-prod#prod-term`
      default = prod-term;
      prod-term = {
        packages = with pkgs; [
          alacritty
          kitty
        ];
        name = "prod-runner-wrapper-shell";
        # [`nix flake show` command](https://nix.dev/manual/nix/2.34/command-ref/new-cli/nix3-flake-show.html)
        motd = ''
          `draw_dash_line`
          You are in the prod runner wrapper shell.
          It provides basic package dependencies
          that allows us to launch any DCC through
          them without directly requiring them on
          the host system.

          `draw_dash_line`
          `nix flake show github:michimussato/flake-prod`
          `draw_dash_line`

          Some example commands:
          - nix develop github:michimussato/flake-prod#blender-4-4-3-devshell
          - alacritty --command nix run github:michimussato/flake-prod#blender-4-4-3-app
        '';
        devshell.startup.prod-term-profile.text = ''
          # `inherit profile;` does not work for devshells.
          # so seems to be the only option to get the
          # same env in the devshell
          #$profile

          # aliases are not exported to subshells
          # hence, use functions
          #
          # automatically export all functions declared here:
          set -a

          # References:
          # - [How to Draw a Full-Width Horizontal Line with Dashes in Bash Terminal (Dynamic Width & Color Guide)](https://linuxvox.com/blog/draw-a-horizontal-line-from-dash-character-occupying-the-full-width-of-a-terminal-in-bash/)
          draw_dash_line() {
            # set -x;
            local width=$(tput cols 2>/dev/null || echo 80);
            printf '%*s\n' "$width" | tr ' ' '-';
            # set +x;
          }

          set +a
        '';
      };
    };
  };
}
