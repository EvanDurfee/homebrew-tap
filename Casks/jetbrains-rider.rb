cask "jetbrains-rider" do
  arch intel: "",
       arm:   "-aarch64"
  os linux: "linux"

  version "2025.2.4,252.27397.121"
  sha256 x86_64_linux: "cd428f7d6db5055cd2594c3d1ef91241843d263cb6301369d3121a847ffb6589",
         arm64_linux:  "75c38a2bd94e31200fc4e3a6cfad83b35c65d36c9d61b9a7b208e3ec82f8c81a"

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
  conflicts_with cask: ["jetbrains-toolbox", "jetbrains-rider-eap"]

  # shim script (https://github.com/Homebrew/homebrew-cask/issues/18809)
  shimscript = "#{staged_path}/rider.wrapper.sh"
  binary shimscript, target: "rider"
  artifact "rider.desktop",
           target: "#{Dir.home}/.local/share/applications/rider.desktop"
  artifact "JetBrains Rider-#{version.csv.first}/bin/rider.svg",
           target: "#{Dir.home}/.local/share/icons/rider.svg"
  artifact "JetBrains Rider-#{version.csv.first}/bin/rider.png",
           target: "#{Dir.home}/.local/share/icons/rider.png"

  preflight do
    File.write("#{staged_path}/JetBrains Rider-#{version.csv.first}/bin/rider64.vmoptions", "-Dide.no.platform.update=true\n", mode: "a+")
    File.write shimscript, <<~EOS
      #!/bin/sh
      exec '#{HOMEBREW_PREFIX}/Caskroom/jetbrains-rider/#{version}/JetBrains Rider-#{version.csv.first}/bin/rider' "$@"
    EOS
    FileUtils.mkdir_p("#{Dir.home}/.local/share/applications")
    FileUtils.mkdir_p("#{Dir.home}/.local/share/icons")
    File.write("#{staged_path}/rider.desktop", <<~EOS)
      [Desktop Entry]
      Version=1.0
      Name=Rider
      Comment=JetBrains .NET IDE
      Exec=#{HOMEBREW_PREFIX}/bin/rider %u
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
