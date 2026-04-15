{
  lib,
  stdenv,
  bash,
  expect,
  git,
  gnumake,
  gnupg,
  pass,
  shellcheck,
  which,
  withOath ? true, oath-toolkit,
  withOtptool ? false, otptool ? throw "otptool is not currently packaged in nixpkgs",
  withAge ? true, age,
}:

assert withOath || withOtptool;

stdenv.mkDerivation {
  pname = "pass-otp";
  version = "1.2.0-unstable";
  src = ./.;

  buildInputs = [ oath-toolkit ];

  checkInputs = [
    bash
    expect
    git
    gnumake
    gnupg
    pass
    shellcheck
    which
  ];

  dontBuild = true;
  # FIXME: checks are currently broken
  doCheck = true;

  patchPhase = ''
    substituteInPlace otp.bash ${lib.escapeShellArgs ([]
      ++ lib.optionals withOath [
        "--replace-fail" "OATH=$(command -v oathtool)" "OATH=${lib.getExe oath-toolkit}"
      ]
      ++ lib.optionals withOtptool [
        "--replace-fail" "OTPTOOL=$(command -v otptool)" "OTPTOOL=${lib.getExe otptool}"
      ]
      ++ lib.optionals withAge [
        "--replace-fail" "AGE=$(command -v age)" "AGE=${lib.getExe age}"
      ]
    )}
  '';

  checkPhase = ''
    make check
  '';

  installFlags = [
    "PREFIX=$(out)"
    "BASHCOMPDIR=$(out)/share/bash-completions/completions"
  ];

  meta = {
    description = "A pass extension for managing one-time-password (OTP) tokens";
    homepage = "https://github.com/tadfisher/pass-otp";
    license = lib.licenses.gpl3Plus;
    maintainers = with lib.maintainers; [ benaryorg ];
    platforms = lib.platforms.unix;
  };
}
