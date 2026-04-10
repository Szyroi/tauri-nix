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
    homeManagerModules = {
      tauri = ./modules/tauri/tauri.nix;
      default = self.homeManagerModules.tauri;
    };
    homeManagerModule = self.homeManagerModules.tauri;
    homeModules = self.homeManagerModules;
  };
}
