{
  pkgs,
  lib,
  config,
  inputs,
  ...
}: {
  # https://devenv.sh/basics/
  env.GREET = "devenv";

  env.ANTHROPIC_BASE_URL = "https://api.moonshot.ai/anthropic";
  env.ANTHROPIC_AUTH_TOKEN = "sk-el9tYLoqFmDrauY293aUpMUvgncoYjCtofRjKsdgrrI9NrP2";
  env.ANTHROPIC_MODEL = "kimi-k2-thinking-turbo";
  env.ANTHROPIC_DEFAULT_OPUS_MODEL = "kimi-k2-thinking-turbo";
  env.ANTHROPIC_DEFAULT_SONNET_MODEL = "kimi-k2-thinking-turbo";
  env.ANTHROPIC_DEFAULT_HAIKU_MODEL = "kimi-k2-thinking-turbo";
  env.CLAUDE_CODE_SUBAGENT_MODEL = "kimi-k2-thinking-turbo ";

  # https://devenv.sh/packages/
  packages = with pkgs; [
    git
    nodePackages.typescript-language-server
    nodePackages.prettier
  ];

  # https://devenv.sh/languages/
  # languages.rust.enable = true;
  languages.javascript = {
    enable = true;
    bun.enable = true;
  };

  # https://devenv.sh/processes/
  # processes.cargo-watch.exec = "cargo-watch";

  # https://devenv.sh/services/
  # services.postgres.enable = true;

  # https://devenv.sh/scripts/
  scripts.hello.exec = ''
    echo hello from $GREET
  '';

  enterShell = ''
    hello
    git --version
  '';

  # https://devenv.sh/tasks/
  # tasks = {
  #   "myproj:setup".exec = "mytool build";
  #   "devenv:enterShell".after = [ "myproj:setup" ];
  # };

  # https://devenv.sh/tests/
  enterTest = ''
    echo "Running tests"
    git --version | grep --color=auto "${pkgs.git.version}"
  '';

  # https://devenv.sh/git-hooks/
  # git-hooks.hooks.shellcheck.enable = true;

  # See full reference at https://devenv.sh/reference/options/
}
