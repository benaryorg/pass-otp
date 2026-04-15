{
  src,
  nixpkgs,
}:

let

  pkgs = import nixpkgs {
    overlays = [ (import "${src}/overlay.nix") ];
  };

in

{
  pass-otp = pkgs.pass-otp;
}
