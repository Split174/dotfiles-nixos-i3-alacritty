{ pkgs, ... }:

let
  # The rest of the system still uses its existing nixpkgs channel.
  ai = (builtins.getFlake (toString ../../flakes/ai)).packages.${pkgs.stdenv.hostPlatform.system};
in {
  environment.systemPackages = [ ai.pi ai.nono ];

  programs.zsh.shellAliases.pi-nono = "nono run --profile pi --allow-cwd -- pi";

  nix.settings = {
    experimental-features = [ "nix-command" "flakes" ];
    extra-substituters = [ "https://cache.numtide.com" ];
    extra-trusted-public-keys = [ "niks3.numtide.com-1:DTx8wZduET09hRmMtKdQDxNNthLQETkc/yaX7M4qK0g=" ];
  };
}
