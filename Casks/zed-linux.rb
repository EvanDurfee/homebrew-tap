cask "zed-linux" do
  arch arm: "aarch64", intel: "x86_64"
  os linux: "linux"

  version "1.27.0"
  sha256 arm64_linux:  "9e4f8b182f41d4cd434cbbc6d1562329a33ef048d65a39bae0665465d0a638bb",
         x86_64_linux: "719f6bf649ea8d87961adbf728e178561bac3f598d72d7949558d1150cfc43dd"

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
