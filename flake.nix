{
  description = "Tauri development environment module for Home Manager";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = {
    self,
    nixpkgs,
    ...
  } @ inputs: {
    nixosModules = {
      tauri = ./tauri-nix/nixos.nix;
      default = self.nixosModules.tauri;
    };

    homeManagerModules = {
      tauri = ./tauri-nix/home-manager/tauri.nix;
      default = self.homeManagerModules.tauri;
    };
    homeManagerModule = self.homeManagerModules.tauri;
    homeModules = self.homeManagerModules;
  };
}
