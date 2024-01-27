{
  description = "Eriim's machine specific configuration flake.";
  #The inputs section defines the sources for the Nix flakes that this configuration depends on. 
  inputs = {
    #The Nix Packages collection, specifically from the nixos-unstable branch on GitHub. 
    #It's a core component providing a vast collection of packages and NixOS modules.
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    #A tool for managing a user's home directory using Nix
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    #A tool for managing secrets using age and Nix, also following nixpkgs for compatibility.
    agenix = {
      url = "github:ryantm/agenix";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.darwin.follows = "";
    };
    #A Wayland compositor
    hyprland = {
      url = "github:hyprwm/hyprland";
    };
    #Collection of Nix packages. Home-rolled, custom built.
    #A custom set of packages and configurations hosted on GitHub by the user 
    eriixpkgs = {
      url = "github:erictossell/eriixpkgs";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    #A configuration for running NixOS on Windows Subsystem for Linux
    NixOS-WSL = {
      url = "github:nix-community/NixOS-WSL";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };
  #The outputs function describes how to transform these inputs 
  #into useful Nix configurations, packages, and development environments.
  outputs = { self, nixpkgs, ... } @ attrs:
    let
      supportedSystems = [ "x86_64-linux" ];
      forAllSystems = nixpkgs.lib.genAttrs supportedSystems;
      nixpkgsFor = forAllSystems (system: import nixpkgs { inherit system; });
    in
    {
      #Defines several NixOS configurations for different machines or purposes, 
      #such as principium, sisyphus, live-image, winix, virtualis, and ambiens. 
      #Each configuration is tailored with specific modules, user, and hostname settings.
      nixosConfigurations = {

        principium =
          let system = "x86_64-linux";
          in nixpkgs.lib.nixosSystem {
            specialArgs = {
              username = "eriim";
              hostname = "principium";
              hyprlandConfig = "desktop";
              inherit system;
            } // attrs;
            modules = [
              ./.
              ./modules/hardware/nvidia
              ./modules/apps/obs
              ./modules/toys
              ./modules/virt
            ];
          }; #principium

        sisyphus =
          let system = "x86_64-linux";
          in nixpkgs.lib.nixosSystem {
            specialArgs = {
              username = "eriim";
              hostname = "sisyphus";
              hyprlandConfig = "laptop";
              inherit system;
            } // attrs;
            modules = [
              ./.
            #which means it likely includes all Nix expressions (*.nix files) present in the current directory. 
            ];
          }; #sisyphus

        live-image =
          let system = "x86_64-linux";
          in nixpkgs.lib.nixosSystem {
            inherit system;
            specialArgs = {
              username = "nixos";
              hostname = "live-image";
              hyprlandConfig = "laptop";
              inherit system;
            } // attrs;
            modules = [
              ./minimal.nix
            ];
          }; #live-image

        winix =
          let system = "x86_64-linux";
          in nixpkgs.lib.nixosSystem {
            inherit system;
            specialArgs = {
              username = "eriim";
              hostname = "winix";
              inherit system;
            } // attrs;
            modules = [
              ./wsl.nix
            ];
          }; #winix-wsl

        virtualis =
          let system = "x86_64-linux";
          in nixpkgs.lib.nixosSystem {
            inherit system;
            specialArgs = {
              username = "eriim";
              hostname = "virtualis";
              inherit system;
            } // attrs;
            modules = [
              ./minimal.nix
            ];
          }; #virtualis

        ambiens =
          let system = "x86_64-linux";
          in nixpkgs.lib.nixosSystem {
            inherit system;
            specialArgs = {
              username = "eriim";
              hostname = "ambiens";
              inherit system;
            } // attrs;
            modules = [
              ./minimal.nix
              ./modules/hardware/network
            ];
          }; #ambiens

      }; #configurations

      #Provides a development shell environment for each supported system, 
      #including useful tools like git, nixpkgs-fmt, and statix.
      devShells = forAllSystems (system:
        let
          pkgs = nixpkgsFor.${system};
        in
        {
          default = pkgs.mkShell {
            buildInputs = with pkgs; [
              git
              nixpkgs-fmt
              statix
            ];
          };
        });
      #Specifies a default template for Eriim's Nix flakes, likely used
      #for initializing new projects with a standard configuration.
      templates.default = {
        path = ./.;
        description = "The default template for Eriim's nixflakes.";
      }; #templates
      #Specifies the nixpkgs-fmt tool for the x86_64-linux system, 
      #likely used for formatting Nix expressions according to a standard style.
      formatter.x86_64-linux = nixpkgs.legacyPackages.x86_64-linux.nixpkgs-fmt;
    };
}
