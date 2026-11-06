{ lib, pkgs, ... }: with lib; {
  options.isogram = {
    kubernetesPackageSet = mkOption {
      type = types.attrsOf types.package;
      default = throw "isogram.kubernetesPackageSet must be set explicitly (e.x. pkgs.isogram.kubernetes.v1_37).";
      defaultText = literalMD "none, must be set explicitly";
      example = literalExpression "pkgs.isogram.kubernetes.v1_37";
      description = ''
        A set of packages compatible with the desired Kubernetes version (e.x. pkgs.isogram.kubernetes.v1_37).
        There is intentionally no default, since Kubernetes minor versions must be upgraded one at a time.
      '';
    };
  };
}
