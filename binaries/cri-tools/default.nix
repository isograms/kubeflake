{ lib
, stdenv
, buildGoModule
, fetchFromGitHub
, installShellFiles
, versionData
,
}:
buildGoModule rec {
  pname = "cri-tools";
  version = versionData.cri-tools.version;

  src = fetchFromGitHub {
    owner = "kubernetes-sigs";
    repo = "cri-tools";
    rev = "v${version}";
    sha256 = versionData.cri-tools.sha256;
  };

  vendorHash = null;

  doCheck = false;

  nativeBuildInputs = [ installShellFiles ];

  buildPhase = ''
    runHook preBuild
    make binaries VERSION=${version}
    runHook postBuild
  '';

  installPhase = ''
    runHook preInstall
    make install BINDIR=$out/bin
  '' + lib.optionalString (stdenv.buildPlatform.canExecute stdenv.hostPlatform) ''
    for shell in bash fish zsh; do
      installShellCompletion --cmd crictl \
        --$shell <($out/bin/crictl completion $shell)
    done
  '' + ''
    runHook postInstall
  '';

  meta = with lib; {
    description = "CLI and validation tools for Kubelet Container Runtime Interface (CRI)";
    homepage = "https://github.com/kubernetes-sigs/cri-tools";
    license = licenses.asl20;
    maintainers = [ ];
    platforms = platforms.linux;
  };
}
