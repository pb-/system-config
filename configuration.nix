# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, ... }:

let
  compiledLayout = pkgs.runCommand "keyboard-layout" {} ''
    ${pkgs.xorg.xkbcomp}/bin/xkbcomp -w 0 ${files/keyboard-layout} $out
  '';
  my-python-packages = python-packages: with python-packages; [
    pip
    pipx
  ];
  python-with-my-packages = pkgs.python3.withPackages my-python-packages;
in {
  imports =
    [ # Include the results of the hardware scan.
      ./hardware-configuration.nix
    ];

  # Use the systemd-boot EFI boot loader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  boot.loader.grub.device = "/dev/nvme0n1";
  boot.initrd.luks.devices.root = {
    device = "/dev/disk/by-uuid/0de8d888-008f-4abd-98fa-7ab2ad56e819";
    preLVM = true;
    allowDiscards = true;
  };

  # temporary workaround for non-working WiFi on 5.10
  boot.kernelPackages = pkgs.linuxPackages_5_12;

  services.tlp.enable = true;

  services.thinkfan.enable = true;

  networking.hostName = "barium"; # Define your hostname.
  networking.networkmanager.enable = true;
  programs.nm-applet.enable = true;

  # networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.

  time.timeZone = "Europe/Berlin";

  # The global useDHCP flag is deprecated, therefore explicitly set to false here.
  # Per-interface useDHCP will be mandatory in the future, so this generated config
  # replicates the default behaviour.
  networking.useDHCP = false;
  networking.interfaces.enp0s31f6.useDHCP = true;

  i18n.defaultLocale = "en_US.UTF-8";
  # console = {
  #   font = "Lat2-Terminus16";
  #   keyMap = "us";
  # };

  # Enable the X11 windowing system.
  services.xserver.enable = true;
  services.xserver.windowManager.i3.enable = true;
  services.xserver.autoRepeatDelay = 330;
  services.xserver.autoRepeatInterval = 25;

  services.xserver.displayManager.defaultSession = "none+i3";
  services.xserver.displayManager.lightdm.enable = true;
  services.xserver.displayManager.autoLogin.enable = true;
  services.xserver.displayManager.autoLogin.user = "pb";
  services.xserver.displayManager.sessionCommands = "${pkgs.xorg.xkbcomp}/bin/xkbcomp ${compiledLayout} $DISPLAY";

  services.xserver.libinput.enable = true;

  fonts.fonts = with pkgs; [
    corefonts
    iosevka
  ];

  programs.xss-lock.enable = true;
  programs.xss-lock.lockerCommand = "${pkgs.i3lock}/bin/i3lock -n -c 202020";

  services.openssh.enable = true;
  programs.ssh.startAgent = true;

  # Configure keymap in X11
  # services.xserver.layout = "us";
  # services.xserver.xkbOptions = "eurosign:e";

  # Enable CUPS to print documents.
  # services.printing.enable = true;

  sound.enable = true;
  hardware.pulseaudio.enable = true;

  # Enable touchpad support (enabled default in most desktopManager).
  # services.xserver.libinput.enable = true;

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.pb = {
    isNormalUser = true;
    extraGroups = [ "wheel" "networkmanager" "audio" "video" "docker" ];
  };

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
    (neovim.override { vimAlias = true; })
    alacritty
    bat
    brightnessctl
    caffeine-ng
    clojure
    docker-compose
    ettercap
    feh
    ffmpeg
    file
    firefox
    git
    gnumake
    gnupg
    gron
    httpie
    imagemagick
    jdk8
    jdk11
    jetbrains.idea-ultimate
    jq
    lshw
    mplayer
    openssl
    pass
    pavucontrol
    pinentry-curses
    pipenv
    postgresql
    powertop
    pwgen
    python-with-my-packages
    rlwrap
    sbt
    scrot
    slack
    spotify
    unzip
    wget
    whois
    xorg.xkbcomp
    zoom-us
  ];

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

  environment.etc = with pkgs; {
    "libstdcpp".source = "${stdenv.cc.cc.lib}/lib";
    "libc".source = "${glibc}/lib";

    "jdk8".source = jdk8;
    "jdk11".source = jdk11;
  };

  virtualisation.docker.enable = true;

  services.redshift.enable = true;
  services.redshift.temperature.day = 5000;
  services.redshift.temperature.night = 3000;
  location.latitude = 52.5;
  location.longitude = 13.4;

  # only want psql client
  services.postgresql.enable = false;

  nixpkgs.config.allowUnfree = true;

  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  # programs.mtr.enable = true;
  # programs.gnupg.agent = {
  #   enable = true;
  #   enableSSHSupport = true;
  # };

  # List services that you want to enable:

  # Open ports in the firewall.
  networking.firewall.allowedTCPPorts = [ 22 4711 ];
  # networking.firewall.allowedUDPPorts = [ ... ];
  # Or disable the firewall altogether.
  # networking.firewall.enable = false;

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "21.05"; # Did you read the comment?

}

