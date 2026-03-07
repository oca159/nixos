{ pkgs, ... }:

{
  # Fonts
  fonts.packages = [
    pkgs.nerd-fonts.jetbrains-mono
    pkgs.nerd-fonts.zed-mono
    pkgs.nerd-fonts.blex-mono
  ];
}
