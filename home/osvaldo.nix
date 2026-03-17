{ config, pkgs, ... }:
let
  dotfiles = "${config.home.homeDirectory}/dotfiles/config";
  create_symlink = path: config.lib.file.mkOutOfStoreSymlink path;
  # Standard .config/directory
  configs = {
    ghostty = "ghostty";
    mise = "mise";
    nvim = "nvim";
    sesh = "sesh";
    wezterm = "wezterm";
  };
in
{
  home = {
    username = "osvaldo";
    homeDirectory = "/home/osvaldo";
    stateVersion = "25.11";

    sessionPath = [
      "$HOME/.local/bin"
      "$HOME/.dotnet/tools"
      "$HOME/.cargo/bin"
      "$HOME/.lmstudio/bin"
    ];

    sessionVariables = {
      EDITOR = "nvim";
      DOTNET_ROLL_FORWARD = "Major";
    };
  };
  programs = {
    home-manager.enable = true;

    tmux = {
      enable = true;
      plugins = with pkgs; [
        tmuxPlugins.sensible
        tmuxPlugins.vim-tmux-navigator
        tmuxPlugins.catppuccin
        tmuxPlugins.resurrect
        tmuxPlugins.continuum
        tmuxPlugins.tmux-fzf
      ];
      extraConfig = ''

        set-option -sa terminal-overrides ",xterm*:Tc"

        set -g mouse on

        set -g default-terminal "tmux-256color"

        set -g detach-on-destroy off

        set -g base-index 1
        set -g pane-base-index 1
        set-window-option -g pane-base-index 1
        set-option -g renumber-windows on

        bind-key x kill-pane

        bind -n M-h resize-pane -L
        bind -n M-l resize-pane -R
        bind -n M-k resize-pane -U
        bind -n M-j resize-pane -D

        bind -n M-i swap-window -t -1

        bind -n M-o swap-window -t +1

        set-window-option -g mode-keys vi

        bind-key -T copy-mode-vi v send-keys -X begin-selection
        bind-key -T copy-mode-vi C-v send-keys -X rectangle-toggle
        bind-key -T copy-mode-vi y send-keys -X copy-selection-and-cancel

        set -g @resurrect-save 'S'
        set -g @resurrect-restore 'R'
        set -g @catppuccin_flavour 'mocha'
        set -g status-left ""

        set -g @catppuccin_right_separator "█"
        set -g @catppuccin_left_separator "█"
        set -g @catppuccin_window_tabs_enabled "on"

        bind-key "T" run-shell "sesh connect \"$(
          sesh list --icons | fzf-tmux -p 80%,70% \
            --no-sort --ansi --border-label ' sesh ' --prompt '⚡  ' \
            --header '  ^a all ^t tmux ^g configs ^x zoxide ^d tmux kill ^f find' \
            --bind 'tab:down,btab:up' \
            --bind 'ctrl-a:change-prompt(⚡  )+reload(sesh list --icons)' \
            --bind 'ctrl-t:change-prompt(🪟  )+reload(sesh list -t --icons)' \
            --bind 'ctrl-g:change-prompt(⚙️  )+reload(sesh list -c --icons)' \
            --bind 'ctrl-x:change-prompt(📁  )+reload(sesh list -z --icons)' \
            --bind 'ctrl-f:change-prompt(🔎  )+reload(fd -H -d 2 -t d -E .Trash . ~)' \
            --bind 'ctrl-d:execute(tmux kill-session -t {2..})+change-prompt(⚡  )+reload(sesh list --icons)' \
            --preview-window 'right:55%' \
            --preview 'sesh preview {}'
        )\""
      '';
    };

    bat.enable = true;

    eza = {
      enable = true;
      enableZshIntegration = true;
      git = true;
      icons = "auto";
    };

    fzf = {
      enable = true;
      enableZshIntegration = true;
      tmux.enableShellIntegration = true;
    };

    zoxide = {
      enable = true;
      enableZshIntegration = true;
    };

    git = {
      enable = true;
      settings = {
        user.name = "Osvaldo Cordova Aburto";
        user.email = "ocordova@pulsarml.com";
        init.defaultBranch = "main";
        pull = {
          rebase = true;
        };
        push = {
          autoSetupRemote = true;
        };
        commit = {
          gpgsign = true;
        };
      };
    };

    zsh = {
      enable = true;
      enableCompletion = true;
      autosuggestion.enable = true;
      syntaxHighlighting.enable = true;
      oh-my-zsh = {
        enable = true;
        theme = "robbyrussell";
        plugins = [
          "git"
          "fzf"
        ];
      };
      shellAliases = {
        cat = "bat";
        cd = "z";
        ff = "fzf --preview 'bat --style=numbers --color=always {}'";
        ls = "eza -lh --group-directories-first --icons=auto";
        lt = "eza --tree --level=2 --long --icons --git";
        lta = "lt -a";

        "atik-dev" =
          "autossh -M 0 -o 'ServerAliveInterval 30' -o 'ServerAliveCountMax 3' -L 5432:atik-metrics-dev.ckjtmazbtg4w.us-west-2.rds.amazonaws.com:5432 -N bastion";
        "atik-prod" =
          "autossh -M 0 -o 'ServerAliveInterval 30' -o 'ServerAliveCountMax 3' -L 5432:atik-metrics-prod.ckjtmazbtg4w.us-west-2.rds.amazonaws.com:5432 -N bastion";
        "pulsar-dev" =
          "autossh -M 0 -o 'ServerAliveInterval 30' -o 'ServerAliveCountMax 3' -L 3300:pulsarrdsdbdev.ckjtmazbtg4w.us-west-2.rds.amazonaws.com:3306 -N bastion";
        "pulsar-prod" =
          "autossh -M 0 -o 'ServerAliveInterval 30' -o 'ServerAliveCountMax 3' -L 3300:pulsarrdsdbprod.ckjtmazbtg4w.us-west-2.rds.amazonaws.com:3306 -N bastion";
        "pulsar-stage" =
          "autossh -M 0 -o 'ServerAliveInterval 30' -o 'ServerAliveCountMax 3' -L 3300:pulsarrdsdbstage.ckjtmazbtg4w.us-west-2.rds.amazonaws.com:3306 -N bastion";
        "pulsargpt-dev" =
          "autossh -M 0 -o 'ServerAliveInterval 30' -o 'ServerAliveCountMax 3' -L 3300:pulsargpt-dev.ckjtmazbtg4w.us-west-2.rds.amazonaws.com:3306 -N bastion";
        "pulsargpt-prod" =
          "autossh -M 0 -o 'ServerAliveInterval 30' -o 'ServerAliveCountMax 3' -L 3300:pulsargpt-prod.ckjtmazbtg4w.us-west-2.rds.amazonaws.com:3306 -N bastion";
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
  };

  dconf.settings = {
    "org/gnome/shell/keybindings" = {
      "switch-to-application-1" = [ ];
      "switch-to-application-2" = [ ];
      "switch-to-application-3" = [ ];
      "switch-to-application-4" = [ ];
      "switch-to-application-5" = [ ];
      "switch-to-application-6" = [ ];
      "switch-to-application-7" = [ ];
      "switch-to-application-8" = [ ];
      "switch-to-application-9" = [ ];
      "toggle-message-tray" = [ ];
      "toggle-application-view" = [ "<Super>a" ];
      "toggle-overview" = [ "<Super>space" ];
    };

    "org/gnome/mutter/keybindings" = {
      "switch-monitor" = [ ];
    };

    # Disable Super+H (Hide window) and Super+V (Notifications)
    "org/gnome/desktop/wm/keybindings" = {
      "minimize" = [ ];
      "focus-active-notification" = [ ];
      "switch-input-source" = [ ];
    };

    # Some versions of GNOME use this for Super+P as well
    "org/gnome/settings-daemon/plugins/media-keys" = {
      "video-out" = [ ];
    };

    "org/gnome/mutter" = {
      "overlay-key" = "";
    };

    "org/gnome/shell" = {
      "enabled-extensions" = [ "hidetopbar@mathieu.bidon.ca" ];
    };
  };

  catppuccin.enable = true;
  catppuccin.flavor = "mocha";

  xdg.configFile = builtins.mapAttrs (name: subpath: {
    source = create_symlink "${dotfiles}/${subpath}";
    recursive = true;
  }) configs;
}
