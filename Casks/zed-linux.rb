cask "zed-linux" do
  version "1.16.2"
  sha256 "c761acb9e52977924c6a36a10224cfb72985e6bef5c1e9e2c6f24e9748b106a7"

  url "https://github.com/zed-industries/zed/releases/download/v#{version}/zed-linux-x86_64.tar.gz"
  name "Zed"
  desc "High-performance, multiplayer code editor"
  homepage "https://zed.dev/"

  livecheck do
    url :url
    strategy :github_latest
  end

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
    run "/usr/bin/xdg-icon-resource", args: ["forceupdate"]
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
