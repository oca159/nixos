{ pkgs, ... }:

{
  programs.zsh.enable = true;

  environment.systemPackages = with pkgs; [
    wezterm
    cool-retro-term

    starship
    neovim
    moreutils
    file
    upx
    delta
    fzf
    zoxide
    ripgrep
    yt-dlp
    fd
    jq
    bat
    yazi
    chafa
    cmatrix
    cava
    figlet
  ];
}
