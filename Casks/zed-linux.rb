cask "zed-linux" do
  arch arm: "aarch64", intel: "x86_64"
  os linux: "linux"

  version "1.28.1"
  sha256 arm64_linux:  "fc75d18f98fe07c62c079e8745fd723cd4654860b5db170772855bc1b8d05b48",
         x86_64_linux: "9c3fc4cbe533e72c8d0e864a62be2b88d69cc44b9f52cd25d4c21d054dda3742"

  url "https://github.com/zed-industries/zed/releases/download/v#{version}/zed-#{os}-#{arch}.tar.gz"
  name "Zed"
  desc "High-performance, multiplayer code editor"
  homepage "https://zed.dev/"

  livecheck do
    url :url
    strategy :github_latest
  end

  depends_on linux: :any

  binary "zed.app/bin/zed"

  preflight_steps do
    mkdir_p ".local/share/applications", base: :home
    mkdir_p ".local/share/icons", base: :home
  end

  postflight_steps do
    copy "zed.app/share/applications/dev.zed.Zed.desktop",
         ".local/share/applications/dev.zed.Zed.desktop",
         target_base: :home
    inreplace ".local/share/applications/dev.zed.Zed.desktop",
              /^TryExec=.*/, "TryExec={{HOMEBREW_PREFIX}}/bin/zed",
              base: :home
    inreplace ".local/share/applications/dev.zed.Zed.desktop",
              /^Exec=zed/, "Exec={{HOMEBREW_PREFIX}}/bin/zed",
              base: :home
    inreplace ".local/share/applications/dev.zed.Zed.desktop",
              /^Icon=.*/, "Icon=zed",
              base: :home
    copy "zed.app/share/icons/hicolor/512x512/apps/zed.png",
         ".local/share/icons/hicolor/512x512/apps/zed.png",
         target_base: :home
    touch ".local/share/icons/hicolor/.xdg-icon-resource-dummy", base: :home
    remove ".local/share/icons/hicolor/.xdg-icon-resource-dummy", base: :home
  end

  uninstall_postflight_steps do
    remove ".local/share/applications/dev.zed.Zed.desktop", base: :home
    remove ".local/share/icons/hicolor/512x512/apps/zed.png", base: :home
  end

  zap trash: [
    "#{ENV.fetch("XDG_CACHE_HOME", "#{Dir.home}/.cache")}/zed",
    "#{ENV.fetch("XDG_CONFIG_HOME", "#{Dir.home}/.config")}/zed",
    "#{ENV.fetch("XDG_DATA_HOME", "#{Dir.home}/.local/share")}/zed",
  ]
end
