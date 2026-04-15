{
  description = "A pass extension for managing one-time-password (OTP) tokens";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
  };

  outputs = { self, nixpkgs }: {
    # passthrough for convenience
    inherit (nixpkgs) lib;

    # just the overlay, allowing use of the same version of nixpkgs verbatim
    legacyPackages = builtins.mapAttrs (system: pkgs: pkgs.extend self.overlays.pass-otp) nixpkgs.legacyPackages;

    # the packages from legacyPackages, add spice if needed
    packages = nixpkgs.lib.flip builtins.mapAttrs self.legacyPackages (system: pkgs: {
      inherit (pkgs) pass-otp;

      pass-with-otp = pkgs.pass.withExtensions (e: [ pkgs.pass-otp ]);
    });

    # check the packages
    checks = self.packages;

    # overlay as-is
    overlays = {
      pass-otp = import ./overlay.nix;
    };
  };
}
