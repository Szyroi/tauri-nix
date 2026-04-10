{
  lib,
  config,
  pkgs,
  ...
}:
with lib; let
  cfg = config.programs.tauri;

  pm = cfg.packageManager;

  jsRuntime =
    if pm == "bun"
    then [pkgs.bun]
    else [pkgs.nodejs];

  jsPackageManagers = with pkgs; {
    pnpm = [nodePackages.pnpm];
    yarn = [nodePackages.yarn];
    npm = [];
    bun = [];
  };

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

  toolchains = {
    rust = with pkgs; [
      rustc
      cargo
      cargo-tauri
    ];

    javascript =
      jsRuntime
      ++ (jsPackageManagers.${pm} or []);

    dotnet = with pkgs; [
      dotnet-sdk
    ];
  };
in {
  options.programs.tauri = {
    enable = mkEnableOption "Tauri dev environment";

    language = mkOption {
      type = types.enum ["rust" "javascript" "dotnet"];
      default = "javascript";
      description = ''
        Primary language for the Tauri project.
      '';

      example = "javascript";
    };

    packageManager = mkOption {
      type = types.enum ["npm" "pnpm" "yarn" "bun" "cargo" "dotnet"];
      default = "bun";
      description = ''
        Package manager used for JavaScript/TypeScript projects.

      '';

      example = "pnpm";
    };

    gdkBackend = mkOption {
      type = types.enum ["x11" "wayland" "auto"];
      default = "x11";
      description = ''
        GTK backend selection for Tauri applications to Fix some Webkit issues.
      '';

      example = "wayland";
    };
  };

  config = mkIf cfg.enable {
    home.packages =
      toolchains.${cfg.language}
      ++ optionals (cfg.language != "dotnet") tauriDeps;

    home.sessionVariables = {
      GDK_BACKEND =
        if cfg.gdkBackend == "auto"
        then
          (
            if pkgs.stdenv.isLinux
            then "wayland"
            else "x11"
          )
        else cfg.gdkBackend;

      XDG_DATA_DIRS =
        "$GSETTINGS_SCHEMAS_PATH"
        + (
          if builtins.getEnv "XDG_DATA_DIRS" != ""
          then ":" + builtins.getEnv "XDG_DATA_DIRS"
          else ""
        );

      WEBKIT_DISABLE_COMPOSITING_MODE = "1";
      GSK_RENDERER = "cairo";

      GST_PLUGIN_SYSTEM_PATH_1_0 =
        "${pkgs.gst_all_1.gstreamer}/lib/gstreamer-1.0:"
        + "${pkgs.gst_all_1.gst-plugins-base}/lib/gstreamer-1.0:"
        + "${pkgs.gst_all_1.gst-plugins-good}/lib/gstreamer-1.0:"
        + "${pkgs.gst_all_1.gst-plugins-bad}/lib/gstreamer-1.0:"
        + "${pkgs.gst_all_1.gst-plugins-ugly}/lib/gstreamer-1.0:"
        + "${pkgs.gst_all_1.gst-libav}/lib/gstreamer-1.0";
    };

    assertions = [
      {
        assertion =
          (cfg.language != "rust" || pm == "cargo")
          && (cfg.language != "dotnet" || pm == "dotnet")
          && (cfg.language != "javascript" || builtins.elem pm ["npm" "pnpm" "yarn" "bun"]);

        message = "Invalid packageManager '${pm}' for language '${cfg.language}'.";
      }
    ];
  };
}
