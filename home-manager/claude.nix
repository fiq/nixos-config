{ pkgs }:

let
  claudeVscodeWrapper = pkgs.writeShellScriptBin "claude-vscode-wrapper" ''
    if [ -x "$HOME/.claude-npm/bin/claude" ]; then
      exec "$HOME/.claude-npm/bin/claude" "$@"
    fi

    exec /run/current-system/sw/bin/claude "$@"
  '';
in
{
  packages = [
    pkgs.nodejs_20
    claudeVscodeWrapper
  ];

  ignoreText = ''
    ~/.ssh
    ~/.aws
    ~/.config
    ~/.gnupg
    ~/.kube
    ~/.local/share/keyrings
    ~/.pki
    **/*.env
    **/*.pem
    **/*.key
    **/*secret*
    **/*token*
  '';

  shellAliases = {
    claude-local = ''"$HOME/.nix-profile/bin/claude-vscode-wrapper"'';
    claude-latest = ''"$HOME/.claude-npm/bin/claude"'';
    # Claude Code has full filesystem access. Avoid running it from $HOME root.
    claude-latest-safe = ''cd "$HOME/Code" && "$HOME/.claude-npm/bin/claude"'';
    claude-latest-install = ''NPM_CONFIG_PREFIX="$HOME/.claude-npm" ${pkgs.nodejs_20}/bin/npm install -g @anthropic-ai/claude-code'';
    claude-latest-update = ''current="$("$HOME/.claude-npm/bin/claude" --version 2>/dev/null || echo not-installed)"; latest="$(${pkgs.nodejs_20}/bin/npm show @anthropic-ai/claude-code version)"; printf "Current: %s\nLatest: %s\n" "$current" "$latest"; read -q "REPLY?Install update? [y/N] " && echo && NPM_CONFIG_PREFIX="$HOME/.claude-npm" ${pkgs.nodejs_20}/bin/npm install -g @anthropic-ai/claude-code || { echo; echo "Cancelled."; }'';
  };

  vscodeExtensions = with pkgs.vscode-marketplace; [
    anthropic.claude-code
    openai.chatgpt
  ];
}
