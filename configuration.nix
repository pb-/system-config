# Edit this configuration file to define what should be installed on
# your system. Help is available in the configuration.nix(5) man page, on
# https://search.nixos.org/options and in the NixOS manual (`nixos-help`).

{ config, pkgs, ... }:

let
  compiledLayout = pkgs.runCommand "keyboard-layout" {} ''
    ${pkgs.xkbcomp}/bin/xkbcomp -w 0 ${files/keyboard-layout} $out
  '';
in {
  imports =
    [ # Include the results of the hardware scan.
      ./hardware-configuration.nix
    ];

  # Use the systemd-boot EFI boot loader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  boot.initrd.luks.devices."luks-680c0d57-43e9-48c5-b4b9-2f5ea8953d3f".device = "/dev/disk/by-uuid/680c0d57-43e9-48c5-b4b9-2f5ea8953d3f";
  networking.hostName = "osmium"; # Define your hostname.
  # networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.

  # Configure network proxy if necessary
  # networking.proxy.default = "http://user:password@proxy:port/";
  # networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";

  # Enable networking
  networking.networkmanager.enable = true;

  # Set your time zone.
  time.timeZone = "Europe/Berlin";

  # Select internationalisation properties.
  i18n.defaultLocale = "en_US.UTF-8";

  i18n.extraLocaleSettings = {
    LC_ADDRESS = "en_US.UTF-8";
    LC_IDENTIFICATION = "en_US.UTF-8";
    LC_MEASUREMENT = "en_US.UTF-8";
    LC_MONETARY = "en_US.UTF-8";
    LC_NAME = "en_US.UTF-8";
    LC_NUMERIC = "en_US.UTF-8";
    LC_PAPER = "en_US.UTF-8";
    LC_TELEPHONE = "en_US.UTF-8";
    LC_TIME = "en_US.UTF-8";
  };

  # Configure keymap in X11
  services.xserver.xkb = {
    layout = "us";
    variant = "";
  };

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users."pb" = {
    isNormalUser = true;
    description = "Paul";
    extraGroups = [ "networkmanager" "wheel" "audio" "video" "docker" ];
    packages = with pkgs; [ ];
  };

  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;

 environment.systemPackages = with pkgs; [
   (neovim.override { vimAlias = true; withPython3 = true; })
   # (texlive.combine { inherit (texlive) scheme-small standalone microtype pgf xkeyval xcolor koma-script babel-german; })
   alacritty
   babashka
   bat
   brightnessctl
   caffeine-ng
   clojure
   cmus
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
   gron
   httpie
   imagemagick
   jdk
   jq
   jujutsu
   killall
   lshw
   mixxx
   mplayer
   newsboat
   openssl
   pass
   pavucontrol
   pinentry-curses
   pipenv
   powertop
   pulseaudio
   pwgen
   python3
   qrcp
   restic
   rlwrap
   scrot
   spotify
   typespeed
   unzip
   wget
   whois
   xclip
   xkbcomp
 ];

  system.stateVersion = "26.05"; # Did you read the comment?

  virtualisation.docker.enable = true;

  # Avoid using the default 172.17/.18: clashes with Wifi on ICE
  virtualisation.docker.daemon.settings.bip = "172.69.0.1/16";
  virtualisation.docker.daemon.settings.default-address-pools = [{
    base = "172.69.0.0/16";
    size = 20;
  }];

  services.tlp.enable = true;
  services.thinkfan.enable = true;

  powerManagement.cpuFreqGovernor = "ondemand";

  programs.nm-applet.enable = true;

  programs.command-not-found.enable = true;

  services.redshift.enable = true;
  services.redshift.temperature.day = 5000;
  services.redshift.temperature.night = 3000;
  location.latitude = 52.5;
  location.longitude = 13.4;

  networking.firewall.allowedTCPPorts = [ 4711 ];

  environment.variables = {
    EDITOR = "vim";
  };

  environment.shellAliases = {
    glc = "git log --graph --oneline --decorate";
    gcaan = "git commit -a --amend --no-edit --reset-author";
    gg = "git grep";
    ggi = "git grep -i";
    gfg = "git ls-files | grep -i";
    cat = "bat -p";
    note = "vim ~/n/$(date -uIns | tr -dC [:digit:] | cut -c -23)";
    t = "pushd $(mkdir -v /tmp/$(date -Is | tr -cd [:digit:]) | cut -d \\' -f 2)";
    feh = "feh -A 'magick %F -auto-orient -strip -resize 1024 -quality 85 -unsharp 1.0x1.0+0.6+0.10 /tmp/export-%N'";
    clj-repl = "clj -Sdeps '{:deps {nrepl/nrepl {:mvn/version \"1.0.0\"} cider/cider-nrepl {:mvn/version \"0.42.1\"}}}' -M -m nrepl.cmdline --middleware '[\"cider.nrepl/cider-middleware\"]' --interactive";
  };

  fonts.packages = with pkgs; [
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

  # hardware.pulseaudio.enable = true;
  # hardware.pulseaudio.package = pkgs.pulseaudioFull;
  services.pipewire.pulse.enable = true;

  # Enable the X11 windowing system.
  services.xserver.enable = true;
  services.xserver.windowManager.i3.enable = true;
  services.xserver.autoRepeatDelay = 330;
  services.xserver.autoRepeatInterval = 25;

  programs.xss-lock.enable = true;
  programs.xss-lock.lockerCommand = "${pkgs.i3lock}/bin/i3lock -n -c 202020";
  programs.i3lock.enable = true;

  services.displayManager.defaultSession = "none+i3";
  services.displayManager.autoLogin.enable = true;
  services.displayManager.autoLogin.user = "pb";

  services.xserver.displayManager.lightdm.enable = true;
  services.xserver.displayManager.sessionCommands = ''
    ${pkgs.xkbcomp}/bin/xkbcomp ${compiledLayout} $DISPLAY
    xinput disable $(xinput list | grep -i touchpad | cut -f 2 | cut -c 4-)
  '';

  # Enable touchpad support.
  services.libinput.enable = true;
}
