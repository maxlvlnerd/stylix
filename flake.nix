{
  inputs = {
    base16-alacritty = {
      flake = false;
      url = "github:aarowill/base16-alacritty";
    };

    base16-alacritty-yaml = {
      flake = false;
      url = "github:aarowill/base16-alacritty/63d8ae5dfefe5db825dd4c699d0cdc2fc2c3eaf7";
    };

    base16-fish = {
      flake = false;
      url = "github:tomyun/base16-fish";
    };

    base16-foot = {
      flake = false;
      url = "github:tinted-theming/base16-foot";
    };

    base16-helix = {
      flake = false;
      url = "github:tinted-theming/base16-helix";
    };

    base16-tmux = {
      flake = false;
      url = "github:tinted-theming/base16-tmux";
    };

    base16-kitty = {
      flake = false;
      url = "github:kdrag0n/base16-kitty";
    };

    base16-vim = {
      flake = false;
      url = "github:chriskempson/base16-vim";
    };

    base16.url = "github:SenchoPens/base16.nix";

    flake-compat = {
      flake = false;
      url = "github:edolstra/flake-compat";
    };

    gnome-shell = {
      flake = false;

      # TODO: Unlocking the input and pointing to official repository requires
      # updating the patch:
      # https://github.com/danth/stylix/pull/224#discussion_r1460339607.
      url = "github:GNOME/gnome-shell/45.1";
    };

    # The 'home-manager' input is used to generate the documentation.
    home-manager = {
      inputs.nixpkgs.follows = "nixpkgs";
      url = "github:nix-community/home-manager/release-23.11";
    };

    nixpkgs.url = "github:NixOS/nixpkgs/nixos-23.11";
  };

  outputs = {
    nixpkgs,
    base16,
    self,
    ...
  } @ inputs: {
    packages =
      nixpkgs.lib.genAttrs [
        "aarch64-darwin"
        "aarch64-linux"
        "i686-linux"
        "x86_64-darwin"
        "x86_64-linux"
      ] (
        system: let
          pkgs = nixpkgs.legacyPackages.${system};
        in {
          docs = import ./docs {
            inherit pkgs inputs;
            inherit (nixpkgs) lib;
          };

          palette-generator = pkgs.callPackage ./palette-generator {};
        }
      );

    nixosModules.stylix = {pkgs, ...} @ args: {
      imports = [
        (import ./stylix/nixos inputs {
          inherit (self.packages.${pkgs.system}) palette-generator;
          base16 = base16.lib args;
          homeManagerModule = self.homeManagerModules.stylix;
        })
      ];
    };

    homeManagerModules.stylix = {pkgs, ...} @ args: {
      imports = [
        (import ./stylix/hm inputs {
          inherit (self.packages.${pkgs.system}) palette-generator;
          base16 = base16.lib args;
        })
      ];
    };

    darwinModules.stylix = {pkgs, ...} @ args: {
      imports = [
        (import ./stylix/darwin inputs {
          inherit (self.packages.${pkgs.system}) palette-generator;
          base16 = base16.lib args;
          homeManagerModule = self.homeManagerModules.stylix;
        })
      ];
    };
  };
}
