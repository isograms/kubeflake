{
  description = "";

  # Nixpkgs / NixOS version to use.
  inputs.nixpkgs.url = "nixpkgs/nixos-26.05";

  outputs =
    { self
    , nixpkgs
    ,
    }:
    # All non-EOL Kubernetes are supported. For more information on the EOL dates,
    # see <https://kubernetes.io/releases/>.
    let
      versionList = {
        # EOL 2027-10-28
        v1_37 = {
          version = "1.37.2";
          sha256 = "sha256-Bbyu5hMQTSrvr/kDFHlRnfz5RIR7ecBfTFOGTCffn5c=";
          cri-o = {
            version = "1.37.3";
            sha256 = "sha256-/L0ap+ujGp2SAyEIxFqnp3tnRgvKSkl194FYDOAfuXg=";
          };
          cri-tools = {
            version = "1.37.0";
            sha256 = "sha256-8TjS7cZXgiaSD7tEQbZmQIQUBkniIHjgAqyMEVqQrd0=";
          };
        };
        # EOL 2027-06-28
        v1_36 = {
          version = "1.36.6";
          sha256 = "sha256-4/231gwj+g9A1oDQKIdmJ6lrfquVhTLSxe6hzFuaDFA=";
          cri-o = {
            version = "1.36.8";
            sha256 = "sha256-AzzgN1KXWfBahDyvkQgYdZWjpHMR78ESXZrMxb4ypvg=";
          };
          cri-tools = {
            version = "1.36.0";
            sha256 = "sha256-Ae0CL/BZdIBzZr+Tttg6sNhn1eS2E1odR6fGpbFRVjI=";
          };
        };
        # EOL 2027-02-28
        v1_35 = {
          version = "1.35.10";
          sha256 = "sha256-LaqG0zNn43JEt04isr8MTtLdH+M59EZcWpC0o64U2FY=";
          cri-o = {
            version = "1.35.11";
            sha256 = "sha256-gNoOhjFO5DE9yw1C3FvVsKFKqCfNdMc2dmrbTYh77Ok=";
          };
          cri-tools = {
            version = "1.35.0";
            sha256 = "sha256-66UDoObxlNBTYJPpo4GoQlV66hXZRf5eLB3ji0KU/Zs=";
          };
        };
      };
    in
    let
      supportedSystems = [ "x86_64-linux" "aarch64-linux" "aarch64-darwin" ];
      forAllSystems = nixpkgs.lib.genAttrs supportedSystems;
      nixpkgsFor = forAllSystems (system: import nixpkgs { inherit system; });
      forAllVersions = nixpkgs.lib.genAttrs (builtins.attrNames versionList);
    in
    rec {
      packages = forAllSystems (
        system:
        let
          pkgs = nixpkgsFor.${system};
        in
        forAllVersions (
          version:
          let
            versionData = builtins.getAttr version versionList;
          in
          {
            kubernetes = pkgs.callPackage ./binaries/kubernetes { inherit versionData; };
            cri-o = pkgs.callPackage ./binaries/cri-o { inherit versionData; };
            cri-tools = pkgs.callPackage ./binaries/cri-tools { inherit versionData; };
            kubectl-ctx = pkgs.callPackage ./binaries/kubectl-ctx { };
          }
        )
      );

      formatter.x86_64-linux = nixpkgs.legacyPackages.x86_64-linux.nixpkgs-fmt;

      nixosModule = { ... }: {
        imports = [
          ./modules/isogram
          ./modules/kubernetes
          ./modules/cri-o
        ];

        nixpkgs.overlays = [
          (final: prev: {
            isogram.kubernetes = forAllVersions (
              version:
              let
                versionData = builtins.getAttr version versionList;
              in
              {
                kubernetes = final.callPackage ./binaries/kubernetes { inherit versionData; };
                cri-o = final.callPackage ./binaries/cri-o { inherit versionData; };
                cri-tools = final.callPackage ./binaries/cri-tools { inherit versionData; };
                kubectl-ctx = final.callPackage ./binaries/kubectl-ctx { };
              }
            );
          })
        ];
      };
    };
}
