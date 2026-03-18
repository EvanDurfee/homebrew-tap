cask "webstorm-linux" do
  arch intel: "",
       arm:   "-aarch64"
  os linux: "linux"

  version "2025.3.4,253.32098.39"
  sha256 x86_64_linux: "7bbdadf9f70f56667b99aa01c91f34d05fee993f1359e062e4043608ca7b6dbb",
         arm64_linux:  "6bb31ce76b741df41fb1492d55a4630b2905947bccc2d3fbd2249414259ab56f"

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

  preflight do
    File.write("#{staged_path}/WebStorm-#{version.csv.second}/bin/webstorm64.vmoptions", "-Dide.no.platform.update=true\n", mode: "a+")
    FileUtils.mkdir_p("#{Dir.home}/.local/share/applications")
    FileUtils.mkdir_p("#{Dir.home}/.local/share/icons/hicolor/scalable/apps")
    File.write("#{staged_path}/jetbrains-webstorm.desktop", <<~EOS)
      [Desktop Entry]
      Version=1.0
      Name=WebStorm
      Comment=A JavaScript and TypeScript IDE
      Exec=#{HOMEBREW_PREFIX}/bin/webstorm %u
      Icon=webstorm
      Type=Application
      Categories=Development;IDE;
      Keywords=jetbrains;ide;javascript;typescript;
      Terminal=false
      StartupWMClass=jetbrains-webstorm
      StartupNotify=true
    EOS
  end

  postflight do
    system "/usr/bin/xdg-icon-resource", "forceupdate"
  end

  zap trash: [
    "#{Dir.home}/.cache/JetBrains/WebStorm#{version.major_minor}",
    "#{Dir.home}/.config/JetBrains/WebStorm#{version.major_minor}",
    "#{Dir.home}/.local/share/JetBrains/WebStorm#{version.major_minor}",
  ]
end
