{ pkgs ? import <nixpkgs> { }, ... }:
let
  inherit (pkgs) lib;

  myDeployCommand = pkgs.writeScript "deploy-to-foo" ''
    #!${pkgs.runtimeShell}
    set -eux
    echo "Deploying to foo..."
    ${pkgs.hello}/bin/hello
    exit 1
  '';

  # executeWithLog name program
  #
  # Execute a command with the output of that command being saved in
  # the systemd journal.
  #
  # * name: The name of the job being executed. Used in the name of the
  #   generated script, so only alphanumeric, underscores, dots,
  #   dashes.
  #
  #   The name is prefixed with "hydra-".
  #
  # * program: The path to an executable to run. No arguments are
  #   accepted.
  #
  # The exit code of your program is preserved on exit.
  executeWithLog = name: program:
    let
      id = lib.escapeShellArg "hydra-${name}";
    in
    pkgs.writeScript "run-with-log-${name}" ''
      #!${pkgs.runtimeShell}

      set -e
      echo "Executing " ${lib.escapeShellArg program} ", logs will appear in the systemd journal. View those logs with:" >&2
      echo "journalctl --identifier ${id}" >&2

      echo "Starting ${lib.escapeShellArg program}..." | ${pkgs.systemd}/bin/systemd-cat --identifier ${id}
      ${pkgs.systemd}/bin/systemd-cat --identifier ${id} ${lib.escapeShellArg program}
    '';
in
{
  runCommandHooks.example-with-log = executeWithLog "hello" myDeployCommand;
}
