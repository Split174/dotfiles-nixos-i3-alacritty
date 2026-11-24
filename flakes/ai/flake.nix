{
  description = "Pinned packages for Pi and its nono sandbox";

  inputs.llm-agents.url = "github:numtide/llm-agents.nix";

  outputs = { llm-agents, ... }:
    let
      systems = [ "x86_64-linux" "aarch64-linux" ];
      forAllSystems = f: builtins.listToAttrs (map (system: {
        name = system;
        value = f system;
      }) systems);
    in {
      packages = forAllSystems (system:
        let
          pkgs = llm-agents.inputs.nixpkgs.legacyPackages.${system};
        in {
          pi = llm-agents.packages.${system}.pi;
          inherit (pkgs) nono;
        });
    };
}
