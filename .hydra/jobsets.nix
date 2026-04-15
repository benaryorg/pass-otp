{
  nixpkgs,
  prs,
  refs,
  ...
}:

{
  jobsets = (import nixpkgs {}).callPackage ({ runCommandLocal, jq }:

    runCommandLocal "project-hydra-spec.json" { inherit prs refs; nativeBuildInputs = [ jq ]; } ''
      jq 'with_entries(select(.value.draft == false) | .key = "pull-\(.key)" | .value |= @uri "https://github.com/\(.head.user.login)/\(.head.repo.name) \(.head.ref)")' $prs > prs.json
      jq 'with_entries(.value = "https://github.com/benaryorg/pass-otp \(.key)")' $refs > refs.json

      jq -s 'add | with_entries(.value = { enabled: 1, hidden: false, description: .key, checkinterval: 128, schedulingshares: 64, enableemail: false, emailoverride: "", keepnr: 3, type: 0, nixexprinput: "src", nixexprpath: ".hydra/build.nix", inputs: { src: { type: "git", value }, nixpkgs: { type: "git", value: "https://git.shell.bsocat.net/nixpkgs nixos-unstable" } } })' prs.json refs.json > $out 
    '')

    {};
}
