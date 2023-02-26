{ inputs, lib, config, pkgs, ... }: {

  services.xserver.enable = true;
  services.xserver.displayManager.sddm.enable = true;
  services.xserver.displayManager.sddm.autoNumlock = true;
  services.xserver.desktopManager.plasma5.enable = true;
  services.xserver.layout = "pl";

  services.xserver.videoDrivers = lib.mkDefault [ "nvidia" ];
  services.xserver.displayManager.setupCommands = ''
    CENTER='DP-0'
    RIGHT='HDMI-0'
    ${pkgs.xorg.xrandr}/bin/xrandr --output $CENTER --primary --output $RIGHT --rotate right --right-of $CENTER
  '';

}