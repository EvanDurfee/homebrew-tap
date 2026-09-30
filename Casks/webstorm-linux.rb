cask "webstorm-linux" do
  arch arm: "-aarch64"
  os linux: "linux"

  version "2026.1.3,261.25134.101"
  sha256 arm64_linux:  "a1941ac69555d0ee1694313a21af8acc7205d127d6401b9b045228a5244c6ef1",
         x86_64_linux: "96bc88a15c68cadc83c9f8239e86d0ddef78c0822886620a2fcf1fc1fd88e3dc"

  url "https://download.jetbrains.com/webstorm/WebStorm-#{version.csv.first}#{arch}.tar.gz"
  name "WebStorm"
  desc "JavaScript IDE"
  homepage "https://www.jetbrains.com/webstorm/"

  livecheck do
    url "https://data.services.jetbrains.com/products/releases?code=WS&latest=true&type=release"
    strategy :json do |json|
      json["WS"]&.map do |release|
        version = release["version"]
        build = release["build"]
        next if version.blank? || build.blank?

        "#{version},#{build}"
      end
    end
  end

  auto_updates false
  conflicts_with cask: "jetbrains-toolbox-linux"

  binary "#{HOMEBREW_PREFIX}/Caskroom/webstorm-linux/#{version}/WebStorm-#{version.csv.second}/bin/webstorm"
  artifact "jetbrains-webstorm.desktop",
           target: "#{Dir.home}/.local/share/applications/jetbrains-webstorm.desktop"
  artifact "WebStorm-#{version.csv.second}/bin/webstorm.svg",
           target: "#{Dir.home}/.local/share/icons/hicolor/scalable/apps/webstorm.svg"

  preflight_steps do
    run "/bin/sh",
        args:  ["-c", "for f in */bin/*64.vmoptions; do printf -- '%s\\n' \"$1\" >> \"$f\"; done", "sh",
                "-Dide.no.platform.update=true"],
        chdir: "."
    mkdir_p ".local/share/applications", base: :home
    mkdir_p ".local/share/icons/hicolor/scalable/apps", base: :home
    write_file "jetbrains-webstorm.desktop", <<~EOS
      [Desktop Entry]
      Version=1.0
      Name=WebStorm
      Comment=A JavaScript and TypeScript IDE
      Exec={{HOMEBREW_PREFIX}}/bin/webstorm %u
      Icon=webstorm
      Type=Application
      Categories=Development;IDE;
      Keywords=jetbrains;ide;javascript;typescript;
      Terminal=false
      StartupWMClass=jetbrains-webstorm
      StartupNotify=true
    EOS
  end

  postflight_steps do
    run "/usr/bin/xdg-icon-resource", args: ["forceupdate"]
  end

  zap trash: [
    "#{Dir.home}/.cache/JetBrains/WebStorm#{version.major_minor}",
    "#{Dir.home}/.config/JetBrains/WebStorm#{version.major_minor}",
    "#{Dir.home}/.local/share/JetBrains/WebStorm#{version.major_minor}",
  ]
end
