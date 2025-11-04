cask "jetbrains-rider" do
  arch intel: "",
       arm:   "-aarch64"
  os linux: "linux"

  version "2025.2.3,252.26830.109"
  sha256 x86_64_linux: "1cfc4e756007c5a8b749c0848e4c050303aeeaabc0917f19732d908201b69446",
         arm64_linux:  "bd03e42b3a04cc1e1b234333285873746bd4d04bf3746fb62b171334a168e976"

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
  conflicts_with cask: "jetbrains-toolbox"

  binary "Rider-#{version.csv.first}/bin/rider"
  artifact "rider.desktop",
           target: "#{Dir.home}/.local/share/applications/rider.desktop"
  artifact "Rider-#{version.csv.first}/bin/rider.svg",
           target: "#{Dir.home}/.local/share/icons/rider.svg"
  artifact "Rider-#{version.csv.first}/bin/rider.png",
           target: "#{Dir.home}/.local/share/icons/rider.png"

  preflight do
    FileUtils.mkdir_p("#{Dir.home}/.local/share/applications")
    FileUtils.mkdir_p("#{Dir.home}/.local/share/icons")
    File.write("#{staged_path}/rider.desktop", <<~EOS)
      [Desktop Entry]
      Version=1.0
      Name=Rider
      Comment=JetBrains .NET IDE
      Exec=#{HOMEBREW_PREFIX}/bin/rider -Dawt.toolkit.name=WLToolkit %u
      Icon=rider
      Type=Application
      Categories=Development;IDE;
      Keywords=jetbrains;ide;c#;f#;dotnet;.net;
      Terminal=false
      StartupWMClass=jetbrains-rider
      StartupNotify=true
    EOS
  end

  zap trash: [
    "#{Dir.home}/.cache/JetBrains/Rider#{version.major_minor}",
    "#{Dir.home}/.config/JetBrains/Rider#{version.major_minor}",
    "#{Dir.home}/.local/share/JetBrains/Rider#{version.major_minor}",
  ]
end
