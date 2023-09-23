# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running `nixos-help`).

{ config, pkgs, lib, inputs, unstable, ... }:

{
  nix.settings.experimental-features = [ "nix-command" "flakes" ];

  # Gnome-Keyring is interfering with hyprland process launcher
  # See https://github.com/hyprwm/Hyprland/issues/1376
  services.gnome.gnome-keyring.enable = lib.mkForce false;

  # Use the systemd-boot EFI boot loader.
  nixpkgs.config.allowUnfree = true;
  nixpkgs.config.cudaSupport  = false;
  boot.loader.systemd-boot.enable = true;
  boot.loader.systemd-boot.memtest86.enable = true;
  boot.loader.systemd-boot.consoleMode = "2";
  boot.loader.efi.canTouchEfiVariables = true;
  boot.loader.efi.efiSysMountPoint = "/boot/efi";
  hardware.enableRedistributableFirmware = true;
  boot.supportedFilesystems = [ "ntfs" ];

  # Mulvad
  services.mullvad-vpn.enable = true;


  # Pick only one of the below networking options.
  #networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.
  networking.networkmanager.enable = true;  # Easiest to use and most distros use this by default.
  services.pipewire.enable = true;
  # Set your time zone.
  time.timeZone = "Pacific/Auckland";

  # Open SSH
  services.openssh.enable = true;
  services.openssh.settings.PasswordAuthentication = true;

  # Configure network proxy if necessary
  # networking.proxy.default = "http://user:password@proxy:port/";
  # networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";

  # Select internationalisation properties.
  # i18n.defaultLocale = "en_US.UTF-8";
  # console = {
  #   font = "Lat2-Terminus16";
  #   keyMap = "us";
  #   useXkbConfig = true; # use xkbOptions in tty.
  # };

  # Enable the X11 windowing system.
  services.xserver.enable = true;

  # Enable the GNOME Desktop Environment.
  services.xserver.displayManager.gdm.enable = true;
  services.xserver.desktopManager.gnome.enable = true;
  
  hardware.opengl = {
    enable = true;
    driSupport = true;
    driSupport32Bit = true;
  };

  # SANE - Scanner
  hardware.sane = {
    enable = true;
    brscan4.enable = true;
    brscan4.netDevices.home = {
      model = "MFC-7350N";
      ip = "192.168.5.250";
    };
  };

  # Docker
  virtualisation.docker.rootless = {
    enable = true;
    setSocketVariable = true;
  };

  virtualisation.docker.enable = true;
  virtualisation.docker.enableNvidia = true;
  virtualisation.containers.enable = true;
  users.extraGroups.docker.members = [ "raf" ];
  
  # OpenRGB
  services.hardware.openrgb.enable = true;
  services.hardware.openrgb.motherboard = "amd";

  # Tiling managers
  programs.sway.enable = true;
  programs.hyprland.enable = true;

  programs.waybar.enable = true;
  programs.waybar.package = unstable.waybar;

  security.polkit.enable = true;

  # Locate DB 
  services.locate = {
    enable = true;
    locate = pkgs.mlocate;
    interval = "hourly";
  };

 

  # zsh
  programs.zsh.enable = true;

  # Configure keymap in X11
  # services.xserver.layout = "us";
  # services.xserver.xkbOptions = "eurosign:e,caps:escape";

  # Enable CUPS to print documents.
  # services.printing.enable = true;

  # Enable sound.
  # sound.enable = true;
  # hardware.pulseaudio.enable = true;

  # Enable touchpad support (enabled default in most desktopManager).
  # services.xserver.libinput.enable = true;

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.raf = {
    isNormalUser = true;
    shell = pkgs.zsh;
    extraGroups = [ "docker" "mlocate" "plugdev" "wheel" "scanner" "lp" ]; # Enable ‘sudo’ print and scan
    initialHashedPassword = "resetme";
    packages = with pkgs; [
      
    ];
  };

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
    home-manager
    firefox
    inetutils
    openssh 
    git
    vim # Do not forget to add an editor to edit configuration.nix! The Nano editor is also installed by default.
    wget
    helix
    kitty
    fuzzel
    inputs.prismlauncher.packages.${system}.prismlauncher-qt5
    minikube
    podman
    #docker
    cudaPackages.cudatoolkit
    python310Full
    python310Packages.virtualenv
    portaudio
    audacity
    keepassxc
    tree
    lynx 
    tmux
    wofi
    google-chrome
    silver-searcher
    grim
    slurp
    swaybg
    gcc
    docker-compose
    pciutils
    lshw
    curl
    nix-index
    elixir_1_15
    gdb
    wireshark
    distrobox
  ];

  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  # programs.mtr.enable = true;
  # programs.gnupg.agent = {
  #   enable = true;
  #   enableSSHSupport = true;
  # };

  # List services that you want to enable:

  # Enable the OpenSSH daemon.
  # services.openssh.enable = true;

  # Open ports in the firewall.
  #networking.firewall.allowedTCPPorts = [ 22 ];
  #networking.firewall.allowedUDPPorts = [ ... ];
  # Or disable the firewall altogether.
  # networking.firewall.enable = false;

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It's perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "23.05"; # Did you read the comment?

  programs.steam.package = unstable.steam;
}

