cask "zed-linux" do
  version "1.5.5"
  sha256 "884c096c91ed0ef2d3d606357a20231abc7e3c3ae347b4374895373a34d3d264"

  url "https://github.com/zed-industries/zed/releases/download/v#{version}/zed-linux-x86_64.tar.gz"
  name "Zed"
  desc "High-performance, multiplayer code editor"
  homepage "https://zed.dev/"

  livecheck do
    url :url
    strategy :github_latest
  end

  binary "zed.app/bin/zed"

  preflight do
    xdg_data = ENV.fetch("XDG_DATA_HOME", "#{Dir.home}/.local/share")
    FileUtils.mkdir_p "#{xdg_data}/applications"
    FileUtils.mkdir_p "#{xdg_data}/icons"
  end

  postflight do
    xdg_data = ENV.fetch("XDG_DATA_HOME", "#{Dir.home}/.local/share")
    desktop_content = File.read("#{staged_path}/zed.app/share/applications/dev.zed.Zed.desktop")
    desktop_content.gsub!(/^TryExec=.*/, "TryExec=#{HOMEBREW_PREFIX}/bin/zed")
    desktop_content.gsub!(/^Exec=zed/, "Exec=#{HOMEBREW_PREFIX}/bin/zed")
    desktop_content.gsub!(/^Icon=.*/, "Icon=zed")
    File.write("#{xdg_data}/applications/dev.zed.Zed.desktop", desktop_content)
    FileUtils.cp("#{staged_path}/zed.app/share/icons/hicolor/512x512/apps/zed.png",
                 "#{xdg_data}/icons/hicolor/512x512/apps/zed.png")
    system "/usr/bin/xdg-icon-resource", "forceupdate"
  end

  uninstall_postflight do
    xdg_data = ENV.fetch("XDG_DATA_HOME", "#{Dir.home}/.local/share")
    FileUtils.rm("#{xdg_data}/applications/dev.zed.Zed.desktop")
    FileUtils.rm("#{xdg_data}/icons/hicolor/512x512/apps/zed.png")
  end

  zap trash: [
    "#{ENV.fetch("XDG_CACHE_HOME", "#{Dir.home}/.cache")}/zed",
    "#{ENV.fetch("XDG_CONFIG_HOME", "#{Dir.home}/.config")}/zed",
    "#{ENV.fetch("XDG_DATA_HOME", "#{Dir.home}/.local/share")}/zed",
  ]
end
