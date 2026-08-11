{ pkgs }:
pkgs.writeShellApplication {
  name = "hello";
  text = ''
    echo "hello"
  '';
}
