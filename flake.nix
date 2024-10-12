{
  description = "CTF Environment";
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };
  outputs = { nixpkgs, flake-utils, ... }: flake-utils.lib.eachDefaultSystem (system:
    let
      pkgs = import nixpkgs {
        inherit system;
        config.allowUnfree = true;
      };
      coolWordlists = pkgs.wordlists.override {
        lists = with pkgs; [
          rockyou
        ];
      };
      python3WithCoolPackages = pkgs.python3.withPackages (ps: with ps; [
        flask
        pycrypto
        cryptography
        requests
        sqlmap
        z3
        beautifulsoup4
        pwntools
      ]);
    in
    {
      devShells = {
        default = pkgs.mkShell {
          buildInputs = (with pkgs; [
            toybox
            binutils
            gnumake
            man-pages
            nmap
            file
            exiftool
            # chepy

            # Executables
            gdb
            checksec
            patchelf
            capstone

            # Data recovery
            scalpel
            testdisk
            ddrescue

            wireshark
            tshark
            hcxtools
            hexdump
            xxd
            hexedit

            # Password cracking
            john
            hashcat
            hashcat-utils

            # Web
            dirb
            burpsuite

            # Steganography
            stegseek
            steghide
            # stegsolve
            pngcheck

            # EWCF
            libewf

            jq
            yq

            # Reverse engineering
            ghidra

            gobuster
            one_gadget
            ropgadget

            # Virtualization
            docker
            # podman
          ]) ++ [
            coolWordlists
            python3WithCoolPackages
          ];
        };
      };
    });
}
