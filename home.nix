{ config, pkgs, ... }:
let
    dotfiles = "${config.home.homeDirectory}/dotfiles/config";
    create_symlink = path: config.lib.file.mkOutOfStoreSymlink path;
    # Standard .config/directory
    configs = {
        nvim = "nvim";
        mise = "mise";
        wezterm = "wezterm";
    };
in
{
  home.username = "osvaldo";
  home.homeDirectory = "/home/osvaldo";
  home.stateVersion = "25.11";
  programs.home-manager.enable = true;

  home.sessionPath = [
    "$HOME/.local/bin"
    "$HOME/.dotnet/tools"
    "$HOME/.cargo/bin"
    "$HOME/.lmstudio/bin"
  ];

  catppuccin.enable = true;

  home.sessionVariables = {
    EDITOR = "nvim";
    DOTNET_ROLL_FORWARD = "Major";
  };

  programs.bat.enable = true;

  programs.eza = {
    enable = true;
    enableZshIntegration = true;
    git = true;
    icons = "auto";
  };

  programs.fzf = {
    enable = true;
    enableZshIntegration = true;
    tmux.enableShellIntegration = true;
  };

  programs.zoxide = {
    enable = true;
    enableZshIntegration = true;
  };

  programs.git = {
    enable = true;
    settings.user.name = "Osvaldo Cordova Aburto";
    settings.user.email = "ocordova@pulsarml.com";
    settings.init.defaultBranch = "main";
    settings.pull = { rebase = true; };
    settings.push = { autoSetupRemote = true; };
    settings.commit = { gpgsign = true; };
  };

  programs.zsh = {
    enable = true;
    enableCompletion = true;
    autosuggestion.enable = true;
    syntaxHighlighting.enable = true;
    oh-my-zsh = {
      enable = true;
      theme = "robbyrussell";
      plugins = [ "git" "fzf" ];
    };
    shellAliases = {
      cat = "bat";
      cd = "z";
      ff = "fzf --preview 'bat --style=numbers --color=always {}'";
      ls = "eza -lh --group-directories-first --icons=auto";
      lt = "eza --tree --level=2 --long --icons --git";
      lta = "lt -a";

      "atik-dev" = "autossh -M 0 -o 'ServerAliveInterval 30' -o 'ServerAliveCountMax 3' -L 5432:atik-metrics-dev.ckjtmazbtg4w.us-west-2.rds.amazonaws.com:5432 -N bastion";
      "atik-prod" = "autossh -M 0 -o 'ServerAliveInterval 30' -o 'ServerAliveCountMax 3' -L 5432:atik-metrics-prod.ckjtmazbtg4w.us-west-2.rds.amazonaws.com:5432 -N bastion";
      "pulsar-dev" = "autossh -M 0 -o 'ServerAliveInterval 30' -o 'ServerAliveCountMax 3' -L 3300:pulsarrdsdbdev.ckjtmazbtg4w.us-west-2.rds.amazonaws.com:3306 -N bastion";
      "pulsar-prod" = "autossh -M 0 -o 'ServerAliveInterval 30' -o 'ServerAliveCountMax 3' -L 3300:pulsarrdsdbprod.ckjtmazbtg4w.us-west-2.rds.amazonaws.com:3306 -N bastion";
      "pulsar-stage" = "autossh -M 0 -o 'ServerAliveInterval 30' -o 'ServerAliveCountMax 3' -L 3300:pulsarrdsdbstage.ckjtmazbtg4w.us-west-2.rds.amazonaws.com:3306 -N bastion";
      "pulsargpt-dev" = "autossh -M 0 -o 'ServerAliveInterval 30' -o 'ServerAliveCountMax 3' -L 3300:pulsargpt-dev.ckjtmazbtg4w.us-west-2.rds.amazonaws.com:3306 -N bastion";
      "pulsargpt-prod" = "autossh -M 0 -o 'ServerAliveInterval 30' -o 'ServerAliveCountMax 3' -L 3300:pulsargpt-prod.ckjtmazbtg4w.us-west-2.rds.amazonaws.com:3306 -N bastion";
      chronos = "autossh -M 0 -o 'ServerAliveInterval 30' -o 'ServerAliveCountMax 3' -L 54322:chronos-demo-orchestrator-prod-orchestrator-db.ckjtmazbtg4w.us-west-2.rds.amazonaws.com:5432 -N bastion";
    };

    initContent = ''
      if command -v fdfind >/dev/null 2>&1; then
        alias fd='fdfind'
      fi

      git-release() {
        echo "# From \`$1\` to \`$2\`"

        while read -r -u 9 author name
        do
          echo "## $name - $author"

          GIT_PAGER=cat git log "$1..$2" \
            --author="$author" \
            --no-merges --reverse \
            --date=iso-strict --pretty="%as %h %s" \
            | sed -E 's/ \(/ `/g' \
            | sed -E 's/\): /` /g'

          echo
        done 9< <(git log "$1..$2" --no-merges --format=$'%ae %an' --date=short-local | sort --unique)
      }

      eval "$(mise activate zsh)"

      if [ -d "$HOME/.zfunc" ]; then
        fpath+=("$HOME/.zfunc")
      fi
      if [ -d "$HOME/.zsh/completions" ]; then
        fpath=("$HOME/.zsh/completions" $fpath)
      fi

      # Keep secrets out of this repo and source them from an untracked file.
      if [ -f "$HOME/.config/secrets/shell.env" ]; then
        source "$HOME/.config/secrets/shell.env"
      fi
      export GPG_TTY=$(tty)
    '';
  };

  xdg.configFile = builtins.mapAttrs (name: subpath: {
      source = create_symlink "${dotfiles}/${subpath}";
      recursive = true;
  }) configs;
}
