{ lib, config, pkgs, ... }:
with lib;
let
  cfg = config.services.x-audio;

  # Rocksmith cable: wanted for Steam and guitarix, never as a default device.
  # Matched by node name so it behaves the same on every host it is plugged into.
  rocksmith = {
    match = { "node.name" = "~alsa_(input|output)\\.usb-Hercules_Rocksmith.*"; };
    priority = 1;
  };

  nodeRule = r: {
    matches = [ r.match ];
    actions."update-props"."priority.session" = r.priority;
  };

  profileRule = name: profile: {
    matches = [ { "device.name" = name; } ];
    actions."update-props"."device.profile" = profile;
  };

  # audio-ctl pick|name|status|mute|live|muted sink|source
  # One short list of usable devices, ● on the default. Raw, monitor and
  # placeholder nodes are hidden so the list is what you would actually choose.
  audioCtl = pkgs.writeShellApplication {
    name = "audio-ctl";
    runtimeInputs = with pkgs; [ pulseaudio wireplumber jq fuzzel gawk coreutils ];
    text = ''
      cmd="''${1:-}"
      case "''${2:-}" in
        sink)   def=sink;   pk=sinks;   wp=@DEFAULT_AUDIO_SINK@;   word=output ;;
        source) def=source; pk=sources; wp=@DEFAULT_AUDIO_SOURCE@; word=mic ;;
        *) echo "usage: audio-ctl pick|name|status|mute sink|source" >&2; exit 2 ;;
      esac

      # name <tab> label, best priority first, one row per label.
      list() {
        pactl -f json list "$pk" | jq -r '
          def short:
            if (.name | test("convolver")) then "speakers"
            elif (.name | test("j416-mic")) then "built-in mic"
            elif (.name | test("Rocksmith")) then "rocksmith"
            elif (.name | test("^bluez")) then (.properties["device.alias"] // .description)
            else ((.properties["node.nick"] // .description) | ascii_downcase) end;
          [ .[]
            | select(.name | test("\\.monitor$|aloop") | not)
            | select(.description | test("Raw Speaker"; "i") | not)
            | select(((.properties["node.nick"] // "") | test("^HDMI [0-9]+$")) | not)
            | { name, label: short,
                prio: ((.properties["priority.session"] // "0") | tonumber) } ]
          | sort_by(-.prio)
          | reduce .[] as $d ([]; if any(.[]; .label == $d.label) then . else . + [$d] end)
          | .[] | [.name, .label] | @tsv'
      }

      current_label() {
        cur=$(pactl get-default-"$def")
        label=$(list | awk -F'\t' -v n="$cur" '$1 == n { print $2; exit }')
        echo "''${label:-other}"
      }

      is_muted() {
        vol=$(wpctl get-volume "$wp")
        case "$vol" in *MUTED*) return 0 ;; *) return 1 ;; esac
      }

      case "$cmd" in
        name) current_label ;;
        status)
          if [ "$def" = source ]; then
            if is_muted; then echo "🚫"; else echo "🎤"; fi
          elif is_muted; then echo "🔇"; else echo "🔊"; fi
          ;;
        mute) wpctl set-mute "$wp" toggle ;;
        # Exit codes for ironbar show_if: 0 = true.
        live) if is_muted; then exit 1; else exit 0; fi ;;
        muted) if is_muted; then exit 0; else exit 1; fi ;;
        pick)
          cur=$(pactl get-default-"$def")
          rows=$(list)
          [ -n "$rows" ] || exit 0
          menu=$(printf '%s\n' "$rows" | while IFS=$'\t' read -r name label; do
            if [ "$name" = "$cur" ]; then printf '● %s\n' "$label"; else printf '  %s\n' "$label"; fi
          done)
          count=$(printf '%s\n' "$menu" | wc -l)
          # Dark colours on purpose: fuzzel's default is a bright cream.
          choice=$(printf '%s\n' "$menu" | fuzzel --dmenu --prompt "$word " \
            --lines "$count" --width 30 --border-width 1 --border-radius 8 \
            --font "SauceCodePro Nerd Font Mono:size=14" \
            --background-color 2b303bff --text-color d8dee9ff \
            --prompt-color 9aa5b4ff --input-color d8dee9ff \
            --match-color 6fb58aff --selection-color 1d4a31ff \
            --selection-text-color d8dee9ff --selection-match-color 6fb58aff \
            --border-color 3b4252ff) || exit 0
          want=$(printf '%s' "$choice" | cut -c3-)
          target=$(printf '%s\n' "$rows" | awk -F'\t' -v l="$want" '$2 == l { print $1; exit }')
          [ -z "$target" ] || pactl set-default-"$def" "$target"
          ;;
        *) echo "usage: audio-ctl pick|name|status|mute sink|source" >&2; exit 2 ;;
      esac
    '';
  };
in {
  options.services.x-audio = {
    enable = mkEnableOption "predictable audio defaults";

    deviceProfiles = mkOption {
      type = types.attrsOf types.str;
      default = { };
      example = { "alsa_card.pci-0000_01_00.1" = "pro-audio"; };
      description = ''
        Card profile to force, keyed by WirePlumber device.name (a leading ~
        makes it a regex). Declared here so it does not depend on whatever
        was last clicked in pavucontrol and saved to ~/.local/state.
      '';
    };

    nodePriorities = mkOption {
      type = types.listOf (types.submodule {
        options = {
          match = mkOption {
            type = types.attrsOf types.str;
            description = "WirePlumber match properties (all must match).";
          };
          priority = mkOption {
            type = types.int;
            description = "priority.session; the highest available node becomes the default.";
          };
        };
      });
      default = [ ];
      description = "Per-host default device ranking. Rocksmith is always ranked last.";
    };
  };

  config = mkIf cfg.enable {
    environment.systemPackages = [ audioCtl ];

    services.pipewire.wireplumber.extraConfig = {
      # Why each setting is here:
      #  - restore-default-targets: a saved default beats priority.session
      #    (state-default-nodes.lua), so one stale click would pin a dead port.
      #  - stream.restore-*: pavucontrol moves one app and the choice, and its
      #    volume, followed that app around. Every app follows the default.
      #  - autoswitch: a Bluetooth headset flipping to headset mode swaps mic
      #    and output mid-call.
      "10-x-audio-settings" = {
        "wireplumber.settings" = {
          "node.restore-default-targets" = false;
          "node.stream.restore-target" = false;
          "node.stream.restore-props" = false;
          "bluetooth.autoswitch-to-headset-profile" = false;
        };
      };

      "10-x-audio-rules" = {
        "monitor.alsa.rules" =
          (mapAttrsToList profileRule cfg.deviceProfiles)
          ++ map nodeRule (cfg.nodePriorities ++ [ rocksmith ]);
      };
    };
  };
}
