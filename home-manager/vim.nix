{ pkgs, ... }:
{
  programs.vim.defaultEditor = true;

    systemPackages = with pkgs; [
      ((vim_configurable.override { python3 = python3; }).customize {
      name = "vim";
      vimrcConfig.packages.myplugins = with pkgs.vimPlugins; {
        start = [ vim-nix ]; # load plugins on startup
      };
      vimrcConfig.customRC = ''
        " custom
        " vimrc
      '';
    })
  ];
}
