# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, ... }:

let
  compiledLayout = pkgs.runCommand "keyboard-layout" {} ''
    ${pkgs.xorg.xkbcomp}/bin/xkbcomp -w 0 ${files/keyboard-layout} $out
  '';
in {
  environment.systemPackages = with pkgs; [
    (neovim.override { vimAlias = true; })
    (texlive.combine { inherit (texlive) scheme-basic standalone microtype pgf xkeyval xcolor koma-script babel-german; })
    android-studio
    bat
    brightnessctl
    caffeine-ng
    clojure
    ettercap
    feh
    ffmpeg
    file
    firefox
    gcc
    git
    gnumake
    gnupg
    gnuplot
    go
    httpie
    imagemagick
    lshw
    minetest
    mplayer
    openssl
    pass
    pavucontrol
    pinentry-curses
    pipenv
    powertop
    pwgen
    python3
    rlwrap
    scrot
    spotify
    termite
    typespeed
    unzip
    wget
    whois
    xorg.xkbcomp
  ];

  virtualisation.docker.enable = true;

  imports =
    [ # Include the results of the hardware scan.
      ./hardware-configuration.nix
    ];

  # Use the GRUB 2 boot loader.
  boot.loader.grub.enable = true;
  boot.loader.grub.version = 2;
  boot.loader.systemd-boot.enable = true;
  boot.loader.grub.efiSupport = true;
  boot.loader.efi.canTouchEfiVariables = true;
  #
  # Define on which hard drive you want to install Grub.
  boot.loader.grub.device = "nodev"; # or "nodev" for efi only

  services.tlp.enable = true;

  networking.hostName = "caesium"; # Define your hostname.
  networking.networkmanager.enable = true;
  programs.nm-applet.enable = true;

  # The global useDHCP flag is deprecated, therefore explicitly set to false here.
  # Per-interface useDHCP will be mandatory in the future, so this generated config
  # replicates the default behaviour.
  networking.useDHCP = false;
  networking.interfaces.enp0s25.useDHCP = true;
  networking.interfaces.wlp3s0.useDHCP = true;

  # Select internationalisation properties.
  i18n.defaultLocale = "en_US.UTF-8";

  # Set your time zone.
  time.timeZone = "Europe/Berlin";

  # Redshift.
  services.redshift.enable = true;
  services.redshift.temperature.day = 5000;
  services.redshift.temperature.night = 3000;
  location.latitude = 52.5;
  location.longitude = 13.4;

  networking.firewall.allowedTCPPorts = [ 4711 ];

  nixpkgs.config.allowUnfree = true;

  environment.variables = {
    EDITOR = "vim";
  };

  environment.shellAliases = {
    glc = "git log --graph --oneline --decorate";
    gcaan = "git commit -a --amend --no-edit";
    gg = "git grep";
    ggi = "git grep -i";
    gfg = "git ls-files | grep -i";
    cat = "bat -p";
  };

  fonts.fonts = with pkgs; [
    corefonts
    iosevka
  ];

  # Enable the OpenSSH daemon.
  services.openssh.enable = true;
  programs.ssh.startAgent = true;

  # gpg
  programs.gnupg.agent.enable = true;

  # Enable CUPS to print documents.
  # services.printing.enable = true;

  hardware.bluetooth.enable = true;
  services.blueman.enable = true;

  # Enable sound.
  sound.enable = true;
  hardware.pulseaudio.enable = true;
  hardware.pulseaudio.package = pkgs.pulseaudioFull;

  # Enable the X11 windowing system.
  services.xserver.enable = true;
  services.xserver.windowManager.i3.enable = true;
  services.xserver.autoRepeatDelay = 330;
  services.xserver.autoRepeatInterval = 25;

  programs.xss-lock.enable = true;
  programs.xss-lock.lockerCommand = "${pkgs.i3lock}/bin/i3lock -n -c 202020";

  programs.adb.enable = true;

  # Auto login.
  services.xserver.displayManager.defaultSession = "none+i3";
  services.xserver.displayManager.lightdm.enable = true;
  services.xserver.displayManager.autoLogin.enable = true;
  services.xserver.displayManager.autoLogin.user = "pb";
  services.xserver.displayManager.sessionCommands = "${pkgs.xorg.xkbcomp}/bin/xkbcomp ${compiledLayout} $DISPLAY";

  # Enable touchpad support.
  services.xserver.libinput.enable = true;

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.pb = {
    isNormalUser = true;
    extraGroups = [ "wheel" "networkmanager" "audio" "video" "docker"];
  };

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "20.03"; # Did you read the comment?

}
