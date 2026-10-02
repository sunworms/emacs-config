let
  lock = builtins.fromJSON (builtins.readFile ./flake.lock);

  fetch = name: let
    locked = lock.nodes.${name}.locked;
    url =
      if locked.type == "github"
      then "https://github.com/${locked.owner}/${locked.repo}/archive/${locked.rev}.tar.gz"
      else if locked.type == "tarball"
      then locked.url
      else throw "inputs.nix: unsupported input type '${locked.type}' for '${name}'";
  in
    fetchTarball {
      inherit url;
      sha256 = locked.narHash;
    };
in
  builtins.mapAttrs (_: fetch) lock.nodes.root.inputs
