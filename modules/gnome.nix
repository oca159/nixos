{ pkgs, ... }:

{
  services = {
    # Enable Gnome
    xserver.enable = true;
    displayManager.gdm.enable = true;
    desktopManager.gnome.enable = true;
  };

  environment.systemPackages = with pkgs; [
    gnomeExtensions.hide-top-bar
  ];

  environment.gnome.excludePackages = with pkgs; [
    gnome-tour
    gnome-terminal
    gedit # text editor
    epiphany # web browser
    geary # email reader
    tali # poker game
    iagno # go game
    hitori # sudoku game
    atomix # puzzle game
  ];
}
