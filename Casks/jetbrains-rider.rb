cask "jetbrains-rider" do
  arch intel: "",
       arm:   "-aarch64"
  os linux: "linux"

  version "2025.3,253.28294.88"
  sha256 x86_64_linux: "bf7be76634ec70dc33008505a08dcc024d4d7ec2bf0e4ace8a71f219d2f40706",
         arm64_linux:  "bce1eed1a6fac3cc0850fc2b38ef557e1c51872c4b619a86ce36d002f6cbcbcb"

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
