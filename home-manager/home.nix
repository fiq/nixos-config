{ config, pkgs, inputs, ... }:

{
  # Home Manager needs a bit of information about you and the paths it should
  # manage.
  nixpkgs.config.allowUnfree = true;
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
    # # It is sometimes useful to fine-tune packages, for example, by applying
    # # overrides. You can do that directly here, just don't forget the
    # # parentheses. Maybe you want to install Nerd Fonts with a limited number of
    # # fonts?
    (pkgs.nerdfonts.override { fonts = [ "SourceCodePro" ]; })

    # # You can also create simple shell scripts directly inside your
    # # configuration. For example, this adds a command 'my-hello' to your
    # # environment:
    # (pkgs.writeShellScriptBin "my-hello" ''
    #   echo "Hello, ${config.home.username}!"
    # '')
    pkgs.keepassxc
    pkgs.tree
    pkgs.vim
    pkgs.emacs
    pkgs.mc
    #pkgs.firefox-bin
    pkgs.cmake
    pkgs.protobuf
    pkgs.python310Full
    #pkgs.python310Packages.ipython
    pkgs.python310Packages.pip
    pkgs.wget 
    pkgs.ffmpeg
    pkgs.silver-searcher
    pkgs.mecab
    pkgs.python310Packages.pyqt5
    pkgs.python39Packages.numpy
    pkgs.libsndfile
    pkgs.dotnet-sdk_7
    pkgs.jdk17
    pkgs.rustup
    pkgs.watch
    pkgs.neovim
    pkgs.mpg123
    pkgs.figlet
    pkgs.fzf
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
  };


  # Enable helix
  programs.helix.enable = true;

  # Let Home Manager install and manage itself.
  programs.home-manager.enable = true;

  # zsh
  programs.zsh = {
    enable = true;
    defaultKeymap = "emacs";
    oh-my-zsh = true;
    enableSyntaxHighlighting = true;
    enableCompletion = true;
    enableAutosuggestions = true;
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
    initExtra = ''
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion
export PYENV_ROOT="$HOME/.pyenv"
command -v pyenv >/dev/null || export PATH="$PYENV_ROOT/bin:$PATH"
eval "$(pyenv init -)"
# prompt
source ''${ZDOTDIR:-~}/.p10k.zsh

if [ -n "$SSH_CLIENT" ] || [ -n "$SSH_TTY" ]; then      # if this is an SSH session
    if which tmux >/dev/null 2>&1; then                 # check if tmux is installed
            if [[ -z "$TMUX" ]] ;then                   # do not allow "tmux in tmux"
                    ID="$( tmux ls | grep -vm1 attached | cut -d: -f1 )"    # get the id of a deattached session
                    if [[ -z "$ID" ]] ;then                                 # if not available create a new one
                            tmux new-session
                    else
                            tmux attach-session -t "$ID"                    # if available, attach to it
                    fi
            fi
    fi
fi
    '';
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
