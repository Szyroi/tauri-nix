{
  lib,
  pkgs,
  config,
  ...
}: let
  gstreamer = with pkgs; [
    gst_all_1.gstreamer
    gst_all_1.gst-plugins-base
    gst_all_1.gst-plugins-good
    gst_all_1.gst-plugins-bad
    gst_all_1.gst-plugins-ugly
    gst_all_1.gst-libav
  ];

  tauriDeps = with pkgs;
    [
      pkg-config
      gtk3
      webkitgtk_4_1
      glib
      cairo
      pango
      harfbuzz
      openssl
      libsoup_3
      librsvg
      libappindicator-gtk3
      at-spi2-atk
    ]
    ++ gstreamer;
in {
  options.tauri.system = {
    enable = lib.mkEnableOption "System-wide Tauri dependencies";
    default = true;
  };

  config = lib.mkIf config.tauri.system.enable {
    environment.systemPackages = tauriDeps;
  };
}
