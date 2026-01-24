{ config, pkgs, lib, inputs, ... }:

{

  # Home Manager needs a bit of information about you and the paths it should
  # manage.
  nixpkgs.config.allowUnfree = true;
  nixpkgs.config.allowUnfreePredicate = pkg: builtins.elem (lib.getName pkg) [
    "vscode"
  ];

  nixpkgs.overlays = [
    inputs.nix-vscode-extensions.overlays.default
  ];
  

  programs.java.enable = true;
  programs.java.package = pkgs.jdk21;
  # This value determines the Home Manager release that your configuration is
  # compatible with. This helps avoid breakage when a new Home Manager release
  # introduces backwards incompatible changes.
  #
  # You should not change this value, even if you update Home Manager. If you do
  # want to update the value, then make sure to first check the Home Manager
  # release notes.
  home.stateVersion = "22.11"; # Please read the comment before changing.

  # The home.packages option allows you to install Nix packages into your
  # environment.
  home.packages = [
    #(pkgs.nerdfonts.override { fonts = [ "SourceCodePro" ]; })
    pkgs.nerd-fonts._0xproto
    pkgs.nerd-fonts.fira-code

    # # You can also create simple shell scripts directly inside your
    # # configuration. For example, this adds a command 'my-hello' to your
    # # environment:
    # (pkgs.writeShellScriptBin "my-hello" ''
    #   echo "Hello, ${config.home.username}!"
    # '')
    pkgs.claude-code
    pkgs.cmake
    pkgs.emacs
    pkgs.gpt-cli
    pkgs.ffmpeg
    pkgs.figlet
    pkgs.fzf
    pkgs.jetbrains.idea-community
    pkgs.gimp3
    pkgs.jq
    pkgs.keepassxc
    pkgs.libsndfile
    pkgs.mc
    pkgs.mecab
    pkgs.mpg123
    pkgs.neovim
    pkgs.protobuf
    pkgs.rustup
    pkgs.silver-searcher
    pkgs.slack
    pkgs.tree
    pkgs.vim-full
    pkgs.vimPlugins.vim-colorschemes
    pkgs.warp-terminal
    pkgs.watch
    pkgs.wget 
  ];

  # Home Manager is pretty good at managing dotfiles. The primary way to manage
  # plain files is through 'home.file'.
  home.file = {
    # # Building this configuration will create a copy of 'dotfiles/screenrc' in
    # # the Nix store. Activating the configuration will then make '~/.screenrc' a
    # # symlink to the Nix store copy.
    # ".screenrc".source = dotfiles/screenrc;
    ".p10k.zsh".source = dotfiles/p10k.zsh;
    ".tmux.conf".source = dotfiles/tmux.conf;

    # # You can also set the file content immediately.
    # ".gradle/gradle.properties".text = ''
    #   org.gradle.console=verbose
    #   org.gradle.daemon.idletimeout=3600000
    # '';
  };

  # You can also manage environment variables but you will have to manually
  # source
  #
  #  ~/.nix-profile/etc/profile.d/hm-session-vars.sh
  #
  # or
  #
  #  /etc/profiles/per-user/innovation/etc/profile.d/hm-session-vars.sh
  #
  # if you don't want to manage your shell through Home Manager.
  home.sessionVariables = {
    EDITOR = "vim";
    ZSH_TMUX_AUTOSTART = "true";
    ZSH_TMUX_AUTOCONNECT = "true";
    ZSH_TMUX_FIXTERM = "true";
  };
  # Enable helix
  programs.helix.enable = true;

  # setup fzf
  programs.fzf = {
    enable = true;
    enableZshIntegration = true;
  };


  # Let Home Manager install and manage itself.
  programs.home-manager.enable = true;

  # Aliaes
  home.shellAliases = {
    pyenv-init = "nix develop github:fiq/nix-pyenv-flake --impure";
    ns="nix search --experimental-features 'nix-command flakes' nixpkgs";
  };

  # zsh
  programs.zsh = {
    enable = true;
    defaultKeymap = "emacs";
    plugins = [
      {
        name = "powerlevel10k-config";
        src = ./dotfiles;
        file = "p10k.zsh";
      }
    ];
    oh-my-zsh = {
      enable = true;
      plugins = ["git" "tmux" "themes" "bundler" "dotenv" "rake" "rbenv" "ruby"]; 
      };
    syntaxHighlighting.enable = true;
    enableCompletion = true;
    autosuggestion.enable = true;
    historySubstringSearch.enable = true;
    zplug = {
      enable = true;
      plugins = [
        {
          name = "romkatv/powerlevel10k";
          tags = [ "as:theme" "depth:1" ];
        }
      ];
    };
    initContent = ''
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion

# prompt
#source ''${ZDOTDIR:-~}/.p10k.zsh
[ -s "$HOME/.zshrc-mutable" ] && \. "$HOME/.zshrc-mutable" # local overrides
   '';
  };


  # vscode
  programs.vscode = {
    enable = true;
    profiles.default.extensions = (with pkgs.vscode-extensions; [
      dracula-theme.theme-dracula
      vscodevim.vim
      yzhang.markdown-all-in-one
      vscjava.vscode-java-pack
      genieai.chatgpt-vscode
    ]) ++ (with pkgs.vscode-marketplace; [
      anthropic.claude-code
      openai.chatgpt
    ]);
  };

  # wezterm
  programs.wezterm = {
    enable = true;
    extraConfig = ''

return {
  font = wezterm.font("SauceCodePro Nerd Font Mono"),
  font_size = 15,
  color_scheme = "Catppuccin Macchiato",
  window_background_opacity = 0.95,
  window_padding = {
    top = 0,
    bottom = 0,
    left = 0,
    right = 0,
  },
}

    '';
  };
}
