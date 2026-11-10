cask "rider-linux" do
  arch arm: "-aarch64"
  os linux: "linux"

  version "2026.3,263.7307.258"
  sha256 arm64_linux:  "a0a22555d53ef1da8afbb5156781fde8a73b00977df9a20df98e86da4e50bb1d",
         x86_64_linux: "1efc74ffd0ae1edf1437b35629ecf0862eb9746430c4313e6eef408575165c21"

  url "https://download.jetbrains.com/rider/JetBrains.Rider-#{version.csv.first}#{arch}.tar.gz"
  name "Rider"
  desc ".NET IDE"
  homepage "https://www.jetbrains.com/rider/"

  livecheck do
    url "https://data.services.jetbrains.com/products/releases?code=RD&latest=true&type=release"
    strategy :json do |json|
      json["RD"]&.map do |release|
        version = release["version"]
        build = release["build"]
        next if version.blank? || build.blank?

        "#{version},#{build}"
      end
    end
  end

  auto_updates false
  conflicts_with cask: "jetbrains-toolbox-linux"
  depends_on linux: :any

  binary "#{HOMEBREW_PREFIX}/Caskroom/rider-linux/#{version}/JetBrains Rider-#{version.csv.first}/bin/rider"
  artifact "jetbrains-rider.desktop",
           target: "#{Dir.home}/.local/share/applications/jetbrains-rider.desktop"
  artifact "JetBrains Rider-#{version.csv.first}/bin/rider.svg",
           target: "#{Dir.home}/.local/share/icons/hicolor/scalable/apps/rider.svg"

  preflight_steps do
    run "/bin/sh",
        args:  ["-c", "for f in */bin/*64.vmoptions; do printf -- '%s\\n' \"$1\" >> \"$f\"; done", "sh",
                "-Dide.no.platform.update=true"],
        chdir: "."
    mkdir_p ".local/share/applications", base: :home
    mkdir_p ".local/share/icons/hicolor/scalable/apps", base: :home
    write_file "jetbrains-rider.desktop", <<~EOS
      [Desktop Entry]
      Version=1.0
      Name=Rider
      Comment=All-in-one IDE for .NET and game development
      Exec={{HOMEBREW_PREFIX}}/bin/rider %u
      Icon=rider
      Type=Application
      Categories=Development;IDE;
      Keywords=jetbrains;ide;c#;f#;dotnet;.net;
      Terminal=false
      StartupWMClass=jetbrains-rider
      StartupNotify=true
    EOS
  end

  postflight_steps do
    touch ".local/share/icons/hicolor/.xdg-icon-resource-dummy", base: :home
    remove ".local/share/icons/hicolor/.xdg-icon-resource-dummy", base: :home
  end

  zap trash: [
    "#{Dir.home}/.cache/JetBrains/Rider#{version.major_minor}",
    "#{Dir.home}/.config/JetBrains/Rider#{version.major_minor}",
    "#{Dir.home}/.local/share/JetBrains/Rider#{version.major_minor}",
  ]
end
