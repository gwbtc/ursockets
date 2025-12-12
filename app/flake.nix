{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
    tools = {
      flake = false;
      url = "github:urbit/tools/d454e2482c3d4820d37db6d5625a6d40db975864";
    };
  };

  outputs = { self, nixpkgs, flake-utils, tools }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = import nixpkgs { inherit system; };

        # !! Add path to local urbit binary
        urbitBin = ./urbit;
        # !! Add current nostril pill to repo
        pill = ./nostrill.pill;

        # Patch tools to make scripts executable
        usableTools = pkgs.runCommand "patched-tools" { } ''
          cp -r ${tools} $out
          chmod +w -R $out
          patchShebangs $out
        '';

        click = "${usableTools}/pkg/click/click";

        # Boot a fake ship with nostrill pill
        bootFakeShip = { shipName ? "bus" }:
          pkgs.runCommand "fake-pier-${shipName}" { } ''
            ${urbitBin} --pier $out -F ${shipName} -B ${pill} -l -x -t
          '';


        # Fake ships for testing
        bus = bootFakeShip { shipName = "bus"; };
        fun = bootFakeShip { shipName = "fun"; };

      in {
        # Development shell with tools
        devShells.default = pkgs.mkShell {
          buildInputs = [
            pkgs.netcat
            pkgs.jq
          ];

          shellHook = ''
            echo ""
            echo "nostrill agent testing environment"
            echo "Click tool available at: ${click}"
            echo ""
            echo "Before running tests add valid path to urbit binary and pill with %nostril desk to flake.nix"
            echo ""
            echo "Available commands:"
            echo "  nix build .#fakePier  - Build fake pier"
            echo "  nix build .#bus  - Build fake ~bus"
            echo "  nix flake check -L --impure  - Build fake ships and run tests"
          '';
        };

        packages = {
          inherit bus fun;
          default = bootFakeShip { shipName = "bus"; };
        };

        # Tests
        checks = {
          test-nostrill = import ./nix/test-nostrill.nix {
            inherit click pkgs;
            pierBus = bus;
            pierFun = fun;
            urbitBin = "${urbitBin}";
          };
        };
      });
}