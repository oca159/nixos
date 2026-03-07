{
  description = "Osvaldo's NixOS Configuration";

  inputs = {
      nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
      rust-overlay.url = "github:oxalica/rust-overlay";
      wezterm.url = "github:wez/wezterm?dir=nix";
      nix-ai-tools.url = "github:numtide/nix-ai-tools";
      catppuccin.url = "github:catppuccin/nix";
      home-manager.url = "github:nix-community/home-manager";
      home-manager.inputs.nixpkgs.follows = "nixpkgs";  };

  outputs = { nixpkgs, catppuccin, home-manager, ... } @ inputs:
  {
    nixosConfigurations.beelink = nixpkgs.lib.nixosSystem {
      specialArgs = { inherit inputs; };
      modules = [
        ./configuration.nix
        ./hardware-configuration.nix
        ./auto-upgrade.nix
        ./fonts.nix
        ./gc.nix
        ./gnome.nix
        ./terminal.nix
        home-manager.nixosModules.home-manager
        {
          home-manager = {
            useGlobalPkgs = true;
            useUserPackages = true;
            users.osvaldo.imports = [
              ./home.nix
              catppuccin.homeModules.catppuccin
            ];
            backupFileExtension = "backup";
          };
        }
      ];
    };
  };
}
